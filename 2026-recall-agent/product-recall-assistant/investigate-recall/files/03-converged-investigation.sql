set feedback on
set pagesize 100
set long 100000
set longchunksize 100000

prompt ============================================================
prompt 1. Relational recall scope
prompt ============================================================

select a.store_code,
       a.store_name,
       a.region_code,
       a.units_sent
from   recall_affected_stores_v a
where  a.batch_id = 'B-482'
order  by a.store_code;

select count(*) as affected_store_count,
       sum(units_sent) as units_sent
from   recall_affected_stores_v
where  batch_id = 'B-482';

select count(distinct customer_id) as exposed_customer_count
from   recall_customer_exposure_v
where  batch_id = 'B-482';

prompt Expected: 120 stores, 2,400 units, and 600 exposed customers.

prompt ============================================================
prompt 2. Native JSON product component list
prompt ============================================================

select p.sku,
       jt.component_code,
       jt.component_name,
       jt.criticality
from   products p,
       json_table(
           p.attributes,
           '$.components[*]'
           columns (
               component_code varchar2(40)  path '$.code',
               component_name varchar2(120) path '$.name',
               criticality    varchar2(20)  path '$.criticality'
           )
       ) jt
where  p.sku = 'HEATPRO-200'
order  by jt.component_code;

prompt Expected: 25 JSON-declared major components and traceable sub-parts.

prompt ============================================================
prompt 3. Component batch attributes stored as JSON
prompt ============================================================

select t.component_code,
       t.component_batch_id,
       t.supplier_name,
       t.site_code,
       t.quality_status,
       json_value(cb.attributes, '$.supplierCertificate')
           as supplier_certificate,
       json_value(cb.attributes, '$.subVendorLot')
           as sub_vendor_lot,
       json_value(cb.attributes, '$.calibrationDriftPct' returning number)
           as calibration_drift_pct
from   recall_component_trace_v t
join   component_batches cb
       on cb.component_batch_id = t.component_batch_id
where  t.batch_id = 'B-482'
order  by t.installed_at;

prompt Expected: 25 component batches and 25 supplier/sub-vendor sites.

prompt ============================================================
prompt 4. Native JSON complaint metadata and narrative
prompt ============================================================

select c.complaint_id,
       json_value(c.complaint_data, '$.severity') as severity,
       json_value(c.complaint_data, '$.symptom') as symptom,
       json_value(c.complaint_data, '$.observations.odor') as odor,
       json_value(c.complaint_data, '$.narrative') as narrative
from   complaints c
where  c.reported_batch = 'B-482'
   or  c.customer_id in (
           select e.customer_id
           from recall_customer_exposure_v e
           where e.batch_id = 'B-482'
       )
order  by c.complaint_id;

prompt Expected: B-482 exposure complaints except unrelated B-900 complaint 9005.
