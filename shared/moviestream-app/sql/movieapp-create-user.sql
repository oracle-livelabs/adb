
drop user moviestream cascade;
create user moviestream identified by "ironMan_3_pg";
grant unlimited tablespace to moviestream ;

-- Grant roles/privileges to user
grant dwrole to moviestream ;
grant oml_developer to moviestream ;
grant graph_developer to moviestream ;
grant console_developer to moviestream ;
grant dcat_sync to moviestream ;
grant soda_app to moviestream with delegate option;

-- These grants are required in order to make plsql automation to work
grant select on v$services to moviestream ;
grant select on dba_rsrc_consumer_group_privs to  moviestream ;
grant execute on dbms_session to  moviestream ;
grant execute on dbms_cloud to  moviestream ;
grant execute on dbms_soda to moviestream;
grant execute on dbms_soda_admin to moviestream;

grant read,write on directory data_pump_dir to moviestream ;
grant ALTER SESSION,
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
        CREATE VIEW to moviestream;
        
grant inherit privileges on user admin to moviestream ;
alter user moviestream grant connect through OML$PROXY;
alter user moviestream grant connect through GRAPH$PROXY_USER;

begin
    ords.enable_schema (
        p_enabled               => TRUE,
        p_schema                => 'MOVIESTREAM',
        p_url_mapping_type      => 'BASE_PATH',
        p_auto_rest_auth        => TRUE   
    );
    commit;
end;
/
