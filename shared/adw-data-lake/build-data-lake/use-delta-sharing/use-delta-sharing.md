# Create External Tables Using the Delta Sharing Protocol

## Introduction

Delta Sharing is an open protocol for secure real-time data sharing across multiple platforms. It allows sharing both static and dynamic data and is designed to be easy for both providers and consumers to use with their existing data and workflows. The Delta Sharing protocol is based on Parquet, which most tools already support. The protocol design goals are:

* Share live data directly without copying it.
* Support a wide range of clients. Recipients can directly consume data from their tools of choice without installing a new platform.
* Provide strong security, auditing, and governance. It enables you to grant, track, and audit access to shared data from a single point of enforcement.
* Scale to terabyte-scale datasets.

Oracle Autonomous AI Database supports the Delta Sharing protocol.

Estimated Time: 10 minutes

Watch the video below for a quick walk-through of the lab.
[](youtube:YH7pPGEaxNI)

### Objectives

In this lab, you will:

* Access the Delta Sharing public examples on GitHub
* Download the profile file that you will use to access the data share
* Navigate to Data Share in Oracle Autonomous AI Database
* Consume the data share and create an external table based on one of the share's files

### Prerequisites

This lab requires the completion of **Lab 1**: Set up the Workshop Environment > **Task 2**: Provision the Autonomous AI Database Instance from the **Contents** menu on the left.

## Task 1: Access the Delta Sharing Public Examples on GitHub

1. Log in to your GitHub account. If you don't have one, create a free GitHub using https://github.com/.

2. Navigate to the Public Delta Sharing Examples using the following URL:

    ```
    <copy>
    https://github.com/delta-io/delta-sharing/tree/main/examples
    </copy>
    ```

    ![Navigate to the public delta sharing examples.](./images/github-public-examples.png " ")

3. Click the **open-datasets-share** Delta Sharing profile link that is included with this example. The profile details are displayed. For a client to consume this Delta Share, it needs a profile. This profile contains the **`endpoint`** and **`bearerToken`** (the password) that you will need in order to access the delta sharing dataset.

    ![Click the delta sharing profile link.](./images/share-profile.png " ")

4. Click the **Download** icon to download the Delta Sharing profile for this example to your local **Downloads** folder.

    ![Click Download delta sharing profile file.](./images/download-share-profile.png " ")

    The **`open-dataset.share`** file is downloaded.

    ![Profile file is downloaded.](./images/file-downloaded.png " ")

## Task 2: Navigate to Data Share

1. Navigate to the **Launchpad** page to access Data Sharing. Click the **Data Studio** tab, and then click the **Data Share** tab.

    ![Navigate to Data Share.](./images/navigate-data-share.png " ")

2. On the **Data Share** page, click **Enable Sharing**.

    ![Enable Data Share.](./images/enable-sharing.png " ")

3. In the **Enable Sharing** dialog box, click the **`ADMIN`** schema in the **Available Schemas** section, and then click the **>** (Select) button to add the selected schema to the **Selected Schemas** section. Click **Save**.

    ![Select the admin schema.](./images/select-admin-schema.png " ")

4. If you get a message about the privileges being changed. Log out of the admin user and then log back in. The **Data Share** Home page is displayed.

    ![Data Share Home page.](./images/data-share-home.png " ")


## Task 3: Consume the Data Share

1. Click the **CONSUME SHARE** tile.

    ![Click CONSUME SHARE.](./images/click-consume-share.png " ")

2. On the **Consume Share** page, click the **Subscribe to Share Provider** drop-down list, and then select **Subscribe to Delta Share Provider**.

    ![Click Subscribe to Share Provider.](./images/click-subscribe-share-provider.png " ")

    The **Subscribe to Share Provider** wizard is displayed.

3. On the **Provider Settings** page 1 of the wizard, specify the following:

    * **Share Source:** Accept the default selection, **`Create Share Provider`**.
    * **Share Provider JSON:** Accept the default selection, **`From File`**.
    * **Delta Share Profile JSON:** Click this box. In the **Open** dialog box, navigate to the location where you downloaded the `open-datasets.share` profile, select it, and then click **Open**.
    * **Provider Name:** Enter **`training-data-share`**.

      ![Complete the Subscribe to Share Provider panel.](./images/complete-subscribe-share-provider.png " ")

