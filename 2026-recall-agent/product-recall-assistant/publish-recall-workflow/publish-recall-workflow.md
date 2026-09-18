# Lab 6: Share Recall Data Safely with ORDS

## Introduction

Kevin needs the returns application to show which stores received batch `B-482`. A map should display each store and the number of affected units, without exposing customer names or giving the application access to database tables.

David keeps the location and shipment data in Oracle AI Database and publishes a read-only web endpoint through Oracle REST Data Services (ORDS). Tim builds the GeoJSON response, saves it as a function, and connects that function to a protected URL.

You will build `/ords/recall/map/v1/batches/B-482/stores`. This separate map endpoint leaves any existing `/api/v1/` routes unchanged. The supporting tables, views, API role, and runtime account are already available. Lab 2 supplies the location data; you create the function and route here.

Estimated Time: 20 minutes

### Objectives

In this lab, you will:

- Build a GeoJSON response from affected-store data.
- Create a reusable, read-only PL/SQL function.
- Define an ORDS module, URL template, and GET handler.
- Require authentication before publishing the endpoint.
- Verify 120 map features and confirm the runtime account cannot read the tables.

## Task 1: Build the Store Map Response

Kevin needs store locations and affected units in one response. David chooses GeoJSON, which map applications can read. Tim uses the same location and shipment data from Lab 2; there is no separate map database or export job.

1. Connect as `RECALL_OWNER`. Build the GeoJSON response for B-482.

    ```sql
    <copy>
    select json_object(
               'type' value 'FeatureCollection',
               'batchId' value 'B-482',
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
                       ) order by a.store_code returning clob
                   ), to_clob('[]')
               ) format json
               returning clob
           ) as stores_geojson
    from   recall_affected_stores_v a
    where  a.batch_id = 'B-482';
    </copy>
    ```

    Open the result cell to inspect the JSON. Expect a `FeatureCollection` with 120 features. Each point contains longitude followed by latitude; its properties supply the store label, region, and affected units. The query selects no customer details.

2. Turn the query into a function so an application can request a batch by its identifier.

    ```sql
    <copy>
    create or replace function recall_store_geojson(
        p_batch_id in varchar2
    ) return clob authid definer is
        l_result clob;
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
                           ) order by a.store_code returning clob
                       ), to_clob('[]')
                   ) format json
                   returning clob
               )
        into   l_result
        from   recall_affected_stores_v a
        where  a.batch_id = l_batch_id;
        return l_result;
    end recall_store_geojson;
    /
    </copy>
    ```

    This is the same query with a parameter instead of a fixed batch. `AUTHID DEFINER` lets the function read its owner’s data without giving the caller table access. The function contains only a SELECT; it cannot change recall records. A batch with no affected stores returns an empty feature collection.

3. Check that the function compiled.

    ```sql
    <copy>
    select line, position, text
    from   user_errors
    where  name = 'RECALL_STORE_GEOJSON'
    and    type = 'FUNCTION'
    order  by sequence;
    </copy>
    ```

    Expect no rows. If errors appear, correct them before publishing the endpoint.

4. Call your new function.

    ```sql
    <copy>
    select json_serialize(
               recall_store_geojson('B-482') returning clob pretty
           ) as stores_geojson;
    </copy>
    ```

5. Grant the API role permission to call only this function.

    ```sql
    <copy>
    grant execute on recall_store_geojson to recall_api_role;
    </copy>
    ```

    `RECALL_APP_USER` already has this role. You are granting execution of your function, not SELECT on the tables. The existing `RECALL_LAB_API` package stays unchanged.

## Task 2: Connect the Function to a URL

Kevin’s application needs a URL, not a SQL connection. David uses `RECALL_APP_USER` to run the HTTP handler. Tim defines the module, the batch parameter in the URL, and the SELECT that calls the function.

1. Switch to an `ADMIN` SQL worksheet. Enable the runtime schema at the `recall` path.

    ```sql
    <copy>
    begin
        ords_admin.enable_schema(
            p_enabled             => true,
            p_schema              => 'RECALL_APP_USER',
            p_url_mapping_type    => 'BASE_PATH',
            p_url_mapping_pattern => 'recall',
            p_auto_rest_auth      => true
        );
        commit;
    end;
    /
    </copy>
    ```

    Leave `RECALL_OWNER` enabled for SQL Developer Web. The setting above protects the metadata catalog; Task 3 adds protection for your custom endpoint.

2. Create an unpublished module.

    ```sql
    <copy>
    begin
        ords_admin.define_module(
            p_schema         => 'RECALL_APP_USER',
            p_module_name    => 'recall.map.v1',
            p_base_path      => 'map/v1/',
            p_items_per_page => 0,
            p_status         => 'NOT_PUBLISHED'
        );
        commit;
    end;
    /
    </copy>
    ```

    The module groups the routes under `/map/v1/`. It remains unavailable while you build and secure it. Rerunning this step replaces this exercise’s module and its handlers; continue through all remaining steps.

3. Define the URL pattern.

    ```sql
    <copy>
    begin
        ords_admin.define_template(
            p_schema      => 'RECALL_APP_USER',
            p_module_name => 'recall.map.v1',
            p_pattern     => 'batches/:batch_id/stores'
        );
        commit;
    end;
    /
    </copy>
    ```

    ORDS passes the batch identifier in the URL to the handler as `:batch_id`.

