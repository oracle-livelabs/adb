
# Translate PostgreSQL files to Oracle SQL

## **Introduction**
This lab introduces the `DBMS_CLOUD_MIGRATION.MIGRATE_FILE` procedure enables you to translate a file containing PostgreSQL statements to Oracle SQL.

Estimated Time: 30 minutes


### **Objectives**

In this lab, you will:

- Create a credential to access Cloud Object Storage
- Use the `DBMS_CLOUD_MIGRATION.MIGRATE_FILE` Procedure to Translate a file that contains PostgreSQL statement to Oracle SQL

### **Prerequisites**

This lab assumes that:

- You have performed the previous lab on provisioning an Oracle Autonomous Database instance.
- You are logged in as the ADMIN user or have EXECUTE privilege on the `DBMS_CLOUD_MIGRATION` package.
- You have uploaded a file containing PostgreSQL SQL statements to your Object Store bucket
- You are connected to your Autonomous Database using SQL Worksheet.

## Task 1: Connect with the SQL Worksheet

To complete the subsequent tasks you need connect to your Autonomous Database using SQL Worksheet.

1. Navigate to your SQL Worksheet and login with your credentials.

## Task 2: Create a credential to access Cloud Object Storage

1. Create a credential to access Cloud Object Store. Copy and paste the following code into your SQL Worksheet, and then click the **Run Script (F5)** icon in the Worksheet toolbar.

  ```
    <copy>
BEGIN
  DBMS_CLOUD.CREATE_CREDENTIAL (
    credential_name => 'LIVE_LAB_OBJCRED',
    username        => 'user1@example.com',
    password        => 'password'
  );
END;
/
  </copy>
  ```
  This creates a credential object to access Cloud Object Store.

## Task 3: Use the `DBMS_CLOUD_MIGRATION.MIGRATE_FILE` Procedure to Translate a PostgreSQL File to Oracle SQL

1. Run the `DBMS_CLOUD_MIGRATION.MIGRATE_FILE` procedure to migrate the PostgreSQL file to Oracle SQL. Copy and paste the following code into your SQL Worksheet, and then click the **Run Script (F5)** icon in the Worksheet toolbar.

   ```
    <copy>
    SET SERVEROUTPUT ON
BEGIN
 DBMS_CLOUD_MIGRATION.MIGRATE_FILE (
     credential_name => 'LIVE_LAB_OBJCRED',
     location_uri    => 'https://objectstorage.region.oraclecloud.com/n/namespace/b/bucket/o/files/postgresfile.sql',
     source_db       => 'POSTGRES'
    );
END;
/
  </copy>
    ```

  This translates the PostgreSQL file postgrestest.sql to Oracle SQL and generates a new file with the name postgresfile_oracle.sql.

 Run the following SQL code to verify that the output file is generated.

    ```
    <copy>
SELECT object_name 
 FROM DBMS_CLOUD.LIST_OBJECTS (credential_name => 'LIVE_LAB_OBJCRED', location_uri => 'https://objectstorage.region.oraclecloud.com/n/namespace/b/bucket/o/files');
  </copy>
    ```

  Run the following query to view the content of the postgrestest_oracle.sql file.

      ```
    <copy>
SELECT UTL_RAW.CAST_TO_VARCHAR2 (DBMS_CLOUD.GET_OBJECT(
   credential_name => 'LIVE_LAB_OBJCRED',
   object_uri => 'https://objectstorage.region.oraclecloud.com/n/namespace/b/bucket/o/files'))
FROM dual;
  </copy>
    ```

## Acknowledgements

- **Author:**       - Shilpa Sharma, Principal User Assistance Developer
- **Contributors:** - Lauran K. Serhal, Consulting User Assistance Developer
- **Last Updated By/Date:** - Shilpa Sharma, April 2025