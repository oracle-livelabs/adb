whenever sqlerror exit sql.sqlcode rollback
set serveroutput on
set feedback on

prompt ============================================================
prompt Product Recall Assistant - Environment Qualification
prompt ============================================================

select user as connected_user,
       sys_context('USERENV', 'CON_NAME') as container_name;

begin
    if user != 'RECALL_OWNER' then
        raise_application_error(
            -20002,
            'Environment check must run as RECALL_OWNER.'
        );
    end if;
end;
/

column banner_full format a90
select banner_full
from   v$version
where  banner_full like 'Oracle Database%';

prompt --- Required object and package visibility ---

select capability,
       case when object_count > 0 then 'PASS' else 'REVIEW' end as status,
       object_count
from (
    select 'DBMS_CLOUD_AI_AGENT' capability, count(*) object_count
    from   all_objects
    where  object_name = 'DBMS_CLOUD_AI_AGENT'
    union all
    select 'DBMS_VECTOR', count(*)
    from   all_objects
    where  object_name = 'DBMS_VECTOR'
    union all
    select 'MDSYS.SDO_GEOMETRY', count(*)
    from   all_types
    where  owner = 'MDSYS'
    and    type_name = 'SDO_GEOMETRY'
);

prompt --- Native JSON, VECTOR, and Spatial smoke tests ---

select json_serialize(
           json_object('status' value 'PASS', 'feature' value 'NATIVE_JSON')
           returning varchar2(200)
       ) as json_test;

select vector_serialize(
           to_vector('[1,0,0,0]', 4, float32)
           returning varchar2(100)
       ) as vector_test;

select sdo_geom.validate_geometry_with_context(
           mdsys.sdo_geometry(
               2001,
               4326,
               mdsys.sdo_point_type(-71.0589, 42.3601, null),
               null,
               null
           ),
           0.00001
       ) as spatial_test
;

prompt --- RECALL_OWNER privilege checks ---

select privilege
from   session_privs
where  privilege in (
           'CREATE TABLE',
           'CREATE VIEW',
           'CREATE PROCEDURE',
           'CREATE PROPERTY GRAPH',
           'CREATE END USER',
           'CREATE DATA ROLE',
           'CREATE DATA GRANT',
           'CREATE END USER CONTEXT',
           'ADMINISTER ANY DATA GRANT',
           'UPDATE ANY END USER CONTEXT'
       )
order by privilege;

select owner, table_name, privilege
from   user_tab_privs_recd
where  table_name in (
           'DBMS_CLOUD_AI',
           'DBMS_CLOUD_AI_AGENT',
           'DBMS_CLOUD',
           'DBMS_VECTOR'
       )
order by table_name, privilege;

prompt --- Workshop schema checks after the owner setup ---

with required_objects as (
    select column_value as object_name
    from table(sys.odcivarchar2list(
        'RECALL_LAB_API',
        'RECALL_INVESTIGATIONS',
        'COMPLAINT_CHUNKS',
        'SUPPLIERS',
        'SUPPLIER_SITES',
        'COMPONENTS',
        'COMPONENT_BATCHES',
        'BATCH_COMPONENTS',
        'RECALL_COMPONENT_TRACE_V'
    ))
)
select r.object_name,
       nvl(u.object_type, 'MISSING') as object_type,
       nvl(u.status, 'MISSING') as status
from   required_objects r
left join user_objects u
       on u.object_name = r.object_name
      and u.object_type != 'PACKAGE BODY'
order  by r.object_name;

declare
    l_missing_or_invalid number;
begin
    select count(*)
    into   l_missing_or_invalid
    from   table(sys.odcivarchar2list(
               'RECALL_LAB_API',
               'RECALL_INVESTIGATIONS',
               'COMPLAINT_CHUNKS',
               'SUPPLIERS',
               'SUPPLIER_SITES',
               'COMPONENTS',
               'COMPONENT_BATCHES',
               'BATCH_COMPONENTS',
               'RECALL_COMPONENT_TRACE_V'
           )) required
    where  not exists (
               select 1
               from   user_objects u
               where  u.object_name = required.column_value
               and    u.object_type != 'PACKAGE BODY'
               and    u.status = 'VALID'
           );

    if l_missing_or_invalid > 0 then
        raise_application_error(
            -20003,
            'Expanded workshop schema is missing or invalid. Rerun 01-owner-setup.sql as RECALL_OWNER.'
        );
    end if;
end;
/

prompt Expected after setup: every Lab 1 object is VALID. Lab 3 creates RECALL_GRAPH.

select user as owner, table_name, grantee, privilege
from   user_tab_privs_made
where  table_name = 'RECALL_LAB_API'
and    grantee = 'RECALL_API_ROLE';

prompt Expected runtime grant: RECALL_API_ROLE has EXECUTE on
prompt RECALL_OWNER.RECALL_LAB_API.