4. Click **Next**. The **Add Shares** page 2 of the wizard is displayed. In the **Available Shares** section, click **DELTA_SHARING**, and then click the **>** (Select) button.

    ![Select Share.](./images/select-share.png " ")

    The **DELTA_SHARING** share is added to the **Selected Shares** section.

    ![Click Subscribe.](./images/click-subscribe.png " ")

5. Click **Subscribe**.

6. On the **Link Data** page, click the **Select Cloud Store Location or enter a public URL** drop-down list.

    ![Click drop-down list.](./images/click-location.png " ")

7. Select the **training-data-share**. The **DELTA_SHARING** data share to which you subscribed is now displayed. You can drill down on this data share to display the available data. Let's create an external table based on the **`DEFAULT.BOSTON-HOUSING`** file. Drag and drop this file onto the data linking job section.

    ![Drill-down on data share.](./images/drill-down-data-share.png " ")

    The external table to be created is displayed in the data linking job section.

    ![Target table displayed.](./images/target-table.png " ")

    You can click the **Settings** icon to display the **Link Data from Cloud Store Location** panel. You can use the various tabs to change the name of the external table name to be created, view the table's properties, view the table's data, view the SQL code used to create the table and more. Click **Close** when you're done.

    ![Click Settings.](./images/click-settings.png " ")

8. Click **Start**. 

    ![Click Start.](./images/click-start.png " ")

    A **Start Link From Cloud Store** message box is displayed. Click **Run**.

    ![Click Run.](./images/click-run.png " ")

9. After the link job is completed, make sure that the data link card has the link icon next to it. You can click the **Report** button for this link job to view a report of the total rows processed successfully and failed for the selected table.

    ![Table created.](./images/table-created.png " ")

10. Click the **`BOSTONHOUSING`** external table link to preview its data. Remember, the source data for this external table is the **`BOSTON-HOUSING`** data share. The **`BOSTONHOUSING`** panel is displayed with the **Preview** tab selected by default that displays the external table's data.

    ![Preview BOSTONHOUSING.](images/bostonhousing-preview.png)

11. Click **Close** to exit the panel and to return to the Data Load Dashboard.

<!-- Old tasks

Task 3: Create a Database Credential and List the Available Schemas and Tables

Create a new database credential that you will use in this task as follows:

