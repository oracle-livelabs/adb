# Flashback Time Travel

## Introduction

This lab shows how to use the `Flashback Time Travel` feature on Oracle Autonomous Database.
In this lab you will learn to work with `Flashback Time Travel` for a table in an Oracle Autonomous Database (Autonomous Data Warehouse [ADW] and Autonomous Transaction Processing [ATP]) on Oracle Cloud Interface.

Estimated Lab Time: 30 minutes (25 minutes if you are running this workshop in an **Oracle LiveLabs sandbox** hosted environment)


### About Oracle Flashback Time Travel

Oracle Flashback Technology is a group of Oracle Database features that let you view past states of database objects or to return database objects to a previous state without using point-in-time media recovery.

Oracle Flashback Time Travel lets you track and store transactional changes to a table over its lifetime. Flashback Time Travel is useful for compliance with record stage policies and audit reports. You can also use Oracle Flashback Time Travel in various scenarios such as accessing historical data, and selective data recovery.

### Objectives

In this lab, you will:

- Connect with SQL Worksheet
- Enable Flashback Time Travel
- Retrieve Historical Data
- Disable Flashback Time Travel
- Restore a Dropped Table
- Modify the Retention Time for Flashback Time Travel
- Purge Historical Data


### Prerequisites

This lab assumes you have:

- Performed the previous lab on provisioning an Oracle Autonomous Database

- Performed the previous lab on Work with Free Sample Data Sets

- You must be logged an as the `ADMIN` user or have `FLASHBACK ARCHIVE` privilege on `FLASHBACK_ARCHIVE`.


## Task 1: Connect with SQL Worksheet

To complete the subsequent tasks you need to use SQL Worksheet.

1. Return to `Database actions` and click `SQL` to start SQL Worksheet and log in as the `ADMIN` user.

   ![Create EMPLOYEES table](images/fda_dbactions.png "Create EMPLOYEES table")

## Task 2: Enable Flashback Time Travel while Creating a Table

To utilize the Flashback Table features for your tables you must first enable flashback for your table which is by default disabled for new and existing tables.
You can enable Flashback Time Travel for an existing table or a new table that you are creating.

1. Execute the following command to enable Flashback Time Travel when you create the `EMPLOYEES` table:

    ```
    <copy>CREATE TABLE employees (EMPNO NUMBER(4) NOT NULL, ENAME VARCHAR2(10), JOB VARCHAR2(9), MGR NUMBER(4)) FLASHBACK ARCHIVE;</copy>
    ```

    ![Create EMPLOYEES table](images/fda-create-emp-table.png "Create EMPLOYEES table")

    This creates the `EMPLOYEES` table with Flashback Time Travel enabled.


## Task 3: Enable Flashback Time Travel for an Existing Table

You can enable Flashback Time Travel for an existing table also, if not already enabled.
In this task, you will first create the `DEPARTMENTS` table and then enable the Flashback Time Travel for the table.

1. Create the `DEPARTMENTS` table by executing the following command:


    ```
    <copy>CREATE TABLE departments (DEPNO NUMBER(4) PRIMARY KEY, DNAME VARCHAR2(10), MGR NUMBER(4), LOC_ID NUMBER(4));</copy>
    ```

    ![Create DEPARTMENTS table](images/fda-create-dept-table.png "Create DEPARTMENTS table")

    This creates the `DEPARTMENTS` table.

2. Execute the following command to enable Flashback Time Travel on the existing `DEPARTMENTS` table, for which Flashback Time Travel is not currently enabled:

    ```
    <copy>ALTER TABLE departments FLASHBACK ARCHIVE;</copy>
    ```

    ![ENable flashback time travel for DEPARTMENTS table](images/fda-enable-ftt-dept.png "ENable flashback time travel for DEPARTMENTS table")

    This enables the Flashback Time Travel for the `DEPARTMENTS` table.

## Task 4: Retrieve a Past State of Data from a Table Using Flashback Query

Once the Flashback Time Travel is enabled for a table you can view the past states of data in the table.

You can use the `SELECT` statement with an `AS OF` clause to retrieve data, as it existed at an earlier time. The query explicitly references a past time through a time stamp or System Change Number (SCN) to return committed data that was current at that point in time.

In this task, you will insert records into the `EMPLOYEES` table, update the records and view the past states of table data.

