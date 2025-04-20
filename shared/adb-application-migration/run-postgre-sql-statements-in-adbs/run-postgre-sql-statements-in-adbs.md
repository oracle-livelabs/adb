
# Run PostgreSQL Statements in Autonomous Database Serverless

## Introduction
This lab introduces the `DBMS_CLOUD_MIGRATION.ENABLE_TRANSLATION` procedure that enables you to run PostgreSQL statements in your Autonomous database session.

**Note: `DBMS_CLOUD_MIGRATION.ENABLE_TRANSLATION` is not supported in Database Actions and is not supported with the Oracle APEX Service.**

Estimated Time: 30 minutes


### Objectives

In this lab, you will:
- Connect to your ADB Instance using SQLDeveloper
- Enable Real-Time SQL Translation in Your Session
- Run PostgreSQL Statements in Your Session
- Disable Real-Time SQL Translation in Your Session

### Prerequisites

This lab assumes that:

- You have performed the previous lab on provisioning an Oracle Autonomous Database instance.
- You are logged in as the ADMIN user or have EXECUTE privilege on the `DBMS_CLOUD_MIGRATION` package.
- You are connected to your Autonomous Database using SQL Worksheet.

## Task 1: Navigate to SQL Worksheet.

To complete the subsequent tasks you need to use SQL Worksheet.

1. Navigate to your SQL Worksheet and login with your credentials.

See the documentation 

## Task 2: Enable Real-Time Translation in Your Session

To run a PostgreSQL statement in your Autonomous Database you must first enable real-time SQL translation in your session. Use the `DBMS_CLOUD_MIGRATION.ENABLE_TRANSLATION` procedure to enable real-time translation for a session.

### Enable Real-Time SQL Translation in Your Session

1. Run `DBMS_CLOUD_MIGRATION.ENABLE_TRANSLATION` to enable real-time translation in your session. Copy and paste the following code into your SQL Worksheet, and then click the **Run Script (F5)** icon in the Worksheet toolbar.

    ```
    <copy>
    BEGIN
        DBMS_CLOUD_MIGRATION.ENABLE_TRANSLATION('POSTGRES');
    END;
    /
    </copy>
    ```
  ![Use DBMS_CLOUD_MIGRATION.ENABLE_TRANSLATION Procedure](images/enable-translation.png)

  This enables the real-time SQL translation in your session.

  Verify the SQL translation language for your session. Copy and paste the following query into your SQL Worksheet, and then click the **Run Script (F5)** icon in the Worksheet toolbar.

      ```
    <copy>
      SELECT SYS_CONTEXT ('USERENV','SQL_TRANSLATION_PROFILE_NAME')
      FROM DUAL;
    </copy>
    ```

  ![Use DBMS_CLOUD_MIGRATION.ENABLE_TRANSLATION Procedure](images/verify-translation.png)

This shows the enabled translation language for your session.

## Task 2: Run PostgreSQL Statements in Your Session

### Run PostgreSQL Statements in Your Session

1. Enter and run PostgreSQL statements in your database session. Copy and paste the following code into your SQL Worksheet, and then click the **Run Script (F5)** icon in the Worksheet toolbar.

    ```
    <copy>
    CREATE TABLE emp (emp_id int, name varchar(255), salary money, hire_date date);
    </copy>
    ```

   ![Use DBMS_CLOUD_MIGRATION.ENABLE_TRANSLATION Procedure](images/create-table.png)

  This entered PostgreSQL statement runs seamlessly as Oracle SQL in your session.

   Verify the table creation. Copy and paste the following code into your SQL Worksheet, and then click the **Run Script (F5)** icon in the Worksheet toolbar.

    ```
    <copy>
    DESCRIBE emp;
    </copy>
    ```

    ![Use DBMS_CLOUD_MIGRATION.ENABLE_TRANSLATION Procedure](images/desc-emp.png)

    Please note that the **MONEY** PostgreSQL datatype is automatically converted to **NUMBER** datatype.

  2. After the table **EMP** is created, you can insert records into the table. Copy and paste the following code into your SQL Worksheet, and then click the **Run Script (F5)** icon in the Worksheet toolbar.

     ```
    <copy>
    INSERT INTO emp(emp_id, name, salary, hire_date) VALUES (101, 'King',  25000, sysdate);
    INSERT INTO emp(emp_id, name, salary, hire_date) VALUES (102, 'James', 30000, sysdate);
    INSERT INTO emp(emp_id, name, salary, hire_date) VALUES (103, 'Nancy', 35000, sysdate);
    INSERT INTO emp(emp_id, name, salary, hire_date) VALUES (104, 'Lauran',35000, sysdate);
    INSERT INTO emp(emp_id, name, salary, hire_date) VALUES (105, 'Neena', 30000, sysdate);
    </copy>
    ```

     ![Use DBMS_CLOUD_MIGRATION.ENABLE_TRANSLATION Procedure](images/insert.png)

    This inserts five records into the **EMP** table.

    Use SQL SELECT statement to retrieve records from the **EMP** table.  Copy and paste the following code into your SQL Worksheet, and then click the **Run Script (F5)** icon in the Worksheet toolbar.

     ```
    <copy>
    Select emp_test.*
    FROM emp AS emp_test;
    </copy>
    ```

    ![Use DBMS_CLOUD_MIGRATION.ENABLE_TRANSLATION Procedure](images/select-emp.png)

    This retrieves five records from the **EMP** table.

## Task 3: Disable Real-Time SQL Translation in Your Session

1. Run `DBMS_CLOUD_MIGRATION.DISABLE_TRANSLATION` to disable real-time translation in your session. Copy and paste the following code into your SQL Worksheet, and then click the **Run Script (F5)** icon in the Worksheet toolbar.

     ```
    <copy>
    BEGIN
        DBMS_CLOUD_MIGRATION.DISABLE_TRANSLATION;
    END;
    /
    </copy>
    ```

    ![Use DBMS_CLOUD_MIGRATION.ENABLE_TRANSLATION Procedure](images/disable-translation.png)
This disables the real-time SQL translation in your session.

**Note:**  An error is encountered if SQL language translation is not enabled for your session.


## Acknowledgements

- **Author:**       - Shilpa Sharma, Principal User Assistance Developer
- **Contributors:** - Lauran K. Serhal, Consulting User Assistance Developer
- **Last Updated By/Date:** - Shilpa Sharma, April 2025