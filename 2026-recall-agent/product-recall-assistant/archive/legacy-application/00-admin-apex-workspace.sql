whenever sqlerror exit sql.sqlcode rollback
set define on
set verify off
set serveroutput on
set feedback on

prompt ============================================================
prompt Product Recall Assistant - APEX Workspace and Accounts
prompt Connect as ADMIN. Facilitator setup only.
prompt ============================================================

accept apex_lab_password char hide prompt 'Shared APEX lab password: '

declare
    l_workspace_id number;
begin
    if user != 'ADMIN' then
        raise_application_error(-20066, 'Wrong user: connect as ADMIN.');
    end if;

    begin
        select workspace_id
        into   l_workspace_id
        from   apex_workspaces
        where  workspace = 'RECALL_LAB';
    exception
        when no_data_found then
            apex_instance_admin.add_workspace(
                p_workspace      => 'RECALL_LAB',
                p_primary_schema => 'RECALL_OWNER'
            );
            select workspace_id
            into   l_workspace_id
            from   apex_workspaces
            where  workspace = 'RECALL_LAB';
    end;

    apex_util.set_security_group_id(l_workspace_id);

    for u in (
        select 'RECALL_OWNER' username,
               'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL' privileges
        from dual
        union all select 'STORE_101_USER',   null from dual
        union all select 'REGION_NE_USER',   null from dual
        union all select 'RECALL_LEAD_USER', null from dual
    ) loop
        if not apex_util.is_username_unique(u.username) then
            apex_util.remove_user(p_user_name => u.username);
        end if;

        apex_util.create_user(
            p_user_name                     => u.username,
            p_email_address                 => lower(u.username) || '@example.invalid',
            p_web_password                  => '&&apex_lab_password',
            p_developer_privs               => u.privileges,
            p_default_schema                => 'RECALL_OWNER',
            p_allow_access_to_schemas       => 'RECALL_OWNER',
            p_change_password_on_first_use  => 'N',
            p_account_locked                => 'N'
        );
    end loop;

    commit;
    dbms_output.put_line('RECALL_LAB workspace and four APEX accounts are ready.');
end;
/

select version_no as apex_version from apex_release;

select workspace_name, user_name, is_admin, is_application_developer
from apex_workspace_apex_users
where workspace_name = 'RECALL_LAB'
order by user_name;

undefine apex_lab_password

prompt APEX workspace setup is complete.
