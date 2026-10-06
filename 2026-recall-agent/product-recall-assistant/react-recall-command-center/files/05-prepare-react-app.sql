-- Product Recall Assistant - Lab 8 application and governed response setup v7
-- Install through DBMS_CLOUD_REPO.INSTALL_SQL with CURRENT_SCHEMA=RECALL_OWNER.

begin
    if sys_context('USERENV', 'CURRENT_SCHEMA') != 'RECALL_OWNER' then
        raise_application_error(-20070, 'Set CURRENT_SCHEMA to RECALL_OWNER before installing this script.');
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
        into l_params
        from dual;

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
        into   l_vector
        from dual;

        return l_vector;
    end embed_query;
end recall_vector_bridge;
/

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
        into   l_result
        from dual;

        return l_result;
    end context;
end recall_graph_api;
/

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
        into l_user
        from dual;

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
                       end,
                       'ddsPolicy' value json_object(
                           'name' value case l_user
                               when 'STORE_101_USER' then 'DG_STORE_101_STORES'
                               when 'REGION_NE_USER' then 'DG_REGION_NE_STORES'
                               when 'RECALL_LEAD_USER' then 'DG_LEAD_STORES'
                           end,
                           'dataRole' value l_role,
                           'scope' value case l_user
                               when 'STORE_101_USER' then 'Store 101 and its authorized downstream evidence'
                               when 'REGION_NE_USER' then 'Northeast stores and their authorized downstream evidence'
                               when 'RECALL_LEAD_USER' then 'All stores and company-wide authorized evidence'
                           end,
                           'rule' value case l_user
                               when 'STORE_101_USER' then 'STORE_ID = 101'
                               when 'REGION_NE_USER' then 'REGION_CODE = ''NORTHEAST'''
                               when 'RECALL_LEAD_USER' then 'All stores'
                           end
                           returning json
                       )
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
        into   l_result
        from dual;

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
        into   l_result
        from dual;

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
        into   l_result
        from dual;

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
                               fetch first 12 rows only
                           ) x
                       ) format json
                       returning json
                   ) returning clob
               )
        into   l_result
        from dual;

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
        into   l_authorized_context
        from dual;

        return recall_agent_bridge.ask_context(l_authorized_context, p_question);
    end ask_agent;
end recall_react_api;
/

declare
    l_status all_objects.status%type;
begin
    select status
    into   l_status
    from   all_objects
    where  object_name = 'RECALL_REACT_API'
    and    owner = 'RECALL_OWNER'
    and    object_type = 'PACKAGE BODY';

    if l_status <> 'VALID' then
        raise_application_error(
            -20072,
            'RECALL_REACT_API package body is INVALID. Check ALL_ERRORS as ADMIN.'
        );
    end if;
end;
/

grant execute on recall_react_api to recall_end_user_login;
/
grant execute on recall_graph_api to recall_end_user_login;
/
grant execute on recall_vector_bridge to recall_end_user_login;
/

declare
    l_valid_count number;
begin
    select count(*)
    into   l_valid_count
    from   all_objects
    where  owner = 'RECALL_OWNER'
    and    object_name in ('RECALL_AGENT_BRIDGE', 'RECALL_GRAPH_API', 'RECALL_REACT_API', 'RECALL_VECTOR_BRIDGE')
    and    object_type in ('PACKAGE', 'PACKAGE BODY')
    and    status = 'VALID';

    if l_valid_count != 8 then
        raise_application_error(-20073, 'Expected eight VALID Lab 8 bridge package objects under RECALL_OWNER; inspect ALL_ERRORS as ADMIN.');
    end if;
end;
/

-- Lab 8 governed response campaign: policy, agent team, audit/refund tables,
-- owner-side bridge, and invoker-rights application API. This must follow
-- RECALL_REACT_API so the approved Lab 7 identity and profile already exist.
begin
    if sys_context('USERENV', 'CURRENT_SCHEMA') != 'RECALL_OWNER' then
        raise_application_error(-20100, 'Set CURRENT_SCHEMA to RECALL_OWNER before installing the Lab 8 response setup.');
    end if;
end;
/

-- The investigation remains read-only until the recall lead explicitly
-- authorizes customer contact. The policy is separate from the initial case
-- JSON so the workshop can demonstrate an approval transition.
begin
    execute immediate q'~
        create table recall_campaign_policy (
            batch_id             varchar2(20) primary key
                                 references batches(batch_id),
            unit_refund_amount   number(12,2) not null,
            refund_steps         varchar2(2000) not null,
            contact_authorized   char(1) default 'N' not null,
            authorized_by        varchar2(128),
            authorized_at        timestamp,
            constraint recall_campaign_policy_auth_ck
                check (contact_authorized in ('Y','N')),
            constraint recall_campaign_policy_amount_ck
                check (unit_refund_amount >= 0)
        )~';
