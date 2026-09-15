whenever sqlerror exit sql.sqlcode rollback
set feedback on
set pagesize 300
set linesize 220
set sqlformat ansiconsole

prompt ============================================================
prompt Product Recall Assistant - Generated Data Validation
prompt Connect as RECALL_OWNER after running 01-owner-setup.sql.
prompt ============================================================

prompt --- Row counts: every seed table must contain at least 100 rows ---

select 'BATCHES' table_name, count(*) row_count from batches
union all select 'BATCH_COMPONENTS', count(*) from batch_components
union all select 'BATCH_SHIPMENTS', count(*) from batch_shipments
union all select 'COMPLAINTS', count(*) from complaints
union all select 'COMPLAINT_CHUNKS', count(*) from complaint_chunks
union all select 'COMPONENTS', count(*) from components
union all select 'COMPONENT_BATCHES', count(*) from component_batches
union all select 'COMPONENT_BATCH_COMPONENT_EDGES', count(*) from component_batch_component_edges
union all select 'COMPONENT_BATCH_SITE_EDGES', count(*) from component_batch_site_edges
union all select 'CUSTOMERS', count(*) from customers
union all select 'PRODUCTS', count(*) from products
union all select 'PURCHASES', count(*) from purchases
union all select 'RECALL_ACTIONS', count(*) from recall_actions
union all select 'RECALL_INVESTIGATIONS', count(*) from recall_investigations
union all select 'RECALL_QUERIES', count(*) from recall_queries
union all select 'RESPONSE_CENTERS', count(*) from response_centers
union all select 'SHIPMENTS', count(*) from shipments
union all select 'SHIPMENT_ITEMS', count(*) from shipment_items
union all select 'STORES', count(*) from stores
union all select 'SUPPLIERS', count(*) from suppliers
union all select 'SUPPLIER_SITES', count(*) from supplier_sites
union all select 'SUPPLIER_SITE_EDGES', count(*) from supplier_site_edges
order by table_name;

prompt --- B-482 converged recall scope ---

select (select count(*)
        from recall_affected_stores_v
        where batch_id = 'B-482') as affected_stores,
       (select sum(units_sent)
        from recall_affected_stores_v
        where batch_id = 'B-482') as units_sent,
       (select count(distinct customer_id)
        from recall_customer_exposure_v
        where batch_id = 'B-482') as exposed_customers,
       (select count(*)
        from recall_component_trace_v
        where batch_id = 'B-482') as component_batches,
       (select count(distinct supplier_site_id)
        from recall_component_trace_v
        where batch_id = 'B-482') as supplier_sites;

prompt Expected: 120 stores, 2,400 units, 600 customers, 25 component batches, 25 supplier sites.

prompt --- Native JSON component projection ---

select count(*) as json_component_count
from   products p,
       json_table(
           p.attributes,
           '$.components[*]'
           columns (component_code varchar2(40) path '$.code')
       ) jt
where  p.sku = 'HEATPRO-200';

prompt Expected: 25 JSON component and sub-part entries.

prompt Vector columns and embeddings are added in Lab 4.

prompt --- Continental U.S. coordinate checkpoint ---

select 'STORES' as location_type,
       count(*) as total_points,
       sum(
           case
               when s.longitude not between -125 and -66
                 or s.latitude not between 24 and 49.5
               then 1 else 0
           end
       ) as outside_continental_bounds,
       min(s.longitude) as min_longitude,
       max(s.longitude) as max_longitude,
       min(s.latitude) as min_latitude,
       max(s.latitude) as max_latitude
from stores s
union all
select 'SUPPLIER_SITES', count(*),
       sum(
           case
               when ss.longitude not between -125 and -66
                 or ss.latitude not between 24 and 49.5
               then 1 else 0
           end
       ),
       min(ss.longitude), max(ss.longitude),
       min(ss.latitude), max(ss.latitude)
from supplier_sites ss;

prompt Expected: zero outside bounds. Generated points use inland U.S. metro anchors.

prompt --- Coordinate readiness checkpoint before Lab 2 ---

select count(*) as coordinate_ready_store_count
from   recall_affected_stores_v a
where  a.batch_id = 'B-482'
and    a.longitude is not null
and    a.latitude is not null;

prompt Expected: 120 stores ready for geometry promotion in Lab 2.

prompt --- Role-scope checkpoints before Deep Data Security policy creation ---

select 'STORE_101_USER' as scope_name,
       (select count(*)
        from recall_affected_stores_v
        where batch_id = 'B-482'
        and store_id = 101) as stores,
       (select sum(units_sent)
        from recall_affected_stores_v
        where batch_id = 'B-482'
        and store_id = 101) as units,
       (select count(distinct customer_id)
        from recall_customer_exposure_v
        where batch_id = 'B-482'
        and store_id = 101) as customers
union all
select 'REGION_NE_USER',
       (select count(*)
        from recall_affected_stores_v
        where batch_id = 'B-482'
        and region_code = 'NORTHEAST'),
       (select sum(units_sent)
        from recall_affected_stores_v
        where batch_id = 'B-482'
        and region_code = 'NORTHEAST'),
       (select count(distinct e.customer_id)
        from recall_customer_exposure_v e
        join stores s on s.store_id = e.store_id
        where e.batch_id = 'B-482'
        and s.region_code = 'NORTHEAST')
union all
select 'RECALL_LEAD_USER',
       (select count(*)
        from recall_affected_stores_v
        where batch_id = 'B-482'),
       (select sum(units_sent)
        from recall_affected_stores_v
        where batch_id = 'B-482'),
       (select count(distinct customer_id)
        from recall_customer_exposure_v
        where batch_id = 'B-482');

prompt Expected: STORE_101_USER 1/12/5, REGION_NE_USER 24/453/120,
prompt and RECALL_LEAD_USER 120/2400/600.

prompt Generated data validation complete.
