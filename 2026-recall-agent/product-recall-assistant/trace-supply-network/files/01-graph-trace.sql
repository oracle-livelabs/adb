set feedback on
set pagesize 100

prompt ============================================================
prompt 1. Component and sub-vendor trace through SQL property graph
prompt ============================================================

select *
from graph_table (
    recall_graph
    match
        (b is batch)-[u is uses_component]->(cb is component_batch)
        -[m is supplied_from]->(site is supplier_site)
        -[o is operated_by]->(sup is supplier),
        (cb is component_batch)-[t is component_type]->(comp is component)
    where b.batch_id = 'B-482'
    columns (
        b.batch_id              as batch_id,
        comp.component_code     as component_code,
        cb.component_batch_id   as component_batch_id,
        cb.quality_status       as quality_status,
        site.site_code          as supplier_site,
        sup.supplier_name       as supplier_name,
        sup.tier_no             as supplier_tier,
        m.produced_at           as produced_at,
        m.received_at           as received_at,
        u.installed_at          as installed_at
    )
)
order by installed_at;

prompt Expected: 25 component paths, including tier-2 sub-vendor lots.

prompt ============================================================
prompt 2. Exposure paths from affected batch to customers
prompt ============================================================

select *
from graph_table (
    recall_graph
    match
        (b is batch)-[is shipped_as]->(sh is shipment)
        -[d is delivered_to]->(s is store)
        -[p is purchased_by]->(c is customer)
    where b.batch_id = 'B-482'
      and p.batch_id = 'B-482'
    columns (
        b.batch_id      as batch_id,
        sh.shipment_id  as shipment_id,
        s.store_code    as store_code,
        c.customer_id   as customer_id,
        p.purchase_id   as purchase_id,
        d.units_sent    as units_sent
    )
)
order by store_code, customer_id;

prompt Expected: 600 exposure paths across 120 affected stores.

prompt ============================================================
prompt 3. Join component lots to downstream customer exposure
prompt ============================================================

select *
from graph_table (
    recall_graph
    match
        (cb is component_batch)<-[u is uses_component]-(b is batch)
        -[is shipped_as]->(sh is shipment)
        -[d is delivered_to]->(s is store)
        -[p is purchased_by]->(c is customer)
    where cb.component_batch_id = 'CB-TSTAT-77'
      and b.batch_id = 'B-482'
      and p.batch_id = 'B-482'
    columns (
        cb.component_batch_id as component_batch_id,
        s.store_code          as store_code,
        c.customer_id         as customer_id,
        p.purchase_id         as purchase_id,
        u.installed_at        as installed_at,
        d.units_sent          as units_sent
    )
)
order by store_code, customer_id;

prompt Expected: the suspect thermostat lot reaches all 600 exposed customers.
