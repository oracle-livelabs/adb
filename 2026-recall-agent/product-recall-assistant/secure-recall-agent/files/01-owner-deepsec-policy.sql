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
    function ask_context(
        p_context  in clob,
        p_question in varchar2
    ) return clob;
end recall_agent_bridge;
/

create or replace package body recall_agent_bridge as
    function run_agent(
        p_context  in clob,
        p_question in varchar2
    ) return clob is
        l_conversation_id varchar2(128);
        l_params          clob;
        l_prompt          clob;
        l_answer          clob;
    begin
        -- The application connection is an end-user DDS session. Oracle only
        -- permits SET_PROFILE when the profile owner is the session user, so
        -- do not mutate the end-user session. RECALL_SECURED_RESPONDER keeps
        -- the owner-owned profile binding in its registered agent metadata.
        l_conversation_id := dbms_cloud_ai.create_conversation(
            attributes => q'~{
              "title":"React Product Recall Assistant",
              "retention_days":1,
              "conversation_length":5
            }~'
        );

        select json_object(
                   'conversation_id' value l_conversation_id returning clob
               )
        into l_params;

        l_prompt :=
            to_clob('Answer the user question using only the four authorized evidence sections in this request: product JSON, DDS-filtered vector and relational evidence, DDS-filtered spatial evidence, and graph evidence. ') ||
            to_clob('Use graphEvidence for component, supplier, store, and customer relationship patterns and spatialEvidence for regions, distances, and response centers. ') ||
            to_clob('Do not infer hidden rows or company totals. Question: ') ||
            to_clob(substr(p_question, 1, 1000)) ||
            to_clob('. Authorized converged evidence: ') ||
            p_context;

        l_answer := dbms_cloud_ai_agent.run_team(
            team_name   => 'RECALL_SECURED_TEAM',
            user_prompt => l_prompt,
            params      => l_params
        );

        return l_answer;
    end run_agent;

    function summarize_context(p_context in clob) return clob is
    begin
        return run_agent(
            p_context,
            'Summarize the authorized recall scope and the first response action.'
        );
    end summarize_context;

    function ask_context(
        p_context  in clob,
        p_question in varchar2
    ) return clob is
    begin
        return run_agent(p_context, p_question);
    end ask_context;
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
