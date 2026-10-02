#!/usr/bin/env python3
"""PeakGear LiveLab extension for the Oracle Data Studio MCP server.

The standard Oracle Data Studio MCP server reads the ADP URL and database
credentials from the local credential store. This launcher adds safe,
read-only PeakGear lab tools before starting that server. It never reads or
returns a password, token, or other secret.
"""

from __future__ import annotations

import json
import time

from mcp.server.fastmcp import Context
from mcp_server.server import main, mcp
from mcp_server.tools._adp_connect import get_adp
from mcp_server.tools._helpers import bound_rows, err


_READINESS_SQL = "SELECT 1 AS LIVE_LAB_READY FROM dual"
_READINESS_TIMEOUT_SECONDS = 15
_TOP_DIGITAL_INTEREST_TIMEOUT_SECONDS = 90
_LIVELAB_QUERY_ADAPTER = "peakgear-json-bound-rows-v1"
_TOP_DIGITAL_INTEREST_SQL = """
WITH month_boundary AS (
    SELECT TRUNC(MAX(event_ts), 'MM') AS current_month
    FROM peakgear_user.lab_digital_intent_raw_v
)
SELECT product_id,
       COUNT(*) AS digital_events
FROM peakgear_user.lab_digital_intent_raw_v
CROSS JOIN month_boundary
WHERE event_ts >= ADD_MONTHS(current_month, -1)
  AND event_ts < current_month
  AND product_id IS NOT NULL
GROUP BY product_id
ORDER BY digital_events DESC, product_id
FETCH FIRST 5 ROWS ONLY
"""
_DIGITAL_CONTRACT_SQL = """
SELECT annotation_name,
       annotation_value
FROM user_annotations_usage
WHERE object_name = 'LAB_DIGITAL_INTENT_RAW_V'
  AND column_name IS NULL
  AND annotation_name IN ('DESCRIPTION', 'TAGS')
ORDER BY annotation_name
"""


# The upstream implementation of adp_run_query declares a string return type,
# but some releases return a Python dict after bounding result rows. FastMCP
# then rejects the result before it reaches Codex. Replace only that registered
# tool with the identical read/write semantics and a JSON-string response. The
# same name means the vendor's normal access-profile policy still applies.
if mcp._tool_manager.get_tool("adp_run_query"):
    mcp.remove_tool("adp_run_query")

# The installed SDK's `get_data_simple()` currently treats AV dimension names
# as hierarchy names. That produces ORA-20300 for the two lab AVs even when
# the AVs are VALID and direct governed SQL works. Keep the vendor tool for
# other AVs, but replace it with a small, allowlisted PeakGear path so the
# lab's Codex checkpoint tests the actual AV drill-down rather than this SDK
# metadata mismatch.
if mcp._tool_manager.get_tool("adp_query_analytic_view"):
    mcp.remove_tool("adp_query_analytic_view")

# The vendor catalog helper checks user-owned database links only.  That is
# correct for private links, but this lab intentionally provisions one PUBLIC
# link under ADMIN and consumes it from PEAKGEAR_USER.  Keep every other
# catalog action unchanged while making the PeakGear checkpoint prove the
# public link through ALL_DB_LINKS plus a real remote round-trip.
_UPSTREAM_ADP_BROWSE_CATALOG = None
_upstream_browse_tool = mcp._tool_manager.get_tool("adp_browse_catalog")
if _upstream_browse_tool:
    _UPSTREAM_ADP_BROWSE_CATALOG = _upstream_browse_tool.fn
    mcp.remove_tool("adp_browse_catalog")

