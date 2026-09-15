whenever sqlerror exit sql.sqlcode rollback
set feedback on
set pagesize 100
set linesize 220

prompt ============================================================
prompt Product Recall Assistant - Promote Coordinates to Spatial
prompt Connect as RECALL_OWNER on Oracle AI Database 26ai.
prompt ============================================================

begin
    if user != 'RECALL_OWNER' then
        raise_application_error(-20060, 'Wrong user: connect as RECALL_OWNER.');
    end if;
end;
/

prompt --- Source longitude and latitude columns ---

select store_code, longitude, latitude
from   stores
where  store_id in (101, 201, 301)
order  by store_id;

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
    -- Lab 2 can be rerun after the backend deployment. Ignore only the
    -- expected duplicate-object conditions; unexpected errors still stop it.
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

commit;

prompt --- V2 indexes and automatically generated metadata ---

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
order  by table_name;

select table_name, column_name, srid
from   user_sdo_geom_metadata
where  table_name in ('STORES', 'RESPONSE_CENTERS', 'SUPPLIER_SITES')
order  by table_name;

select object_name, object_type, status
from   user_objects
where  object_name in (
           'RECALL_AFFECTED_STORES_V',
           'RECALL_COMPONENT_TRACE_V',
           'RECALL_LAB_API'
       )
and    object_type != 'PACKAGE'
order  by object_name, object_type;

prompt Spatial promotion complete. No metadata rows were inserted manually.
