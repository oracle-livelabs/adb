# Lab 7: Show Each Role Only What It Needs: Make the Recall Agent Role-Aware with Deep Data Security

## Introduction

Daniel Brooks, a Data Governance Lead, has to protect trust while the recall response moves quickly. A store associate needs local instructions, a Northeast manager needs a regional picture, and the recall lead needs the company-wide scope. Giving every person the same answer would either hide useful context or expose more customer and store data than the job requires.

Your mission is to make authorization part of the database retrieval itself. Three local Deep Data Security end users will run the same vector search and request the same agent summary. The database grants filter stores, customers, complaints, and complaint vectors before the agent sees them, while shared component and supplier-site evidence remains available to all three roles. This is the differentiator: role boundaries do not depend on a browser filter or a promise in the prompt.

By the end of the lab, the store role will see 1 store, 12 units, and 5 customers; the Northeast role will see 24 stores, 453 units, and 120 customers; and the recall lead will see 120 stores, 2,400 units, and 600 customers. The same retrieval will produce three authorized answers with different complaint evidence.

This lab makes the security contract explicit: local users authenticate as themselves, their assigned data grants filter the database rows, and only the resulting authorized JSON and vector evidence are sent to the agent. `RECALL_OWNER` retains the direct Select AI Agent privilege and the OCI resource principal. The local users do not become `RECALL_OWNER`, do not receive unrestricted table access, and do not receive a broad `DBMS_CLOUD_AI_AGENT` grant. They use the approved package boundary; the owner-side definer-rights bridge performs the governed agent handoff. Lab 8 extends this same boundary with role-filtered Spatial and Graph evidence in the React application.

Estimated Time: 12 minutes

### Objectives

In this lab, you will:

- Inspect local end users, data roles, and parent-to-child data grants.
- Run the same vector similarity search as three business roles.
- Confirm that unauthorized complaint chunks never enter retrieval.
- Ask the same agent team for a role-aware recall summary.
- Inspect the active end-user identity and data role.

## Task 1: Inspect Security at the Source

