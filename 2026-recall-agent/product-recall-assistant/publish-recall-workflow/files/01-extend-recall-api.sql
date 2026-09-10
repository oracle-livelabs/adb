whenever sqlerror exit sql.sqlcode rollback
set define off
set serveroutput on size unlimited
set feedback on
set long 200000

prompt ============================================================
prompt Product Recall Assistant - Lab 6 Owner API
prompt Connect as RECALL_OWNER.
prompt ============================================================

begin
    if user != 'RECALL_OWNER' then
        raise_application_error(-20031, 'Wrong user: connect as RECALL_OWNER.');
    end if;
end;
/

create or replace package recall_lab_api authid definer as
    function get_recall_context(p_batch_id in varchar2) return clob;
    function get_spatial_impact(p_batch_id in varchar2) return clob;
    function get_affected_stores(p_batch_id in varchar2) return clob;
    function get_component_sites(p_batch_id in varchar2) return clob;
end recall_lab_api;
/

create or replace package body recall_lab_api as
    function get_recall_context(p_batch_id in varchar2) return clob is
        l_result   clob;
        l_batch_id varchar2(20) := upper(trim(p_batch_id));
    begin
        select json_object(
                   'batchId' value b.batch_id,
                   'status' value b.recall_status,
                   'product' value p.product_name,
                   'investigationCaseId' value (
                       select max(i.case_id) keep (dense_rank last order by i.opened_at)
                       from recall_investigations i
                       where i.batch_id = l_batch_id
                       and i.case_status = 'OPEN'
                   ),
                   'affectedStoreCount' value (
                       select count(*) from recall_affected_stores_v a
                       where a.batch_id = l_batch_id
                   ),
                   'unitsSent' value (
                       select sum(a.units_sent) from recall_affected_stores_v a
                       where a.batch_id = l_batch_id
                   ),
                   'customerExposureCount' value (
                       select count(distinct e.customer_id)
                       from recall_customer_exposure_v e
                       where e.batch_id = l_batch_id
                   ),
                   'componentBatchCount' value (
                       select count(*)
                       from recall_component_trace_v t
                       where t.batch_id = l_batch_id
                   ),
                   'supplierSiteCount' value (
                       select count(distinct t.supplier_site_id)
                       from recall_component_trace_v t
                       where t.batch_id = l_batch_id
                   ),
                   'componentTrace' value (
                       select json_arrayagg(
                                  json_object(
                                      'componentCode' value t.component_code,
                                      'componentBatchId' value t.component_batch_id,
                                      'qualityStatus' value t.quality_status,
                                      'supplier' value t.supplier_name,
                                      'supplierSite' value t.site_code,
                                      'supplierTier' value t.tier_no,
                                      'producedAt' value t.produced_at,
                                      'receivedAt' value t.received_at,
                                      'installedAt' value t.installed_at
                                  )
                                  order by t.installed_at
                                  returning clob
                              )
                       from recall_component_trace_v t
                       where t.batch_id = l_batch_id
                   ) format json,
                   'complaintIds' value (
                       select json_arrayagg(x.complaint_id order by x.distance returning clob)
                       from (
                           select cc.complaint_id,
                                  vector_distance(cc.embedding, q.query_vector, cosine)
                                      as distance
                           from complaint_chunks cc
                           join complaints c
                                on c.complaint_id = cc.complaint_id
                           cross join recall_queries q
                           where q.query_key = 'HEAT_ODOR'
                           and (
                               c.reported_batch = l_batch_id
                               or c.customer_id in (
                                   select customer_id
                                   from recall_customer_exposure_v
                                   where batch_id = l_batch_id
                               )
                           )
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
        into l_result
        from batches b
        join products p on p.product_id = b.product_id
        where b.batch_id = l_batch_id;

        return l_result;
    exception
        when no_data_found then
            select json_object(
                       'error' value 'UNKNOWN_BATCH',
                       'batchId' value l_batch_id
                       returning clob
                   )
            into l_result;
            return l_result;
    end get_recall_context;

    function get_spatial_impact(p_batch_id in varchar2) return clob is
        l_result   clob;
        l_batch_id varchar2(20) := upper(trim(p_batch_id));
    begin
        execute immediate q'~
            with nearest_centers as (
                select a.store_id,
                       a.region_code,
                       a.units_sent,
                       rc.center_name,
                       row_number() over (
                           partition by a.store_id
                           order by sdo_geom.sdo_distance(
                               a.location,
                               rc.location,
                               0.00001,
                               'unit=km'
                           )
                       ) as rn
                from   recall_affected_stores_v a
                cross  join response_centers rc
                where  a.batch_id = :batch_id
            ),
            region_summary as (
                select region_code,
                       count(*) as store_count,
                       sum(units_sent) as units_sent
                from   nearest_centers
                where  rn = 1
                group  by region_code
            ),
            center_summary as (
                select center_name,
                       count(*) as store_count,
                       sum(units_sent) as units_sent
                from   nearest_centers
                where  rn = 1
                group  by center_name
            )
            select json_object(
                       'batchId' value :batch_id,
                       'responseRadiusKm' value 25,
                       'affectedStoreCount' value (
                           select count(*)
                           from   nearest_centers
                           where  rn = 1
                       ),
                       'unitsSent' value (
                           select sum(units_sent)
                           from   nearest_centers
                           where  rn = 1
                       ),
                       'storesWithinResponseRadius' value (
                           select count(distinct a.store_id)
                           from   recall_affected_stores_v a
                           cross  join response_centers rc
                           where  a.batch_id = :batch_id
                           and    sdo_within_distance(
                                      a.location,
                                      rc.location,
                                      'distance=25 unit=km'
                                  ) = 'TRUE'
                       ),
                       'regions' value (
                           select json_arrayagg(
                                      json_object(
                                          'region' value region_code,
                                          'storeCount' value store_count,
                                          'unitsSent' value units_sent
                                          returning clob
                                      )
                                      order by region_code
                                      returning clob
                                  )
                           from   region_summary
                       ) format json,
                       'nearestResponseCenters' value (
                           select json_arrayagg(
                                      json_object(
                                          'center' value center_name,
                                          'storeCount' value store_count,
                                          'unitsSent' value units_sent
                                          returning clob
                                      )
                                      order by center_name
                                      returning clob
                                  )
                           from   center_summary
                       ) format json
                       returning clob
                   )~'
        into   l_result
        using  l_batch_id, l_batch_id, l_batch_id;

        return l_result;
    exception
        when no_data_found then
            select json_object(
                       'error' value 'UNKNOWN_BATCH',
                       'batchId' value l_batch_id
                       returning clob
                   )
            into   l_result;

            return l_result;
    end get_spatial_impact;

    function get_affected_stores(p_batch_id in varchar2) return clob is
        l_result   clob;
        l_batch_id varchar2(20) := upper(trim(p_batch_id));
    begin
        select json_object(
                   'type' value 'FeatureCollection',
                   'batchId' value l_batch_id,
                   'features' value coalesce(
                       json_arrayagg(
                           json_object(
                               'type' value 'Feature',
                               'geometry' value json_object(
                                   'type' value 'Point',
                                   'coordinates' value json_array(
                                       a.location.sdo_point.x,
                                       a.location.sdo_point.y
                                   )
                               ),
                               'properties' value json_object(
                                   'storeCode' value a.store_code,
                                   'storeName' value a.store_name,
                                   'region' value a.region_code,
                                   'unitsSent' value a.units_sent
                               )
                           )
                           order by a.store_code
                           returning clob
                       ),
                       to_clob('[]')
                   ) format json
                   returning clob
               )
        into l_result
        from recall_affected_stores_v a
        where a.batch_id = l_batch_id;

        return l_result;
    end get_affected_stores;

    function get_component_sites(p_batch_id in varchar2) return clob is
        l_result   clob;
        l_batch_id varchar2(20) := upper(trim(p_batch_id));
    begin
        select json_object(
                   'type' value 'FeatureCollection',
                   'batchId' value l_batch_id,
                   'features' value coalesce(
                       json_arrayagg(
                           json_object(
                               'type' value 'Feature',
                               'geometry' value json_object(
                                   'type' value 'Point',
                                   'coordinates' value json_array(
                                       t.location.sdo_point.x,
                                       t.location.sdo_point.y
                                   )
                               ),
                               'properties' value json_object(
                                   'componentCode' value t.component_code,
                                   'componentBatchId' value t.component_batch_id,
                                   'supplier' value t.supplier_name,
                                   'supplierSite' value t.site_code,
                                   'supplierTier' value t.tier_no,
                                   'qualityStatus' value t.quality_status
                               )
                           )
                           order by t.supplier_site_id
                           returning clob
                       ),
                       to_clob('[]')
                   ) format json
                   returning clob
               )
        into l_result
        from recall_component_trace_v t
        where t.batch_id = l_batch_id;

        return l_result;
    end get_component_sites;

end recall_lab_api;
/

show errors package body recall_lab_api

grant execute on recall_lab_api to recall_api_role;

prompt --- Verify the Lab 6 package members ---

select procedure_name
from   user_procedures
where  object_name = 'RECALL_LAB_API'
and    procedure_name in (
           'GET_RECALL_CONTEXT',
           'GET_SPATIAL_IMPACT',
           'GET_AFFECTED_STORES',
           'GET_COMPONENT_SITES'
       )
order  by procedure_name;

select json_serialize(
           recall_lab_api.get_recall_context('B-482')
           returning clob pretty
       ) as context_json
;

select json_serialize(
           recall_lab_api.get_spatial_impact('B-482')
           returning clob pretty
       ) as spatial_impact
;

select json_serialize(
           recall_lab_api.get_affected_stores('B-482')
           returning clob pretty
       ) as stores_geojson
;

select json_serialize(
           recall_lab_api.get_component_sites('B-482')
           returning clob pretty
       ) as component_sites_geojson
;

prompt Owner API ready. No customer names or email addresses are returned.
