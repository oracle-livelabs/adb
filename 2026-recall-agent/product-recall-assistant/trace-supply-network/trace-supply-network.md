# Lab 3: Find the Source and the Reach: Trace Recall Paths with SQL Property Graph

## Introduction

Kevin's next question is, “If we accept returns, what do we need to trace back to, and how far did the suspect path reach?” A component lot, supplier site, store delivery, and customer purchase are related, but a flat table list makes the route hard to explain.

David models the recall as connected business entities over the existing operational tables. The graph does not become a second system of record. It gives the team a way to ask about paths: upstream from B-482 to components and suppliers, or downstream through shipments, stores, purchases, and customers.

Tim creates `RECALL_GRAPH` and uses `GRAPH_TABLE` to query those paths. He explains how the graph definition exposes the relationships while the relational rows remain current. The SQL makes Kevin's traceability question concrete rather than leaving it to manual joins and screenshots.

By the end of the lab, Kevin can see 25 component paths, suspect thermostat and thermal-sensor routes, and 600 downstream exposure paths across 120 stores. David now has the relationship evidence needed for the returns workflow.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

- Create `RECALL_GRAPH` over the recall relational tables.
- Inspect the property graph definition.
- Trace `B-482` to component batches, supplier sites, and suppliers.
- Trace `B-482` to shipments, stores, purchases, and customers.
- Connect a suspect component lot to downstream exposure paths.

## Task 1: Create the Recall Property Graph

Kevin needs the connected path, not another report of disconnected identifiers. David defines the graph over current tables; Tim creates and verifies it.

1. Confirm that Lab 1 did not create the graph early.

    ```sql
    <copy>
    select graph_name
    from   user_property_graphs
    where  graph_name = 'RECALL_GRAPH';
    </copy>
    ```

    Before this task, the query returns no rows. Lab 3 owns graph creation.

2. Create the property graph over the relational tables.

    ```sql
    <copy>
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
    </copy>
    ```

    The graph stores metadata over the existing relational tables. It does not copy the recall data into a separate graph store. `OPTIONS (ENFORCED MODE)` validates the graph keys and references when Oracle creates the graph.

    The block above is the complete rerunnable graph definition.

3. Verify the graph and labels.

    ```sql
    <copy>
    select graph_name
    from   user_property_graphs
    where  graph_name = 'RECALL_GRAPH';

    select label_name
    from   user_pg_labels
    where  graph_name = 'RECALL_GRAPH'
    order  by label_name;
    </copy>
    ```

    The graph includes vertices for batches, shipments, stores, customers, components, component batches, supplier sites, and suppliers. The relational tables and their graph-supporting indexes were prepared during Lab 1. The existing `BATCH_COMPONENTS_UQ` key supports the batch-component edge.

## Task 2: Trace Upstream Component Lots

Kevin asks where the suspect lots came from. David follows the graph upstream; Tim queries the supplier and component paths.

1. Traverse from batch `B-482` to component batches, supplier sites, and suppliers.

    ```sql
    <copy>
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
    </copy>
    ```

    The result returns 25 component paths. It includes the curated thermal sensor and contact-set suppliers plus generated tier-1 and tier-2 sub-vendor lots.

## Task 3: Trace Downstream Exposure

Kevin asks who may have received the affected units. David follows the same graph downstream; Tim traces shipments, stores, and purchases.

1. Traverse from batch `B-482` to shipments, stores, purchases, and customers.

    ```sql
    <copy>
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
    </copy>
    ```

    The graph returns 600 exposure paths across 120 affected stores.

2. Note the modeling choice:

    - Graph paths make relationship questions natural.
    - The base data remains relational and constrained.
    - The graph definition does not copy data into a separate store.

## Task 4: Connect Component Lots to Exposure

Kevin needs one explainable route from cause to exposure. David joins both directions; Tim returns the connected path.

1. Trace the suspect thermostat lot to downstream customers.

    ```sql
    <copy>
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
    </copy>
    ```

    The suspect thermostat lot reaches all 600 exposed customers because batch `B-482` used that lot.

2. The queries in this task provide the graph checkpoints.

You have completed Lab 3. Lab 4 uses AI Vector Search to rank complaint evidence related to heat and odor.

## Troubleshooting

| Symptom | Likely cause | Recovery |
|---|---|---|
| `RECALL_GRAPH` already exists | Task 1 ran earlier | Continue with Task 2. |
| Graph query reports an invalid graph | A base object changed after setup | Run `ALTER PROPERTY GRAPH recall_graph COMPILE`. |
| Graph labels are missing | The Lab 3 graph definition is incomplete | Ask the facilitator to verify the backend deployment, then recheck the graph definition. |
| Exposure path count differs | Seed purchases or shipment items changed | Recheck `purchases` and `recall_affected_stores_v`. |
| Component path count differs | Component trace seed data changed | Recheck `recall_component_trace_v`. |

## Learn More

- [Create a SQL property graph](https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/create-property-graph.html)
- [Oracle Property Graph Developer Guide](https://docs.oracle.com/en/database/oracle/property-graph/26.1/spgdg/)

## Acknowledgements

- **Author:** Tim Cline, Product Management Architect
- Contributors: David Start, Director and Kevin Lazarz, Senior Manager
- **Last updated:** October 2026