exception
    when others then
        if sqlcode != -955 then raise; end if;
end;
/

begin
    execute immediate q'~
        create table recall_campaigns (
            campaign_id       number generated always as identity primary key,
            batch_id          varchar2(20) not null
                              references batches(batch_id),
            end_user_name     varchar2(128) not null,
            channel           varchar2(20) not null,
            tone              varchar2(30) not null,
            status            varchar2(30) default 'DRAFT' not null,
            template_source   varchar2(30) default 'SELECT_AI_AGENT' not null,
            template_text     clob not null,
            product_name      varchar2(200) not null,
            sku               varchar2(80) not null,
            recipient_count   number default 0 not null,
            total_refund      number(14,2) default 0 not null,
            created_at        timestamp default systimestamp not null,
            approved_by       varchar2(128),
            approved_at       timestamp,
            constraint recall_campaign_channel_ck
                check (channel in ('EMAIL','SMS')),
            constraint recall_campaign_tone_ck
                check (tone in ('PROFESSIONAL','REASSURING','CONCISE')),
            constraint recall_campaign_status_ck
                check (status in ('DRAFT','APPROVED')),
            constraint recall_campaign_source_ck
                check (template_source in ('SELECT_AI_AGENT','SAFE_FALLBACK')),
            constraint recall_campaign_total_ck
                check (total_refund >= 0)
        )~';
exception
    when others then
        if sqlcode != -955 then raise; end if;
end;
/

begin
    execute immediate q'~
        create table recall_campaign_recipients (
            campaign_id       number not null
                              references recall_campaigns(campaign_id),
            purchase_id       number not null
                              references purchases(purchase_id),
            customer_id       number not null
                              references customers(customer_id),
            customer_name     varchar2(100) not null,
            email             varchar2(200) not null,
            batch_id          varchar2(20) not null,
            product_name      varchar2(200) not null,
            sku               varchar2(80) not null,
            quantity          number not null,
            refund_amount     number(12,2) not null,
            notice_status     varchar2(30) default 'DRAFT' not null,
            refund_status     varchar2(30) default 'NOT_CREATED' not null,
            constraint recall_campaign_recipient_pk
                primary key (campaign_id, purchase_id),
            constraint recall_campaign_recipient_notice_ck
                check (notice_status in ('DRAFT','APPROVED')),
            constraint recall_campaign_recipient_refund_ck
                check (refund_status in ('NOT_CREATED','READY_FOR_PROCESSING')),
            constraint recall_campaign_recipient_qty_ck
                check (quantity > 0),
            constraint recall_campaign_recipient_amount_ck
                check (refund_amount >= 0)
        )~';
exception
    when others then
        if sqlcode != -955 then raise; end if;
end;
/

begin
    execute immediate q'~
        create table recall_refund_intents (
            refund_intent_id  number generated always as identity primary key,
            campaign_id       number not null
                              references recall_campaigns(campaign_id),
            purchase_id       number not null,
            customer_id       number not null,
            refund_amount     number(12,2) not null,
            status            varchar2(30) default 'READY_FOR_PROCESSING' not null,
            created_at        timestamp default systimestamp not null,
            constraint recall_refund_intent_status_ck
                check (status in ('READY_FOR_PROCESSING','SIMULATED_ISSUED')),
            constraint recall_refund_intent_amount_ck
                check (refund_amount >= 0),
            constraint recall_refund_intent_uq
                unique (campaign_id, purchase_id)
        )~';
exception
    when others then
        if sqlcode != -955 then raise; end if;
end;
/

begin
    execute immediate q'~
        create table recall_campaign_audit (
            audit_id       number generated always as identity primary key,
            campaign_id    number,
            batch_id       varchar2(20) not null,
            actor_name     varchar2(128) not null,
            action_name    varchar2(40) not null,
            detail_text    varchar2(2000),
            created_at     timestamp default systimestamp not null
        )~';
exception
    when others then
        if sqlcode != -955 then raise; end if;
end;
/

merge into recall_campaign_policy p
using (
    select 'B-482' as batch_id,
           129.99 as unit_refund_amount,
           '1. Verify the purchase and affected batch. 2. Stop using the item. 3. Provide the approved refund through the service team. 4. Retain the campaign and refund decision for audit.' as refund_steps,
           'N' as contact_authorized
    from dual
) s
on (p.batch_id = s.batch_id)
when not matched then
    insert (
        batch_id, unit_refund_amount, refund_steps, contact_authorized
    ) values (
        s.batch_id, s.unit_refund_amount, s.refund_steps, s.contact_authorized
    );
