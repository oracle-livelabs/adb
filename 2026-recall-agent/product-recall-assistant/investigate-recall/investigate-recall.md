# Lab 1: Decide Whether to Open the Case: Shape the Recall Evidence with JSON

## Introduction

Kevin's first question is simple: “Do we have enough evidence to open the B-482 case, and what could this mean for returns?” He has a report from a source application, not a clean spreadsheet, and he needs the decision to remain traceable after the team starts acting.

David's design is to keep the incoming report as JSON beside the operational recall records. The flexible report can retain its observations and workflow fields, while SQL connects the fields that matter to products, component lots, stores, shipments, and exposure. Nothing needs to be copied into a separate document system before the investigation begins.

Tim implements that design. He shows Kevin how native JSON preserves the report, how `JSON_VALUE` and `JSON_TABLE` expose the evidence SQL needs, and how `JSON_TRANSFORM` changes the workflow state without rebuilding the document. In the tasks, Tim opens the case and verifies the scope from the same database.

By the end of the lab, Kevin has a traceable open case for `B-482`: 120 affected stores, 2,400 units, 600 potentially exposed customers, 25 component batches, and 25 supplier sites. That decision becomes the evidence base for David's next design step.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

- Inspect a reported case stored in a native `JSON` column.
- Open the case by updating its JSON workflow state and relational status.
- Confirm the expanded recall scope across stores, units, customers, components, and supplier sites.
- Use `JSON_TABLE` to project product components from a JSON array.
- Use `JSON_VALUE` to read component-batch and complaint observations.
- Keep the learner workflow on `RECALL_OWNER`, not `ADMIN`.

## Task 1: Inspect the Reported Case JSON

Kevin needs to see the report before he authorizes work. David keeps the original JSON as evidence; Tim starts by inspecting it.

1. Sign in to **Database Actions** as `RECALL_OWNER` and select **SQL**. Open a new worksheet. Do not use `ADMIN` for learner tasks.

2. Confirm the connected identity.

    ```sql
    <copy>
    select user as connected_user;
    </copy>
    ```

    Continue only when the query returns `RECALL_OWNER`.

3. Confirm that `CASE_DATA` uses the Oracle native `JSON` data type.

    ```sql
    <copy>
    select table_name,
           column_name,
           data_type
    from   user_tab_columns
    where  table_name = 'RECALL_INVESTIGATIONS'
    and    column_name = 'CASE_DATA';
    </copy>
    ```

    The result identifies `CASE_DATA` as `JSON`, not a text column containing JSON-looking data.

4. Display the JSON document that arrived from the quality-monitoring workflow.

    ```sql
    <copy>
    select case_id,
           case_status,
           json_serialize(case_data returning clob pretty) as case_json
    from   recall_investigations
    where  case_id = 'CASE-B482-2026';
    </copy>
    ```

    The relational case status is `REVIEW`. Inside the document, `workflowState` is `REPORTED`. The JSON also contains the batch, source, and reported time. Its three quality signals describe the incident. Customer contact is not authorized.

## Task 2: Open the Investigation by Updating JSON

Kevin needs a recorded decision, not an informal status change. David requires the source report and operational state to stay aligned; Tim updates both in one transaction.

1. Update the case row. `JSON_TRANSFORM` changes the workflow state and adds audit fields. It preserves the rest of the document.

    ```sql
    <copy>
    update recall_investigations
    set    case_status = 'OPEN',
           opened_at = systimestamp,
           opened_by = user,
           case_data = json_transform(
               case_data,
               set '$.workflowState' = 'OPEN',
               set '$.openedBy' = user,
               set '$.openedAt' = to_char(
                   systimestamp,
                   'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM'
               )
           )
    where  case_id = 'CASE-B482-2026'
    and    batch_id = 'B-482'
    and    case_status = 'REVIEW'
    and    json_value(case_data, '$.workflowState') = 'REPORTED';

    update batches b
    set    recall_status = 'INVESTIGATING',
           issue_code = 'THERMAL-ODOR',
           issue_summary =
               'Reports of overheating, electrical odor, and early shutoff.'
    where  b.batch_id = 'B-482'
    and    exists (
               select 1
               from   recall_investigations i
               where  i.case_id = 'CASE-B482-2026'
               and    i.batch_id = b.batch_id
               and    i.case_status = 'OPEN'
               and    json_value(i.case_data, '$.workflowState') = 'OPEN'
           );

    commit;
    </copy>
    ```

    The first update changes JSON workflow metadata and approved relational columns. The second makes the batch status available to later labs.

