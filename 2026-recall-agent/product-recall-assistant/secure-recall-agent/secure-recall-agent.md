# Lab 7: Give Each User the Right Recall Scope with Deep Data Security

## Introduction

Kevin wants store staff, regional managers, and the recall lead to use the same returns application. But a store employee should not see another store's customers or complaints. A regional manager needs a wider view, and the recall lead needs the company-wide picture.

David keeps those access rules in Oracle AI Database, alongside the records and complaint vectors. The same rules limit ordinary queries and vector searches before information reaches the assistant. The application does not need a separate set of filters for each search method.

Tim has prepared the code that gathers recall facts and sends them to the assistant. You will build the access rules, assign them to three users, and compare their results. The assistant does not decide what a user may see; it receives only the evidence the database permits.

Estimated Time: 25 minutes

### Objectives

- Define store, regional, and company-wide access with data roles.
- Apply those rules to related customers, shipments, complaints, and vectors.
- Run identical queries as three users and compare the results.
- Give the assistant each user's permitted evidence and check its answer.

## Task 1: Define Who Can See Which Stores

Kevin describes three responsibilities. David turns them into three data roles. Tim starts with the stores each role may see.

The workshop already includes local end users STORE_101_USER, REGION_NE_USER, and RECALL_LEAD_USER, using the workshop password. You will assign their data roles after defining the rules. They are database end users, not additional application schemas.

1. Connect as **RECALL_OWNER**. Create the Store 101 data role.

    ```sql
    <copy>
    create or replace data role recall_store_101_data_role;
    </copy>
    ```

2. Create the Northeast data role.

    ```sql
    <copy>
    create or replace data role recall_region_ne_data_role;
    </copy>
    ```

3. Create the recall lead data role.

    ```sql
    <copy>
    create or replace data role recall_lead_data_role;
    </copy>
    ```

4. Give each data role the prepared login role. It provides connection and approved package privileges, not unrestricted table access.

    ```sql
    <copy>
    grant recall_end_user_login to recall_store_101_data_role;
    grant recall_end_user_login to recall_region_ne_data_role;
    grant recall_end_user_login to recall_lead_data_role;
    </copy>
    ```

5. Allow only Store 101.

    ```sql
    <copy>
    create or replace data grant recall_owner.dg_store_101_stores
    as select on recall_owner.stores
    where store_id = 101
    to recall_store_101_data_role;
    </copy>
    ```

6. Allow stores marked NORTHEAST in this workshop dataset.

    ```sql
    <copy>
    create or replace data grant recall_owner.dg_region_ne_stores
    as select on recall_owner.stores
    where region_code = 'NORTHEAST'
    to recall_region_ne_data_role;
    </copy>
    ```

7. Allow all stores for the recall lead. This grant has no row filter.

    ```sql
    <copy>
    create or replace data grant recall_owner.dg_lead_stores
    as select on recall_owner.stores
    to recall_lead_data_role;
    </copy>
    ```

## Task 2: Apply the Rules to Related Records

Hiding a store is not enough if its customers or complaints remain visible. David follows the relationships between the records. Tim makes the permitted stores determine the related records each user can read.

Stay connected as **RECALL_OWNER**. Run each block separately.

1. Limit customers to those whose home store is visible.

    ```sql
    <copy>
    create or replace data grant recall_owner.dg_store_customers
    as select on recall_owner.customers
    where home_store_id in (select store_id from recall_owner.stores)
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;
    </copy>
    ```

2. Limit purchases to visible stores.

    ```sql
    <copy>
    create or replace data grant recall_owner.dg_store_purchases
    as select on recall_owner.purchases
    where store_id in (select store_id from recall_owner.stores)
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;
    </copy>
    ```

3. Limit shipment items to visible stores. This also limits the units counted for each user.

    ```sql
    <copy>
    create or replace data grant recall_owner.dg_store_shipment_items
    as select on recall_owner.shipment_items
    where store_id in (select store_id from recall_owner.stores)
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;
    </copy>
    ```

4. Allow shipment headers only when a related shipment item is visible.

    ```sql
    <copy>
    create or replace data grant recall_owner.dg_store_shipments
    as select on recall_owner.shipments
    where shipment_id in (
        select shipment_id from recall_owner.shipment_items
    )
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;
    </copy>
    ```

5. Limit complaints to visible customers.

    ```sql
    <copy>
    create or replace data grant recall_owner.dg_customer_complaints
    as select on recall_owner.complaints
    where customer_id in (select customer_id from recall_owner.customers)
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;
    </copy>
    ```

6. Limit searchable chunks to visible complaints. A hidden complaint must not reappear through vector search.

    ```sql
    <copy>
    create or replace data grant recall_owner.dg_complaint_chunks
    as select on recall_owner.complaint_chunks
    where complaint_id in (select complaint_id from recall_owner.complaints)
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;
    </copy>
    ```