/

-- The campaign writer is a separate Select AI Agent team. It drafts language
-- only; it has no SQL, notification, payment, or human tool.
begin
    begin
        dbms_cloud_ai_agent.drop_team('RECALL_CAMPAIGN_TEAM', force => true);
    exception when others then null;
    end;
    begin
        dbms_cloud_ai_agent.drop_task('DRAFT_RECALL_NOTICE_TASK', force => true);
    exception when others then null;
    end;
    begin
        dbms_cloud_ai_agent.drop_agent('RECALL_CAMPAIGN_WRITER', force => true);
    exception when others then null;
    end;

    dbms_cloud_ai_agent.create_agent(
        agent_name => 'RECALL_CAMPAIGN_WRITER',
        attributes => q'~{
          "profile_name":"RECALL_AGENT_PROFILE",
          "role":"You draft a customer recall notice from the approved facts supplied in the request. Return only a JSON object with subject, body, and refundSteps. Use the supplied placeholders exactly. Never invent a product, batch, amount, eligibility rule, deadline, contact detail, or legal claim. Do not send a message and do not issue a refund.",
          "enable_human_tool":false
        }~'
    );

    dbms_cloud_ai_agent.create_task(
        task_name  => 'DRAFT_RECALL_NOTICE_TASK',
        attributes => q'~{
          "instruction":"Create a concise, professional recall notice. For a generic request, use placeholders {{customer_name}}, {{product_name}}, {{sku}}, {{batch_id}}, {{refund_amount}}, and {{refund_steps}}. For a request with selected recipient facts, use only those supplied name and order facts; never include an email address. Return strict JSON with string properties subject, body, and refundSteps.",
          "tools":[],
          "enable_human_tool":false
        }~'
    );

    dbms_cloud_ai_agent.create_team(
        team_name => 'RECALL_CAMPAIGN_TEAM',
        attributes => q'~{
          "agents":[{"name":"RECALL_CAMPAIGN_WRITER","task":"DRAFT_RECALL_NOTICE_TASK"}],
          "process":"sequential"
        }~',
        description => 'Human-approved recall notice drafting team.'
    );
end;
/

create or replace package recall_campaign_bridge authid definer as
    function policy(p_batch_id in varchar2) return clob;
    function generate_template(
        p_batch_id       in varchar2,
        p_product_name   in varchar2,
        p_sku            in varchar2,
        p_recipient_count in number,
        p_refund_steps   in varchar2,
        p_channel        in varchar2,
        p_tone           in varchar2,
        p_personalization in varchar2 default null
    ) return clob;
    function create_draft(
        p_end_user       in varchar2,
        p_batch_id       in varchar2,
        p_channel        in varchar2,
        p_tone           in varchar2,
        p_context        in clob,
        p_template       in clob
    ) return number;
    function personalize_notice(
        p_end_user          in varchar2,
        p_campaign_id       in number,
        p_recipient_context in clob
    ) return clob;
    function campaign_batch(
        p_campaign_id in number,
        p_actor       in varchar2
    ) return varchar2;
    function authorize_contact(
        p_batch_id in varchar2,
        p_actor    in varchar2
    ) return clob;
    function approve_campaign(
        p_campaign_id in number,
        p_actor       in varchar2
    ) return clob;
    function status(
        p_batch_id in varchar2,
        p_actor    in varchar2
    ) return clob;
end recall_campaign_bridge;
/

