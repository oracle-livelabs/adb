whenever sqlerror exit sql.sqlcode rollback
set define off
set serveroutput on size unlimited
set feedback on

prompt ============================================================
prompt Product Recall Assistant - Prepare React and Node Capstone
prompt Connect as RECALL_OWNER.
prompt ============================================================

begin
    if user != 'RECALL_OWNER' then
        raise_application_error(-20070, 'Wrong user: connect as RECALL_OWNER.');
    end if;
end;
/

-- The React app asks questions against the same role-filtered JSON used by
-- Lab 7. The owner-side bridge retains OCI access.
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

-- Embedding is isolated behind a definer-rights bridge because the ONNX
-- model is owned by RECALL_OWNER. It returns only the serialized vector;
-- row filtering remains in the invoker-rights RECALL_REACT_API package.
create or replace package recall_vector_bridge authid definer as
    function embed_query(p_text in varchar2) return clob;
end recall_vector_bridge;
/

create or replace package body recall_vector_bridge as
    function embed_query(p_text in varchar2) return clob is
        l_vector clob;
    begin
        select vector_serialize(
                   vector_embedding(
                       recall_minilm_l12_v2
                       using substr(p_text, 1, 1000) as data
                   )
                   returning clob
               )
        into   l_vector;

        return l_vector;
    end embed_query;
end recall_vector_bridge;
/

show errors package body recall_vector_bridge

-- Shared property-graph data is exposed through a narrow definer-rights package.
-- The role-filtered downstream projection is added to RECALL_REACT_API below;
-- it runs in the active end-user session so Deep Data Security filters rows.
create or replace package recall_graph_api authid definer as
    function context(p_batch_id in varchar2 default 'B-482') return clob;
end recall_graph_api;
/

