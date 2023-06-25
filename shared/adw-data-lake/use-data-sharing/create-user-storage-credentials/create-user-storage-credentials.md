# Create User, Role, Cloud Storage, and Credential

## Introduction

In this lab, you will ...

> **Note:** While this lab uses Oracle Autonomous Data Warehouse, the steps are identical for loading data into an Oracle Autonomous Transaction Processing database.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

* Navigate to the SQL Worksheet utility in Oracle Autonomous Database Data Tools.

### Prerequisites

This lab requires the completion of **Lab 1: Set up the Workshop Environment > Task 3: Create an Autonomous Data Warehouse Instance**, from the **Contents** menu on the left.

## Task 1: Navigate to the SQL Worksheet

1. Log in to the **Oracle Cloud Console**, if you are not already logged as the Cloud Administrator. You will complete all the labs in this workshop using this Cloud Administrator. On the **Sign In** page, select your tenancy, enter your username and password, and then click **Sign In**. The **Oracle Cloud Console** Home page is displayed.

2. Open the **Navigation** menu and click **Oracle Database**. Under **Oracle Database**, click **Autonomous Database**.

3. On the **Autonomous Databases** page, click your **ADW-Data-Lake** ADB instance.
    ![The Autonomous Database is displayed and highlighted.](./images/adb-page.png " ")

4. On the **Autonomous Database details** page, click **Database actions**.

    ![On the partial Autonomous Database Details page, the Database Actions button is highlighted.](./images/click-db-actions.png " ")

5. A **Launch DB actions** message box with the message **Please wait. Initializing DB Actions** is displayed. Next, the **Database Actions | Launchpad** Home page is displayed in a _**new tab in your browser**_. In the **Data Studio** section, click the **SQL** card to display the SQL Worksheet.

    ![The Database Actions Launchpad Home page is displayed. The Data Load card in the Data Studio section is highlighted.](./images/click-sql-card.png " ")

## Task 2: For Limited Availability (LA) Only