1. Connect as `RECALL_OWNER` and run [`01-owner-deepsec-policy.sql`](files/01-owner-deepsec-policy.sql).

    ```sql
    <copy>
    whenever sqlerror exit sql.sqlcode rollback
    set define off
    set serveroutput on size unlimited
    set feedback on

    prompt ============================================================
    prompt Product Recall Assistant - Lab 7 Deep Data Security Policy
    prompt Connect as RECALL_OWNER.
    prompt ============================================================

    begin
        if user != 'RECALL_OWNER' then
            raise_application_error(-20042, 'Wrong user: connect as RECALL_OWNER.');
        end if;
    end;
    /

    create or replace data role recall_store_101_data_role;
    create or replace data role recall_region_ne_data_role;
    create or replace data role recall_lead_data_role;

    grant recall_end_user_login to recall_store_101_data_role;
    grant recall_end_user_login to recall_region_ne_data_role;
    grant recall_end_user_login to recall_lead_data_role;

    -- Shared reference data required by the converged investigation.
    create or replace data grant recall_owner.dg_products_read
    as select on recall_owner.products
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_batches_read
    as select on recall_owner.batches
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_actions_read
    as select on recall_owner.recall_actions
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_queries_read
    as select on recall_owner.recall_queries
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_response_centers_read
    as select on recall_owner.response_centers
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_suppliers_read
    as select on recall_owner.suppliers
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_supplier_sites_read
    as select on recall_owner.supplier_sites
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_components_read
    as select on recall_owner.components
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_component_batches_read
    as select on recall_owner.component_batches
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_batch_components_read
    as select on recall_owner.batch_components
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_component_site_edges_read
    as select on recall_owner.component_batch_site_edges
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_component_type_edges_read
    as select on recall_owner.component_batch_component_edges
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_supplier_site_edges_read
    as select on recall_owner.supplier_site_edges
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    -- Store visibility is the root authorization decision.
    create or replace data grant recall_owner.dg_store_101_stores
    as select on recall_owner.stores
    where store_id = 101
    to recall_store_101_data_role;

    create or replace data grant recall_owner.dg_region_ne_stores
    as select on recall_owner.stores
    where region_code = 'NORTHEAST'
    to recall_region_ne_data_role;

    create or replace data grant recall_owner.dg_lead_stores
    as select on recall_owner.stores
    to recall_lead_data_role;

    -- Customer and purchase access follows the visible store set.
    create or replace data grant recall_owner.dg_store_customers
    as select on recall_owner.customers
    where home_store_id in (select store_id from recall_owner.stores)
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_store_purchases
    as select on recall_owner.purchases
    where store_id in (select store_id from recall_owner.stores)
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    -- Shipment and spatial impact follow the same authorized stores.
    create or replace data grant recall_owner.dg_store_shipment_items
    as select on recall_owner.shipment_items
    where store_id in (select store_id from recall_owner.stores)
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_store_shipments
    as select on recall_owner.shipments
    where shipment_id in (
        select shipment_id from recall_owner.shipment_items
    )
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    -- Complaint access follows the authorized customer; vector chunks follow
    -- the authorized parent complaint, matching the source-article pattern.
    create or replace data grant recall_owner.dg_customer_complaints
    as select on recall_owner.complaints
    where customer_id in (select customer_id from recall_owner.customers)
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_complaint_chunks
    as select on recall_owner.complaint_chunks
    where complaint_id in (select complaint_id from recall_owner.complaints)
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace package recall_agent_bridge authid definer as
        function summarize_context(p_context in clob) return clob;
    end recall_agent_bridge;
    /

    create or replace package body recall_agent_bridge as
        function summarize_context(p_context in clob) return clob is
            l_conversation_id varchar2(128);
            l_params          clob;
            l_prompt          clob;
            l_answer          clob;
        begin
            dbms_cloud_ai.set_profile('RECALL_AGENT_PROFILE');
            l_conversation_id := dbms_cloud_ai.create_conversation(
                attributes => q'~{
                  "title":"Role-aware Product Recall Assistant",
                  "retention_days":1,
                  "conversation_length":5
                }~'
            );

            select json_object(
                       'conversation_id' value l_conversation_id returning clob
                   )
            into l_params;

            l_prompt :=
                to_clob('Summarize only this authorized recall JSON and vector evidence. ') ||
                to_clob('Do not infer hidden rows or company totals. Evidence: ') ||
                p_context;

            l_answer := dbms_cloud_ai_agent.run_team(
                team_name   => 'RECALL_SECURED_TEAM',
                user_prompt => l_prompt,
                params      => l_params
            );

            return l_answer;
        end summarize_context;
    end recall_agent_bridge;
    /

    show errors package body recall_agent_bridge

    begin
        execute immediate q'~
            create table recall_authorized_requests (
                request_id     number generated always as identity primary key,
                end_user_name  varchar2(128) not null,
                batch_id       varchar2(20) not null,
                context_json   json not null,
                created_at     timestamp default systimestamp not null
            )~';
    exception
        when others then
            if sqlcode != -955 then raise; end if;
    end;
    /

    create or replace package recall_context_sink authid definer as
        function store_context(
            p_batch_id in varchar2,
            p_context  in clob
        ) return number;
    end recall_context_sink;
    /

    create or replace package body recall_context_sink as
        function store_context(
            p_batch_id in varchar2,
            p_context  in clob
        ) return number is
            l_request_id number;
            l_end_user   varchar2(128);
        begin
            select json_value(p_context, '$.endUser' returning varchar2(128))
            into l_end_user;

            if l_end_user is null then
                raise_application_error(-20044, 'Captured context lacks an end user.');
            end if;

            insert into recall_authorized_requests(
                end_user_name, batch_id, context_json
            ) values (
                l_end_user, upper(trim(p_batch_id)), json(p_context)
            )
            returning request_id into l_request_id;

            commit;
            return l_request_id;
        end store_context;
    end recall_context_sink;
    /

    show errors package body recall_context_sink

    create or replace package recall_secure_api authid current_user as
        function current_end_user return varchar2;
        function get_secured_context(p_batch_id in varchar2) return clob;
        function capture_secured_context(p_batch_id in varchar2) return number;
    end recall_secure_api;
    /

    create or replace package body recall_secure_api as
        function current_end_user return varchar2 is
            l_user varchar2(128);
        begin
            select json_value(
                       ora_end_user_context,
                       '$.USERNAME' returning varchar2(128)
                   )
            into l_user;
            return l_user;
        end current_end_user;

        function get_secured_context(p_batch_id in varchar2) return clob is
            l_result clob;
        begin
            select json_object(
                       'endUser' value current_end_user,
                       'batchId' value upper(trim(p_batch_id)),
                       'affectedStoreCount' value (
                           select count(distinct si.store_id)
                           from shipments sh
                           join shipment_items si on si.shipment_id = sh.shipment_id
                           where sh.batch_id = upper(trim(p_batch_id))
                       ),
                       'unitsSent' value (
                           select coalesce(sum(si.units_sent), 0)
                           from shipments sh
                           join shipment_items si on si.shipment_id = sh.shipment_id
                           where sh.batch_id = upper(trim(p_batch_id))
                       ),
                       'customerExposureCount' value (
                           select count(distinct p.customer_id)
                           from purchases p
                           where p.batch_id = upper(trim(p_batch_id))
                       ),
                       'componentBatchCount' value (
                           select count(*)
                           from batch_components bc
                           where bc.batch_id = upper(trim(p_batch_id))
                       ),
                       'supplierSiteCount' value (
                           select count(distinct cb.supplier_site_id)
                           from batch_components bc
                           join component_batches cb
                                on cb.component_batch_id = bc.component_batch_id
                           where bc.batch_id = upper(trim(p_batch_id))
                       ),
                       'semanticComplaints' value (
                           select json_arrayagg(
                                      json_object(
                                          'complaintId' value x.complaint_id,
                                          'text' value x.chunk_text,
                                          'distance' value round(x.distance, 4)
                                      ) order by x.distance returning clob
                                  )
                           from (
                               select cc.complaint_id,
                                      cc.chunk_text,
                                      vector_distance(
                                          cc.embedding, q.query_vector, cosine
                                      ) as distance
                               from complaint_chunks cc
                               cross join recall_queries q
                               where q.query_key = 'HEAT_ODOR'
                               and vector_distance(
                                       cc.embedding, q.query_vector, cosine
                                   ) < 0.70
                               order by distance
                               fetch first 5 rows only
                           ) x
                       ) format json,
                       'firstAction' value (
                           select action_text from recall_actions where priority_no = 1
                       ),
                       'customerContactAuthorized' value 'false' format json
                       returning clob
                   )
            into l_result;
            return l_result;
        end get_secured_context;

        function capture_secured_context(p_batch_id in varchar2) return number is
            l_context clob;
        begin
            l_context := get_secured_context(p_batch_id);
            return recall_context_sink.store_context(p_batch_id, l_context);
        end capture_secured_context;
    end recall_secure_api;
    /

    show errors package body recall_secure_api

    grant execute on recall_secure_api to recall_end_user_login;

    -- This responder has no retrieval tool. The invoker-rights package completes
    -- secured retrieval first, then passes only the materialized JSON to the team.
    begin
        dbms_cloud_ai_agent.drop_team('RECALL_SECURED_TEAM', force => true);
        dbms_cloud_ai_agent.drop_task('SUMMARIZE_SECURED_RECALL_TASK', force => true);
        dbms_cloud_ai_agent.drop_agent('RECALL_SECURED_RESPONDER', force => true);

        dbms_cloud_ai_agent.create_agent(
            agent_name => 'RECALL_SECURED_RESPONDER',
            attributes => q'~{
              "profile_name":"RECALL_AGENT_PROFILE",
              "role":"You are a role-aware product recall investigator. Summarize only the pre-authorized recall JSON and vector evidence supplied in the request. Never infer or add stores, customers, complaints, counts, or totals absent from that evidence.",
              "enable_human_tool":false
            }~'
        );

        dbms_cloud_ai_agent.create_task(
            task_name  => 'SUMMARIZE_SECURED_RECALL_TASK',
            attributes => q'~{
              "instruction":"Summarize only the authorized JSON and vector evidence in this request: {query}. State the end user, visible store count, visible units, visible customer count, shared component batch count, shared supplier site count, visible complaint IDs, and first action without expanding beyond the active role scope.",
              "tools":[],
              "enable_human_tool":false
            }~'
        );

        dbms_cloud_ai_agent.create_team(
            team_name  => 'RECALL_SECURED_TEAM',
            attributes => q'~{
              "agents":[{"name":"RECALL_SECURED_RESPONDER","task":"SUMMARIZE_SECURED_RECALL_TASK"}],
              "process":"sequential"
            }~'
        );
    end;
    /

    prompt --- Verify owner data grants used in Task 1 ---

    select grant_name, grantee, object_owner, object_name, predicate
    from   user_data_grants
    where  grant_name in (
               'DG_STORE_101_STORES',
               'DG_REGION_NE_STORES',
               'DG_CUSTOMER_COMPLAINTS',
               'DG_COMPLAINT_CHUNKS',
               'DG_COMPONENT_BATCHES_READ',
               'DG_SUPPLIER_SITES_READ'
           )
    order  by grant_name, grantee;

    prompt Deep Data Security policy and secured agent wrapper are ready.
    </copy>
    ```

    The script creates or refreshes the three data roles, 60 owner data-grant assignments, secured packages, and `RECALL_SECURED_TEAM`. The shared response-center grant supports the Lab 8 role-filtered Spatial evidence without exposing additional customer or store rows.

