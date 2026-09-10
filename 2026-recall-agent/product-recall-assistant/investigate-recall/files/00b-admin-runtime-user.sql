whenever sqlerror exit sql.sqlcode rollback
set define on
set verify off
set serveroutput on
set feedback on

prompt ============================================================
prompt Product Recall Assistant - Runtime User Bootstrap
prompt Connect as ADMIN after choosing a RECALL_APP_USER password.
prompt This script can run after the owner setup.
prompt ============================================================

accept recall_app_password char hide prompt 'Password for RECALL_APP_USER: '

create user recall_app_user
    identified by "&&recall_app_password"
    default tablespace data
    temporary tablespace temp
    quota 0 on data
    account unlock;

grant recall_api_role to recall_app_user;

select username, account_status, default_tablespace
from   dba_users
where  username = 'RECALL_APP_USER';

select grantee, granted_role, admin_option
from   dba_role_privs
where  grantee = 'RECALL_APP_USER';

undefine recall_app_password

prompt RECALL_APP_USER bootstrap complete.
prompt Save a least-privilege SQLcl connection for the runtime test.