1. Use the **`CREATE_CREDENTIAL`** procedure in the **`DBMS_CLOUD`** PL/SQL package to create and store the cloud service credentials in the Autonomous Database. For additional information, see the [CREATE_CREDENTIAL procedure](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/dbms-cloud-subprograms.html#GUID-742FC365-AA09-48A8-922C-1987795CF36A) documentation. Copy and paste the following code into your SQL Worksheet. You can substitute the `credential_name` with your own value. Click the **Run Script** icon in the Worksheet toolbar.

    >**Note:** It is a requirement to use **`bearer_token`** as the **`username`**.

    ```
    <copy>
    BEGIN
        dbms_cloud.create_credential(
        credential_name=>'PUBLIC_DELTA',
        username => 'bearer_token',
        password => 'faaie590d541265bcab1f2de9813274bf233');
    end;
    </copy>
    ```

    ![Create database credential.](./images/create-database-credential.png " ")

2. To identify the available schemas and tables in this Delta Sharing example, copy and paste the following code into your SQL worksheet, and then click the **Run Script** icon in the Worksheet toolbar.

     ```
    <copy>
    SELECT SHARE_NAME, SCHEMA_NAME, TABLE_NAME
    FROM
    dbms_share.discover_available_tables(
    endpoint=>'https://sharing.delta.io/delta-sharing/',
    credential_name=>'PUBLIC_DELTA');
    </copy>
    ```

     ![Query the available schemas and tables in the Delta Share.](./images/schemas-tables-displayed.png " ")

     In the next task, you will access one of the data share tables, **`BOSTON-HOUSING`**, using the Data Sharing tool.

Task 5: Create an External Table Based on a Table in the Delta Share

Navigate the **Database Actions | Launchpad** page.

1. Go back to the **Autonomous Database | Oracle Cloud Infrastructure** browser tab. On your **Autonomous Databases** page, click your **ADW-Data-Lake** Autonomous Database instance.

2. On the **ADW-Data-Lake** page, click the **Database actions** drop-down list, and then click **View all database actions**.

Task 4: Create a Parquet External Table Based on a Table in the Delta Share

Create an external table and load it with data from the **`boston-housing`** table in the Delta Public share. Use the **`EXTERNAL_TABLE`** procedure in the **`DBMS_CLOUD`** package to create and populate the external table.

1. Copy and paste the following code into your SQL Worksheet, and then click the **Run Script** icon in the Worksheet toolbar.

    ```
    <copy>
    DECLARE
  l_TABLE_NAME        DBMS_QUOTED_ID := '"BOSTONHOUSING"';
  l_CREDENTIAL_NAME   DBMS_QUOTED_ID := '"PUBLIC_DELTA"';
  l_FILE_URI_LIST     CLOB :=
    q'[https://sharing.delta.io/delta-sharing/#DELTA_SHARING.DEFAULT.BOSTON-HOUSING]';
  l_COLUMN_LIST       CLOB :=
    q'[
     "ID"       NUMBER
    ,"crim"     BINARY_DOUBLE
    ,"zn"       BINARY_DOUBLE
    ,"indus"    BINARY_DOUBLE
    ,"chas"     NUMBER
    ,"nox"      BINARY_DOUBLE
    ,"rm"       BINARY_DOUBLE
    ,"age"      BINARY_DOUBLE
    ,"dis"      BINARY_DOUBLE
    ,"rad"      NUMBER
    ,"tax"      NUMBER
    ,"ptratio"  BINARY_DOUBLE
    ,"black"    BINARY_DOUBLE
    ,"lstat"    BINARY_DOUBLE
    ,"medv"     BINARY_DOUBLE]';
  l_FIELD_LIST        CLOB := null;
  l_FORMAT            CLOB :=
    '{
       "type" : "parquet",
       "access_protocol" : "delta_sharing"
     }';
BEGIN
  DBMS_CLOUD.CREATE_EXTERNAL_TABLE
  ( TABLE_NAME        => l_TABLE_NAME
   ,CREDENTIAL_NAME   => l_CREDENTIAL_NAME
   ,FILE_URI_LIST     => l_FILE_URI_LIST
   ,COLUMN_LIST       => l_COLUMN_LIST
   ,FIELD_LIST        => l_FIELD_LIST
   ,FORMAT            => l_FORMAT
  );
END;
/
    </copy>
    ```
The PL/SQL block is executed successfully and the new **`BOSTONHOUSING`** external table is created and populated.

  ![Create external table.](./images/create-external-table.png " ")

2. Query the **`BOSTONHOUSING`** external table. Copy and paste the following code into your SQL Worksheet, and then click the **Run Script** icon in the Worksheet toolbar.

    ```
    <copy>
    select *
    from BOSTONHOUSING;
    </copy>
    ```

    ![Query external table.](./images/query-external-table.png " ")

-->

## Learn more

* [DBMS_CLOUD Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/dbms-cloud-package.html#GUID-CE359BEA-51EA-4DE2-88DB-F21A9FC10721)
* [File Naming for Text Output (CSV, JSON, Parquet, or XML)](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/export-data-file-namingl.html#GUID-1A52F59C-2797-48A5-A058-950318DBE9AF)

You may now proceed to the next lab.

## Acknowledgements

* **Author:** Lauran K. Serhal, Consulting User Assistance Developer
* **Contributor:** Alexey Filanovskiy, Senior Principal Product Manager
* **Last Updated By/Date:** Lauran K. Serhal, October 2025

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) 2025 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)