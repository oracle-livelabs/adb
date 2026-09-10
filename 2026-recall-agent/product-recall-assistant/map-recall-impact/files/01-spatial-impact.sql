set feedback on
set pagesize 100
set long 100000
set longchunksize 100000

prompt ============================================================
prompt 1. Indexed proximity filter for affected stores
prompt ============================================================

select distinct
       a.store_code,
       a.store_name,
       rc.center_name
from   recall_affected_stores_v a
cross  join response_centers rc
where  a.batch_id = 'B-482'
and    sdo_within_distance(
           a.location,
           rc.location,
           'distance=25 unit=km'
       ) = 'TRUE'
order  by a.store_code;

prompt Expected: all 120 affected stores are within 25 km of an authorized
prompt response center or colocated recall desk.

prompt ============================================================
prompt 2. Nearest response center for every affected store
prompt ============================================================

with ranked_centers as (
    select a.store_code,
           a.store_name,
           rc.center_name,
           sdo_geom.sdo_distance(
               a.location,
               rc.location,
               0.00001,
               'unit=km'
           ) as distance_km,
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
    where  a.batch_id = 'B-482'
)
select store_code,
       store_name,
       center_name,
       round(distance_km, 1) as distance_km
from   ranked_centers
where  rn = 1
order  by store_code;

prompt Expected center assignments:
prompt BOS-01/CAM-01/PVD-01/HFD-01 -> Boston Recall Center
prompt NYC-01/NWK-01 -> New York Recall Center
prompt PHL-01 -> Philadelphia Recall Center
prompt CHI-01/MKE-01 -> Chicago Recall Center
prompt DET-01 -> Detroit Recall Center
prompt Generated stores -> their colocated Recall Desk

prompt ============================================================
prompt 3. Component supplier and sub-vendor locations
prompt ============================================================

select distinct
       t.component_code,
       t.component_batch_id,
       t.supplier_name,
       t.site_code,
       t.city || ', ' || t.state_code as site_location,
       t.quality_status,
       t.produced_at,
       t.received_at
from   recall_component_trace_v t
where  t.batch_id = 'B-482'
order  by t.produced_at;

prompt Expected: 25 component batches across 25 supplier/sub-vendor sites.

prompt ============================================================
prompt 4. Map-ready GeoJSON for affected stores
prompt ============================================================

select json_serialize(
           json_object(
               'type' value 'FeatureCollection',
               'features' value json_arrayagg(
                   json_object(
                       'type' value 'Feature',
                       'id' value a.store_id,
                       'geometry' value
                           json(sdo_util.to_geojson(a.location)),
                       'properties' value json_object(
                           'storeCode' value a.store_code,
                           'storeName' value a.store_name,
                           'region' value a.region_code,
                           'unitsSent' value a.units_sent
                           returning json
                       )
                       returning json
                   )
                   order by a.store_code
                   returning json
               )
               returning json
           )
           returning clob pretty
       ) as affected_store_geojson
from   recall_affected_stores_v a
where  a.batch_id = 'B-482';

prompt Expected: one FeatureCollection containing 120 store features.

prompt ============================================================
prompt 5. Map-ready GeoJSON for component supplier sites
prompt ============================================================

select json_serialize(
           json_object(
               'type' value 'FeatureCollection',
               'features' value json_arrayagg(
                   json_object(
                       'type' value 'Feature',
                       'id' value t.supplier_site_id,
                       'geometry' value
                           json(sdo_util.to_geojson(t.location)),
                       'properties' value json_object(
                           'componentCode' value t.component_code,
                           'componentBatchId' value t.component_batch_id,
                           'supplier' value t.supplier_name,
                           'siteCode' value t.site_code,
                           'qualityStatus' value t.quality_status
                           returning json
                       )
                       returning json
                   )
                   order by t.supplier_site_id
                   returning json
               )
               returning json
           )
           returning clob pretty
       ) as component_site_geojson
from   recall_component_trace_v t
where  t.batch_id = 'B-482';

prompt Expected: one FeatureCollection containing 25 supplier-site features.