create or replace package body recall_campaign_bridge as
    function session_user return varchar2 is
        l_user varchar2(128);
    begin
        select json_value(ora_end_user_context, '$.USERNAME' returning varchar2(128))
        into l_user
        from dual;
        return upper(l_user);
    end session_user;

    function safe_template return clob is
    begin
        return json_serialize(
                   json_object(
                       'source' value 'SAFE_FALLBACK',
                       'template' value q'~{"subject":"Important safety notice for {{product_name}}","body":"Hello {{customer_name}},\n\nWe are contacting you about {{product_name}} ({{sku}}), batch {{batch_id}}. Please stop using the item and follow these steps:\n{{refund_steps}}\n\nYour approved refund amount is {{refund_amount}}. Our recall response team will help complete the refund.","refundSteps":"{{refund_steps}}"}~'
                       returning json
                   ) returning clob
               );
    end safe_template;

    function policy(p_batch_id in varchar2) return clob is
        l_result clob;
    begin
        select json_serialize(
                   json_object(
                       'batchId' value p.batch_id,
                       'unitRefundAmount' value p.unit_refund_amount,
                       'refundSteps' value p.refund_steps,
                       'contactAuthorized' value
                           case when p.contact_authorized = 'Y'
                                then 'true' else 'false' end format json,
                       'authorizedBy' value p.authorized_by,
                       'authorizedAt' value to_char(
                           p.authorized_at, 'YYYY-MM-DD HH24:MI:SS'
                       )
                       returning json
                   ) returning clob
               )
        into l_result
        from recall_campaign_policy p
        where p.batch_id = upper(trim(p_batch_id));
        return l_result;
    exception
        when no_data_found then
            return json_serialize(
                       json_object(
                           'error' value 'NO_CAMPAIGN_POLICY',
                           'batchId' value upper(trim(p_batch_id))
                           returning json
                       ) returning clob
                   );
    end policy;

    function generate_template(
        p_batch_id        in varchar2,
        p_product_name    in varchar2,
        p_sku             in varchar2,
        p_recipient_count in number,
        p_refund_steps    in varchar2,
        p_channel         in varchar2,
        p_tone            in varchar2,
        p_personalization in varchar2 default null
    ) return clob is
        l_prompt          clob;
        l_params          clob;
        l_answer          clob;
        l_conversation_id varchar2(128);
    begin
        l_prompt :=
            to_clob('Draft a customer recall notice template using only these approved facts. ') ||
            to_clob('Return strict JSON with subject, body, and refundSteps. ') ||
            to_clob(case when p_personalization is null
                         then 'Do not include customer names, email addresses, or new facts. '
                         else 'Use the selected customer and order facts exactly. Do not include an email address or new facts. '
                    end) ||
            to_clob('Batch: ' || p_batch_id ||
                    '; product: ' || p_product_name ||
                    '; SKU: ' || p_sku ||
                    '; authorized recipient count: ' || to_char(p_recipient_count) ||
                    '; channel: ' || p_channel ||
                    '; tone: ' || p_tone ||
                    '; approved refund steps: ' || p_refund_steps ||
                    case when p_personalization is null then
                         '. Required placeholders: {{customer_name}}, {{product_name}}, {{sku}}, {{batch_id}}, {{refund_amount}}, {{refund_steps}}.'
                    else
                         '; selected recipient facts: ' || p_personalization ||
                         '. Return a personalized notice, including the purchase ID and quantity.'
                    end);

        l_conversation_id := dbms_cloud_ai.create_conversation(
            attributes => q'~{
              "title":"Recall Notice Template Draft",
              "retention_days":1,
              "conversation_length":2
            }~'
        );
        select json_object(
                   'conversation_id' value l_conversation_id returning clob
               )
        into l_params
        from dual;

        l_answer := dbms_cloud_ai_agent.run_team(
            team_name   => 'RECALL_CAMPAIGN_TEAM',
            user_prompt => l_prompt,
            params      => l_params
        );

        if l_answer is null then
            return safe_template;
        end if;

        return json_serialize(
                   json_object(
                       'source' value 'SELECT_AI_AGENT',
                       'template' value l_answer
                       returning json
                   ) returning clob
               );
    exception
        when others then
            -- The workflow remains reviewable during a provider outage. The
            -- UI labels this as a safe fallback instead of implying an LLM run.
            return safe_template;
    end generate_template;

    function create_draft(
        p_end_user in varchar2,
        p_batch_id in varchar2,
        p_channel  in varchar2,
        p_tone     in varchar2,
        p_context  in clob,
        p_template in clob
    ) return number is
        l_campaign_id number;
        l_product_name varchar2(200);
        l_sku          varchar2(80);
        l_template_text varchar2(32767);
        l_source       varchar2(30);
    begin
        if session_user != upper(p_end_user) then
            raise_application_error(-20101, 'Campaign actor does not match the active database identity.');
        end if;

        l_product_name := json_value(p_context, '$.productName' returning varchar2(200));
        l_sku := json_value(p_context, '$.sku' returning varchar2(80));
        l_template_text := json_value(p_template, '$.template' returning varchar2(32767));
        l_source := json_value(p_template, '$.source' returning varchar2(30));

        insert into recall_campaigns(
            batch_id, end_user_name, channel, tone, status,
            template_source, template_text, product_name, sku,
            recipient_count, total_refund
        ) values (
            upper(trim(p_batch_id)), upper(p_end_user), upper(p_channel),
            upper(p_tone), 'DRAFT', nvl(l_source, 'SAFE_FALLBACK'),
            nvl(l_template_text, 'No template generated.'), l_product_name, l_sku,
            0, 0
        ) returning campaign_id into l_campaign_id;

        insert into recall_campaign_audit(
            campaign_id, batch_id, actor_name, action_name, detail_text
        ) values (
            l_campaign_id, upper(trim(p_batch_id)), upper(p_end_user),
            'DRAFT_CREATED', 'Generic LLM notice template captured for review; no customer records were materialized.'
        );

        return l_campaign_id;
    end create_draft;

    function personalize_notice(
        p_end_user          in varchar2,
        p_campaign_id       in number,
        p_recipient_context in clob
    ) return clob is
        l_batch_id      varchar2(20);
        l_product_name  varchar2(200);
        l_sku           varchar2(80);
        l_channel       varchar2(20);
        l_tone          varchar2(30);
        l_template      clob;
        l_customer_name varchar2(100);
        l_purchase_id   number;
        l_customer_id   number;
        l_email         varchar2(200);
        l_quantity      number;
        l_refund_amount number;
    begin
        select batch_id, product_name, sku, channel, tone
        into   l_batch_id, l_product_name, l_sku, l_channel, l_tone
        from   recall_campaigns
        where  campaign_id = p_campaign_id
        and    end_user_name = upper(p_end_user)
        for update;

        l_purchase_id := json_value(p_recipient_context, '$.purchaseId' returning number);
        l_customer_id := json_value(p_recipient_context, '$.customerId' returning number);
        l_customer_name := json_value(p_recipient_context, '$.customerName' returning varchar2(100));
        l_email := json_value(p_recipient_context, '$.email' returning varchar2(200));
        l_quantity := json_value(p_recipient_context, '$.quantity' returning number);
        l_refund_amount := json_value(p_recipient_context, '$.refundAmount' returning number);

        l_template := generate_template(
            l_batch_id, l_product_name, l_sku, 1,
            json_value(policy(l_batch_id), '$.refundSteps' returning varchar2(2000)),
            l_channel, l_tone,
            'Customer name: ' || l_customer_name ||
            '; order / purchase ID: ' || l_purchase_id ||
            '; quantity: ' || l_quantity ||
            '; approved refund amount: $' || to_char(l_refund_amount, 'FM999G999G990D00')
        );

        merge into recall_campaign_recipients r
        using (select p_campaign_id as campaign_id, l_purchase_id as purchase_id from dual) s
        on (r.campaign_id = s.campaign_id and r.purchase_id = s.purchase_id)
        when not matched then insert (
            campaign_id, purchase_id, customer_id, customer_name, email,
            batch_id, product_name, sku, quantity, refund_amount
        ) values (
            p_campaign_id, l_purchase_id, l_customer_id, l_customer_name, l_email,
            l_batch_id, l_product_name, l_sku, l_quantity, l_refund_amount
        );

        update recall_campaigns c
        set (recipient_count, total_refund) = (
            select count(*), coalesce(sum(refund_amount), 0)
            from recall_campaign_recipients r
            where r.campaign_id = c.campaign_id
        )
        where c.campaign_id = p_campaign_id;

        insert into recall_campaign_audit(
            campaign_id, batch_id, actor_name, action_name, detail_text
        ) values (
            p_campaign_id, l_batch_id, upper(p_end_user), 'RECIPIENT_PERSONALIZED',
            'One DDS-authorized customer order was materialized and personalized for review.'
        );
        return l_template;
    exception
        when no_data_found then
            raise_application_error(-20109, 'Campaign or selected customer record is not available to this persona.');
    end personalize_notice;

    function campaign_batch(
        p_campaign_id in number,
        p_actor       in varchar2
    ) return varchar2 is
        l_batch_id varchar2(20);
    begin
        select batch_id into l_batch_id
        from recall_campaigns
        where campaign_id = p_campaign_id
        and end_user_name = upper(p_actor);
        return l_batch_id;
    exception
        when no_data_found then
            raise_application_error(-20112, 'Campaign is not available to this persona.');
    end campaign_batch;

    function authorize_contact(
        p_batch_id in varchar2,
        p_actor    in varchar2
    ) return clob is
        l_batch_id varchar2(20) := upper(trim(p_batch_id));
    begin
        if session_user != upper(p_actor) or upper(p_actor) != 'RECALL_LEAD_USER' then
            raise_application_error(-20102, 'Only the recall response lead can authorize customer contact.');
        end if;

        update recall_campaign_policy
        set    contact_authorized = 'Y',
               authorized_by = upper(p_actor),
               authorized_at = systimestamp
        where  batch_id = l_batch_id;

        if sql%rowcount = 0 then
            raise_application_error(-20103, 'No campaign policy exists for batch ' || l_batch_id || '.');
        end if;

        insert into recall_campaign_audit(
            batch_id, actor_name, action_name, detail_text
        ) values (
            l_batch_id, upper(p_actor), 'CONTACT_AUTHORIZED',
            'Recall lead approved customer notice generation for this batch.'
        );
        commit;
        return policy(l_batch_id);
    end authorize_contact;

    function approve_campaign(
        p_campaign_id in number,
        p_actor       in varchar2
    ) return clob is
        l_batch_id recall_campaigns.batch_id%type;
        l_status   recall_campaigns.status%type;
    begin
        if session_user != upper(p_actor) or upper(p_actor) != 'RECALL_LEAD_USER' then
            raise_application_error(-20104, 'Only the recall response lead can approve a campaign.');
        end if;

        select batch_id, status
        into   l_batch_id, l_status
        from   recall_campaigns
        where  campaign_id = p_campaign_id
        for update;

        if l_status != 'DRAFT' then
            raise_application_error(-20105, 'Only a DRAFT campaign can be approved.');
        end if;

        update recall_campaigns
        set    status = 'APPROVED',
               approved_by = upper(p_actor),
               approved_at = systimestamp
        where  campaign_id = p_campaign_id;

        update recall_campaign_recipients
        set    notice_status = 'APPROVED',
               refund_status = 'READY_FOR_PROCESSING'
        where  campaign_id = p_campaign_id;

        insert into recall_refund_intents(
            campaign_id, purchase_id, customer_id, refund_amount
        )
        select r.campaign_id, r.purchase_id, r.customer_id, r.refund_amount
        from   recall_campaign_recipients r
        where  r.campaign_id = p_campaign_id
        and    not exists (
                   select 1
                   from recall_refund_intents i
                   where i.campaign_id = r.campaign_id
                   and   i.purchase_id = r.purchase_id
               );

        insert into recall_campaign_audit(
            campaign_id, batch_id, actor_name, action_name, detail_text
        ) values (
            p_campaign_id, l_batch_id, upper(p_actor), 'CAMPAIGN_APPROVED',
            'Notice delivery and refund intents are ready for an external review or provider.'
        );
        commit;
        return status(l_batch_id, upper(p_actor));
    exception
        when no_data_found then
            raise_application_error(-20106, 'Campaign not found.');
    end approve_campaign;

    function status(
        p_batch_id in varchar2,
        p_actor    in varchar2
    ) return clob is
        l_batch_id varchar2(20) := upper(trim(p_batch_id));
        l_result clob;
    begin
        select json_serialize(
                   json_object(
                       'batchId' value l_batch_id,
                       'policy' value json_query(policy(l_batch_id), '$' returning json) format json,
                       'campaign' value (
                           select json_object(
                                      'campaignId' value c.campaign_id,
                                      'status' value c.status,
                                      'channel' value c.channel,
                                      'tone' value c.tone,
                                      'templateSource' value c.template_source,
                                      'template' value c.template_text,
                                      'productName' value c.product_name,
                                      'sku' value c.sku,
                                      'recipientCount' value c.recipient_count,
                                      'totalRefund' value c.total_refund,
                                      'createdAt' value to_char(c.created_at, 'YYYY-MM-DD HH24:MI:SS'),
                                      'approvedBy' value c.approved_by,
                                      'approvedAt' value to_char(c.approved_at, 'YYYY-MM-DD HH24:MI:SS'),
                                      'recipients' value (
                                          select coalesce(
                                                     json_arrayagg(
                                                         json_object(
                                                             'purchaseId' value r.purchase_id,
                                                             'customerId' value r.customer_id,
                                                             'customerName' value r.customer_name,
                                                             'email' value r.email,
                                                             'batchId' value r.batch_id,
                                                             'productName' value r.product_name,
                                                             'sku' value r.sku,
                                                             'quantity' value r.quantity,
                                                             'refundAmount' value r.refund_amount,
                                                             'noticeStatus' value r.notice_status,
                                                             'refundStatus' value r.refund_status
                                                             returning json
                                                         ) order by r.purchase_id returning json
                                                     ),
                                                     json('[]')
                                                 )
                                          from recall_campaign_recipients r
                                          where r.campaign_id = c.campaign_id
                                      ) format json
                                      returning json
                                  )
                           from recall_campaigns c
                           where c.batch_id = l_batch_id
                           and   (
                                     upper(p_actor) = 'RECALL_LEAD_USER'
                                     or c.end_user_name = upper(p_actor)
                                 )
                           order by c.created_at desc
                           fetch first 1 row only
                       ) format json
                       returning json
                   ) returning clob
               )
        into l_result
        from dual;
        return l_result;
    end status;