2. Inspect the owner-created grants that form the protected retrieval chain.

    ```sql
    <copy>
    select grant_name, grantee, object_owner, object_name, predicate
    from   user_data_grants
    where  grant_name in (
               'DG_STORE_101_STORES',
               'DG_REGION_NE_STORES',
               'DG_CUSTOMER_COMPLAINTS',
               'DG_COMPLAINT_CHUNKS',
               'DG_COMPONENT_BATCHES_READ',
               'DG_SUPPLIER_SITES_READ'
           )
    order  by grant_name, grantee;
    </copy>
    ```

    The query returns 14 rows because shared grants have one row for each data-role grantee.

    The role-scoped authorization path is:

    ```text
    visible stores -> visible customers -> visible complaints -> visible vectors
    ```

    `DG_COMPLAINT_CHUNKS` authorizes a chunk only when its parent complaint is visible. Similarity search cannot rank an unauthorized vector. Component and supplier-site grants apply to all three roles because they describe the recalled batch and do not expose customer identity.

3. Connect as `ADMIN` and run [`02-admin-assign-data-roles.sql`](files/02-admin-assign-data-roles.sql). The assignment view is ADMIN-only, so run the following query in that same session:

    ```sql
    <copy>
    select grantee, data_role
    from   dba_data_role_grants
    where  grantee in (
               'STORE_101_USER',
               'REGION_NE_USER',
               'RECALL_LEAD_USER'
           )
    order  by grantee;
    </copy>
    ```

    `DBA_DATA_ROLE_GRANTS` is an administrative view; do not run it as `RECALL_OWNER`. Disconnect `ADMIN` after this check.