For the LA release only, the stage database must be **whietelisted**. As the `In order to whitelist, `ADMIN` user, run the following code.

1. Copy and paste the following script into your SQL Worksheet, and then click the **Run Script (F5)** icon in the Worksheet toolbar.

    ```
    <copy>
    -- create a new role and grant the role to the admin user.

    CREATE ROLE adpbeta;
    GRANT ADPBETA TO admin;
    COMMIT;
    </copy>
    ```

    ![Create a new role](images/create-role.png)

2. Query the ADP version and the whitelisting status. Copy and paste the following query into your SQL Worksheet, and then click the **Run Statement** icon in the Worksheet toolbar.

    ```
    <copy>
    -- Check the ADP version and whitelisting status.

    SELECT
    json_value(get_adp_status,'$.ADPVersion') version,
    json_value(get_adp_status,'$.operationalState') operational_state,
    JSON_QUERY(get_adp_status,'$.packageState[*]?(@.sharing=="VALID")' PRETTY) share_status
    FROM dual;
    </copy>
    ```

    ![Check ADP version and whitelisting status](images/check-version-state.png)

3. Confirm that the Data Sharing tile is now visible in the **Data Studio** section on the **DATA LOAD** page. Click **Oracle Database Actions** in the banner to display the Launchpad landing page. In the **Data Studio** section, the **Data Sharing** tile should be displayed.

    ![The Data Sharing tile is displayed.](images/data-sharing-tile.png)

## Task 3: Create a User and Grant Privileges to the User

Create a user that will be a **data provider**. A user that will share the data needs to have certain privileges. You will also grant this user the required roles, and enable REST and data sharing.

1. Copy and paste the following script into your SQL Worksheet, and then click the **Run Script (F5)** icon in the Worksheet toolbar.

    ```
    <copy>
    -- Create a new user that will provide the shared data.

    CREATE USER share_provider IDENTIFIED BY DataShare4ADW;

    -- Grant the new user the required roles.

    GRANT CONNECT TO share_provider;
    GRANT DWROLE TO share_provider;
    GRANT RESOURCE TO share_provider;

    -- Enable REST.

    BEGIN
        ORDS.ENABLE_SCHEMA(
            p_enabled => TRUE,
            p_schema => 'SHARE_PROVIDER',
            p_url_mapping_type => 'BASE_PATH',
            p_url_mapping_pattern => 'share_provider',
            p_auto_rest_auth=> TRUE
        );

    -- ENABLE DATA SHARING
        DBMS_SHARE.ENABLE_SCHEMA(
        SCHEMA_NAME => 'SHARE_PROVIDER',
        ENABLED => TRUE
        );
        commit;
    END;
    /
    </copy>
    ```

    ![Run the script](images/run-script.png)

    The results are displayed in the **Script Output** tab.

    ![View the script results](images/script-results.png)

## Task 4: Create Oracle Object Storage Bucket

You must store Shared data somewhere. Object Store is the place where you should store that data. You have to create a link to Cloud Storage (bucket URL) and associate the access credentials with it.

1. In the **Autonomous Database** browser tab, open the **Navigation** menu in the Oracle Cloud console and click **Storage**. Under **Object Storage & Archive Storage**, click **Buckets**.

2. On the **Buckets** page, select the compartment where you want to create the bucket from the **Compartment** drop-down list in the **List Scope** section. Make sure you are in the region where you want to create your bucket.

    ![The Buckets page is displayed.](./images/bucket-page.png " ")

3. Click **Create Bucket**.

4. In the **Create Bucket** panel, specify the following:
    - **Bucket Name:** Enter a meaningful name for the bucket.
    - **Default Storage Tier:** Accept the default **Standard** storage tier. Use this tier for storing frequently accessed data that requires fast and immediate access. For infrequent access, choose the **Archive** storage tier.
    - **Encryption:** Accept the default **Encrypt using Oracle managed keys**.

    >**Note:** Bucket names must be unique per tenancy and region.

5. Click **Create** to create the bucket.

  ![The completed Create Bucket panel is displayed.](./images/create-bucket-panel.png " ")

6. The new bucket is displayed on the **Buckets** page. The default bucket type (visibility) is **Private**.

  ![The new bucket is displayed on the Buckets page.](./images/bucket-created.png " ")

## Task 5: Generate an RSA Key Pair and Get the Key's Fingerprint

_**IMPORTANT:** If you already have an RSA key pair in PEM format (minimum 2048 bits) and a fingerprint of the public key, you can skip this optional task and proceed to **Task 6**. To get your user's and tenancy's OCID, see [Where to Get the Tenancy's OCID and User's OCID](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five); however, going through the entire task might be easier for you as you can get all the information that you need from the **Configuration File Preview** dialog box when you create your keys    ._

In this task, you will get the following items that are required to create a Cloud location in the next task.

+ An RSA key pair in PEM format (minimum 2048 bits). See [How to Generate an API Signing Key](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#two).
+ The Fingerprint of the public key. See [How to Get the Key's Fingerprint](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#four).
+ The Tenancy's OCID and the user's OCID. See [Where to Get the Tenancy's OCID and User's OCID](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five).

1. In the Console banner, click the **Profile** icon. From the drop-down menu, click your **User settings**.

    ![Click the person icon at the far upper right and click your username.](./images/click-your-username.png " ")

2. The **User Details** page is displayed. In the **User Information** tab, click the **Copy** link next to the **OCID** field. Make a note of this username's OCID as you will need it in a later task. Scroll down the page to the **Resources** section, and then click **API Keys**.

    ![Click Auth Tokens under Resources at the bottom left.](./images/click-api-key.png " ")

3. In the **API Keys** section, click **Add API Key**. The **Add API Key** dialog box is displayed.

    ![Click Add API Key.](./images/click-add-api-key.png " ")

4. Click **Download Private Key**. The private key is downloaded to your Web browser's default directory such as the **Downloads** folder in MS-Windows. A checkmark is displayed next to the **Download Private Key**.

    ![Download private key.](./images/download-private-key.png " ")

    The name of the downloaded private key is usually as follows:

    **`oraclecloudidentityservice_username-date.pem`**

    Rename your downloaded private key to something shorter such as:

    **`oci-api-private-key.pem`**

5. In most cases, you do not need to download the public key; however, you will download the public key for potential future use. click **Download Public Key**. The public key is downloaded to your Web browser's default directory such as the **Downloads** folder in MS-Windows. A checkmark is displayed next to the **Download Public Key**.

    ![Download public key.](./images/download-public-key.png " ")

    The name of the downloaded public key is usually as follows:

    **`oraclecloudidentityservice_username-date_public.pem`**

    Rename your downloaded private key to something shorter such as:

    **`oci-api-public-key.pem`**

6. A checkmark should appear next to each Click **Add**. The key is added and the **Configuration File Preview** dialog box is displayed. The file snippet includes required parameters and values you'll need to create your configuration file.

    ![Configuration file preview.](./images/config-file-preview.png " ")

    This dialog box contains all of the information that you will need in the next task to create a new Cloud location and credential. Copy the **User's OCID**, **API Key Fingerprint**, and **Tenancy OCID** to a text editor of your choice such as Notepad in MS-Windows. You will need those values in the next task.

    ![Credentials items.](./images/credentials-items.png " ")

7. Click **Close**.

## Task 6: Create an OCI Native Credential

To access data in the Object Store, you need to enable your database user to authenticate itself with the Object Store using your OCI object store account and a credential. You do this by creating a private `CREDENTIAL` object for your user that stores this information encrypted in your Autonomous Data Warehouse. This information is only usable for your user schema. For more information on OCI Native Credentials, see the [Autonomous Database Now Supports Accessing the Object Storage with OCI Native Authentication](https://blogs.oracle.com/datawarehousing/post/autonomous-database-now-supports-accessing-the-object-storage-with-oci-native-authentication) blog and the [Create Oracle Cloud Infrastructure Native Credentials](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/create-oracle-cloud.html#GUID-4E849D62-2DB2-426E-9DF8-7E6169C20EE9) documentation.

1. Return to the browser tab that contains the SQL Worksheet. Create a storage link that points to an the Object Storage bucket URI that you created in the previous task. The format of the URL is as follows:

    `https://objectstorage.<`**region name**`>.oraclecloud.com/n/<`**namespace name**`>/b/<`**bucket name**`>/o`

    In our example, the **region name** is `ca-toronto-1`, the **Namespace** is blurred for security, and the **bucket name** is `data-share-bucket`.

    Copy and paste the following script into your SQL Worksheet, and then click the **Run Statement** icon in the Worksheet toolbar.

    ```
    <copy>
    -- Create Storage Link that points to an Object Store URI
    -- Make sure the user has WRITE privileges to the specified bucket

    BEGIN
        DBMS_SHARE.CREATE_CLOUD_STORAGE_LINK(
            STORAGE_LINK_NAME => 'data_share_storage_3',
            URI => 'https://objectstorage.ca-toronto-1.oraclecloud.com/n/adwc4pm/b/data-share-bucket/o/'
        );
    END;
    /
    </copy>
    ```

    ![Create a cloud storage link.](images/create-storage-link.png)

