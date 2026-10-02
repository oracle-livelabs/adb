# HOL6091 revision and release checklist

Estimated Time: 10 minutes to review; allow a separate full dry-run.

## Revision status

WMS 12202 / LiveLabs 4526 / HOL6091. The original submission was merged in PR 540. This revision is prepared on `codex/hol6091-mike-review-20261001` for later review. No approval, OCA attestation, or production acceptance is claimed.

Mode: publish-ready structure with explicit runtime gates. Six labs retain 78 minutes of planned content plus 12 minutes for troubleshooting. The main path uses new Data Studio; legacy actions appear only in appendices.

## Source precedence and applied changes

The narrated walkthrough supplies the procedure. The supplied working SQL supplies exact identifiers and queries. Peer feedback improves clarity and removes confusing branches. The workshop owner explicitly retained Mia on Gold when the recorded final query used native Silver.

| Area | Revision |
|---|---|
| Setup | Reservation, first OCI password change, correct database region/compartment, and separate PG login; no attendee imports or credential remapping |
| Project and names | Use `peakgear_medallion`; lowercase recorded flow/workflow names; correct quoted Bronze, Silver, and Gold identifiers |
| Bronze | Catalog browsing and Sample Data work in the newer recording; remove obsolete empty-tree warnings from the main path |
| Bronze registration | Run the prepared `wf_01_raw_to_bronze` to register bridge views over preloaded Bronze |
| Expressions | Review Expression → Column Mapping; remove the failed regex-edit exercise and unnecessary Save/Validate instructions |
| Silver | Explain the four workflow steps and default-variable dialog; use Jobs → Transforms; wait for success |
| Inventory | Lead with catalog discovery; use supplied SQL; explain grain, ATP, one-month coverage, null handling, and the gap calculation |
| Saved analysis | Save as Inventory gap analysis; no read-aloud requirement or unverified store-name join |
| Gold | Run after Silver; explain the bridge view and native PG target; correct table and SALES_REGION checks |
| Metadata | Demonstrate Catalog → AI Enrichment after loading Gold; review and save descriptions/tags; remove unavailable Data Transforms annotation-tab instructions |
| NLQ | Start from Gold's Query with AI; simplify to top 10 product names by latest-month sales; provide Gold reference SQL |
| Images | Cropped/redacted original video frames replace outdated screenshots; failed attempts and credentials are excluded |
| Navigation | Keep legacy procedures in appendices; point sandbox help at the shared LiveLabs help lab |

## Evidence established by source review

* The recording is about 28 minutes 36 seconds; narration and frames were reviewed locally.
* 00:00–05:17: reservation, OCI password change, Data Studio database connection, and project selection.
* 05:23–07:25: four Bronze tables and successful lowercase Bronze SQL.
* 07:47–08:40: Bronze view-registration workflow.
* 08:57–09:57: expressions reviewed in Column Mapping; narrator explicitly removes the editing exercise.
* 10:01–13:20: Silver workflow, prepared defaults, child-job monitoring, and completion.
* 13:26–15:36: Silver SQL; corrections are consolidated into clean final instructions.
* 15:50–19:32: discovery, grain checks, one-month coverage, ATP completeness, and inventory result.
* 19:50–20:46: Gold workflow and job completion.
* 20:56–22:00: native Gold catalog, generated metadata, Save, and persisted description/tags in Overview.
* 22:30–23:36: Gold SQL and West-region check.
* 24:12 onward: Query with AI entry point is visible, but the attempted Gold NLQ fails. The final successful query uses native Silver. It is not evidence of a successful Gold NLQ.

The SQL reference for Mia was adapted to the confirmed Gold DDL and West-only scope. It has been reviewed statically, not executed against the event database in this revision. No live workflow or database mutation was performed while authoring.

## Deliberate scope decisions