end recall_campaign_bridge;
/


create or replace package recall_campaign_api authid current_user as
    function status(p_batch_id in varchar2 default 'B-482') return clob;
    function authorize_contact(p_batch_id in varchar2 default 'B-482') return clob;
    function draft_campaign(
        p_batch_id in varchar2 default 'B-482',
        p_channel  in varchar2 default 'EMAIL',
        p_tone     in varchar2 default 'PROFESSIONAL'
    ) return clob;
    function customer_options(p_batch_id in varchar2 default 'B-482') return clob;
    function personalize_campaign(
        p_campaign_id in number,
        p_purchase_id in number
    ) return clob;
    function approve_campaign(p_campaign_id in number) return clob;
end recall_campaign_api;
/

create or replace package body recall_campaign_api as
    function current_user return varchar2 is
        l_user varchar2(128);
    begin
        select upper(json_value(ora_end_user_context, '$.USERNAME' returning varchar2(128)))
        into l_user
        from dual;
        if l_user not in ('STORE_101_USER', 'REGION_NE_USER', 'RECALL_LEAD_USER') then
            raise_application_error(-20107, 'No supported recall persona is active.');
        end if;
        return l_user;
    end current_user;

    function context(p_batch_id in varchar2) return clob is
        l_batch_id varchar2(20) := upper(trim(p_batch_id));
        l_user varchar2(128) := current_user;
        l_policy clob;
        l_result clob;
    begin
        l_policy := recall_campaign_bridge.policy(l_batch_id);
        select json_serialize(
                   json_object(
                       'batchId' value b.batch_id,
                       'productName' value p.product_name,
                       'sku' value p.sku,
                       'recipientCount' value (
                           select count(*)
                           from purchases pu
                           join customers cu on cu.customer_id = pu.customer_id
                           where pu.batch_id = l_batch_id
                       ),
                       'totalRefund' value (
                           select coalesce(sum(pu.quantity), 0) *
                                  json_value(l_policy, '$.unitRefundAmount' returning number)
                           from purchases pu
                           join customers cu on cu.customer_id = pu.customer_id
                           where pu.batch_id = l_batch_id
                       ),
                       'policy' value json_query(l_policy, '$' returning json) format json,
                       'activeUser' value l_user
                       returning json
                   ) returning clob
               )
        into l_result
        from batches b
        join products p on p.product_id = b.product_id
        where b.batch_id = l_batch_id;
        return l_result;
    exception
        when no_data_found then
            return json_serialize(
                       json_object(
                           'error' value 'UNKNOWN_BATCH',
                           'batchId' value l_batch_id
                           returning json
                       ) returning clob
                   );
    end context;

    function status(p_batch_id in varchar2 default 'B-482') return clob is
    begin
        return recall_campaign_bridge.status(p_batch_id, current_user);
    end status;

    function authorize_contact(p_batch_id in varchar2 default 'B-482') return clob is
    begin
        return recall_campaign_bridge.authorize_contact(p_batch_id, current_user);
    end authorize_contact;

    function draft_campaign(
        p_batch_id in varchar2 default 'B-482',
        p_channel  in varchar2 default 'EMAIL',
        p_tone     in varchar2 default 'PROFESSIONAL'
    ) return clob is
        l_user       varchar2(128) := current_user;
        l_context    clob;
        l_policy     clob;
        l_template   clob;
        l_campaign_id number;
        l_authorized varchar2(5);
        l_product    varchar2(200);
        l_sku        varchar2(80);
        l_count      number;
        l_steps      varchar2(2000);
    begin
        l_context := context(p_batch_id);
        l_authorized := json_value(l_context, '$.policy.contactAuthorized' returning varchar2(5));
        if l_authorized != 'true' then
            return json_serialize(
                       json_object(
                           'error' value 'CONTACT_NOT_AUTHORIZED',
                           'message' value 'The recall response lead must authorize customer contact before drafting notices.',
                           'context' value json_query(l_context, '$' returning json) format json
                           returning json
                       ) returning clob
                   );
        end if;

        l_product := json_value(l_context, '$.productName' returning varchar2(200));
        l_sku := json_value(l_context, '$.sku' returning varchar2(80));
        l_count := json_value(l_context, '$.recipientCount' returning number);
        l_steps := json_value(l_context, '$.policy.refundSteps' returning varchar2(2000));
        l_template := recall_campaign_bridge.generate_template(
            p_batch_id, l_product, l_sku, l_count, l_steps,
            upper(p_channel), upper(p_tone)
        );
        l_campaign_id := recall_campaign_bridge.create_draft(
            l_user, p_batch_id, p_channel, p_tone, l_context, l_template
        );
        return recall_campaign_bridge.status(p_batch_id, l_user);
    end draft_campaign;

    function customer_options(p_batch_id in varchar2 default 'B-482') return clob is
        l_batch_id varchar2(20) := upper(trim(p_batch_id));
        l_policy clob := recall_campaign_bridge.policy(l_batch_id);
        l_unit_refund number := json_value(l_policy, '$.unitRefundAmount' returning number);
        l_result clob;
    begin
        if json_value(l_policy, '$.contactAuthorized' returning varchar2(5)) != 'true' then
            raise_application_error(-20110, 'Customer contact must be authorized before loading the customer list.');
        end if;

        select json_serialize(
                   json_object(
                       'batchId' value l_batch_id,
                       'customers' value coalesce(
                           json_arrayagg(
                               json_object(
                                   'purchaseId' value pu.purchase_id,
                                   'customerId' value cu.customer_id,
                                   'customerName' value cu.full_name,
                                   'quantity' value pu.quantity,
                                   'refundAmount' value pu.quantity * l_unit_refund,
                                   'orderReference' value 'PUR-' || pu.purchase_id
                                   returning json
                               ) order by cu.full_name, pu.purchase_id returning json
                           ), json('[]')
                       ) format json
                       returning json
                   ) returning clob
               )
        into l_result
        from purchases pu
        join customers cu on cu.customer_id = pu.customer_id
        where pu.batch_id = l_batch_id;
        return l_result;
    end customer_options;

    function personalize_campaign(
        p_campaign_id in number,
        p_purchase_id in number
    ) return clob is
        l_user varchar2(128) := current_user;
        l_batch_id varchar2(20);
        l_policy clob;
        l_unit_refund number;
        l_recipient clob;
        l_notice clob;
    begin
        l_batch_id := recall_campaign_bridge.campaign_batch(p_campaign_id, l_user);
        l_policy := recall_campaign_bridge.policy(l_batch_id);
        l_unit_refund := json_value(l_policy, '$.unitRefundAmount' returning number);
        select json_serialize(
                   json_object(
                       'purchaseId' value pu.purchase_id,
                       'customerId' value cu.customer_id,
                       'customerName' value cu.full_name,
                       'email' value cu.email,
                       'quantity' value pu.quantity,
                       'refundAmount' value pu.quantity * l_unit_refund
                       returning json
                   ) returning clob
               )
        into l_recipient
        from purchases pu
        join customers cu on cu.customer_id = pu.customer_id
        where pu.purchase_id = p_purchase_id
        and pu.batch_id = l_batch_id;

        l_notice := recall_campaign_bridge.personalize_notice(
            l_user, p_campaign_id, l_recipient
        );
        return json_serialize(
                   json_object(
                       'state' value json_query(recall_campaign_bridge.status(
                           l_batch_id, l_user
                       ), '$' returning json) format json,
                       'personalizedNotice' value json_query(l_notice, '$' returning json) format json
                       returning json
                   ) returning clob
               );
    exception
        when no_data_found then
            raise_application_error(-20111, 'The selected customer order is not available to this DDS persona.');
    end personalize_campaign;

    function approve_campaign(p_campaign_id in number) return clob is
    begin
        return recall_campaign_bridge.approve_campaign(p_campaign_id, current_user);
    end approve_campaign;
end recall_campaign_api;
/


grant execute on recall_campaign_bridge to recall_end_user_login;
/
grant execute on recall_campaign_api to recall_end_user_login;
/

declare
    l_valid_count number;
begin
    select count(*)
    into l_valid_count
    from all_objects
    where owner = 'RECALL_OWNER'
    and object_name in ('RECALL_CAMPAIGN_API', 'RECALL_CAMPAIGN_BRIDGE')
    and object_type in ('PACKAGE', 'PACKAGE BODY')
    and status = 'VALID';
    if l_valid_count <> 4 then
        raise_application_error(-20108, 'Expected four VALID campaign package objects under RECALL_OWNER. Review ALL_ERRORS as ADMIN.');
    end if;
end;
/
