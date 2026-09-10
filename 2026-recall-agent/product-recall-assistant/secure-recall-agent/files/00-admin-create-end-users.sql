whenever sqlerror exit sql.sqlcode rollback
set define on
set verify off
set serveroutput on
set feedback on

prompt ============================================================
prompt Product Recall Assistant - Lab 7 Local End Users
prompt Connect as ADMIN. Facilitator setup only.
prompt ============================================================

prompt Workshop-only simplification: all three end users share one lab password.
prompt Production users must have distinct credentials or use enterprise IAM.
accept lab_end_user_password char hide prompt 'Shared Lab 7 end-user password: '

begin
    if user != 'ADMIN' then
        raise_application_error(-20040, 'Wrong user: connect as ADMIN.');
    end if;
end;
/

declare
    procedure create_or_update_end_user(
        p_name     in varchar2,
        p_password in varchar2
    ) is
        l_count number;
        l_sql   varchar2(4000);
    begin
        select count(*) into l_count
        from dba_end_users
        where username = upper(p_name);

        if instr(p_password, '"') > 0 then
            raise_application_error(-20041, 'Lab passwords cannot contain a double quote.');
        end if;

        if l_count = 0 then
            l_sql := 'create end user ' || dbms_assert.simple_sql_name(p_name) ||
                     ' identified by "' || p_password || '"' ||
                     ' account unlock schema recall_owner';
        else
            l_sql := 'alter end user ' || dbms_assert.simple_sql_name(p_name) ||
                     ' identified by "' || p_password || '"' ||
                     ' account unlock schema recall_owner';
        end if;

        execute immediate l_sql;
    end;
begin
    create_or_update_end_user('STORE_101_USER',  '&&lab_end_user_password');
    create_or_update_end_user('REGION_NE_USER',  '&&lab_end_user_password');
    create_or_update_end_user('RECALL_LEAD_USER','&&lab_end_user_password');
end;
/

select username, schema, authentication_type, account_status
from dba_end_users
where username in ('STORE_101_USER','REGION_NE_USER','RECALL_LEAD_USER')
order by username;

undefine lab_end_user_password

prompt Local Deep Data Security end users are ready.