1. Run the following code snippet in your SQL Worksheet to insert records into the `EMPLOYEES` table:

    ```
    <copy>INSERT INTO employees (empno, ename, job, mgr) VALUES (1001, 'Jhon', 'IT_MAN', NULL);
    INSERT INTO employees (empno, ename, job, mgr) VALUES (1002, 'King', 'HR_MAN', NULL);
    INSERT INTO employees (empno, ename, job, mgr) VALUES (1003, 'Joel', 'IT_MAN', NULL);
    INSERT INTO employees (empno, ename, job, mgr) VALUES (1004, 'Laurent', 'VP', NULL);
    INSERT INTO employees (empno, ename, job, mgr) VALUES (1005, 'Peter', 'VP', NULL);
    COMMIT;</copy>
    ```

    ![Inserting into the EMPLOYEES table](images/fda-insert-emp-table.png "Inserting data into the EMPLOYEES table")

2. Keep a note of the current timestamp in order to see the current state of data in the future. Run the following command to retrieve the current timestamp of the database:

    ```
    <copy>SELECT SYSTIMESTAMP FROM dual;</copy>
    ```

    ![Query database for the current timestmap](images/fda-timestamp-query.png "Query database for the current timestmap")

3. Update a record in the `EMPLOYEES` table. For example, to update the `MGR` field for EMPNO 1002, run the following command in your SQL Worksheet:

    ```
    <copy>UPDATE EMPLOYEES
    SET mgr=1004
    WHERE empno=1002;</copy>
    ```

    ![Update the employees table](images/fda-emp-update.png "Update the employees table")


4. To verify the update execute the following command in your SQL Worksheet:

    ```
    <copy>SELECT * FROM EMPLOYEES
    WHERE empno=1002;</copy>
    ```

    ![Verify the update](images/fda-verify-update-emp.png "Verify the update")


5. Now, you can use Oracle Flashback Query to examine the contents of the table as it existed at a previous timestamp. Run the following command in your SQL Worksheet:

    > **Note:** Copy the following command, however, substitute in your database's timestamp in place of the one used in this code example.

    ```
    <copy>SELECT * FROM employees
    AS OF TIMESTAMP
    TO_TIMESTAMP('2023-07-12 12:30:45','YYYY-MM-DD HH:MI:SS')
    WHERE empno=1002;</copy>
    ```
   ![Query the employees table using AS OF clause](images/fda-flashback-query.png "Query the employees table using AS OF clause")
    Observe the result as it displays the `NULL` for the `MGR` field.

## Task 5: Disable Flashback Time Travel

You can disable the `FLASHBACK TIME TRAVEL` for a table using the `NO FLASHBACK ARCHIVE` clause.
In this task you will disable the `FLASHBACK TIME TRAVEL` for the `EMPLOYEES` table.

1. To disable Flashback Time Travel for the EMPLOYEE table, run the following code snippet in your SQL Worksheet:

    ```
    <copy>ALTER TABLE employees NO FLASHBACK ARCHIVE;</copy>
    ```

    ![Disable Flashback Time Travel for the Employees table](images/fda-noflashback-archive.png  "Disable Flashback Time Travel for the Employees table")

## Task 6: Restore a Table Using Flashback Table

You can use the `FLASHBACK TABLE` statement along with the `TO BEFORE DROP` clause to restore a dropped table.

When you drop a table, Oracle assigns a system-generated name to the table and the table becomes a part of the recycle bin. You can restore the dropped table using either the original user-specified name of the table or the system-generated name.
The dropped table is restored from recycle bin, along with all possible dependent objects.

In this task, you will drop the `DEPARTMENTS` table and then restore it back using the `FLASHBACK TABLE` command.

> **Note:** You must first disable `FLASHBACK ARCHIVE` for a table to drop the table that has `FLASHBACK ARCHIVE` enabled for it.

1. Disable Flashback Time Travel for the `DEPARTMENTS` table.

    ```
    <copy>
    ALTER TABLE departments NO FLASHBACK ARCHIVE;
    </copy>
    ```
    ![Disable Flashback Time Travel for the departments table](images/fda-dept-noftt.png  "Disable Flashback Time Travel for the departments table")
     This disables the `Flashback Time Travel` on the `DEPARTMENTS` table.

2. Drop the `DEPARTMENTS` table using the following command:

    ```
    <copy>
    DROP TABLE departments;
    </copy>
    ```
    ![Drop the departments table](images/fda-drop-dept.png  "Drop the departments table")
    The table is dropped and now a part of the recycle bin and has a system-generated name.

