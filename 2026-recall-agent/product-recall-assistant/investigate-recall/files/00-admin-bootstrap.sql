whenever sqlerror exit sql.sqlcode rollback
set define on
set verify off
set serveroutput on
set feedback on

prompt ============================================================
prompt Product Recall Assistant - ADMIN Bootstrap
prompt Connect as ADMIN on a new Autonomous AI Database 26ai.
prompt This script creates identities and grants platform privileges.
prompt It does not create or own application data.
prompt ============================================================

accept recall_owner_password char hide prompt 'Password for RECALL_OWNER: '

create user recall_owner
    identified by "&&recall_owner_password"
    default tablespace data
    temporary tablespace temp
    quota unlimited on data
    account unlock;

grant create session to recall_owner;
grant create table to recall_owner;
grant create view to recall_owner;
grant create procedure to recall_owner;
grant create sequence to recall_owner;
grant create trigger to recall_owner;
grant create type to recall_owner;
grant create property graph to recall_owner;
grant create mining model to recall_owner;

prompt --- Privileges reserved for later Deep Data Security labs ---

grant create end user to recall_owner;
grant create data role to recall_owner;
grant create data grant to recall_owner;
grant create end user context to recall_owner;
grant administer any data grant to recall_owner;
grant update any end user context to recall_owner;

prompt --- Select AI and Select AI Agent privileges for Lab 2 ---

grant execute on dbms_cloud_ai to recall_owner;
grant execute on dbms_cloud_ai_agent to recall_owner;
grant execute on dbms_vector to recall_owner;
grant execute on dbms_cloud to recall_owner;
grant create credential to recall_owner;

prompt --- Local ONNX model loading prerequisites for Lab 4 ---

prompt --- Spatial Studio proxy access ---

grant spatial_admin to recall_owner;

alter user "RECALL_OWNER"
    grant connect through "SPATIAL$PROXY_USER";

prompt --- Runtime database roles ---

create role recall_api_role;
grant create session to recall_api_role;

create role recall_end_user_login;
grant create session to recall_end_user_login;
grant recall_end_user_login to recall_owner with admin option;

prompt --- Verify the identity boundary ---

column username format a24
column account_status format a20
column proxy format a24
column client format a24
column authentication format a20

select username, account_status, default_tablespace
from   dba_users
where  username = 'RECALL_OWNER'
order  by username;

select role
from   dba_roles
where  role in ('RECALL_API_ROLE', 'RECALL_END_USER_LOGIN')
order  by role;

select grantee, privilege
from   dba_sys_privs
where  grantee = 'RECALL_OWNER'
order  by privilege;

select grantee, granted_role, admin_option, default_role
from   dba_role_privs
where  grantee = 'RECALL_OWNER'
and    granted_role = 'SPATIAL_ADMIN';

select proxy, client, authentication
from   dba_proxies
where  proxy = 'SPATIAL$PROXY_USER'
and    client = 'RECALL_OWNER';

undefine recall_owner_password

prompt RECALL_OWNER bootstrap and Spatial Studio access complete.
prompt Disconnect ADMIN now.
prompt Reconnect as RECALL_OWNER before running 01-owner-setup.sql.