7. Share product, batch, response instructions, search question, and response-center reference records. These facts help every role understand the recall without granting customer access.

    ```sql
    <copy>
    create or replace data grant recall_owner.dg_products_read
    as select on recall_owner.products
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_batches_read
    as select on recall_owner.batches
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_actions_read
    as select on recall_owner.recall_actions
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_queries_read
    as select on recall_owner.recall_queries
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_response_centers_read
    as select on recall_owner.response_centers
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;
    </copy>
    ```

8. Share component and supplier reference records. These describe the recalled product and support Lab 8 supply-chain queries.

    ```sql
    <copy>
    create or replace data grant recall_owner.dg_suppliers_read
    as select on recall_owner.suppliers
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_supplier_sites_read
    as select on recall_owner.supplier_sites
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_components_read
    as select on recall_owner.components
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_component_batches_read
    as select on recall_owner.component_batches
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_batch_components_read
    as select on recall_owner.batch_components
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_component_site_edges_read
    as select on recall_owner.component_batch_site_edges
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_component_type_edges_read
    as select on recall_owner.component_batch_component_edges
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;

    create or replace data grant recall_owner.dg_supplier_site_edges_read
    as select on recall_owner.supplier_site_edges
    to recall_store_101_data_role, recall_region_ne_data_role, recall_lead_data_role;
    </copy>
    ```

9. Switch to **ADMIN** and assign one data role to each end user.

    ```sql
    <copy>
    grant data role recall_store_101_data_role to store_101_user;
    grant data role recall_region_ne_data_role to region_ne_user;
    grant data role recall_lead_data_role to recall_lead_user;
    </copy>
    ```

10. Verify the assignments. Expect three rows, one matching role per user.

    ```sql
    <copy>
    select grantee, data_role
    from   dba_data_role_grants
    where  grantee in ('STORE_101_USER', 'REGION_NE_USER', 'RECALL_LEAD_USER')
    order  by grantee;
    </copy>
    ```

## Task 3: Test the Same Queries as Three Users

Kevin wants proof that changing the signed-in user changes the result without changing the application query. Tim tests database results before asking the assistant anything.

Use a direct database connection, such as SQLcl or SQL Developer desktop, for these local end users. Use the same database connection details as RECALL_OWNER, with the end-user name and workshop password. Check Step 1 after every login. Do not use an ADMIN session or change only the current schema.

1. Connect as **STORE_101_USER** and confirm the end-user identity.

    ```sql
    <copy>
    select json_value(ora_end_user_context, '$.USERNAME'
                      returning varchar2(128)) as end_user;
    </copy>
    ```

    Expect STORE_101_USER. If it is null or different, correct the connection before continuing.

2. Check the active data role.

    ```sql
    <copy>
    select role_name
    from   v$end_user_data_role
    order  by role_name;
    </copy>
    ```

    Expect RECALL_STORE_101_DATA_ROLE.

3. Count the affected stores and units visible to this user.

    ```sql
    <copy>
    select count(distinct si.store_id) as affected_stores,
           coalesce(sum(si.units_sent), 0) as units_sent
    from   shipments sh
    join   shipment_items si on si.shipment_id = sh.shipment_id
    where  sh.batch_id = 'B-482';
    </copy>
    ```

    Expect **1 store and 12 units**.

4. Count the potentially exposed customers visible to this user.

    ```sql
    <copy>
    select count(distinct customer_id) as customers
    from   purchases
    where  batch_id = 'B-482';
    </copy>
    ```

    Expect **5 customers**.

5. Search for the strongest permitted complaint matches. The search uses the vector from Lab 4; access rules determine which complaint chunks are available to search.

    ```sql
    <copy>
    select cc.complaint_id,
           round(vector_distance(cc.embedding, q.query_vector, cosine), 4) as distance,
           cc.chunk_text
    from   complaint_chunks cc
    cross  join recall_queries q
    where  q.query_key = 'HEAT_ODOR'
    and    vector_distance(cc.embedding, q.query_vector, cosine) < 0.70
    order  by distance
    fetch first 5 rows only;
    </copy>
    ```

    Expect complaint 9001. The distance ceiling excludes weak matches.

6. Test a specific complaint outside Store 101's scope.

    ```sql
    <copy>
    select complaint_id, chunk_text
    from   complaint_chunks
    where  complaint_id = 9003;
    </copy>
    ```

    Expect **no rows**. This is a successful security check, not missing seed data.

7. Reconnect as **REGION_NE_USER** and repeat Steps 1–6 without changing the SQL. Expect the Northeast data role, **24 stores, 453 units, and 120 customers**, with semantic matches 9001, 9002, and 9006. Complaint 9003 remains outside this workshop region's scope.

8. Reconnect as **RECALL_LEAD_USER** and repeat Steps 1–6. Expect the lead data role, **120 stores, 2,400 units, and 600 customers**. Semantic matches include 9001, 9002, 9006, 9003, and 9007. Step 6 now returns complaint 9003.