4. Add the GET handler.

    ```sql
    <copy>
    begin
        ords_admin.define_handler(
            p_schema      => 'RECALL_APP_USER',
            p_module_name => 'recall.map.v1',
            p_pattern     => 'batches/:batch_id/stores',
            p_method      => 'GET',
            p_source_type => ords.source_type_media,
            p_source      => q'~
                select 'application/geo+json',
                       recall_owner.recall_store_geojson(:batch_id)
                from dual
            ~'
        );
        commit;
    end;
    /
    </copy>
    ```

    The media handler sends the function’s CLOB as the response body, with the GeoJSON content type. It avoids wrapping the document in an ORDS row collection or truncating it through a text-print call. The bind variable passes the batch identifier without constructing SQL from user input.

## Task 3: Protect and Publish the Endpoint

Kevin wants trusted clients to see the map, not anonymous visitors. David requires authentication for the whole module. Tim adds that rule before publishing any route.

1. Stay connected as `ADMIN`. Require authentication for the module.

    ```sql
    <copy>
    declare
        l_roles    owa.vc_arr;
        l_patterns owa.vc_arr;
        l_modules  owa.vc_arr;
    begin
        l_modules(1) := 'recall.map.v1';
        ords_admin.define_privilege(
            p_schema         => 'RECALL_APP_USER',
            p_privilege_name => 'recall.map.authenticated',
            p_roles          => l_roles,
            p_patterns       => l_patterns,
            p_modules        => l_modules,
            p_label          => 'Authenticated recall map',
            p_description    => 'Require authentication for the store map endpoint.'
        );
        commit;
    end;
    /
    </copy>
    ```

    The empty ORDS role list requires an authenticated identity but no additional ORDS role. This is an authentication rule, not store-by-store authorization. Lab 7 introduces database-enforced user scopes.

2. Publish the protected module.

    ```sql
    <copy>
    begin
        ords_admin.publish_module(
            p_schema      => 'RECALL_APP_USER',
            p_module_name => 'recall.map.v1',
            p_status      => 'PUBLISHED'
        );
        commit;
    end;
    /
    </copy>
    ```

3. Confirm the runtime account has no direct SELECT grants on the owner’s tables, including through its API role.

    ```sql
    <copy>
    select grantee, table_name, privilege
    from   dba_tab_privs
    where  owner = 'RECALL_OWNER'
    and    grantee in ('RECALL_APP_USER', 'RECALL_API_ROLE')
    and    privilege = 'SELECT'
    order  by grantee, table_name;
    </copy>
    ```

    Expect no rows. The HTTP handler can execute the approved function, but cannot use these identities to select directly from the application tables.

## Task 4: Test What an Application Receives

Kevin needs proof that the URL works and blocks anonymous access. Tim tests it from a terminal, outside SQL Developer Web. These requests read data; they do not open a case or change the recall.

1. Replace `<adb-ords-host>` with the hostname from your SQL Developer Web URL, then run:

    ```bash
    <copy>
    RECALL_MAP_URL="https://<adb-ords-host>/ords/recall/map/v1/batches/B-482/stores"
    </copy>
    ```

2. Request the map without credentials.

    ```bash
    <copy>
    curl --connect-timeout 10 --max-time 30 --silent --show-error \
      --output /dev/null --write-out "HTTP %{http_code}\n" \
      "$RECALL_MAP_URL"
    </copy>
    ```

    Expect `HTTP 401`. A `404` does not prove authentication is working; check that you published the module and used the exact URL.

3. Request it with the runtime account.

    ```bash
    <copy>
    curl --connect-timeout 10 --max-time 30 --silent --show-error \
      --user RECALL_APP_USER --include "$RECALL_MAP_URL"
    </copy>
    ```

    Curl prompts for the workshop password without storing it in the command. Expect HTTP `200`, content type `application/geo+json`, and a `FeatureCollection`. Database credentials are used here only to test the service; do not embed them in browser application code. Production clients need an appropriate application authentication flow.

4. Check the number of map features. This command requires `jq`.

    ```bash
    <copy>
    curl --connect-timeout 10 --max-time 30 --fail --silent --show-error \
      --user RECALL_APP_USER "$RECALL_MAP_URL" \
      | jq '{batchId, type, featureCount: (.features | length), unitsSent: ([.features[].properties.unitsSent] | add)}'
    </copy>
    ```

    Expect batch `B-482`, type `FeatureCollection`, **120 features**, and **2,400 units**. Check that the properties contain only store code, store name, region, and units sent.

## Conclusion

You built the SQL response, saved it as a function, connected it to a GET route, and protected that route before publishing it. Kevin’s returns application can now request the affected-store map without being allowed to query the source tables.

For David, the Oracle AI Database advantage is that the API reads the same shipment records and spatial data used in the earlier labs. There is no separate spatial database or synchronization job. Tim selects the fields in SQL, while the database controls execution privileges and ORDS controls access to the web endpoint.

## Learn More

- [ORDS administration PL/SQL reference](https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/26.2/orddg/oracle-rest-data-services-administration-pl-sql-package-reference.html)
- [Developing ORDS applications](https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/26.2/orddg/developing-REST-applications.html)

## Acknowledgements

- **Author:** Tim Cline, Product Management Architect
- Contributors: David Start, Director and Kevin Lazarz, Senior Manager
- **Last updated:** October 2026