2. Verify the relational and JSON states together.

    ```sql
    <copy>
    select i.case_id,
           i.case_status,
           b.recall_status,
           json_value(i.case_data, '$.workflowState')
               as json_workflow_state,
           json_value(i.case_data, '$.openedBy')
               as json_opened_by,
           json_value(i.case_data, '$.openedAt')
               as json_opened_at,
           json_serialize(i.case_data returning clob pretty) as case_json
    from   recall_investigations i
    join   batches b on b.batch_id = i.batch_id
    where  i.case_id = 'CASE-B482-2026';
    </copy>
    ```

    The case is `OPEN`, the batch is `INVESTIGATING`, and the JSON workflow state is `OPEN`. The JSON opening user is `RECALL_OWNER`.

## Task 3: Confirm the Larger Recall Scope

Kevin asks what the decision means for the returns operation. David defines scope as stores, units, customers, components, and suppliers; Tim verifies each figure.

1. Count the affected stores, shipped units, exposed customers, component batches, and supplier sites.

    ```sql
    <copy>
    select count(*) as affected_store_count,
           sum(units_sent) as units_sent
    from   recall_affected_stores_v
    where  batch_id = 'B-482';

    select count(distinct customer_id) as exposed_customer_count
    from   recall_customer_exposure_v
    where  batch_id = 'B-482';

    select count(*) as component_batch_count,
           count(distinct supplier_site_id) as supplier_site_count
    from   recall_component_trace_v
    where  batch_id = 'B-482';
    </copy>
    ```

    Your result should show:

    | Measure | Expected value |
    |---|---:|
    | Affected stores | 120 |
    | Units sent | 2,400 |
    | Exposed customers | 600 |
    | Component batches | 25 |
    | Supplier sites | 25 |

2. The three results above form the Lab 1 checkpoint.

## Task 4: Project Product Components from JSON

Kevin needs product detail without a new data pipeline. David keeps flexible components in JSON; Tim projects only the fields the investigation needs.

1. Use `JSON_TABLE` to turn the product component array into relational rows.

    ```sql
    <copy>
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
    </copy>
    ```

    The query returns 25 major components and traceable sub-parts. These include the thermostat, liner, power cord, thermal sensor, and contact set.

2. Explain why JSON fits this part of the model:

    - Product component attributes can vary by product family.
    - The recall still joins component batches through relational keys.
    - JSON keeps flexible product and complaint data close to the records that use it.

## Task 5: Read Component and Complaint JSON

Kevin needs the supporting observations beside the scope. David connects JSON to relational trace data; Tim reads both as evidence.

1. Inspect component-batch JSON attributes, including supplier certificate and sub-vendor lot details.

    ```sql
    <copy>
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
    </copy>
    ```

    The result contains 25 installed lots. The curated thermostat and thermal-sensor lots show `SUSPECT`. Generated sub-parts add `WATCH` and `SUSPECT` data with certificates, sub-vendor lots, and timestamps.

2. Read structured complaint observations and narrative text.

    ```sql
    <copy>
    select c.complaint_id,
           json_value(c.complaint_data, '$.severity') as severity,
           json_value(c.complaint_data, '$.symptom') as symptom,
           json_value(c.complaint_data, '$.observations.odor') as odor,
           json_value(c.complaint_data, '$.narrative') as narrative
    from   complaints c
    where  c.reported_batch = 'B-482'
       or  c.customer_id in (
               select customer_id
               from   recall_customer_exposure_v
               where  batch_id = 'B-482'
           )
    order  by c.complaint_id;
    </copy>
    ```

    Complaint `9005` is absent because it belongs to batch `B-900`. Complaints `9002` and `9007` came from customers who bought `B-482`. Those complaints did not name the batch.

You have completed Lab 1. Lab 2 uses Oracle Spatial to map the same stores and supplier sites.

## Troubleshooting

| Symptom | Likely cause | Recovery |
|---|---|---|
| The case already shows `OPEN` | The JSON update ran earlier | Continue, or ask the facilitator to restore `REVIEW` and `REPORTED`. |
| The case update affects zero rows | The row is not in the seeded review state | Inspect `CASE_STATUS` and `$.workflowState`, then ask the facilitator to reset the case. |
| Connected user is not `RECALL_OWNER` | Wrong Database Actions session | Sign out and reconnect as `RECALL_OWNER`. |
| Object or view does not exist | The prepared workshop environment is incomplete | Ask the facilitator to verify the backend deployment. |
| Component counts are zero | The B-482 data is not in the prepared state | Ask the facilitator to verify the backend deployment. |
| Your result differs from the checkpoint | Seed data changed | Ask the facilitator to restore the prepared B-482 data. |

For recovery, ask the facilitator to restore the prepared B-482 data.

## Learn More

- [JSON in Oracle AI Database](https://docs.oracle.com/en/database/oracle/oracle-database/26/adjsn/overview-json-oracle-ai-database.html)
- [JSON_TABLE SQL function](https://docs.oracle.com/en/database/oracle/oracle-database/26/adjsn/columns-clause-sql-json-function-json_table.html)

## Acknowledgements

- **Author:** Tim Cline, Product Management Architect
- Contributors: David Start, Director and Kevin Lazarz, Senior Manager
- **Last updated:** October 2026