* Retain the prepared expressions and cleansing workflow instead of teaching a new processor or renaming live flow components during the event. Clear purpose labels are added in the guide; the deployed project itself was not changed.
* Keep Gold-flow inspection brief. An optional facilitator explanation can show its filter and the aggregation component's Attributes → Is Group By settings, including CHANNEL_TYPE. Do not ask attendees to change margin calculations or grouping.
* Do not add writable-Iceberg SQL, a Spark exercise, an analyst-created Gold table, or a metadata before/after NLQ accuracy experiment to this 90-minute revision.
* Do not claim that Catalog enrichment proves automatic Data Transforms filter capture, database annotation propagation, or Select AI metadata consumption. Those are separate checks.
* Keep FreeSQL out: these queries require the private event catalogs, schema, and AI configuration.

## Required checks before requesting approval

- [ ] Freeze and record the approved PeakGear dataset revision in the private deployment record.
- [ ] Confirm isolated attendee environments and provision the recorded project, catalog mount, credentials, and defaults.
- [ ] Verify that `wf_01_raw_to_bronze` contains only the intended Bronze-view registration in the event build.
- [ ] Inspect the definition of `PG."ailh_enriched_sales_v"` and prove that the Gold source reads published Silver, rather than only a native intermediate copy.
- [ ] Run all supplied SQL in the final build, including a legitimate empty inventory result if the extract changes.
- [ ] Confirm both workflows succeed in sequence; the Silver clear/reset step must target only disposable assigned data.
- [ ] Verify Gold filter, aggregation grain, and margin semantics against the actual flow. TXN_ID is not assumed to be a transaction count.
- [ ] Repeat Catalog AI Enrichment, inspect descriptions, save, reopen, and confirm the intended metadata persistence and model configuration.
- [ ] Verify the AI profile exposes the exact case-sensitive Gold object and the supported metadata sources.
- [ ] Test the revised Gold prompt through Query with AI. Inspect both outer query and latest-month subquery, execute, and compare totals with the reference query.
- [ ] Capture a successful Gold NLQ result only after the previous check passes. Do not reuse the recorded Silver result as proof.
- [ ] Rehearse the full 90-minute agenda, with setup and troubleshooting included.
- [x] Render all six local LiveLabs pages with expanded tasks and verify all workshop images load.
- [ ] Complete the repository's official reviewer checks before submission.
- [ ] Confirm the author's OCA/sign-off requirements before the later PR submission; do not attest on the author's behalf.

## Facilitator talking points

* Lab 1: “Alex prepares data, Sam investigates across tiers, and Mia consumes a focused business product. Bronze retains, Silver refines, and Gold publishes.”
* Lab 2: “Bronze is preloaded. First we register its views, then review the joins and expressions. The workflow handles preparation, cleansing, and publication to Iceberg.”
* Lab 3: “Sam finds inventory through the catalog and combines it with sales. The gap is a review signal based on past sales, not a forecast or an automatic purchase order.”
* Lab 4: “Gold is a native Oracle table containing West only. The filter determines membership; Catalog AI Enrichment helps us describe that business scope. We review the generated text before saving.”
* Lab 5: “Mia selects the Gold table as context, asks one focused question, and checks the generated SQL. A plausible answer from the wrong table is not a successful result.”
* Lab 6: “Open-table tiers and native Oracle products can coexist. We used OCI and Oracle SQL; Spark and additional clouds are extensions, not workloads demonstrated today.”

## Validation boundaries

See `validation-result.md` for the structural check. All 12 SQL blocks in Labs 2–4 match the supplied working SQL after whitespace normalization. Local image paths, manifest targets, and Git whitespace checks pass.

A separate headless Chrome session rendered all six LiveLabs pages with tasks expanded and workshop images decoded. The preview caught and fixed underscore formatting in navigation identifiers. Firefox and a GitHub connector were unavailable; screenshots came from the authorized recording. Local Git and the public GitHub API supplied repository checks.

The automated Lanham ratings remain advisory and low in several files; they include SQL, technical identifiers, possessives, and product terminology. The manual editorial assessment below is separate from that report and from runtime acceptance.

The owner previously chose public Oracle documentation and UI evidence instead of supplying oracle-db-skills. Current public documentation was checked for catalog access and Select AI concepts; the event-specific UI sequence is grounded in the recording.

Editorial self-grade: 4/5 for clarity, consistent identifiers, persona continuity, and explicit evidence boundaries. Final Gold NLQ runtime acceptance and official reviewer checks remain open.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
