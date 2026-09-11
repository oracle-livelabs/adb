# Lab 2: Put Help Where It Is Needed: Map Recall Impact with Oracle Spatial

## Introduction

Kevin now asks, “Where do we need to support returns, and who should respond?” A list of 120 stores is not a field plan. He needs each affected location connected to a response center before store teams start calling for help.

David's design is to treat locations as database data, not coordinates exported to a separate map. Stores, response centers, and supplier sites become indexed points. The same workflow can test a 25-kilometer response radius, choose the nearest center, and produce map-ready output for the application.

Tim promotes the existing longitude and latitude values to Oracle Spatial `SDO_GEOMETRY`, creates the Spatial indexes, and runs the proximity and distance SQL. He then produces GeoJSON that later APIs and the command center can use without recalculating assignments elsewhere.

By the end of the lab, Kevin has response coverage and a nearest-center assignment for every affected store. David can carry the location evidence forward without introducing a spreadsheet-and-map handoff.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

- Convert longitude and latitude values to `SDO_GEOMETRY`.
- Create `SPATIAL_INDEX_V2` indexes without manually inserting spatial metadata.
- Use `SDO_WITHIN_DISTANCE` for indexed proximity filtering.
- Use `SDO_GEOM.SDO_DISTANCE` to assign nearest response centers.
- Create GeoJSON for affected stores and component supplier sites.

## Task 1: Promote Coordinates to Oracle Spatial

Kevin needs a field plan, not raw coordinates. David promotes locations to first-class data; Tim creates the points and indexes.

1. Inspect the relational longitude and latitude values before adding spatial columns.

    ```sql
    <copy>
    select 'STORE' as location_type,
           store_code as location_code,
           longitude,
           latitude
    from   stores
    where  store_id in (101, 201, 301)
    union all
    select 'RESPONSE_CENTER',
           to_char(center_id),
           longitude,
           latitude
    from   response_centers
    where  center_id in (1, 2, 3)
    union all
    select 'SUPPLIER_SITE',
           site_code,
           longitude,
           latitude
    from   supplier_sites
    where  supplier_site_id between 401 and 405
    order  by location_type, location_code;
    </copy>
    ```

    These are regular numeric columns. The next block is safe to rerun if you need to repeat this lab task.

2. Ensure and populate the `SDO_GEOMETRY` columns, then create the V2 spatial indexes.

    ```sql
    <copy>
    declare
        procedure run_ddl(
            p_sql          in varchar2,
            p_ignored_code in number
        ) is
        begin
            execute immediate p_sql;
        exception
            when others then
                if sqlcode != p_ignored_code then
                    raise;
                end if;
        end;
    begin
        -- This block is rerunnable after a previous Lab 2 attempt.
        run_ddl(
            'alter table stores add (location mdsys.sdo_geometry)',
            -1430
        );
        run_ddl(
            'alter table response_centers add (location mdsys.sdo_geometry)',
            -1430
        );
        run_ddl(
            'alter table supplier_sites add (location mdsys.sdo_geometry)',
            -1430
        );
    end;
    /

    update stores
    set    location = mdsys.sdo_geometry(longitude, latitude);

    update response_centers
    set    location = mdsys.sdo_geometry(longitude, latitude);

    update supplier_sites
    set    location = mdsys.sdo_geometry(longitude, latitude);

    declare
        procedure run_ddl(
            p_sql          in varchar2,
            p_ignored_code in number
        ) is
        begin
            execute immediate p_sql;
        exception
            when others then
                if sqlcode != p_ignored_code then
                    raise;
                end if;
        end;
    begin
        run_ddl(
            'alter table stores modify (location not null)',
            -1442
        );
        run_ddl(
            'alter table response_centers modify (location not null)',
            -1442
        );
        run_ddl(
            'alter table supplier_sites modify (location not null)',
            -1442
        );

        run_ddl(
            'create index stores_spatial_ix on stores(location) indextype is mdsys.spatial_index_v2',
            -955
        );
        run_ddl(
            'create index response_centers_spatial_ix on response_centers(location) indextype is mdsys.spatial_index_v2',
            -955
        );
        run_ddl(
            'create index supplier_sites_spatial_ix on supplier_sites(location) indextype is mdsys.spatial_index_v2',
            -955
        );
    end;
    /

    commit;
    </copy>
    ```

    The 26ai constructor creates WGS84 points from longitude and latitude. The script inserts no rows into `USER_SDO_GEOM_METADATA`; each V2 index creates its metadata automatically.

    The block is rerunnable and safely recognizes columns and indexes that already exist.

3. The prepared backend uses the populated `LOCATION` columns and the current `RECALL_LAB_API` package.

