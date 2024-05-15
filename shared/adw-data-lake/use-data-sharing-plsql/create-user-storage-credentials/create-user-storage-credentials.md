# Create a Share Provider User, an Object Storage Bucket, and an OCI Credential

## Introduction

In this lab, you will create a **data share provider** user and grant this user the necessary role and privileges. You will also create an Oracle Object Storage bucket (if you don't have one) where you will store the shared data. You will optionally create an RSA key pair if you don't have one. This will provide you with the private key, the user's and tenancy's OCIDs, and the fingerprint which you will need to create the OCI credential. Finally, you'll create an OCI credential.

![Create a user, a bucket, and an OCI credential.](./images/user-bucket-credential-diagram.png =65%x*)

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

* Create a user that will be the data share provider.
* Grant the data share provider the necessary role and privileges.
* Create an Oracle Object Storage bucket where you'll store the shared data.
* Generate an RSA key pair to generate a private key and a fingerprint.
* Create an OCI native credential and associate the buckets' URL with the credential.

### Prerequisites

This lab assumes that you have successfully completed all of the preceding labs in the **Contents** menu on the left.

## Task 1: Navigate to the SQL Worksheet

1. Log in to the **Oracle Cloud Console**, if you are not already logged in; otherwise, skip to step 4.

2. Open the **Navigation** menu and click **Oracle Database**. Under **Oracle Database**, click **Autonomous Database**.

3. On the **Autonomous Databases** page, click your **ADW-Data-Lake** ADB instance.
    ![The Autonomous Database is displayed and highlighted.](./images/adb-page.png " ")

4. On the **Autonomous Database details** page, click the **Database actions** drop-down list, and then click **SQL**.

    ![On the partial Autonomous Database Details page, the Database Actions button is highlighted.](./images/click-db-actions.png " ")

5. The SQL Worksheet is displayed.

    ![The SQL worksheet is displayed.](./images/sql-worksheet.png " ")

## Task 2: Create a Share Provider User and Grant Privileges to the User

As the **`admin`** user, create a **share_provider** user and grant this user the required role and privileges and enable REST and data sharing.

### **The Data Share Provider**

Oracle Autonomous Database Serverless enables the data share provider to share existing objects such as tables with authorized recipients. The share can contain a single table, a set of related tables, a set of tables with some logical grouping. The provider could be a person, an institution, or a software system that shares the objects.

Autonomous Database comes with a predefined database role named `DWROLE`. This role provides the privileges necessary for most database users;however, The DWROLE role does not allocate any tablespace quota to the user. If the user is going to be adding data or other objects, you need to grant the user tablespace quota. For more information about this role, see [Manage Database User Privileges](https://docs.oracle.com/en-us/iaas/autonomous-database/doc/managing-database-users.html).

1. Create a **share_provider** user and grant this user the required role and privileges and enable REST and data sharing. Copy and paste the following script into your SQL Worksheet, and then click the **Run Script (F5)** icon in the Worksheet toolbar.

    ```
    <copy>
    -- Create a new user that will provide the shared data.

    CREATE USER share_provider IDENTIFIED BY DataShare4ADW;

    -- Grant the new user the required role and privileges.

    GRANT CONNECT TO share_provider;
    GRANT DWROLE TO share_provider;
    GRANT RESOURCE TO share_provider;
    GRANT UNLIMITED TABLESPACE TO share_provider;

    -- Enable REST.

    BEGIN
        ORDS_ADMIN.ENABLE_SCHEMA(
            p_enabled => TRUE,
            p_schema => 'SHARE_PROVIDER',
            p_url_mapping_type => 'BASE_PATH',
            p_url_mapping_pattern => 'share_provider',
            p_auto_rest_auth=> TRUE
        );

    -- Enable data sharing.
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

2. Log out of the **`admin`** user. On the **Oracle Database Actions | SQL** banner, click the drop-down list next to the **`ADMIN`** user, and then select **Sign Out** from the drop-down menu. When prompted if you want to leave the site, click **Leave**.

    ![Log out of admin](images/logout-admin.png)

3. Log in as the newly created user, **`share_provider`**. On the **Sign-in** page, enter **`share_provider`** as the username and **`DataShare4ADW`** as the password, and then click **Sign in**. The Database Actions Launchpad page is displayed. You are now logged in as the newly created **`share_provider`** user.

    ![Log in as share_provider](images/login-share-provider.png)

4. Click the **Development** tab, and then click the **SQL** tab to display the SQL Worksheet.

    ![Logged in as share_provider](images/share-provider.png)

4. Run the following query to determine if the user has the required privileges to share objects. Copy and paste the following query into your SQL Worksheet, and then click the **Run Statement** icon. A **`1`** result indicates that the user has the required privileges to share objects. A **`0`** result indicates that the user doesn't have the privileges to share objects. The user must revisit the previous steps.

    ```
    <copy>
    SELECT dbms_share.can_create_share
    FROM dual;
    </copy>
    ```

    ![Determine if the user has the privilege to share](images/can-user-share.png)

## Task 3: Create an Oracle Object Storage Bucket

You should store the data share data in Object Storage. You will then create a link to your Object Storage bucket and associate the access credentials with that bucket.

>**Note:** If you already have an Object Storage bucket, you don't need to create a new one.

1. In your **Autonomous Database** browser tab, open the **Navigation** menu in the Oracle Cloud console and click **Storage**. Under **Object Storage & Archive Storage**, click **Buckets**.

2. On the **Buckets** page, select the compartment where you want to create the bucket from the **Compartment** drop-down list in the **List Scope** section. Make sure you are in the region where you want to create your bucket.

    ![The Buckets page is displayed.](./images/bucket-page.png " ")

3. Click **Create Bucket**.

4. In the **Create Bucket** panel, specify the following:
    - **Bucket Name:** Enter **data-share-bucket**.
    - **Default Storage Tier:** Accept the default **Standard** storage tier. Use this tier for storing frequently accessed data that requires fast and immediate access. For infrequent access, choose the **Archive** storage tier.
    - **Encryption:** Accept the default **Encrypt using Oracle managed keys**.

    >**Note:** Bucket names must be unique per tenancy and region.

5. Click **Create** to create the bucket.

    ![The completed Create Bucket panel is displayed.](./images/create-bucket-panel.png " ")

6. The new bucket is displayed on the **Buckets** page.

    ![The new bucket is displayed on the Buckets page.](./images/bucket-created.png " ")

## Task 4: (Optional) Generate an RSA Key Pair and Get the Key's Fingerprint

1. In the Console banner, click the **Profile** icon. From the drop-down menu, click your **My profile**.

    ![Click the person icon at the far upper right and click your username.](./images/click-my-profile.png " ")

2. The **My profile** page is displayed. In the **User Information** tab, you can click the **Copy** link next to the **OCID** field. Make a note of this username's OCID as you will need it in a later task. Scroll down the page to the **Resources** section, and then click **API Keys**.

    ![Click Auth Tokens under Resources at the bottom left.](./images/click-api-key.png " ")

3. In the **API Keys** section, click **Add API Key**. The **Add API Key** dialog box is displayed.

    ![Click Add API Key.](./images/click-add-api-key.png " ")

4. Click **Download private key**. The private key is downloaded to your Web browser's default directory such as the **Downloads** folder in MS-Windows. A checkmark is displayed next to the **Download private key**.

    ![Download private key.](./images/download-private-key.png " ")

    The name of the downloaded private key is usually as follows:

    **`oraclecloudidentityservice_username-date.pem`**

    Rename your downloaded private key to something shorter such as:

    **`oci-api-private-key.pem`**

5. In most cases, you do not need to download the public key; however, you can download the public key for potential future use. click **Download Public Key**. The public key is downloaded to your Web browser's default directory such as the **Downloads** folder in MS-Windows. A checkmark is displayed next to the **Download Public Key**.

6. A checkmark should appear next to each button. Click **Add**. The key is added and the **Configuration File Preview** dialog box is displayed. The file snippet includes required parameters and values you'll need to create your configuration file.

    ![Configuration file preview.](./images/config-file-preview.png " ")

    This dialog box contains all of the information that you will need in the next task to create a new Cloud location and credential. Click the **Copy** link to copy the **User's OCID**, **API Key Fingerprint**, and **Tenancy OCID** to your clipboard and then paste it into a text editor of your choice such as Notepad in MS-Windows. You will need those values in the next task.

    ![Credentials items.](./images/credentials-items.png " ")

    You can access the downloaded private key and then paste the key value in the above text editor file as you will need the value in the next task.

    ![Private key value.](./images/get-private-key-value.png " ")

7. In the **Configuration File Preview** dialog box, click **Close**.

## Task 5: Create an OCI Native Credential as the share_provider User

To access data in the Object Store, you need to enable your database user to authenticate itself with the Object Store using your OCI object store account and a credential. You do this by creating a private `CREDENTIAL` object for your user that stores this information encrypted in your Autonomous Data Warehouse. This information is only usable for your user schema. For more information on OCI Native Credentials, see the [Autonomous Database Now Supports Accessing the Object Storage with OCI Native Authentication](https://blogs.oracle.com/datawarehousing/post/autonomous-database-now-supports-accessing-the-object-storage-with-oci-native-authentication) blog and the [Create Oracle Cloud Infrastructure Native Credentials](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/create-oracle-cloud.html#GUID-4E849D62-2DB2-426E-9DF8-7E6169C20EE9) documentation.

1. Return to the browser tab that contains the SQL Worksheet, if not already there. **IMPORTANT:** Make sure you are logged in as the **`share_provider`** user. Create a storage link that points to the Object Storage bucket URI that you created in the previous task. The URL's format is as follows:

    `https://objectstorage.<`**region name**`>.oraclecloud.com/n/<`**namespace name**`>/b/<`**bucket name**`>/o`

    In our example, the **region name** is `ca-toronto-1`, the **Namespace** is blurred for security, and the **bucket name** is `data-share-bucket`.

2. Create a named storage link that points to your Object Storage bucket's URI. Make sure that the user has `WRITE` privileges to the specified bucket. Copy and paste the following script into your SQL Worksheet, and then click the **Run Statement** icon in the Worksheet toolbar.

    >**Note:** Substitute the URI value in the following code with your own bucket's URI. In our example, we replaced the actual tenancy name in the URI value with the **`tenancy-name`** place holder for security.

    ```
    <copy>
    BEGIN
        DBMS_SHARE.CREATE_CLOUD_STORAGE_LINK(
            STORAGE_LINK_NAME => 'data_share_storage_link',
            URI => 'https://objectstorage.ca-toronto-1.oraclecloud.com/n/tenancy-name/b/data-share-bucket/o/'
        );
    END;
    /
    </copy>
    ```

    ![Create a cloud storage link.](images/create-storage-link.png)

3. Create an OCI native credential to access your Object Store. Copy and paste the following script into your SQL Worksheet. Substitute the placeholders values for the `user_ocid`, `tenancy_ocid`, `private_key`, and `fingerprint` in the following code with the respective values that you saved from the **Configuration File Preview** dialog box from the previous task.

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

4. Verify that you can access the **`data-share-bucket`** with the **`SHARE_BUCKET_CREDENTIAL`** credential that you just created. Copy and paste the following script into your SQL Worksheet, and then click the **Run Statement** icon in the Worksheet toolbar. 

    >**Note:** Substitute the **LOCATION_URI** value in the following code with your own bucket's URI value. In our example, we replaced the actual tenancy name in the URI value with the **`tenancy-name`** place holder for security.

    ```
    <copy>
    SELECT OBJECT_NAME, BYTES
    FROM
    DBMS_CLOUD.LIST_OBJECTS(
        credential_name=>'SHARE_BUCKET_CREDENTIAL',
        LOCATION_URI => 'https://objectstorage.ca-toronto-1.oraclecloud.com/n/tenancy-name/b/data-share-bucket/o/');
    </copy>
    ```

    You are able to access the bucket but since you have not uploaded any files to it, you will get the message **No rows are returned** in the **Script Output**.

    ![Access user bucket.](images/access-user-bucket.png)

    >**Note:** In our example below, after we created the **`data-share-bucket`** bucket, we uploaded a local file named `customer-extension.csv` to the bucket to show the following result.

    ![Access bucket.](images/access-bucket.png)

5. Associate the storage link that you created in step 2 with your OCI native credential that you created in step 3. Copy and paste the following script into your SQL Worksheet, and then click the **Run Script** icon in the Worksheet toolbar.

    ```
    <copy>
    BEGIN
    DBMS_SHARE.set_storage_credential
        (storage_link_name=>'data_share_storage_link',
         credential_name=>'SHARE_BUCKET_CREDENTIAL');
    END;
    /
    </copy>
    ```

    ![Associate storage link with credential name.](images/associate-link-credential.png)

6. To query the existing cloud stores, copy and paste the following script into your SQL Worksheet, and then click the **Run Statement** icon in the Worksheet toolbar.

    ```
    <copy>
    SELECT *
    FROM user_lineage_cloud_storage_links;
    </copy>
    ```

    ![Query cloud stores.](images/query-cloud-stores.png)

7. To query existing credentials, copy and paste the following script into your SQL Worksheet, and then click the **Run Statement** icon in the Worksheet toolbar.

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
* **Last Updated By/Date:** Lauran K. Serhal, April 2024

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C), 2024 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
