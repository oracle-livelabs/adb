/*
1. Begin by adding based workshop packages,
2. Create a moviestream user

*/

-- Install base moviestream
-- Install the setup file from github 
declare
    l_git varchar2(4000);
    l_repo_name varchar2(100) := 'common';
    l_owner varchar2(100) := 'martygubar';
    l_package_file varchar2(200) := 'building-blocks/setup/workshop-setup.sql';
begin
    -- get a handle to github
    l_git := dbms_cloud_repo.init_github_repo(
                repo_name       => l_repo_name,
                owner           => l_owner );

    -- install the package header
    dbms_cloud_repo.install_file(
        repo        => l_git,
        file_path   => l_package_file,
        stop_on_error => false);

end;
/

-- Add the MOVIESTREAM  user
begin
    workshop.write('Begin demo install');
    workshop.write('add user MOVIESTREAM', 1);
    add_adb_user('MOVIESTREAM','watchS0meMovies#');
    
    ords_admin.enable_schema (
        p_enabled               => TRUE,
        p_schema                => 'MOVIESTREAM',
        p_url_mapping_type      => 'BASE_PATH',
        p_auto_rest_auth        => TRUE   
    );    
    
end;
/

-- connect as moviestream and run movieapp-add-data.sql