_PEAKGEAR_AI_OBJECTS = frozenset({
    "LAB_PRODUCTS_RAW_V",
    "LAB_DIGITAL_INTENT_RAW_V",
    "LAB_RETURNS_RAW_V",
    "LAB_PRODUCTS_SEMANTIC_T",
    "LAB_DIGITAL_POPULARITY_T",
    "LAB_RETURNS_T",
    "LAB_DIGITAL_POPULARITY_AV",
    "LAB_RETURNS_AV",
})
_UPSTREAM_ADP_AI_CHAT = None
_upstream_ai_chat_tool = mcp._tool_manager.get_tool("adp_ai_chat")
if _upstream_ai_chat_tool:
    _UPSTREAM_ADP_AI_CHAT = _upstream_ai_chat_tool.fn
    mcp.remove_tool("adp_ai_chat")


def _payload_items(payload):
    """Normalize the installed SDK's list/dict query result shapes."""
    if isinstance(payload, str):
        try:
            payload = json.loads(payload)
        except ValueError:
            return []
    if isinstance(payload, list):
        return payload
    if isinstance(payload, dict):
        return payload.get("rows") or payload.get("items") or []
    return []


@mcp.tool()
def adp_browse_catalog(action: str,
                       catalog_name: str = None,
                       search_term: str = None,
                       object_type: str = None,
                       ctx: Context = None) -> str:
    """Browse catalogs, with an accurate PeakGear PUBLIC-link checkpoint.

    The upstream implementation is used unchanged for all actions except
    ``check_db_link`` for ``PEAKGEAR_OPERATIONS_LINK``.  A public link is
    owned by ADMIN, so it is not guaranteed to appear in a user-scoped
    catalog-links endpoint even though PEAKGEAR_USER can query through it.
    """
    if (action or "").lower() == "check_db_link" and \
            (catalog_name or "").upper() == "PEAKGEAR_OPERATIONS_LINK":
        client = get_adp(ctx)
        if client is None:
            return err("ADP is not connected. Set ADP_URL, ADP_USER, ADP_PASSWORD.")
        try:
            link_result = client.Misc.run_query(
                """SELECT owner, db_link, host
                   FROM all_db_links
                   WHERE UPPER(db_link) = 'PEAKGEAR_OPERATIONS_LINK'"""
            )
            link_rows = _payload_items(link_result)
            if not link_rows:
                return json.dumps({
                    "status": False,
                    "message": "The PUBLIC database link PEAKGEAR_OPERATIONS_LINK was not found in ALL_DB_LINKS."
                })
            round_trip_result = client.Misc.run_query(
                "SELECT 1 AS remote_round_trip FROM dual@PEAKGEAR_OPERATIONS_LINK"
            )
            round_trip_rows = _payload_items(round_trip_result)
            return json.dumps({
                "status": bool(round_trip_rows),
                "owner": link_rows[0].get("OWNER") or link_rows[0].get("owner") or "PUBLIC",
                "db_link": "PEAKGEAR_OPERATIONS_LINK",
                "scope": "PUBLIC",
                "remote_round_trip": bool(round_trip_rows),
                "message": "PUBLIC Operations database link is visible and queryable from PEAKGEAR_USER."
            })
        except Exception as exc:
            return err(exc)

    if (action or "").lower() == "entities" and \
            (catalog_name or "").upper() == "LOCAL":
        if _UPSTREAM_ADP_BROWSE_CATALOG is None:
            return err("The upstream adp_browse_catalog implementation is unavailable.")
        try:
            result = _UPSTREAM_ADP_BROWSE_CATALOG(
                action=action,
                catalog_name=catalog_name,
                search_term=search_term,
                object_type=object_type,
                ctx=ctx,
            )
            payload = json.loads(result) if isinstance(result, str) else result
            if isinstance(payload, list):
                payload = [
                    row for row in payload
                    if isinstance(row, dict)
                    and (row.get("schema") or row.get("SCHEMA", "")).upper()
                    == "PEAKGEAR_USER"
                ]
            return json.dumps(payload, default=str)
        except Exception as exc:
            return err(exc)

    if _UPSTREAM_ADP_BROWSE_CATALOG is None:
        return err("The upstream adp_browse_catalog implementation is unavailable.")
    return _UPSTREAM_ADP_BROWSE_CATALOG(
        action=action,
        catalog_name=catalog_name,
        search_term=search_term,
        object_type=object_type,
        ctx=ctx,
    )


