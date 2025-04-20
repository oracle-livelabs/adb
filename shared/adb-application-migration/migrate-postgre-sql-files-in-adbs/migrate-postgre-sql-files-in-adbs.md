
# Translate PostgreSQL files to Oracle SQL

## **Introduction**
This lab introduces the `DBMS_CLOUD_MIGRATION.MIGRATE_FILE` procedure enables you to translate a file containing PostgreSQL statements to Oracle SQL.

Estimated Time: 30 minutes


### **Objectives**

In this lab, you will:

- Upload a file containing PostgreSQL SQL statements to your Object Storage bucket
- Create a credential to access Cloud Object Storage
- Use the `DBMS_CLOUD_MIGRATION.MIGRATE_FILE` Procedure to Translate a file that contains PostgreSQL statement to Oracle SQL

### **Prerequisites**

This lab assumes that:

- You have performed the previous lab on provisioning an Oracle Autonomous Database instance.
- You are logged in as the ADMIN user or have EXECUTE privilege on the `DBMS_CLOUD_MIGRATION` package.
- You are connected to your Autonomous Database using SQL Worksheet.

## Task 1: Upload a File Containing PostgreSQL SQL Statements to Object Storage

1. Open the **Navigation** menu in the Oracle Cloud console and click **Storage**. Under **Object Storage & Archive Storage**, click **Buckets**.

2. On the **Buckets** page, select the compartment that contains your bucket from the **Compartment** drop-down list in the **List Scope** section. Make sure you are in the region where your bucket was created.

3. On the **Buckets** page, click the bucket's name link to which you want to upload the files. The **Bucket Details** page is displayed.


![Use DBMS_CLOUD_MIGRATION.ENABLE_TRANSLATION Procedure](images/bucket_page.png)

4. Scroll down the page to the **Objects** section, and then click **Upload**.

![Use DBMS_CLOUD_MIGRATION.ENABLE_TRANSLATION Procedure](images/upload.png)

5. In the **Upload Objects** panel, you can drag and drop a single or multiple files into the **Choose Files from your Computer** field or click **select files** to choose the file that you want to upload from your computer.

![Use DBMS_CLOUD_MIGRATION.ENABLE_TRANSLATION Procedure](images/upload_file.png)

6. Click **Upload** to upload the selected file to the bucket.

7. When the file is uploaded, click **Close** to close the **Upload Objects** panel. The **Bucket Details** page is re-displayed. The newly uploaded file is displayed in the **Objects** section.

![Use DBMS_CLOUD_MIGRATION.ENABLE_TRANSLATION Procedure](images/uploaded_file.png)

8. To return to the **Buckets** page, click **Object Storage** in the breadcrumbs.

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