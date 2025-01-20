# Monitor Autonomous Database from Google Cloud Console

## Introduction
Cloud Monitoring lets you monitor your Oracle Database@Google Cloud resources using custom dashboards. You can create custom dashboards using Cloud Monitoring and the available Oracle Database@Google Cloud metrics and logs.

This lab walks you through the steps to view and use the monitoring metrics available for Oracle Database@Google Cloud resources using Cloud Monitoring.

You can use Cloud Monitoring to monitor your Oracle Database@Google Cloud resources using custom dashboards, and metrics charts and alerts.

Estimated Time: 15 minutes

### Objectives

As a database admin or user:
1. Set up cloud credentials and use the sample .dmp file to import data to your Autonomous database.


### Required Artifacts
- Access to a pre-provisioned Autonomous Database instance.

## Task 1: View Autonomous Database Metrics in Google Cloud

You can view available Oracle Database@Google Cloud metrics using Cloud Monitoring in the Google Cloud console.

To view an available metric:

1. After logging into your Google Cloud Console, search for 'Metrics explorer' in the **Search** bar. Click **Metrics explorer**.

    ![Cloud Metrics Explorer](./images/cloud-metrics-explorer-search.png " ") 

2. In the **Queries** section, click **Select a metric**, and choose **Autonomous Database**. Under **ACTIVE METRIC CATEGORIES** select **Autonomousdatabase**. Click **CPU Utilization** under **ACTIVE METRICS**.

    ![Cloud Metrics Explorer](./images/metrics-explorer.png " ") 

3. Click **Apply**. The metric is displayed. You can view your metric as a chart, table, or both by selecting the option in the results pane.

    ![Cloud Metrics Explorer](./images/cpu-util.png " ")

4. Similarly a number of other Metrics can be viewed for Autonomous Database.

## Task 2: Set up User credentials in your target autonomous database

Now that we have the Access key and the Secret, let's set up the target database to read from the Google Cloud Storage and import data.

Here, we will use **SQLcl** to demonstrate the steps needed to set up Google Cloud Storage credentials.

Download and install sqlcl on the Google Cloud Compute VM instance.

You can download sqlcl from https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-24.3.2.330.1718.zip

- Once connected to your autonomous database as ***admin*** user, run the following pl/sql procedure, replacing the username with **Access key** and password with **Secret**.

    ```
    <copy>
    set define off
    begin
    DBMS_CLOUD.CREATE_CREDENTIAL(
    credential_name => 'GOOGLE_CRED_NAME',
    username => 'Access_key',
    password => 'Secret'
    );
    END;
    /
    </copy>
    ```

- Here's a screenshot of the above command run from a SQLcl.

    ![Cloud Storage Settings](./images/create-cloud-cred.png " ") 

- Ensure the pl/sql procedure is executed successfully from the log message.

- Test the access to Google Cloud Storage

    ```
    <copy>
    SELECT * FROM DBMS_CLOUD.LIST_OBJECTS('GOOGLE_CRED_NAME', 'https://gcpdatapump.storage.googleapis.com/');
    </copy>
    ```

    ![This image shows the result of performing the above step.](./images/query-gcpdatapump.png " ")

## Task 3: Import data from Azure storage using impdp utility

- From the same SQLcl window run the data pump import command.

    ```
    <copy>
    datapump import -
    -schemas HR -
    -excludeexpr "IN ('PROCEDURE', 'PACKAGE')" -
    -directory data_pump_dir -
    -credential GOOGLE_CRED_NAME -
    -remaptablespaces USERS=DATA -
    -dumpuri https://gcpdatapump.storage.googleapis.com/HR.dmp -
    -logfile testuser1.log
     </copy>
    ```
    
    ![This image shows the result of performing the above step.](./images/import.png " ")

All Done! Your application schema was successfully imported.

You may now **proceed to the next lab**.

## Acknowledgements

*Congratulations! You have successfully completed migrating an Oracle database to the Autonomous database.*

- **Author** - Tejus Subrahmanya
- **Last Updated By/Date** - Tejus Subrahmanya, August 2024