@mcp.tool()
def adp_ai_chat(question: str,
                mode: str = "chat",
                tables: str = None,
                profile_name: str = None,
                max_rows: int = 1000,
                ctx: Context = None) -> str:
    """Run Select AI only against the prepared PeakGear lab objects.

    This is a second, deterministic boundary in addition to the database
    login.  The upstream tool remains responsible for Select AI execution,
    but an NL-to-SQL request naming another schema is refused before it can
    reach the database.
    """
    requested = []
    for raw in (tables or "").split(","):
        key = raw.strip().strip('"').strip("'").upper()
        if key:
            requested.append(key.rsplit(".", 1)[-1])
    if not requested:
        return err(
            "PeakGear LiveLab requires an explicit tables list; use only the prepared PEAKGEAR_USER lab objects."
        )
    forbidden = sorted(set(requested) - _PEAKGEAR_AI_OBJECTS)
    if forbidden:
        return err(
            "PeakGear LiveLab object boundary refused: "
            + ", ".join(forbidden)
            + ". Use only prepared PEAKGEAR_USER lab objects."
        )
    if _UPSTREAM_ADP_AI_CHAT is None:
        return err("The upstream adp_ai_chat implementation is unavailable.")
    return _UPSTREAM_ADP_AI_CHAT(
        question=question,
        mode=mode,
        tables=tables,
        profile_name=profile_name,
        max_rows=max_rows,
        ctx=ctx,
    )


@mcp.tool()
def adp_run_query(sql: str, max_rows: int = 1000, ctx: Context = None) -> str:
    """Execute SQL in ADP and return a JSON string with bounded result rows.

    This LiveLab compatibility replacement exists because the installed server
    can otherwise return a dict despite declaring ``-> str``. It preserves the
    built-in tool name and access-profile rules; it does not broaden access.
    """
    try:
        client = get_adp(ctx)
        if client is None:
            return err("ADP is not connected. Set ADP_URL, ADP_USER, ADP_PASSWORD.")
        result = client.Misc.run_query(sql)
        payload = json.loads(result) if isinstance(result, str) else result
        return json.dumps(bound_rows(payload, max_rows=max_rows), default=str)
    except Exception as exc:
        return err(exc)


def _peakgear_av_sql(av_name: str, owner: str, max_rows: int) -> str | None:
    """Return a fixed, read-only query for the two PeakGear AVs."""
    if not isinstance(max_rows, int) or not 1 <= max_rows <= 1000:
        raise ValueError("max_rows must be an integer from 1 to 1000.")
    if not owner or not owner.replace("_", "").isalnum():
        raise ValueError("owner must be a simple database identifier.")
    owner_sql = owner.upper()
    av_sql = av_name.upper()
    if owner_sql != "PEAKGEAR_USER":
        return None
    if av_sql == "LAB_DIGITAL_POPULARITY_AV":
        return f'''SELECT
  "LAB_PRODUCT_HIER"."PRODUCT_ID" AS product_id,
  "LAB_PRODUCT_HIER"."PRODUCT_NAME" AS product_name,
  "LAB_PRODUCT_HIER"."CATEGORY_NAME" AS category_name,
  "MEASURES"."DIGITAL_EVENTS" AS digital_events
FROM "{owner_sql}"."{av_sql}"
HIERARCHIES (lab_product_hier)
WHERE "LAB_PRODUCT_HIER"."PRODUCT_ID" IS NOT NULL
ORDER BY digital_events DESC, product_id
FETCH FIRST {max_rows} ROWS ONLY'''
    if av_sql == "LAB_RETURNS_AV":
        return f'''SELECT
  "LAB_PRODUCT_HIER"."PRODUCT_ID" AS product_id,
  "LAB_PRODUCT_HIER"."PRODUCT_NAME" AS product_name,
  "LAB_PRODUCT_HIER"."CATEGORY_NAME" AS category_name,
  "LAB_STORE_HIER"."STORE_ID" AS store_id,
  "LAB_STORE_HIER"."STORE_NAME" AS store_name,
  "MEASURES"."RETURNED_UNITS" AS returned_units
FROM "{owner_sql}"."{av_sql}"
HIERARCHIES (lab_product_hier, lab_store_hier)
WHERE "LAB_PRODUCT_HIER"."PRODUCT_ID" IS NOT NULL
ORDER BY returned_units DESC, product_id, store_id
FETCH FIRST {max_rows} ROWS ONLY'''
    return None


