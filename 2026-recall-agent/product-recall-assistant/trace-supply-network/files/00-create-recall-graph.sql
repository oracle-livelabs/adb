whenever sqlerror exit sql.sqlcode rollback
set feedback on
set pagesize 100
set linesize 220

prompt ============================================================
prompt Product Recall Assistant - Create the SQL Property Graph
prompt Connect as RECALL_OWNER after Labs 1 and 2.
prompt ============================================================

begin
    if user != 'RECALL_OWNER' then
        raise_application_error(-20050, 'Wrong user: connect as RECALL_OWNER.');
    end if;
end;
/

prompt --- Property graph definition ---

create or replace property graph recall_graph
    vertex tables (
        batches
            key (batch_id)
            label batch
            properties (batch_id, recall_status, issue_code),
        shipments
            key (shipment_id)
            label shipment
            properties (shipment_id, batch_id, shipped_on),
        stores
            key (store_id)
            label store
            properties (store_id, store_code, store_name, region_code),
        customers
            key (customer_id)
            label customer
            properties (customer_id, full_name, home_store_id),
        components
            key (component_id)
            label component
            properties (component_id, component_code, component_name, criticality),
        component_batches
            key (component_batch_id)
            label component_batch
            properties (component_batch_id, quality_status, supplier_lot_code),
        supplier_sites
            key (supplier_site_id)
            label supplier_site
            properties (supplier_site_id, site_code, site_name, city, state_code),
        suppliers
            key (supplier_id)
            label supplier
            properties (supplier_id, supplier_name, tier_no, supplier_type)
    )
    edge tables (
        batch_shipments
            key (batch_shipment_id)
            source key (batch_id) references batches(batch_id)
            destination key (shipment_id) references shipments(shipment_id)
            label shipped_as no properties,
        shipment_items
            key (shipment_item_id)
            source key (shipment_id) references shipments(shipment_id)
            destination key (store_id) references stores(store_id)
            label delivered_to
            properties (shipment_item_id, units_sent),
        purchases as store_to_customer
            key (purchase_id)
            source key (store_id) references stores(store_id)
            destination key (customer_id) references customers(customer_id)
            label purchased_by
            properties (purchase_id, batch_id, purchased_on, quantity),
        batch_components
            key (batch_component_id)
            source key (batch_id) references batches(batch_id)
            destination key (component_batch_id)
                references component_batches(component_batch_id)
            label uses_component
            properties (quantity_per_unit, installed_at, assembly_station),
        component_batch_site_edges
            key (edge_id)
            source key (component_batch_id)
                references component_batches(component_batch_id)
            destination key (supplier_site_id)
                references supplier_sites(supplier_site_id)
            label supplied_from
            properties (supplier_lot_code, produced_at, received_at),
        component_batch_component_edges
            key (edge_id)
            source key (component_batch_id)
                references component_batches(component_batch_id)
            destination key (component_id) references components(component_id)
            label component_type no properties,
        supplier_site_edges
            key (edge_id)
            source key (supplier_site_id)
                references supplier_sites(supplier_site_id)
            destination key (supplier_id) references suppliers(supplier_id)
            label operated_by no properties
    )
    options (enforced mode);

commit;

prompt --- Verify graph metadata ---

select graph_name
from   user_property_graphs
where  graph_name = 'RECALL_GRAPH';

select label_name
from   user_pg_labels
where  graph_name = 'RECALL_GRAPH'
order  by label_name;

prompt Graph creation complete. Relational indexes were created during Lab 1 setup.
prompt BATCH_COMPONENTS_UQ supports the batch-component edge.
prompt GRAPH_TABLE traversal begins in Task 2.