4. Reconnect as `RECALL_OWNER` and inspect the secured responder team.

    ```sql
    <copy>
    select agent_team_name, status
    from   user_ai_agent_teams
    where  agent_team_name = 'RECALL_SECURED_TEAM';
    </copy>
    ```

    `RECALL_SECURE_API` uses invoker rights to materialize the secured JSON and vector evidence. `RECALL_CONTEXT_SINK` captures that PII-safe document. The trusted `RECALL_AGENT_BRIDGE` passes only the captured JSON to `RECALL_SECURED_TEAM`. The responder has no SQL or retrieval tool. Lab 8 adds product JSON, DDS-filtered spatial impact, and a compact Graph trace summary before its application bridge makes the same handoff.

    The privilege and data flow is:

    ```text
    local end user
        -> ORA_END_USER_CONTEXT and assigned Deep Data Security data role
        -> RECALL_SECURE_API AUTHID CURRENT_USER
        -> data grants filter stores, customers, complaints, and vectors
        -> PII-safe authorized JSON and vector evidence
        -> RECALL_AGENT_BRIDGE AUTHID DEFINER
        -> DBMS_CLOUD_AI_AGENT.RUN_TEAM('RECALL_SECURED_TEAM', ...)
    ```

    The `EXECUTE` privilege on `DBMS_CLOUD_AI_AGENT` belongs to the owner-side bridge owner. The local user receives `EXECUTE` only on the approved application/security packages. This is why the local user can request an answer without being able to query arbitrary tables or expand the JSON scope.