3. Query the `RECYCLEBIN` to view the dropped `DEPARTMENTS` table.

    ```
    <copy>
    SELECT object_name, original_name FROM RECYCLEBIN;
    </copy>
    ```
    ![Query the recycle bin to view the dropped departments table](images/fda-recyclebin.png  "Query the recycle bin to view the dropped departments table")
    This shows the dropped table `DEPARTMENTS` in the recycle bin.

4. Restore the `DEPARTMENTS` table.

    ```
    <copy>
    FLASHBACK TABLE departments TO BEFORE DROP
    </copy>
    ```
    ![Restore the dropped departments table](images/fda-restore-dept.png  "Restore the dropped departments table")
    This restores the `DEPARTMENTS` table from the recycle bin.

5. Verify the existence of the `DEPARTMENTS` table.

    ```
    <copy>
    DESC departments;
    </copy>
    ```
    ![Verify the departments table](images/fda-verify-dept.png "Verify the departments table")

## Task 7: Modify Flashback Archive Retention Time

 A Flashback Archive is configured with retention time. Data archived in the Flashback Archive is retained for the retention time specified when the Flashback Archive was created. You can modify the retention time for Flashback Time Travel for your database.

1. To modify the retention time to 90 days for Flashback Time Travel, run the following code snippet in your SQL Worksheet:

    ```
    <copy>
    BEGIN
      DBMS_CLOUD_ADMIN.SET_FLASHBACK_ARCHIVE_RETENTION(
      retention_days => 90);
    END;
    </copy>
    ```
    ![Modify the retention period for the Flashback Data Archive](images/fda-retention-period.png "Modify the retention period for the Flashback Data Archive")

> Note: To modify the retention time for Flashback Time Travel you must be logged in as the `ADMIN` user or you must have execute privilege on `DBMS_CLOUD_ADMIN`.

## Task 8: Purge Historical Data

You can purge the `Flashback ARCHIVE` based on the timestamp or SCN or you can also purge all Flashback Time Travel data.

In this task you will learn about the steps to purge `Flashback Time Travel`.

1. To purge `Flashback Time Travel` historical data before a specified timestamp, run the following code snippet in your SQL Worksheet:

    ```
   <copy>BEGIN
   DBMS_CLOUD_ADMIN.PURGE_FLASHBACK_ARCHIVE(scope => 'timestamp', before_timestamp => '01-Jul-2023 12:00:00');
   END;
   /</copy>
    ```
    ![Purge the Flashback Data Archive based on the provided timestamp](images/fda_purge_timestamp.png "Purge the Flashback Data Archive based on the provided timestamp")
    This purges the flashback historical data based on the provided `timestamp` from the `Flashback Data Archive`.

2. To purge `Flashback Time Travel` historical data before a specified `SCN`, run the following code snippet in your SQL Worksheet:

    ```

    <copy>BEGIN
    DBMS_CLOUD_ADMIN.PURGE_FLASHBACK_ARCHIVE(scope => 'scn',before_scn=> '38567332107905');
    END;
    /</copy>
    ```

    ![Purge the Flashback Data Archive based on the provided scn](images/fda-purge-scn.png  "Purge the Flashback Data Archive based on the provided scn")
     This purges the flashback historical data based on the `scn` from the `Flashback Data Archive`.

3. To purge all `Flashback Time Travel` historical data, run the following code snippet in your SQL Worksheet:

    ```

    <copy>BEGIN
    DBMS_CLOUD_ADMIN.PURGE_FLASHBACK_ARCHIVE(scope => 'ALL');
    END;
    /</copy>
    ```

    ![Purge all Flashback Time Travel Data](images/fda-purge-all.png "Purge all Flashback Time Travel Data")
    This purges all the flashback historical data from the `Flashback Data Archive`.
> **Note:** To purge the `Flashback Data ARchive` you must be logged in as the `ADMIN` user or you must have execute privilege on `DBMS_CLOUD_ADMIN`.

## Want to Learn More?

- See the documentation [Use Flashback Time Travel](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/flashback-time-travel-autononomous.html#GUID-A98E1F8B-FAE4-4FFF-955D-3A0E5F8EBC4A)
- For more information see [How to Use Flashback Time Travel in Autonomous Database](https://blogs.oracle.com/datawarehousing/post/flashback-time-travel-autonomous-database#:~:text=Retention%20of%20Historical%20Changes%3A%20Flashback,the%20timestamp%20of%20each%20change.).

## Acknowledgments

- **Author** - Shilpa Sharma, Senior User Assistance Developer, Database Development
- **Contributor** - Rick Green, Principal User Assistance Developer, Database Development
- **Last Updated By/Date** - Shilpa Sharma, October, 2023