4. Inspect the promoted geometry values.

    ```sql
    <copy>
    select s.store_code,
           s.location.sdo_gtype as geometry_type,
           s.location.sdo_srid as srid,
           s.location.sdo_point.x as longitude,
           s.location.sdo_point.y as latitude
    from   stores s
    where  s.store_id in (101, 201, 301)
    order  by s.store_id;
    </copy>
    ```

    Each row is a two-dimensional point with geometry type `2001` and SRID `4326`.

5. Confirm the V2 indexes and their generated metadata.

    ```sql
    <copy>
    select index_name,
           table_name,
           status,
           ityp_owner,
           ityp_name
    from   user_indexes
    where  index_name in (
               'STORES_SPATIAL_IX',
               'RESPONSE_CENTERS_SPATIAL_IX',
               'SUPPLIER_SITES_SPATIAL_IX'
           )
    order  by table_name, index_name;

    select table_name, column_name, srid
    from   user_sdo_geom_metadata
    where  table_name in ('STORES', 'RESPONSE_CENTERS', 'SUPPLIER_SITES')
    order  by table_name;
    </copy>
    ```

    Each index reports `VALID` and uses the `MDSYS` V2 index type. The second query returns generated SRID `4326` metadata.

## Task 2: Find Stores Within Response Radius

Kevin asks whether every store has nearby help. David defines a response-radius rule; Tim applies it inside the database.

1. Find affected stores within 25 kilometers of any recall response center.

    ```sql
    <copy>
    select distinct
           a.store_code,
           a.store_name,
           rc.center_name
    from   recall_affected_stores_v a
    cross  join response_centers rc
    where  a.batch_id = 'B-482'
    and    sdo_within_distance(
               a.location,
               rc.location,
               'distance=25 unit=km'
           ) = 'TRUE'
    order  by a.store_code;
    </copy>
    ```

    The result contains all 120 affected stores. An authorized recall desk serves each store within 25 kilometers.

2. Note the operational result:

    - The generated national footprint includes 120 affected stores.
    - Every affected store has a nearby authorized response location.
    - The next task ranks the nearest center when service areas overlap.

## Task 3: Assign the Nearest Response Center

Kevin needs one center accountable for each location. David chooses a repeatable nearest-center rule; Tim calculates it.

1. Rank response centers by distance for every affected store.

    ```sql
    <copy>
    with ranked_centers as (
        select a.store_code,
               a.store_name,
               rc.center_name,
               sdo_geom.sdo_distance(
                   a.location,
                   rc.location,
                   0.00001,
                   'unit=km'
               ) as distance_km,
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
        where  a.batch_id = 'B-482'
    )
    select store_code,
           store_name,
           center_name,
           round(distance_km, 1) as distance_km
    from   ranked_centers
    where  rn = 1
    order  by store_code;
    </copy>
    ```

    All 120 affected stores now have a response-center assignment.

## Task 4: Map Stores and Supplier Sites

Kevin needs the plan in the application. David uses GeoJSON as the exchange format; Tim prepares the store and supplier location results.

1. Use the queries in this task to return:

    - stores within the 25-kilometer response radius,
    - nearest-center assignments for all affected stores,
    - component supplier and sub-vendor locations,
    - a store GeoJSON `FeatureCollection` with 120 features,
    - a supplier-site GeoJSON `FeatureCollection` with 25 features.

2. Explain why spatial belongs in the database for this workflow:

    - Store and supplier-site locations join directly to recall facts.
    - Spatial operators can use spatial indexes.
    - SQL produces GeoJSON from the governed data used by later labs.

You have completed Lab 2. Lab 3 traces upstream component lots and downstream customer exposure with SQL property graph.

## Troubleshooting

| Symptom | Likely cause | Recovery |
|---|---|---|
| `LOCATION` does not exist | The prepared workshop environment is incomplete | Ask the facilitator to verify the backend deployment. |
| Column or index already exists | The promotion script already ran | Continue with verification; do not repeat the promotion step. |
| Spatial index is invalid | Promotion stopped during index creation | Ask the facilitator to verify the backend deployment before retrying the spatial steps. |
| Locations fall outside the continental U.S. | The database contains older generated coordinates | Ask the facilitator to refresh the prepared spatial data, then regenerate the GeoJSON captures. |
| GeoJSON has fewer than 120 stores | Batch `B-482` data changed | Recheck `recall_affected_stores_v`. |
| Supplier-site GeoJSON is empty | Component trace data did not load | Recheck `recall_component_trace_v`. |

## Learn More

- [Oracle AI Database Spatial Developer Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/spatl/index.html)
- [Spatial changes in Oracle AI Database 26ai](https://docs.oracle.com/en/database/oracle/oracle-database/26/spatl/changes-this-release-oracle-spatial-developers-guide.html)
- [Oracle Spatial GeoJSON support](https://docs.oracle.com/en/database/oracle/oracle-database/26/spatl/)

## Acknowledgements

- **Author:** Tim Cline, Product Management Architect
- Contributors: David Start, Director and Kevin Lazarz, Senior Manager
- **Last updated:** October 2026