## Task 2: Compare Store and Regional Retrieval

1. Connect as `STORE_101_USER` and run [`03-test-secured-vector.sql`](files/03-test-secured-vector.sql).

    The script stops if `ORA_END_USER_CONTEXT` or the expected data role is missing. Confirm the displayed end-user identity; a saved connection name alone does not prove which identity it uses.

    Confirm the session identity and active role:

    ```text
    End user: STORE_101_USER
    Data role: RECALL_STORE_101_DATA_ROLE
    ```

    The vector result contains the closest authorized complaint match, `9001`, for the store role. The secured context reports one store, 12 units, and five potentially exposed customers. The secured context uses the top-ranked results below a `0.70` cosine-distance ceiling so weakly related generated observations do not appear.

2. Run the identical script as `REGION_NE_USER`.

    The SQL text and query vector do not change. Deep Data Security expands the visible set according to `RECALL_REGION_NE_DATA_ROLE`.

    The result contains complaints `9001`, `9002`, and `9006`. The secured context reports 24 stores, 453 units, and 120 potentially exposed customers.

3. Compare why complaint `9003` is absent. Its customer belongs to the Manhattan store, outside the Northeast grant. The database hides the complaint and its vector before `VECTOR_DISTANCE` ranks candidates.

## Task 3: Run the Same Select AI Agent for All Three Roles

1. Connect as `RECALL_LEAD_USER` and rerun [`03-test-secured-vector.sql`](files/03-test-secured-vector.sql).

    The vector result now contains complaints `9001`, `9002`, `9006`, `9003`, and `9007`. The context reports 120 stores, 2,400 units, and 600 customers.

2. While connected as each end user, run [`04-capture-secured-context.sql`](files/04-capture-secured-context.sql).

    Each call stores the JSON already filtered by the active end-user security context. It contains no customer names or email addresses.

3. Reconnect as `RECALL_OWNER` and run [`05-run-secured-agent.sql`](files/05-run-secured-agent.sql).

    This is the role-aware Select AI Agent demonstration. The script invokes `RECALL_SECURED_TEAM` three times through `RECALL_AGENT_BRIDGE.SUMMARIZE_CONTEXT`. It processes the latest store, regional, and recall-lead contexts.

    ```sql
    <copy>
    l_answer := dbms_cloud_ai_agent.run_team(
        team_name   => 'RECALL_SECURED_TEAM',
        user_prompt => l_prompt,
        params      => l_params
    );
    </copy>
    ```

    The owner-side service retains the OCI resource principal and the direct agent-framework privilege. It does not rerun retrieval or expand the captured scope. The same team, task, and prompt process all three requests. Only the database-authorized JSON changes. This owner-run script demonstrates the JSON/vector handoff after each local user captured context; Lab 8 performs the converged JSON/vector/Spatial/Graph handoff on demand from the application session.

4. Compare the role-aware checkpoints.

    | End user | Visible stores | Units | Customers | Semantic complaints |
    |---|---:|---:|---:|---|
    | `STORE_101_USER` | 1 | 12 | 5 | `9001` |
    | `REGION_NE_USER` | 24 | 453 | 120 | `9001`, `9002`, `9006` |
    | `RECALL_LEAD_USER` | 120 | 2,400 | 600 | `9001`, `9002`, `9006`, `9003`, `9007` |

    Wording can vary because the model generates prose. Counts and complaint IDs must stay within the active role scope.

5. Match each generated answer to its security context.

    - The `STORE_101_USER` answer must name one store, 12 units, five customers, and complaint `9001` only.
    - The `REGION_NE_USER` answer must name 24 stores, 453 units, 120 customers, and complaints `9001`, `9002`, and `9006` only.
    - The `RECALL_LEAD_USER` answer must name 120 stores, 2,400 units, 600 customers, and complaints `9001`, `9002`, `9006`, `9003`, and `9007`.

    This is the central before-and-after result. One Select AI Agent receives three authorized contexts and produces three appropriately scoped answers.

    The model is not the authorization layer. Deep Data Security has already removed unauthorized rows before `RUN_TEAM` receives the JSON. The model may vary its wording, but it cannot recover a complaint, store, customer, vector, or count that was absent from the authorized input.

