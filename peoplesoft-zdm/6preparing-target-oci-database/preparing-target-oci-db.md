# Configure OCI ADB-S Database for PeopleSoft

## Introduction

This lab walks you through the steps to configure ADB-S database for PeopleSoft before performing the  "**ZDM**" Migration.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:
* Run SQL scripts to configure ADB-S for PeopleSoft
 

### Prerequisites
* zdm user login to the on-premise system and connected to ADB-S database using ADB wallet


## Task: Login to ADB-S and perform the SQL execution

Login to the on-premise PeopleSoft system as zdm user and connect to the ADB-S database and execute the following SQL commands for preparing the database before performing the ZDM operation

   ```
   <copy>[zdmuser@psfthcm9247 ~]$ sqlplus admin@psatp_tpurgent

   SQL*Plus: Release 19.0.0.0.0 - Production on Mon Nov 20 13:36:52 2023
   Version 19.19.0.0.0

   Copyright (c) 1982, 2022, Oracle.  All rights reserved.

   Enter password:
   Last Successful login time: Mon Nov 20 2023 13:03:39 +00:00

   Connected to:
   Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
   Version 19.21.0.1.0

   SQL> DROP ROLE PSADMIN;
   DROP ROLE PSADMIN
   *
   ERROR at line 1:
   ORA-01919: role 'PSADMIN' does not exist
   SQL> CREATE ROLE PSADMIN;
   GRANT
   CREATE SESSION,
   CREATE TABLE,
   CREATE PROCEDURE,
   CREATE SYNONYM,
   CREATE VIEW,
   CREATE TRIGGER,
   CREATE DATABASE LINK,
   CREATE MATERIALIZED VIEW,
   CREATE SEQUENCE
   TO PSADMIN ;

   Role created.

   SQL> GRANT SELECT ON USER_AUDIT_POLICIES to PSADMIN;
   Grant succeeded.
   SQL> GRANT EXECUTE ON DBMS_FGA to PSADMIN;
   Grant succeeded.
   SQL> grant execute on DBMS_METADATA to PSADMIN;
   Grant succeeded.
   SQL> grant execute on DBMS_MVIEW to PSADMIN;
   Grant succeeded.
   SQL> grant execute on DBMS_SESSION to PSADMIN;
   Grant succeeded.
   SQL> grant execute on DBMS_STATS to PSADMIN;
   Grant succeeded.
   SQL> grant execute on DBMS_XMLGEN to PSADMIN;
   Grant succeeded.
   SQL> grant execute on DBMS_APPLICATION_INFO to PSADMIN;
   Grant succeeded.
   SQL> grant execute on dbms_refresh to PSADMIN;
   Grant succeeded.
   SQL> grant execute on dbms_job to PSADMIN;
   Grant succeeded.
   SQL> grant execute on dbms_lob to PSADMIN;
   Grant succeeded.
   SQL> grant execute on DBMS_OUTPUT to PSADMIN;
   Grant succeeded.
   SQL> GRANT CREATE MATERIALIZED VIEW TO PSADMIN;
   Grant succeeded. </copy>
   ```

You may now **proceed to the next lab.**

## Acknowledgements
* **Authors** - Deepak Kumar M, Principal Cloud Architect
* **Contributors** - Deepak Kumar M, Principal Cloud Architect
* **Last Updated By/Date** - Deepak Kumar M, Principal Cloud Architect, November 2023


