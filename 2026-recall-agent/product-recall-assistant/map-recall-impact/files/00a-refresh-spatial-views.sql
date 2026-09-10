whenever sqlerror exit sql.sqlcode rollback
set feedback on

prompt ============================================================
prompt Product Recall Assistant - Refresh Spatial Recall Views
prompt Run after adding and populating the LOCATION columns.
prompt ============================================================

create or replace view recall_affected_stores_v as
select x.batch_id,
       s.store_id,
       s.store_code,
       s.store_name,
       s.region_code,
       x.units_sent,
       s.longitude,
       s.latitude,
       s.location
from   (
           select sh.batch_id,
                  si.store_id,
                  sum(si.units_sent) as units_sent
           from   shipments sh
           join   shipment_items si on si.shipment_id = sh.shipment_id
           group  by sh.batch_id, si.store_id
       ) x
join   stores s on s.store_id = x.store_id;

create or replace view recall_component_trace_v as
select bc.batch_id,
       bc.component_batch_id,
       c.component_id,
       c.component_code,
       c.component_name,
       c.criticality,
       cb.quality_status,
       cb.supplier_lot_code,
       cb.produced_at,
       cb.received_at,
       bc.installed_at,
       bc.assembly_station,
       ss.supplier_site_id,
       ss.site_code,
       ss.site_name,
       ss.city,
       ss.state_code,
       ss.longitude,
       ss.latitude,
       ss.location,
       s.supplier_id,
       s.supplier_name,
       s.tier_no,
       s.supplier_type
from   batch_components bc
join   component_batches cb
       on cb.component_batch_id = bc.component_batch_id
join   components c
       on c.component_id = cb.component_id
join   supplier_sites ss
       on ss.supplier_site_id = cb.supplier_site_id
join   suppliers s
       on s.supplier_id = ss.supplier_id;

alter package recall_lab_api compile body;

show errors package body recall_lab_api

select object_name, object_type, status
from   user_objects
where  object_name in (
           'RECALL_AFFECTED_STORES_V',
           'RECALL_COMPONENT_TRACE_V',
           'RECALL_LAB_API'
       )
and    object_type != 'PACKAGE'
order  by object_name, object_type;

prompt Spatial recall views and read package are valid.
