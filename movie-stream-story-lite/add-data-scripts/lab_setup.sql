/**
    create tables used for installing data sets
**/
begin
  
  -- drop tables if they exist
  for rec in (
            select table_name
            from user_tables
            where table_name in ('MOVIESTREAM_LABS', 'MOVIESTREAM_LOG')
            )
    loop
        dbms_output.put_line('drop ' || rec.table_name);
        execute immediate 'drop table ' || rec.table_name;
    end loop;
    
    -- create the tables
    dbms_output.put_line('create table moviestream_labs');
    dbms_cloud.create_external_table(table_name => 'moviestream_labs',
                file_uri_list => 'https://raw.githubusercontent.com/martygubar/learning-library/master/data-management-library/autonomous-database/shared/movie-stream-story-lite/add-data-scripts/moviestream-lite-labs.json',
                format => json_object('skipheaders' value '0', 'delimiter' value '\n','ignoreblanklines' value 'true'),
                column_list => 'doc varchar2(30000)'
            );
  
    dbms_output.put_line('create table moviestream_log');
    execute immediate ('create table moviestream_log (
                            execution_time timestamp (6),
                            message varchar2(32000 byte)
                        )'
                        );  
end;
/

/**
    create procedure that writes logs
**/
create or replace procedure moviestream_write 
(
  message in varchar2 default ''
) as 
begin
    dbms_output.put_line(to_char(systimestamp, 'DD-MON-YY HH:MI:SS') || ' - ' || message); 
    
    if message is not null then
        execute immediate 'insert into moviestream_log values(:t1, :msg)' 
                using systimestamp, message;
        commit;
    end if;

end moviestream_write;
/

/**
    Create procedure that runs commands
**/
create or replace procedure moviestream_exec 
(
  sql_ddl in varchar2,
  raise_exception in boolean := false
  
) as 
begin
    -- Wrapper for execute immediate
    moviestream_write(sql_ddl);
    execute immediate sql_ddl;
    
    exception
      when others then
        if raise_exception then
            raise;
        else    
            moviestream_write(sqlerrm);
        end if;
    
end moviestream_exec;
/

/**
    install other scripts
**/
declare
    l_owner     varchar2(100) := 'martygubar';
    l_repo_name varchar2(100) := 'learning-library';
BEGIN
  -- Loop over the list of labs and install the script
  for rec in (
            select  lab_num,
                    script
            from (
                select  to_number(m.doc.lab_num) as lab_num,
                        m.doc.script as script
                from moviestream_labs m
                )
            order by lab_num asc
            )
    loop
        dbms_cloud_repo.install_file(
            repo => dbms_cloud_repo.init_github_repo(                 
                     repo_name       => l_repo_name,
                     owner           => l_owner
                    ),
            file_path     =>     rec.script,
            stop_on_error => false
          );

    end loop;
END;
/