@mcp.tool()
def adp_query_analytic_view(av_name: str,
                             show_sql: bool = False,
                             owner: str = None,
                             max_rows: int = 1000,
                             ctx: Context = None) -> str:
    """Query a PeakGear AV with a governed, bounded drill-down.

    The two lab AVs use an explicit allowlisted SQL shape because the current
    upstream SDK confuses dimension and hierarchy names. Other AV names keep
    the upstream SDK path and are not broadened by this compatibility tool.
    """
    client = get_adp(ctx)
    if not client:
        return err("ADP is not connected. Set ADP_URL, ADP_USER, ADP_PASSWORD.")
    try:
        effective_owner = owner or client.rest.username
        statement = _peakgear_av_sql(av_name, effective_owner, max_rows)
        if statement:
            if show_sql:
                return statement
            result = client.Misc.run_query(statement)
            payload = json.loads(result) if isinstance(result, str) else result
            return json.dumps(bound_rows(payload, max_rows=max_rows), default=str)

        # Preserve the vendor behavior for non-PeakGear AVs.
        if not client.Analytics.is_exist(av_name, owner):
            return err(f'Analytic view "{av_name}" does not exist.')
        if show_sql:
            result = client.Analytics.get_sql_simple(av_name, owner)
            return result if isinstance(result, str) else json.dumps(result, default=str)
        rows = client.Analytics.get_data_simple(av_name, owner)
        if isinstance(rows, str):
            try:
                rows = json.loads(rows)
            except ValueError:
                return rows
        if isinstance(rows, dict):
            rows = rows.get('items') or rows.get('rows') or rows
        return json.dumps(bound_rows(rows, max_rows=max_rows), default=str)
    except Exception as exc:
        return err(exc)


def _verify_adp_round_trip(client) -> None:
    """Run a bounded, read-only query before declaring the session ready."""
    response = client.rest.post(
        f"{client.rest.get_prefix()}/_/sql",
        {"statementText": _READINESS_SQL},
        timeout=_READINESS_TIMEOUT_SECONDS,
    )
    payload = json.loads(response)
    if not payload.get("items"):
        raise RuntimeError("The ADP readiness query returned no rows.")


def _run_read_only_statement(client,
                             statement: str,
                             timeout_seconds: int = _READINESS_TIMEOUT_SECONDS) -> list[object]:
    """Execute one fixed read-only statement and return only its row payload."""
    response = client.rest.post(
        f"{client.rest.get_prefix()}/_/sql",
        {"statementText": statement},
        timeout=timeout_seconds,
    )
    payload = json.loads(response)
    statements = payload.get("items") or []
    if not statements:
        raise RuntimeError("The read-only query returned no rows.")
    first = statements[0]
    result_set = first.get("resultSet") if isinstance(first, dict) else None
    if isinstance(result_set, dict):
        rows = result_set.get("items") or []
        if rows:
            return rows
    return statements


