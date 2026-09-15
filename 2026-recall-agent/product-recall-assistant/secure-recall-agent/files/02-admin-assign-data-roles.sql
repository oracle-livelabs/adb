whenever sqlerror exit sql.sqlcode rollback
set feedback on

prompt ============================================================
prompt Product Recall Assistant - Assign Lab 7 Data Roles
prompt Connect as ADMIN. ADMIN owns no application data or policy.
prompt ============================================================

begin
    if user != 'ADMIN' then
        raise_application_error(-20043, 'Wrong user: connect as ADMIN.');
    end if;
end;
/

grant data role recall_store_101_data_role to store_101_user;
grant data role recall_region_ne_data_role to region_ne_user;
grant data role recall_lead_data_role to recall_lead_user;

select grantee, data_role
from dba_data_role_grants
where grantee in ('STORE_101_USER','REGION_NE_USER','RECALL_LEAD_USER')
order by grantee;

prompt Data roles assigned. ADMIN owns no recall objects.
