declare
   l_workspace_name VARCHAR2(20) := 'MOVIESTREAM';
   l_schema_name VARCHAR2(20) := 'MOVIESTREAM';
   l_password VARCHAR2(20) := 'watchS0meMovies#';

begin

    begin
        workshop.write('create apex workspace',2);
        apex_instance_admin.add_workspace(
             p_workspace_id   => null,
             p_workspace      => l_workspace_name,
             p_primary_schema => l_schema_name);
    exception
        when others then              
            workshop.write(sqlerrm); 
    end;
    
      -- We must set the APEX workspace security group ID in our session before we can call create_user
    begin
        workshop.write('add apex ' || l_schema_name || ' user',2);
        apex_util.set_security_group_id( apex_util.find_security_group_id( p_workspace => l_workspace_name));
        apex_util.create_user( 
            p_user_name               => l_schema_name,
            p_email_address           => 'admin@o.com',
            p_default_schema          => l_schema_name,
            p_allow_access_to_schemas => l_schema_name,
            p_web_password            => l_password,
            p_developer_privs         => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL' );  -- workspace administrator
            
        commit;
    exception
        when others then              
            workshop.write(sqlerrm); 
    
    end;

    -- Set the name of the workspace in which the app needs to be installed
    apex_application_install.set_workspace(l_workspace_name);
    
    -- Setting the application id to 101
    apex_application_install.set_application_id(101);
    apex_application_install.generate_offset();
    
    -- Setting the Schema
    apex_application_install.set_schema(l_schema_name);
    
    -- Setting application alias
    apex_application_install.set_application_alias('ASK-ORACLE');
    
    -- Set Auto Install Supporting Objects
    apex_application_install.set_auto_install_sup_obj( p_auto_install_sup_obj => true );
    
    END;
/

@f101.sql