def _saved_digital_contract(client) -> dict[str, str]:
    """Read only the table-level Data Studio contract for the raw view."""
    response = client.Misc.run_query(_DIGITAL_CONTRACT_SQL)
    payload = json.loads(response) if isinstance(response, str) else response
    if isinstance(payload, list):
        items = payload
    elif isinstance(payload, dict):
        items = payload.get("rows") or payload.get("items") or []
    else:
        items = []
    contract: dict[str, str] = {}
    for item in items:
        if isinstance(item, dict):
            name = item.get("ANNOTATION_NAME") or item.get("annotation_name")
            value = item.get("ANNOTATION_VALUE") or item.get("annotation_value")
        elif isinstance(item, (list, tuple)) and len(item) >= 2:
            name, value = item[0], item[1]
        else:
            continue
        if name is not None:
            contract[str(name).upper()] = "" if value is None else str(value)
    return contract


@mcp.tool()
def adp_get_connection_info(ctx: Context = None) -> str:
    """Show the non-secret ADP connection identity used by LiveLab.

    Returns the configured Data Studio URL, database username, and whether
    a bounded read-only query completed. Passwords, access tokens, query
    results, and other credentials are never returned.
    """
    try:
        lifespan = ctx.request_context.lifespan_context
        config = lifespan.get("_adp_config")
        if not config:
            return err("ADP is not configured for this MCP server.")

        client = get_adp(ctx)
        result = {
            "service": "ADP",
            "adp_url": config.url,
            "adp_user": config.user,
            "session_ready": False,
            "readiness_check": "SELECT 1 FROM dual",
            "query_result_adapter": _LIVELAB_QUERY_ADAPTER,
            "query_result_contract": "adp_run_query returns a JSON string",
        }
        if client is None:
            result["readiness_detail"] = "No ADP client is available."
            return json.dumps(result, indent=2)

        started = time.monotonic()
        _verify_adp_round_trip(client)
        elapsed_ms = round((time.monotonic() - started) * 1000)
        result.update(
            {
                "session_ready": True,
                "readiness_detail": "Read-only database round-trip succeeded.",
                "readiness_elapsed_ms": elapsed_ms,
            }
        )
        return json.dumps(result, indent=2)
    except Exception as exc:
        return err(exc)


@mcp.tool()
def adp_get_top_digital_interest(ctx: Context = None) -> str:
    """Return the five product IDs with the most digital interest right now.

    This is a narrow, read-only PeakGear lab tool. It reads only
    PEAKGEAR_USER.LAB_DIGITAL_INTENT_RAW_V. The metric and period intentionally
    match the saved Data Studio description: each row is one digital event and
    "right now" is the latest completed calendar month. Product names are not
    returned because this raw view does not contain them. The tool first
    requires table-level DESCRIPTION and TAGS annotations saved in Data Studio
    and returns a controlled stop when that contract is absent.
    """
    try:
        client = get_adp(ctx)
        if client is None:
            return err("No ADP client is available.")

        contract = _saved_digital_contract(client)
        required = {"DESCRIPTION", "TAGS"}
        missing = sorted(required.difference(contract))
        if missing:
            return json.dumps(
                {
                    "status": "needs_data_studio_contract",
                    "object": "PEAKGEAR_USER.LAB_DIGITAL_INTENT_RAW_V",
                    "missing_annotations": missing,
                    "message": (
                        "Review and save the table Description and Tags in "
                        "Data Studio AI Enrichment before asking for this ranking."
                    ),
                }
            )

        rows = _run_read_only_statement(
            client,
            _TOP_DIGITAL_INTEREST_SQL,
            timeout_seconds=_TOP_DIGITAL_INTEREST_TIMEOUT_SECONDS,
        )
        return json.dumps(
            {
                "object": "PEAKGEAR_USER.LAB_DIGITAL_INTENT_RAW_V",
                "definition": {
                    "customer_interest": "COUNT(*) of digital events",
                    "right_now": "latest completed calendar month based on EVENT_TS",
                    "result_grain": "one row per PRODUCT_ID",
                },
                "rows": rows,
                "contract_source": "Data Studio native DESCRIPTION and TAGS annotations",
                "note": "Product names and return risk require the governed Analytic View.",
            },
            default=str,
        )
    except Exception as exc:
        return err(exc)


if __name__ == "__main__":
    main()