## Task 4: Give the Assistant Only Permitted Evidence

Kevin wants the assistant to explain those same results. The prepared RECALL_SECURE_API package gathers facts using the caller's data roles. Its capture function stores that filtered document for an owner-side service to summarize. The service does not repeat the queries with wider access.

RECALL_AGENT_BRIDGE and RECALL_SECURED_TEAM already exist. The team has no retrieval tools: it summarizes the supplied evidence. These prepared components also support the application in Lab 8.

1. Connect as **STORE_101_USER**. Preview the document the assistant will receive.

    ```sql
    <copy>
    select json_serialize(
               recall_secure_api.get_secured_context('B-482')
               returning clob pretty
           ) as authorized_evidence;
    </copy>
    ```

    Open the CLOB value to read the full JSON. Compare endUser, affectedStoreCount, unitsSent, customerExposureCount, and semanticComplaints with Task 3. Customer names and email fields are excluded; complaint text still needs the same access protection as its source records.

2. Capture this user's evidence. Run this block as a script. Enable DBMS Output for the connection to see the request ID.

    ```sql
    <copy>
    declare
        l_request_id number;
    begin
        l_request_id := recall_secure_api.capture_secured_context('B-482');
        dbms_output.put_line('Captured request ID: ' || l_request_id);
    end;
    /
    </copy>
    ```

    This stores and commits a snapshot; it does not change the recall case. Run capture as the end user, not RECALL_OWNER.

3. Repeat Steps 1–2 as **REGION_NE_USER**, then as **RECALL_LEAD_USER**. Each login produces a separate snapshot with its own permitted counts and complaints.

4. Reconnect as **RECALL_OWNER** and confirm that all three users captured evidence.

    ```sql
    <copy>
    select end_user_name, max(request_id) as latest_request_id
    from   recall_authorized_requests
    where  batch_id = 'B-482'
    and    end_user_name in ('STORE_101_USER', 'REGION_NE_USER', 'RECALL_LEAD_USER')
    group  by end_user_name
    order  by end_user_name;
    </copy>
    ```

    Expect three rows. Capture any missing user's evidence before continuing.

5. Ask the assistant to summarize the latest Store 101 snapshot.

    ```sql
    <copy>
    select recall_agent_bridge.summarize_context(
               json_serialize(context_json returning clob)
           ) as agent_answer
    from   recall_authorized_requests
    where  request_id = (
               select max(request_id)
               from   recall_authorized_requests
               where  batch_id = 'B-482'
               and    end_user_name = 'STORE_101_USER'
           );
    </copy>
    ```

    The response appears in **AGENT_ANSWER**. Open the CLOB cell for the full answer. This sends the captured evidence to the configured OCI Generative AI service.

6. Run Step 5 twice more, changing only STORE_101_USER to REGION_NE_USER, then RECALL_LEAD_USER. Compare the answers with these database checkpoints, not an exact sentence.

    | End user | Stores | Units | Customers | Semantic complaint IDs |
    |---|---:|---:|---:|---|
    | STORE_101_USER | 1 | 12 | 5 | 9001 |
    | REGION_NE_USER | 24 | 453 | 120 | 9001, 9002, 9006 |
    | RECALL_LEAD_USER | 120 | 2,400 | 600 | 9001, 9002, 9006, 9003, 9007 |

    All roles share 25 component batches and 25 supplier sites. The first response remains quarantine and stop sales; customer contact is not yet authorized. Reject answers that invent facts or expand beyond the supplied evidence. Access filtering does not eliminate model errors.

## Conclusion

You built the rules that let one returns application serve three responsibilities. The same SQL returned different store, unit, customer, and complaint results because the signed-in users had different data roles.

For Kevin, the application can answer local, regional, and company-wide questions without exposing every record to every user. For David, Oracle AI Database keeps access rules with both business records and complaint vectors. There is no separate vector store requiring another copy of those rules. Tim retrieves permitted evidence before passing it to the assistant; a prompt is not a substitute for database authorization.

Lab 8 uses these packages and data roles in the Recall Command Center.

## Learn More

- [Securing Vector Search with Deep Data Security in Oracle AI Database](https://medium.com/@thomas.minne/securing-vector-search-with-deep-data-security-in-oracle-ai-database-c2fe0c4dd736)
- [Configure direct logon with local end users](https://docs.oracle.com/en/database/oracle/oracle-database/26/ddscg/configure-oracle-deep-data-security-direct-logon-local-end-users.html)
- [Create Deep Data Security data grants](https://docs.oracle.com/en/database/oracle/oracle-database/26/ddscg/create-data-grants.html)
- [End-user security context](https://docs.oracle.com/en/database/oracle/oracle-database/26/ddscg/end-user-security-context.html)

## Acknowledgements

- **Author:** Tim Cline, Product Management Architect
- Contributors: David Start, Director and Kevin Lazarz, Senior Manager
- **Last updated:** October 2026
