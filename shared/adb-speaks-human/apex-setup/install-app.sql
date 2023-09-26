DECLARE
    l_workspace_name VARCHAR2(100) := 'MOVIESTREAM';
    l_schema_name VARCHAR2(100) := 'MOVIESTREAM';
    l_workspace_usr_pwd VARCHAR2(100) := 'change_me';
begin
    apex_instance_admin.add_workspace(
     p_workspace_id   => null,
     p_workspace      => l_workspace_name,
     p_primary_schema => l_schema_name);

      -- We must set the APEX workspace security group ID in our session before we can call create_user
    apex_util.set_security_group_id( apex_util.find_security_group_id( p_workspace => l_workspace_name));
  apex_util.create_user( 
        p_user_name               => 'WKSP_ADMIN',
        p_email_address           => 'admin@o.com',
        p_default_schema          => l_schema_name,
        p_allow_access_to_schemas => l_schema_name,
        p_web_password            => l_workspace_usr_pwd,
        p_developer_privs         => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL' );  -- workspace administrator
 
       
    commit;
end;
/

BEGIN
    -- Set the name of the workspace in which the app needs to be installed
    apex_application_install.set_workspace('MOVIESTREAM');

    -- Setting the application id to 101
    apex_application_install.set_application_id(101);
    apex_application_install.generate_offset();

    -- Setting the Schema
    apex_application_install.set_schema('MOVIESTREAM');

    -- Setting application alias
    apex_application_install.set_application_alias('ASK-ORACLE');

    -- Set Auto Install Supporting Objects
    apex_application_install.set_auto_install_sup_obj( p_auto_install_sup_obj => true );

END;
/
@f101.sql