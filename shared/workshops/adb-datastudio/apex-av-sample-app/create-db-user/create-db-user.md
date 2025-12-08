# Create a Database User

## Introduction

In this lab, you will create a database user and grant necessary privileges to that user.

Estimated Time:  Less than 5 minutes.

### Objectives

In this lab, you will:

- Create a database user.
- Create an APEX workspace.

### Prerequisites:

- Complete the previous lab.

### User and APEX Manager in Oracle Database Actions

Oracle Database Actions provides GUI tools for creating and managing database users and creating APEX workspaces.  The following commands were generated using those tools.

## Task 1 - Create a Database User and APEX Workspace

As the ADMIN user in SQL Worksheet, create a new database user and grant the required privileges. To allow access to the Database Actions tool set the user is also enabled for Oracle REST Data Services (ORDS).

1.  Run the following commands.

~~~SQL
<copy>
-- CREATE USER
CREATE USER moviestream IDENTIFIED BY Welcome#1234;

-- ROLES and GRANTS
GRANT CONNECT TO MOVIESTREAM;
GRANT DWROLE TO MOVIESTREAM;
GRANT RESOURCE TO MOVIESTREAM;
ALTER USER MOVIESTREAM DEFAULT ROLE CONNECT,DWROLE,RESOURCE;
GRANT APEX_ADMINISTRATOR_ROLE TO MOVIESTREAM;
ALTER USER moviestream QUOTA UNLIMITED on data;

-- ENABLE REST
BEGIN
    ORDS.ENABLE_SCHEMA(
        p_enabled => TRUE,
        p_schema => 'MOVIESTREAM',
        p_url_mapping_type => 'BASE_PATH',
        p_url_mapping_pattern => 'moviestream',
        p_auto_rest_auth=> TRUE
    );
    commit;
END;
/
</copy>
~~~

## Task 2 - Create an APEX Workspace

As the ADMIN user in SQL Worksheet, create a new workspace and APEX user.

~~~SQL
<copy>
BEGIN
    APEX_INSTANCE_ADMIN.ADD_WORKSPACE(
        p_workspace => 'MOVIESTREAM',
        p_primary_schema => 'MOVIESTREAM');

    -- SET WORKSPACE
    APEX_UTIL.SET_WORKSPACE(
        p_workspace => 'MOVIESTREAM');

    -- CREATE APEX USER
    APEX_UTIL.CREATE_USER(
        p_user_name => 'MOVIESTREAM',
        p_web_password => 'Welcome#1234',
        p_developer_privs => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
        p_email_address => 'JOE@ANYMAIL.COM',
        p_default_schema => 'MOVIESTREAM',
        p_change_password_on_first_use => 'N');
        COMMIT;
END;
/
</copy>
~~~

Your database user and APEX workspace are now ready to use.

You may now **proceed to the next lab**

## Acknowledgements

- Created By/Date - William (Bud) Endress, Product Manager, Autonomous AI Database, June 2023
- Last Updated By - William (Bud) Endress, May 2024

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C)  Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
