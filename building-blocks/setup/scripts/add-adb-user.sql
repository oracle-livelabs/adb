create or replace procedure add_adb_user(user_name varchar2, pwd varchar2) authid current_user
as
    l_count number;
    
    begin
        select count(*)
        into l_count
        from all_users
        where upper(username) = upper(user_name);

        workshop.write('create user', 1);
        if l_count > 0 then
            workshop.write(user_name || ' already exists.', -1);
            return;
        end if;
        
        -- Raise exception with an error
        workshop.write('create user ' || user_name || ' identified by ####');
        execute immediate 'create user ' || user_name || ' identified by ' || pwd;

        workshop.write('grant privileges', 1);
        --workshop.exec('grant connect to ' || user_name);
        --workshop.exec('grant resource to ' || user_name);
        workshop.exec('grant dwrole to ' || user_name);
        workshop.exec('grant console_developer to ' || user_name);
        workshop.exec('grant oml_developer to ' || user_name);
        workshop.exec('grant graph_developer to ' || user_name);
        workshop.exec('grant dcat_sync to ' || user_name);
        workshop.exec('grant soda_app to ' || user_name || ' with delegate option');
        workshop.exec('alter user ' || user_name || ' quota unlimited on data');
/*
        workshop.exec('grant unlimited tablespace to ' || user_name);
        workshop.exec('grant create table to ' || user_name);
        workshop.exec('grant create view to ' || user_name);
        workshop.exec('grant create sequence to ' || user_name);
        workshop.exec('grant create procedure to ' || user_name);
        workshop.exec('grant create job to ' || user_name);
*/

        workshop.exec('grant ALTER SESSION,
            CONNECT,        
            DEBUG CONNECT SESSION,
            RESOURCE,
            CREATE ANALYTIC VIEW,
            CREATE ATTRIBUTE DIMENSION,
            CREATE HIERARCHY,
            CREATE ANY INDEX, 
            CREATE JOB,
            CREATE MATERIALIZED VIEW,
            CREATE MINING MODEL,
            CREATE PROCEDURE,
            CREATE SEQUENCE,
            CREATE SESSION,
            CREATE SYNONYM,
            CREATE TABLE,
            CREATE TRIGGER,
            CREATE TYPE,
            CREATE VIEW to ' || user_name);
        workshop.exec('grant execute on dbms_cloud to ' || user_name);
        workshop.exec('grant execute on dbms_cloud_repo to ' || user_name);
        workshop.exec('grant execute on dbms_soda to ' || user_name);
        workshop.exec('grant execute on dbms_soda_admin to ' || user_name);
        workshop.exec('grant read on directory data_pump_dir to ' || user_name);
        workshop.exec('grant write on directory data_pump_dir to ' || user_name);
        workshop.exec('grant select on sys.v_$services to ' || user_name);
        workshop.exec('grant select on sys.dba_rsrc_consumer_group_privs to ' || user_name);
        workshop.exec('grant execute on dbms_session to ' || user_name);
        workshop.exec('alter user ' || user_name || ' grant connect through OML$PROXY');
        workshop.exec('alter user ' || user_name || ' grant connect through GRAPH$PROXY_USER');
        -- workshop.exec('alter user ' || user_name || ' default role connect, resource, dwrole, oml_developer, graph_developer');
            
        commit;
        
        workshop.write('enable database actions access', 1);
        if user = 'ADMIN' then
            -- using ORDS package instead of ORDS_ADMIN. Seems to work w/in PLSQL, whereas ORDS_ADMIN does not.
            ords.enable_schema (
                    p_enabled               => TRUE,
                    p_schema                => user_name,
                    p_url_mapping_type      => 'BASE_PATH',
                    p_auto_rest_auth        => TRUE   
                );                
        else
            workshop.write('TO DO', 1);
            workshop.write('Run the following as "ADMIN" in SQL Worksheet to allow your new user to use the SQL Tools', 2);
            workshop.write('begin 
                    ords_admin.enable_schema (
                        p_enabled               => TRUE,
                        p_schema                => ''' || user_name || ''',
                        p_url_mapping_type      => ''BASE_PATH'',
                        p_auto_rest_auth        => TRUE   
                    );
                    end;
                    /');
        end if;

        EXCEPTION when others then
            workshop.write('Unable to create the user.', -1);
            workshop.write(sqlerrm);
            raise;



end add_adb_user;
/

begin
    workshop.exec('grant execute on add_adb_user to public');
end;
/