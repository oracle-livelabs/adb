# Lab 6: Put Trusted Facts in Reach: Publish the Recall API with ORDS

## Introduction

Kevin wants the returns process to reach the field application and trusted partners without handing out database credentials. Store and supplier locations are useful for response work; customer names and the underlying table model are not part of the delivery contract.

David designs a small read-only interface. Owner-owned PL/SQL packages decide what facts and GeoJSON features leave the database. ORDS publishes those functions as authenticated routes, and the runtime user receives package execution rather than application-table access.

Tim extends the package with the returns context, spatial summary, affected-store GeoJSON, and component-site GeoJSON. He then verifies the package grants and API responses. The SQL makes the contract visible: applications receive a stable response shape, not an invitation to query the schema.

By the end of the lab, Kevin's application path can retrieve approved JSON and GeoJSON through authenticated endpoints. Anonymous requests stop at `401 Unauthorized`, and the responses contain no customer names or email addresses.

Estimated Time: 12 minutes

### Objectives

In this lab, you will:

- Extend the owner API with affected-store GeoJSON.
- Extend the owner API with component supplier-site GeoJSON.
- Publish authenticated, read-only ORDS handlers.
- Test JSON and spatial responses.
- Verify that runtime credentials and customer PII remain protected.

## Task 1: Extend the Approved Database Interface

Kevin needs an application contract, not table access. David puts approved facts behind a package; Tim extends and tests that interface.

1. Connect as `RECALL_OWNER` and run the package definition below.

    ```sql
    <copy>
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
    </copy>
    ```

    The script adds `GET_SPATIAL_IMPACT`, `GET_AFFECTED_STORES`, and `GET_COMPONENT_SITES` while preserving `GET_RECALL_CONTEXT`. It returns a compact spatial summary plus GeoJSON point features for affected store locations and component supplier sites.

2. Confirm that the Lab 6 package specification is installed.

    ```sql
    <copy>
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
    </copy>
    ```

    Continue only when all four function names appear. If `GET_AFFECTED_STORES` is missing, ask the facilitator to verify the prepared database interface.

3. Inspect the package grant.

    ```sql
    <copy>
    select grantee, privilege
    from   user_tab_privs_made
    where  table_name = 'RECALL_LAB_API'
    order  by grantee;
    </copy>
    ```

    `RECALL_API_ROLE` receives package execution. It receives no table grant.

4. Call all four functions as the owner.

    ```sql
    <copy>
    set long 200000

    select json_serialize(
               recall_lab_api.get_recall_context('B-482')
               returning clob pretty
           ) as context_json;

    select json_serialize(
               recall_lab_api.get_spatial_impact('B-482')
               returning clob pretty
           ) as spatial_impact;

    select json_serialize(
               recall_lab_api.get_affected_stores('B-482')
               returning clob pretty
           ) as stores_geojson;

    select json_serialize(
               recall_lab_api.get_component_sites('B-482')
               returning clob pretty
           ) as component_sites_geojson;
    </copy>
    ```

    Confirm 120 stores, 2,400 units, 600 potentially exposed customers, 25 component batches, 25 supplier sites, 120 store GeoJSON features, and 25 component-site GeoJSON features. No response contains customer names or email addresses.

## Task 2: Publish and Protect the Routes

Kevin needs the contract available to trusted clients. David makes ORDS the authenticated delivery layer; Tim publishes and protects the routes.

1. The prepared backend publishes the module into `RECALL_APP_USER`. The schema alias is `recall`, and the module base path is `api/v1/`.

2. Review the four routes.

    | Route | Purpose |
    |---|---|
    | `GET health` | Confirm service availability |
    | `GET batches/:batch_id/context` | Return approved recall facts |
    | `GET batches/:batch_id/stores` | Return affected stores as GeoJSON |
    | `GET batches/:batch_id/component-sites` | Return component supplier sites as GeoJSON |

3. Confirm the authentication boundary. An anonymous health request must return HTTP `401`.

    ```bash
    curl --ipv4 --connect-timeout 10 --max-time 20 --show-error -i \
      "https://<adb-ords-host>/ords/recall/api/v1/health"
    ```

    A reachable, protected route returns `HTTP/1.1 401 Unauthorized` and an ORDS JSON error body. This is the expected result. Do not add `RECALL_APP_USER` credentials to the command line or workshop files.

## Task 3: Test the Protected API

Kevin needs evidence that the route behaves as designed. David tests both allowed and anonymous paths; Tim checks the JSON and GeoJSON responses.

1. Set the required environment values without placing the password in shell history.

2. Run [`03-test-api.sh`](files/03-test-api.sh).

3. Confirm these results:

    - Anonymous health access returns `401`.
    - Authenticated health access returns `200`.
    - Context returns status `INVESTIGATING`, 120 stores, 2,400 units, 600 customers, 25 component batches, and 25 supplier sites.
    - The store GeoJSON response contains ten features.
    - The component-site GeoJSON response contains five features.
    - The responses contain no customer names or email addresses.

4. Review the delivery boundary:

    - `RECALL_OWNER` owns every table and package.
    - `RECALL_APP_USER` owns delivery metadata and calls the approved package.
    - ORDS requires authentication for the entire module.
    - The service returns read-only, PII-safe JSON and GeoJSON.
    - Lab 7 applies user roles before vector retrieval and agent summarization.
    - Lab 8 replaces the prototype UI with the deployable React/Node capstone.

You have completed Lab 6. The recall workflow now has a protected API surface.

## Troubleshooting

| Symptom | Likely cause | Recovery |
|---|---|---|
| Anonymous request returns `404` | ORDS metadata has not refreshed | Wait several seconds and retry. |
| Anonymous request returns `200` | Module privilege is missing | Ask the facilitator to verify the published module; stop until it returns `401`. |
| Curl reaches its 20-second timeout | The client cannot reach the public ORDS endpoint | Verify the hostname, Autonomous Database public-access policy, VPN, proxy, and outbound firewall rules. |
| Authenticated request returns `401` | Runtime password is incorrect | Re-enter the password outside shell history. |
| `ORA-00904` names `GET_AFFECTED_STORES` | The approved package is incomplete | Ask the facilitator to verify the backend deployment, then verify `USER_PROCEDURES`. |
| Context passes but stores fail | The GeoJSON package extension is missing | Ask the facilitator to verify the backend deployment. |

## Learn More

- [Developing Oracle REST Data Services applications](https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/26.2/orddg/developing-REST-applications.html)
- [ORDS PL/SQL package reference](https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/26.2/orddg/ORDS-reference.html)
- [Oracle Spatial GeoJSON support](https://docs.oracle.com/en/database/oracle/oracle-database/26/spatl/)

## Acknowledgements

- **Author:** Tim Cline, Product Management Architect
- Contributors: David Start, Director and Kevin Lazarz, Senior Manager
- **Last updated:** October 2026