2. Create an OCI native credential. Copy and paste the following script into your SQL Worksheet. Substitute the values for the `user_ocid`, `tenancy_ocid`, `private_key`, and `fingerprint` in the following code with the respective values that you saved from the **Configuration File Preview** dialog box from the previous task.

    >**Note:** To find your unencrypted **private_key** value that you downloaded in the previous task: Open the private key file in a text editor, and then copy the entire key value but don't include the **-----BEGIN PRIVATE KEY-----** and **-----END PRIVATE KEY-----** lines. Next, paste the copied value in the following code.

    ![Private key value.](./images/private-key-value.png " ")

    ```
    <copy>
    BEGIN
    dbms_cloud.create_credential(
        credential_name=>'SHARE_BUCKET_CREDENTIAL',
        user_ocid=>'user_ocid',
        tenancy_ocid=>'tenancy_ocid',
        private_key=>'private_key',
        fingerprint=>'fingerprint');
    END;
    /
    </copy>
    ```

    ![Completed code example.](images/code-example-completed.png)

    Next, click the **Run Script (F5)** icon in the Worksheet toolbar.

    ![Create an OCI credential.](images/create-credential.png)

3. Verify that you can access the **`data-share-bucket`** with the **`SHARE_BUCKET_CREDENTIAL`** credential that you just created. Copy and paste the following script into your SQL Worksheet, and then click the **Run Statement** icon in the Worksheet toolbar.

    ```
    <copy>
    SELECT OBJECT_NAME, BYTES
    FROM
    DBMS_CLOUD.LIST_OBJECTS(
    credential_name=>'SHARE_BUCKET_CREDENTIAL',
    LOCATION_URI => 'https://objectstorage.ca-toronto-1.oraclecloud.com/n/adwc4pm/b/data-share-bucket/o/');
    </copy>
    ```

    >**Note:** In our example below, we uploaded a `customer-extension.csv` file to the **`data-share-bucket`** bucket to show the following result. You didn't upload any files to the **`data-share-bucket`** bucket that you created earlier.

    ![Access bucket.](images/access-bucket.png)

4. Associate the storage link that you created in step 1 with your OCI native credential that you created in step 2. Copy and paste the following script into your SQL Worksheet, and then click the **Run Script** icon in the Worksheet toolbar.

    ```
    <copy>
    BEGIN
    DBMS_SHARE.set_storage_credential
        (storage_link_name=>'data_share_storage_3',
         credential_name=>'SHARE_BUCKET_CREDENTIAL');
    END;
    /
    </copy>
    ```

    ![Associate storage link with credential name.](images/associate-link-credential.png)

5. To query the existing cloud stores, copy and paste the following script into your SQL Worksheet, and then click the **Run Statement** icon in the Worksheet toolbar.

    ```
    <copy>
    SELECT *
    FROM user_lineage_cloud_storage_links;
    </copy>
    ```

    ![Query cloud stores.](images/query-cloud-stores.png)

6. To query existing credentials, copy and paste the following script into your SQL Worksheet, and then click the **Run Statement** icon in the Worksheet toolbar.

    ```
    <copy>
    SELECT *
    FROM all_credentials;
    </copy>
    ```

    ![Query existing credentials.](images/query-credentials.png)

You may now proceed to the next lab.

## Learn More

* [Oracle Cloud Infrastructure Documentation](https://docs.cloud.oracle.com/en-us/iaas/Content/GSG/Concepts/baremetalintro.htm)
* [Using Oracle Autonomous Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)

## Acknowledgements

* **Author:** Lauran K. Serhal, Consulting User Assistance Developer
* **Contributor:** Alexey Filanovskiy, Senior Principal Product Manager
* **Last Updated By/Date:** Lauran K. Serhal, July 2023

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