create or replace package body recall_graph_api as
    function context(p_batch_id in varchar2 default 'B-482') return clob is
        l_batch_id varchar2(20) := upper(trim(p_batch_id));
        l_result  clob;
        l_exists  number;
    begin
        select count(*)
        into   l_exists
        from   batches
        where  batch_id = l_batch_id;

        if l_exists = 0 then
            return json_serialize(
                       json_object(
                           'error' value 'UNKNOWN_BATCH',
                           'batchId' value l_batch_id
                           returning json
                       ) returning clob
                   );
        end if;

        select json_serialize(
                   json_object(
                       'graphName' value 'RECALL_GRAPH',
                       'batchId' value l_batch_id,
                       'scope' value 'Shared component and supplier trace; customer identities excluded.',
                       'vertices' value (
                           select coalesce(
                                      json_arrayagg(
                                          json_object(
                                              'id' value v.vertex_id,
                                              'labels' value json_array(v.vertex_label returning json),
                                              'properties' value json_object(
                                                  'name' value v.display_name,
                                                  'code' value v.code_value,
                                                  'status' value v.status_value,
                                                  'city' value v.city,
                                                  'state' value v.state_code,
                                                  'tier' value v.tier_no,
                                                  'lot' value v.lot_code,
                                                  'installedAt' value v.installed_at
                                                  returning json
                                              ) returning json
                                          ) order by v.sort_no, v.vertex_id returning json
                                      ),
                                      json('[]')
                                  )
                           from (
                               select 'BATCH:' || b.batch_id as vertex_id,
                                      'batch' as vertex_label,
                                      b.batch_id as display_name,
                                      b.issue_code as code_value,
                                      b.recall_status as status_value,
                                      cast(null as varchar2(80)) as city,
                                      cast(null as varchar2(2)) as state_code,
                                      cast(null as number) as tier_no,
                                      cast(null as varchar2(40)) as lot_code,
                                      cast(null as varchar2(40)) as installed_at,
                                      1 as sort_no
                               from batches b
                               where b.batch_id = l_batch_id
                               union all
                               select distinct
                                      'COMPONENT_BATCH:' || cb.component_batch_id,
                                      'component_batch',
                                      cb.component_batch_id,
                                      cb.supplier_lot_code,
                                      cb.quality_status,
                                      cast(null as varchar2(80)),
                                      cast(null as varchar2(2)),
                                      cast(null as number),
                                      cb.supplier_lot_code,
                                      to_char(bc.installed_at, 'YYYY-MM-DD HH24:MI'),
                                      2
                               from batch_components bc
                               join component_batches cb
                                    on cb.component_batch_id = bc.component_batch_id
                               where bc.batch_id = l_batch_id
                               union all
                               select distinct
                                      'COMPONENT:' || c.component_id,
                                      'component',
                                      c.component_name,
                                      c.component_code,
                                      c.criticality,
                                      cast(null as varchar2(80)),
                                      cast(null as varchar2(2)),
                                      cast(null as number),
                                      cast(null as varchar2(40)),
                                      cast(null as varchar2(40)),
                                      3
                               from batch_components bc
                               join component_batches cb
                                    on cb.component_batch_id = bc.component_batch_id
                               join components c
                                    on c.component_id = cb.component_id
                               where bc.batch_id = l_batch_id
                               union all
                               select distinct
                                      'SUPPLIER_SITE:' || ss.supplier_site_id,
                                      'supplier_site',
                                      ss.site_name,
                                      ss.site_code,
                                      'TIER-' || to_char(s.tier_no),
                                      ss.city,
                                      ss.state_code,
                                      s.tier_no,
                                      cast(null as varchar2(40)),
                                      cast(null as varchar2(40)),
                                      4
                               from batch_components bc
                               join component_batches cb
                                    on cb.component_batch_id = bc.component_batch_id
                               join supplier_sites ss
                                    on ss.supplier_site_id = cb.supplier_site_id
                               join suppliers s
                                    on s.supplier_id = ss.supplier_id
                               where bc.batch_id = l_batch_id
                               union all
                               select distinct
                                      'SUPPLIER:' || s.supplier_id,
                                      'supplier',
                                      s.supplier_name,
                                      s.supplier_type,
                                      'TIER-' || to_char(s.tier_no),
                                      cast(null as varchar2(80)),
                                      cast(null as varchar2(2)),
                                      s.tier_no,
                                      cast(null as varchar2(40)),
                                      cast(null as varchar2(40)),
                                      5
                               from batch_components bc
                               join component_batches cb
                                    on cb.component_batch_id = bc.component_batch_id
                               join supplier_sites ss
                                    on ss.supplier_site_id = cb.supplier_site_id
                               join suppliers s
                                    on s.supplier_id = ss.supplier_id
                               where bc.batch_id = l_batch_id
                           ) v
                       ) format json,
                       'edges' value (
                           select coalesce(
                                      json_arrayagg(
                                          json_object(
                                              'id' value e.edge_id,
                                              'source' value e.source_id,
                                              'target' value e.target_id,
                                              'labels' value json_array(e.edge_label returning json),
                                              'properties' value json_object(
                                                  'label' value e.edge_label,
                                                  'supplierLot' value e.supplier_lot,
                                                  'installedAt' value e.installed_at,
                                                  'producedAt' value e.produced_at,
                                                  'receivedAt' value e.received_at
                                                  returning json
                                              ) returning json
                                          ) order by e.edge_id returning json
                                      ),
                                      json('[]')
                                  )
                           from (
                               select distinct
                                      'USES:' || t.batch_id || ':' || t.component_batch_id as edge_id,
                                      'BATCH:' || t.batch_id as source_id,
                                      'COMPONENT_BATCH:' || t.component_batch_id as target_id,
                                      'uses_component' as edge_label,
                                      t.supplier_lot_code as supplier_lot,
                                      to_char(t.installed_at, 'YYYY-MM-DD HH24:MI') as installed_at,
                                      cast(null as varchar2(40)) as produced_at,
                                      cast(null as varchar2(40)) as received_at
                               from graph_table (
                                   recall_graph
                                   match
                                       (b is batch)-[u is uses_component]->(cb is component_batch)
                                       -[m is supplied_from]->(site is supplier_site)
                                       -[o is operated_by]->(sup is supplier),
                                       (cb is component_batch)-[t is component_type]->(comp is component)
                                   columns (
                                       b.batch_id as batch_id,
                                       cb.component_batch_id as component_batch_id,
                                       cb.supplier_lot_code as supplier_lot_code,
                                       u.installed_at as installed_at
                                   )
                               ) t
                               where t.batch_id = l_batch_id
                               union all
                               select distinct
                                      'TYPE:' || t.component_batch_id || ':' || to_char(t.component_id) as edge_id,
                                      'COMPONENT_BATCH:' || t.component_batch_id,
                                      'COMPONENT:' || to_char(t.component_id),
                                      'component_type',
                                      cast(null as varchar2(40)),
                                      cast(null as varchar2(40)),
                                      cast(null as varchar2(40)),
                                      cast(null as varchar2(40))
                               from graph_table (
                                   recall_graph
                                   match
                                       (b is batch)-[u is uses_component]->(cb is component_batch)
                                       -[m is supplied_from]->(site is supplier_site)
                                       -[o is operated_by]->(sup is supplier),
                                       (cb is component_batch)-[t is component_type]->(comp is component)
                                   columns (
                                       b.batch_id as batch_id,
                                       cb.component_batch_id as component_batch_id,
                                       comp.component_id as component_id
                                   )
                               ) t
                               where t.batch_id = l_batch_id
                               union all
                               select distinct
                                      'SITE:' || t.component_batch_id || ':' || to_char(t.supplier_site_id) as edge_id,
                                      'COMPONENT_BATCH:' || t.component_batch_id,
                                      'SUPPLIER_SITE:' || to_char(t.supplier_site_id),
                                      'supplied_from',
                                      t.supplier_lot_code,
                                      cast(null as varchar2(40)),
                                      to_char(t.produced_at, 'YYYY-MM-DD HH24:MI'),
                                      to_char(t.received_at, 'YYYY-MM-DD HH24:MI')
                               from graph_table (
                                   recall_graph
                                   match
                                       (b is batch)-[u is uses_component]->(cb is component_batch)
                                       -[m is supplied_from]->(site is supplier_site)
                                       -[o is operated_by]->(sup is supplier),
                                       (cb is component_batch)-[t is component_type]->(comp is component)
                                   columns (
                                       b.batch_id as batch_id,
                                       cb.component_batch_id as component_batch_id,
                                       site.supplier_site_id as supplier_site_id,
                                       m.supplier_lot_code as supplier_lot_code,
                                       m.produced_at as produced_at,
                                       m.received_at as received_at
                                   )
                               ) t
                               where t.batch_id = l_batch_id
                               union all
                               select distinct
                                      'OPERATED:' || to_char(t.supplier_site_id) || ':' || to_char(t.supplier_id) as edge_id,
                                      'SUPPLIER_SITE:' || to_char(t.supplier_site_id),
                                      'SUPPLIER:' || to_char(t.supplier_id),
                                      'operated_by',
                                      cast(null as varchar2(40)),
                                      cast(null as varchar2(40)),
                                      cast(null as varchar2(40)),
                                      cast(null as varchar2(40))
                               from graph_table (
                                   recall_graph
                                   match
                                       (b is batch)-[u is uses_component]->(cb is component_batch)
                                       -[m is supplied_from]->(site is supplier_site)
                                       -[o is operated_by]->(sup is supplier),
                                       (cb is component_batch)-[t is component_type]->(comp is component)
                                   columns (
                                       b.batch_id as batch_id,
                                       site.supplier_site_id as supplier_site_id,
                                       sup.supplier_id as supplier_id
                                   )
                               ) t
                               where t.batch_id = l_batch_id
                           ) e
                       ) format json
                       returning json
                   ) returning clob
               )
        into   l_result;

        return l_result;
    end context;