## Task 4: Verify the Guardrail and Context

1. Run these queries as any local end user.

    ```sql
    <copy>
    select json_value(
               ora_end_user_context,
               '$.USERNAME' returning varchar2(128)
           ) as end_user
    ;

    select role_name
    from   v$end_user_data_role
    order  by role_name;
    </copy>
    ```

    Direct login establishes the end-user security context. The business identity owns no schema and receives no unrestricted table grants.

2. Explain the security result:

    - The database role-filters store, customer, purchase, and shipment rows.
    - JSON complaint records follow the authorized customer.
    - Vector chunks follow the authorized complaint.
    - Lab 8 spatial impact counts use only visible stores in the active end-user session.
    - Component and supplier-site counts remain shared recall evidence.
    - The owner-managed agent receives only the captured, role-filtered JSON and vector evidence in this lab; Lab 8 adds the same role-filtered Spatial and Graph sections.
    - The same database policy applies before data reaches the model.

    In other words, the local user calls the approved agent-facing package, not an unrestricted model endpoint. The package executes retrieval as `AUTHID CURRENT_USER`, and the definer-rights bridge uses the owner’s agent privilege only after the DDS-filtered document has been created. Definer's rights provide controlled access to the configured AI service; they do not bypass the data grants because retrieval has already run in the end-user context.

3. A production application should propagate the end-user context with a supported Oracle client driver. This lab uses direct login to keep the identity flow visible.

You have completed the Deep Data Security policy. Lab 8 deploys the final React/Node application and makes all three authorized experiences visible through one sign-in page.

## Troubleshooting

| Symptom | Likely cause | Recovery |
|---|---|---|
| End-user login fails | The prepared login role or data-role grant is missing | Ask the facilitator to verify the backend deployment. |
| The script reports `ORA-20045` | The connection label points to a schema user instead of a local end user | Recreate the connection with the actual `STORE_101_USER`, `REGION_NE_USER`, or `RECALL_LEAD_USER` username. |
| Store preflight reports more than one chunk | The session is not using the prepared policy or has broad visibility | Disconnect and create a fresh end-user session, then ask the facilitator to verify the backend deployment. |
| `USER_DATA_GRANTS` returns no rows | The prepared owner policy is missing | Ask the facilitator to verify the backend deployment. |
| `ORA_END_USER_CONTEXT` returns null | The session uses a schema user | Reconnect with the Lab 7 end-user connection. |
| Vector query returns no rows | The prepared parent or query-vector grant is missing | Ask the facilitator to verify the backend deployment. |
| `RECALL_OWNER` cannot query `DBA_DATA_ROLE_GRANTS` | The role-assignment view is ADMIN-only | Ask the facilitator to run the Task 1 assignment query as `ADMIN`. |
| Store user sees complaint `9003` | The store role has a broad grant | Stop the lab. Inspect `USER_DATA_GRANTS` as `RECALL_OWNER` or `DBA_DATA_GRANTS` as `ADMIN`. |
| Captured context shows company totals for every user | `RECALL_SECURE_API` uses definer rights | Recreate it with `AUTHID CURRENT_USER`. |
| Agent call fails in an end-user session | Deep Data Security suppresses the owner OCI principal | Capture as the end user, then run `05-run-secured-agent.sql` as owner. |
| Model call fails | The profile, region, or IAM policy blocks access | Verify Lab 5 before changing the security policy. |

## Learn More

- [Securing Vector Search with Deep Data Security in Oracle AI Database](https://medium.com/@thomas.minne/securing-vector-search-with-deep-data-security-in-oracle-ai-database-c2fe0c4dd736)
- [Configure direct logon with local end users](https://docs.oracle.com/en/database/oracle/oracle-database/26/ddscg/configure-oracle-deep-data-security-direct-logon-local-end-users.html)
- [Create Deep Data Security data grants](https://docs.oracle.com/en/database/oracle/oracle-database/26/ddscg/create-data-grants.html)
- [End-user security context](https://docs.oracle.com/en/database/oracle/oracle-database/26/ddscg/end-user-security-context.html)

## Acknowledgements

- **Author:** Oracle AI World 2026 Product Recall Assistant workshop team
- **Last updated:** July 2026
