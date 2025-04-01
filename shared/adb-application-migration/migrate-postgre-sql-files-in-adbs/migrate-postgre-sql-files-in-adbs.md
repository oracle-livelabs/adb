
# Translate PostgreSQL files to Oracle SQL

## **Introduction**
This lab introduces the `DBMS_CLOUD_MIGRATION.MIGRATE_FILE` procedure enables you to translate a file containing PostgreSQL statements to a file containing Oracle SQL statements.

Estimated Time: 30 minutes


### **Objectives**

In this lab, you will:
- Upload PostgreSQL file in Object Storage
- Connect with SQL Worksheet
- Use the `DBMS_CLOUD_MIGRATION.MIGRATE_FILE` Procedure to Translate a file that contains PostgreSQL statement to Oracle SQL

### **Prerequisites**

This lab assumes that:

- You have performed the previous lab on provisioning an Oracle Autonomous Database instance.
- You are logged in as the ADMIN user or have EXECUTE privilege on the `DBMS_CLOUD_MIGRATION` package.
- You are connected to your Autonomous Database using SQL Worksheet.

## Task 2: Use the `DBMS_CLOUD_MIGRATION.MIGRATE_SQL` Procedure to Translate a PostgreSQL statement to Oracle SQL

The `DBMS_CLOUD_MIGRATION.MIGRATE_FILE` procedure accepts a SQL file containing SQL statements written in PostgreSQL as input, translates the statements to Oracle SQL and generates a new file containing Oracle SQL.

### Run the `DBMS_CLOUD_MIGRATION.MIGRATE_FILE` procedure

1. Use `DBMS_CLOUD_MIGRATION.MIGRATE_FILE` to translate PostgreSQL file to Oracle SQL. Copy and paste the following code into your SQL Worksheet, and then click the **Run Script (F5)** icon in the Worksheet toolbar.

    ```
    <copy>
    SET SERVEROUTPUT ON
BEGIN
 DBMS_CLOUD_MIGRATION.MIGRATE_FILE (
     credential_name => 'OCI$RESOURCE_PRINCIPAL',
     location_uri    => 'https://objectstorage.region.oraclecloud.com/n/namespace/b/bucket/o/files/postgresfile.sql',
     source_db       => 'POSTGRES'
    );
END;
/
  </copy>
    ```

  This accepts PostgreSQL statement as input and translates it to Oracle SQL. The translated statement is then assigned to the `translated_sql_output` variable.
  You can display the output (translated statement) using `DBMS_OUTPUT.PUT_LINE`.

## Task 2: Use the `DBMS_CLOUD_MIGRATION.MIGRATE_SQL` Function to Translate a PostgreSQL statement to Oracle SQL

The `DBMS_CLOUD_MIGRATION.MIGRATE_SQL`function  enables you to translate a non-SQL statement to Oracle SQL. With the `DBMS_CLOUD_MIGRATION.MIGRATE_SQL` function you can translate only one SQL statement per call.

**Note:**  With the `DBMS_CLOUD_MIGRATION.MIGRATE_SQL` function you can translate only one SQL statement per call.

### Run the `DBMS_CLOUD_MIGRATION.MIGRATE_SQL` function

1. Translate PostgreSQL statement to Oracle SQL using the `DBMS_CLOUD_MIGRATION.MIGRATE_SQL` function. Copy and paste the following code into your SQL Worksheet, and then click the **Run Script (F5)** icon in the Worksheet toolbar.

    ```
    <copy>
    SELECT DBMS_CLOUD_MIGRATION.MIGRATE_SQL(
        'CREATE TABLE emp (employee_id int, last_name VARCHAR(25), salary int, hire_date date);',
        'POSTGRES') AS output
        FROM DUAL;
    </copy>
    ```
  ![Use DBMS_CLOUD_MIGRATION.MIGRATE_SQL Procedure](images/migrate-sql-function.png)

The function version of the `DBMS_CLOUD_MIGRATION.MIGRATE_SQL` subroutine accepts a PostgreSQL statement as a function parameter and translates the statement to Oracle SQL.

## Acknowledgements

- **Author:**       - Shilpa Sharma, Principal User Assistance Developer
- **Contributors:** - Lauran K. Serhal, Consulting User Assistance Developer
- **Last Updated By/Date:** - Shilpa Sharma, March 2025