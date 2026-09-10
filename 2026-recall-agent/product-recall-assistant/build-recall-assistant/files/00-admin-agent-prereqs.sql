whenever sqlerror exit sql.sqlcode rollback
set serveroutput on
set feedback on

prompt ============================================================
prompt Product Recall Assistant - Lab 2 ADMIN Prerequisites
prompt Run once as ADMIN. Learners never run this script.
prompt ============================================================

begin
    if user != 'ADMIN' then
        raise_application_error(
            -20020,
            'Wrong user: connect as ADMIN before running this script.'
        );
    end if;
end;
/

begin
    dbms_cloud_admin.enable_resource_principal(
        username     => 'RECALL_OWNER',
        grant_option => false
    );
    dbms_output.put_line(
        'Enabled resource-principal access for RECALL_OWNER.'
    );
exception
    when others then
        if sqlcode = -20031 then
            dbms_output.put_line(
                'Resource-principal access was already enabled.'
            );
        else
            raise;
        end if;
end;
/

begin
    dbms_cloud_admin.enable_principal_auth(
        provider => 'OCI',
        username => 'RECALL_OWNER'
    );
    dbms_output.put_line(
        'Enabled OCI principal authentication for RECALL_OWNER.'
    );
exception
    when others then
        if sqlcode = -20031 then
            dbms_output.put_line(
                'OCI principal authentication was already enabled.'
            );
        else
            raise;
        end if;
end;
/

select grantee,
       table_schema,
       table_name,
       privilege
from   all_tab_privs
where  grantee = 'RECALL_OWNER'
and    table_name = 'OCI$RESOURCE_PRINCIPAL';

select json_value(cloud_identity, '$.REGION') as database_region,
       json_value(cloud_identity, '$.COMPARTMENT_OCID')
           as database_compartment
from   v$pdbs
where  name = sys_context('USERENV', 'DB_NAME');

prompt ADMIN prerequisites complete.
prompt Confirm that OCI IAM limits the database resource principal
prompt to the approved Generative AI compartment and operations.
