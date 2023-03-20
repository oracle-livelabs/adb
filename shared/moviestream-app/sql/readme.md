
**To install the database objects required for the demo. Connect to ADB as ADMIN:**

    ```sql
    declare
        l_git varchar2(4000);
        l_repo_name varchar2(100) := 'adb';
        l_owner varchar2(100) := 'martygubar';
        l_package_file varchar2(200) := 'shared/moviestream-app/sql/movieapp-initialize-db.sql';
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
    ```

Then, connect as MOVIESTREAM user and run the following:    

*Moviestream password is hardcoded to: watchS0meMovies#*
     ```sql
    declare
        l_git varchar2(4000);
        l_repo_name varchar2(100) := 'adb';
        l_owner varchar2(100) := 'martygubar';
        l_package_file varchar2(200) := 'shared/moviestream-app/sql/movieapp-add-data.sql';
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
    ```