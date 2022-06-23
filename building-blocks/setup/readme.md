# Install workshop utilities
Run the setup. You'll find all of the scripts required to set up the labs
It also includes the ability to install any data set.

## Workshop Utility Setup
```sql
<copy>
declare
    l_git varchar2(4000);
    l_repo_name varchar2(100) := 'adb-get-started';
    l_owner varchar2(100) := 'martygubar';
    l_package_file varchar2(200) := 'setup/workshop-setup.sql';
begin
    -- get a handle to github
    l_git := dbms_cloud_repo.init_github_repo(
                 repo_name       => l_repo_name,
                 owner           => l_owner );

    -- install the package header
    dbms_cloud_repo.install_file(
        repo        => l_git,
        file_path   => l_package_file);

end;
/
</copy>
```
## Add a data set