end recall_graph_api;
/

show errors package body recall_graph_api

begin
    dbms_cloud_ai_agent.drop_team('RECALL_SECURED_TEAM', force => true);
    dbms_cloud_ai_agent.drop_task('SUMMARIZE_SECURED_RECALL_TASK', force => true);
    dbms_cloud_ai_agent.drop_agent('RECALL_SECURED_RESPONDER', force => true);

    dbms_cloud_ai_agent.create_agent(
        agent_name => 'RECALL_SECURED_RESPONDER',
        attributes => q'~{
          "profile_name":"RECALL_AGENT_PROFILE",
          "role":"You are a role-aware converged product recall investigator. Summarize only the pre-authorized product JSON, vector and relational evidence, spatial evidence, and graph evidence supplied in the request. Never infer or add stores, customers, complaints, counts, locations, relationships, or totals absent from that evidence.",
          "enable_human_tool":false
        }~'
    );

    dbms_cloud_ai_agent.create_task(
        task_name  => 'SUMMARIZE_SECURED_RECALL_TASK',
        attributes => q'~{
          "instruction":"Answer the user's question using only the four authorized evidence sections in this request: productJson, authorizedJsonVectorEvidence, spatialEvidence, and graphEvidence. Use the spatial section for regions, response-radius coverage, and response centers; use graphEvidence for component, supplier, store, and customer relationship patterns. State the active end user when relevant, cite only visible counts and complaint IDs, and never expand beyond the active role scope.",
          "tools":[],
          "enable_human_tool":false
        }~'
    );

    dbms_cloud_ai_agent.create_team(
        team_name => 'RECALL_SECURED_TEAM',
        attributes => q'~{
          "agents":[{"name":"RECALL_SECURED_RESPONDER","task":"SUMMARIZE_SECURED_RECALL_TASK"}],
          "process":"sequential"
        }~'
    );
end;
/

create or replace package recall_react_api authid current_user as
    function current_identity return clob;
    function product_context(p_batch_id in varchar2 default 'B-482') return clob;
    function secured_stores(p_batch_id in varchar2 default 'B-482') return clob;
    function secured_graph(p_batch_id in varchar2 default 'B-482') return clob;
    function search_vector_evidence(
        p_batch_id   in varchar2,
        p_search_text in varchar2
    ) return clob;
    function ask_agent(
        p_batch_id in varchar2,
        p_question in varchar2
    ) return clob;
end recall_react_api;
/

create or replace package body recall_react_api as
    function current_identity return clob is
        l_user varchar2(128);
        l_role varchar2(128);
    begin
        select json_value(
                   ora_end_user_context,
                   '$.USERNAME' returning varchar2(128)
               )
        into l_user;

        if l_user not in (
            'STORE_101_USER', 'REGION_NE_USER', 'RECALL_LEAD_USER'
        ) then
            raise_application_error(-20071, 'No supported recall persona is active.');
        end if;

        select role_name
        into l_role
        from v$end_user_data_role
        fetch first 1 row only;

        return json_serialize(
                   json_object(
                       'username' value l_user,
                       'dataRole' value l_role,
                       'roleLabel' value case l_user
                           when 'STORE_101_USER' then 'Store associate'
                           when 'REGION_NE_USER' then 'Northeast regional manager'
                           when 'RECALL_LEAD_USER' then 'Recall response lead'
                       end
                       returning json
                   ) returning clob
               );
    end current_identity;

    function product_context(p_batch_id in varchar2 default 'B-482') return clob is
        l_result clob;
    begin
        select json_serialize(
                   json_object(
                       'batchId' value b.batch_id,
                       'product' value p.product_name,
                       'sku' value p.sku,
                       'category' value p.category,
                       'recallStatus' value b.recall_status,
                       'issueCode' value b.issue_code,
                       'issueSummary' value b.issue_summary,
                       'manufacturedOn' value to_char(b.manufactured_on, 'YYYY-MM-DD'),
                       'components' value json_query(
                           p.attributes,
                           '$.components' returning json
                       ) format json
                       returning json
                   ) returning clob
               )
        into l_result
        from batches b
        join products p on p.product_id = b.product_id
        where b.batch_id = upper(trim(p_batch_id));

        return l_result;
    exception
        when no_data_found then
            return json_serialize(
                       json_object(
                           'error' value 'UNKNOWN_BATCH',
                           'batchId' value upper(trim(p_batch_id))
                           returning json
                       ) returning clob
                   );
    end product_context;

    function secured_stores(p_batch_id in varchar2 default 'B-482') return clob is
        l_result clob;
    begin
        select json_serialize(
                   json_object(
                       'type' value 'FeatureCollection',
                       'features' value coalesce(
                           json_arrayagg(
                               json_object(
                                   'type' value 'Feature',
                                   'geometry' value json_object(
                                       'type' value 'Point',
                                       'coordinates' value json_array(
                                           x.longitude, x.latitude returning json
                                       ) returning json
                                   ) format json,
                                   'properties' value json_object(
                                       'storeId' value x.store_id,
                                       'storeCode' value x.store_code,
                                       'storeName' value x.store_name,
                                       'regionCode' value x.region_code,
                                       'unitsSent' value x.units_sent
                                       returning json
                                   ) format json
                                   returning json
                               ) order by x.store_id returning json
                           ),
                           json('[]')
                       ) format json
                       returning json
                   ) returning clob
               )
        into l_result
        from (
            select s.store_id,
                   s.store_code,
                   s.store_name,
                   s.region_code,
                   s.location.sdo_point.x as longitude,
                   s.location.sdo_point.y as latitude,
                   sum(si.units_sent) as units_sent
            from shipments sh
            join shipment_items si on si.shipment_id = sh.shipment_id
            join stores s on s.store_id = si.store_id
            where sh.batch_id = upper(trim(p_batch_id))
            group by s.store_id, s.store_code, s.store_name, s.region_code,
                     s.location.sdo_point.x, s.location.sdo_point.y
        ) x;

        return l_result;
    end secured_stores;

    function secured_graph(p_batch_id in varchar2 default 'B-482') return clob is
        l_batch_id varchar2(20) := upper(trim(p_batch_id));
        l_result  clob;
    begin
        select json_serialize(
                   json_object(
                       'graphName' value 'RECALL_GRAPH',
                       'batchId' value l_batch_id,
                       'scope' value 'DDS-filtered downstream store and customer exposure',
                       'authorizedStoreCount' value (
                           select count(distinct s.store_id)
                           from shipments sh
                           join shipment_items si on si.shipment_id = sh.shipment_id
                           join stores s on s.store_id = si.store_id
                           where sh.batch_id = l_batch_id
                       ),
                       'authorizedCustomerCount' value (
                           select count(distinct c.customer_id)
                           from shipments sh
                           join shipment_items si on si.shipment_id = sh.shipment_id
                           join purchases p on p.store_id = si.store_id
                           join customers c on c.customer_id = p.customer_id
                           where sh.batch_id = l_batch_id
                             and p.batch_id = l_batch_id
                       ),
                       'vertices' value (
                           select coalesce(
                                      json_arrayagg(
                                          json_object(
                                              'id' value v.vertex_id,
                                              'labels' value json_array(v.vertex_label returning json),
                                              'properties' value json_object(
                                                  'name' value v.display_name,
                                                  'code' value v.code_value,
                                                  'status' value v.status_value,
                                                  'regionCode' value v.region_code,
                                                  'storeId' value v.store_id,
                                                  'customerId' value v.customer_id,
                                                  'unitsSent' value v.units_sent,
                                                  'purchasedOn' value v.purchased_on
                                                  returning json
                                              ) returning json
                                          ) order by v.sort_no, v.vertex_id returning json
                                      ),
                                      json('[]')
                                  )
                           from (
                               select distinct
                                      'STORE:' || s.store_id as vertex_id,
                                      'store' as vertex_label,
                                      s.store_code as display_name,
                                      s.store_name as code_value,
                                      'AUTHORIZED' as status_value,
                                      s.region_code as region_code,
                                      s.store_id as store_id,
                                      cast(null as number) as customer_id,
                                      sum(si.units_sent) over (partition by s.store_id) as units_sent,
                                      cast(null as varchar2(40)) as purchased_on,
                                      6 as sort_no
                               from shipments sh
                               join shipment_items si on si.shipment_id = sh.shipment_id
                               join stores s on s.store_id = si.store_id
                               where sh.batch_id = l_batch_id
                               union all
                               select distinct
                                      'CUSTOMER:' || c.customer_id,
                                      'customer',
                                      c.full_name,
                                      to_char(c.customer_id),
                                      'AUTHORIZED',
                                      s.region_code,
                                      s.store_id,
                                      c.customer_id,
                                      cast(null as number),
                                      to_char(p.purchased_on, 'YYYY-MM-DD'),
                                      7
                               from purchases p
                               join customers c on c.customer_id = p.customer_id
                               join stores s on s.store_id = p.store_id
                               where p.batch_id = l_batch_id
                           ) v
                       ) format json,
                       'edges' value (
                           select coalesce(
                                      json_arrayagg(
                                          json_object(
                                              'id' value e.edge_id,
                                              'source' value e.source_id,
                                              'target' value e.target_id,
                                              'labels' value json_array(e.edge_label returning json),
                                              'properties' value json_object(
                                                  'label' value e.edge_label,
                                                  'unitsSent' value e.units_sent,
                                                  'quantity' value e.quantity,
                                                  'purchasedOn' value e.purchased_on
                                                  returning json
                                              ) returning json
                                          ) order by e.edge_id returning json
                                      ),
                                      json('[]')
                                  )
                           from (
                               select distinct
                                      'DELIVERED:' || l_batch_id || ':' || s.store_id as edge_id,
                                      'BATCH:' || l_batch_id as source_id,
                                      'STORE:' || s.store_id as target_id,
                                      'delivered_to' as edge_label,
                                      sum(si.units_sent) as units_sent,
                                      cast(null as number) as quantity,
                                      cast(null as varchar2(40)) as purchased_on
                               from shipments sh
                               join shipment_items si on si.shipment_id = sh.shipment_id
                               join stores s on s.store_id = si.store_id
                               where sh.batch_id = l_batch_id
                               group by s.store_id
                               union all
                               select distinct
                                      'PURCHASE:' || p.purchase_id,
                                      'STORE:' || p.store_id,
                                      'CUSTOMER:' || p.customer_id,
                                      'purchased_by',
                                      cast(null as number),
                                      p.quantity,
                                      to_char(p.purchased_on, 'YYYY-MM-DD')
                               from purchases p
                               join customers c on c.customer_id = p.customer_id
                               join stores s on s.store_id = p.store_id
                               where p.batch_id = l_batch_id
                           ) e
                       ) format json
                       returning json
                   ) returning clob
               )
        into   l_result;

        return l_result;
    end secured_graph;

    -- Spatial evidence is materialized in the active end-user session so
    -- Deep Data Security filters the stores before distance calculations.
    function secured_spatial(p_batch_id in varchar2 default 'B-482') return clob is
        l_batch_id varchar2(20) := upper(trim(p_batch_id));
        l_result  clob;
    begin
        select json_serialize(
                   json_object(
                       'batchId' value l_batch_id,
                       'responseRadiusKm' value 25,
                       'affectedStoreCount' value (
                           select count(distinct s.store_id)
                           from shipments sh
                           join shipment_items si on si.shipment_id = sh.shipment_id
                           join stores s on s.store_id = si.store_id
                           where sh.batch_id = l_batch_id
                       ),
                       'unitsSent' value (
                           select coalesce(sum(si.units_sent), 0)
                           from shipments sh
                           join shipment_items si on si.shipment_id = sh.shipment_id
                           where sh.batch_id = l_batch_id
                       ),
                       'storesWithinResponseRadius' value (
                           select count(distinct s.store_id)
                           from shipments sh
                           join shipment_items si on si.shipment_id = sh.shipment_id
                           join stores s on s.store_id = si.store_id
                           where sh.batch_id = l_batch_id
                           and exists (
                               select 1
                               from response_centers rc
                               where sdo_within_distance(
                                         s.location,
                                         rc.location,
                                         'distance=25 unit=km'
                                     ) = 'TRUE'
                           )
                       ),
                       'regions' value (
                           select coalesce(
                                      json_arrayagg(
                                          json_object(
                                              'region' value x.region_code,
                                              'storeCount' value x.store_count,
                                              'unitsSent' value x.units_sent
                                              returning clob
                                          ) order by x.region_code returning clob
                                      ),
                                      to_clob('[]')
                                  )
                           from (
                               select s.region_code,
                                      count(distinct s.store_id) as store_count,
                                      sum(si.units_sent) as units_sent
                               from shipments sh
                               join shipment_items si on si.shipment_id = sh.shipment_id
                               join stores s on s.store_id = si.store_id
                               where sh.batch_id = l_batch_id
                               group by s.region_code
                           ) x
                       ) format json,
                       'nearestResponseCenters' value (
                           select coalesce(
                                      json_arrayagg(
                                          json_object(
                                              'center' value x.center_name,
                                              'storeCount' value x.store_count,
                                              'unitsSent' value x.units_sent
                                              returning clob
                                          ) order by x.center_name returning clob
                                      ),
                                      to_clob('[]')
                                  )
                           from (
                               select y.center_name,
                                      count(*) as store_count,
                                      sum(y.units_sent) as units_sent
                               from (
                                   select s.store_id,
                                          sum(si.units_sent) over (
                                              partition by s.store_id, rc.center_name
                                          ) as units_sent,
                                          rc.center_name,
                                          row_number() over (
                                              partition by s.store_id
                                              order by sdo_geom.sdo_distance(
                                                  s.location,
                                                  rc.location,
                                                  0.00001,
                                                  'unit=km'
                                              )
                                          ) as rn
                                   from shipments sh
                                   join shipment_items si on si.shipment_id = sh.shipment_id
                                   join stores s on s.store_id = si.store_id
                                   cross join response_centers rc
                                   where sh.batch_id = l_batch_id
                               ) y
                               where y.rn = 1
                               group by y.center_name
                           ) x
                       ) format json
                       returning json
                   ) returning clob
               )
        into   l_result;

        return l_result;
    end secured_spatial;

    -- Keep the graph payload compact for the language model. The UI uses
    -- SECURED_GRAPH for interactive vertices and edges; the agent needs the
    -- path pattern, shared trace counts, and role-specific exposure counts.
    function secured_graph_evidence(p_batch_id in varchar2 default 'B-482') return clob is
        l_batch_id varchar2(20) := upper(trim(p_batch_id));
        l_result  clob;
    begin
        select json_serialize(
                   json_object(
                       'graphName' value 'RECALL_GRAPH',
                       'scope' value 'Shared component and supplier trace plus DDS-filtered downstream exposure',
                       'pathPattern' value 'BATCH -[uses_component]-> COMPONENT_BATCH -[supplied_from]-> SUPPLIER_SITE -[operated_by]-> SUPPLIER',
                       'downstreamPattern' value 'BATCH -[delivered_to]-> STORE -[purchased_by]-> CUSTOMER',
                       'sharedComponentBatchCount' value (
                           select count(*)
                           from batch_components bc
                           where bc.batch_id = l_batch_id
                       ),
                       'sharedSupplierSiteCount' value (
                           select count(distinct cb.supplier_site_id)
                           from batch_components bc
                           join component_batches cb
                                on cb.component_batch_id = bc.component_batch_id
                           where bc.batch_id = l_batch_id
                       ),
                       'sharedSupplierCount' value (
                           select count(distinct ss.supplier_id)
                           from batch_components bc
                           join component_batches cb
                                on cb.component_batch_id = bc.component_batch_id
                           join supplier_sites ss
                                on ss.supplier_site_id = cb.supplier_site_id
                           where bc.batch_id = l_batch_id
                       ),
                       'authorizedStoreCount' value (
                           select count(distinct s.store_id)
                           from shipments sh
                           join shipment_items si on si.shipment_id = sh.shipment_id
                           join stores s on s.store_id = si.store_id
                           where sh.batch_id = l_batch_id
                       ),
                       'authorizedCustomerCount' value (
                           select count(distinct p.customer_id)
                           from purchases p
                           join customers c on c.customer_id = p.customer_id
                           join stores s on s.store_id = p.store_id
                           where p.batch_id = l_batch_id
                       ),
                       'relationshipCounts' value json_object(
                           'deliveredTo' value (
                               select count(distinct s.store_id)
                               from shipments sh
                               join shipment_items si on si.shipment_id = sh.shipment_id
                               join stores s on s.store_id = si.store_id
                               where sh.batch_id = l_batch_id
                           ),
                           'purchasedBy' value (
                               select count(*)
                               from purchases p
                               join customers c on c.customer_id = p.customer_id
                               join stores s on s.store_id = p.store_id
                               where p.batch_id = l_batch_id
                           ),
                           'componentTypes' value (
                               select count(*)
                               from batch_components bc
                               join component_batches cb
                                    on cb.component_batch_id = bc.component_batch_id
                               where bc.batch_id = l_batch_id
                           )
                           returning clob
                       ) format json,
                       'componentSupplierTrace' value (
                           select coalesce(
                                      json_arrayagg(
                                          json_object(
                                              'componentBatchId' value x.component_batch_id,
                                              'componentCode' value x.component_code,
                                              'supplierSiteId' value x.supplier_site_id,
                                              'supplierSiteName' value x.site_name,
                                              'supplierName' value x.supplier_name,
                                              'qualityStatus' value x.quality_status,
                                              'supplierLot' value x.supplier_lot_code
                                              returning clob
                                          ) order by x.component_batch_id returning clob
                                      ),
                                      to_clob('[]')
                                  )
                           from (
                               select distinct
                                      cb.component_batch_id,
                                      c.component_code,
                                      ss.supplier_site_id,
                                      ss.site_name,
                                      s.supplier_name,
                                      cb.quality_status,
                                      cb.supplier_lot_code
                               from batch_components bc
                               join component_batches cb
                                    on cb.component_batch_id = bc.component_batch_id
                               join components c
                                    on c.component_id = cb.component_id
                               join supplier_sites ss
                                    on ss.supplier_site_id = cb.supplier_site_id
                               join suppliers s
                                    on s.supplier_id = ss.supplier_id
                               where bc.batch_id = l_batch_id
                           ) x
                       ) format json
                       returning json
                   ) returning clob
               )
        into   l_result;

        return l_result;
    end secured_graph_evidence;

    function search_vector_evidence(
        p_batch_id    in varchar2,
        p_search_text in varchar2
    ) return clob is
        l_batch_id   varchar2(20) := upper(trim(p_batch_id));
        l_search     varchar2(1000) := trim(p_search_text);
        l_vector     clob;
        l_result     clob;
    begin
        if l_search is null then
            raise_application_error(-20074, 'Enter a complaint symptom or evidence phrase.');
        end if;

        l_vector := recall_vector_bridge.embed_query(l_search);

        select json_serialize(
                   json_object(
                       'batchId' value l_batch_id,
                       'query' value l_search,
                       'results' value (
                           select coalesce(
                                      json_arrayagg(
                                          json_object(
                                              'complaintId' value x.complaint_id,
                                              'text' value x.chunk_text,
                                              'distance' value round(x.distance, 4),
                                              'severity' value x.severity,
                                              'symptom' value x.symptom
                                              returning json
                                          ) order by x.distance returning json
                                      ),
                                      json('[]')
                                  )
                           from (
                               select cc.complaint_id,
                                      cc.chunk_text,
                                      vector_distance(
                                          cc.embedding,
                                          to_vector(l_vector),
                                          cosine
                                      ) as distance,
                                      json_value(c.complaint_data, '$.severity') as severity,
                                      json_value(c.complaint_data, '$.symptom') as symptom
                               from complaint_chunks cc
                               join complaints c
                                    on c.complaint_id = cc.complaint_id
                               where cc.embedding is not null
                                 and (
                                     c.reported_batch = l_batch_id
                                     or c.customer_id in (
                                         select p.customer_id
                                         from purchases p
                                         where p.batch_id = l_batch_id
                                     )
                                 )
                               order by vector_distance(
                                   cc.embedding,
                                   to_vector(l_vector),
                                   cosine
                               )
                               fetch first 8 rows only
                           ) x
                       ) format json
                       returning json
                   ) returning clob
               )
        into   l_result;

        return l_result;
    end search_vector_evidence;

    function ask_agent(
        p_batch_id in varchar2,
        p_question in varchar2
    ) return clob is
        l_authorized_context clob;
        l_product_context    clob;
        l_spatial_context    clob;
        l_graph_context      clob;
    begin
        l_product_context := product_context(p_batch_id);
        l_authorized_context := recall_secure_api.get_secured_context(p_batch_id);
        l_spatial_context := secured_spatial(p_batch_id);
        l_graph_context := secured_graph_evidence(p_batch_id);

        select json_serialize(
                   json_object(
                       'productJson' value json_query(
                           l_product_context, '$' returning json
                       ) format json,
                       'authorizedJsonVectorEvidence' value json_query(
                           l_authorized_context, '$' returning json
                       ) format json,
                       'spatialEvidence' value json_query(
                           l_spatial_context, '$' returning json
                       ) format json,
                       'graphEvidence' value json_query(
                           l_graph_context, '$' returning json
                       ) format json
                       returning clob
                   ) returning clob
               )
        into   l_authorized_context;

        return recall_agent_bridge.ask_context(l_authorized_context, p_question);
    end ask_agent;
end recall_react_api;
/

show errors package body recall_react_api

declare
    l_status user_objects.status%type;
begin
    select status
    into   l_status
    from   user_objects
    where  object_name = 'RECALL_REACT_API'
    and    object_type = 'PACKAGE BODY';

    if l_status <> 'VALID' then
        raise_application_error(
            -20072,
            'RECALL_REACT_API package body is INVALID. Review SHOW ERRORS output.'
        );
    end if;
end;
/

grant execute on recall_react_api to recall_end_user_login;
grant execute on recall_graph_api to recall_end_user_login;
grant execute on recall_vector_bridge to recall_end_user_login;

select object_name, object_type, status
from   user_objects
where  object_name in ('RECALL_AGENT_BRIDGE', 'RECALL_GRAPH_API', 'RECALL_REACT_API', 'RECALL_VECTOR_BRIDGE')
order  by object_name, object_type;

prompt React and Node database bridge is ready.
