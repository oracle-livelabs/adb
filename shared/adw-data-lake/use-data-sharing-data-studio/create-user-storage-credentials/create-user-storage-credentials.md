# Create a Share Provider User, an Object Storage Bucket, and an OCI Credential

## Introduction

In this lab, as the **`admin`** user, you will create a **data share provider** and a **data share consumer** users and grant the two users the necessary role and privileges. Next, as the new **`share_provider`** user, you will create an Oracle Object Storage bucket (if you don't have one) where you will store the shared data. You will optionally create an RSA key pair, if you don't have one. This will provide you with the private key, the user's and tenancy's OCIDs, and the fingerprint which you will need to create the OCI credential. Finally, you'll create an OCI credential.

![Create a user, a bucket, and an OCI credential.](./images/user-bucket-credential-diagram.png " ")

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

* As an **`admin`** user, you will do the following:
    * create a data share provider user and grant this user the necessary role and privileges.
    * Create a data share consumer user and grant this user the necessary role and privileges.
* As the **`share_provider`** user, you will do the following:
    * Create an Oracle Object Storage bucket (if you don't have one) where you'll store the shared data.
    * Generate an RSA key pair to generate a private key and a fingerprint (if you need that)
    * Create an OCI native credential and associate the buckets' URL with the credential.

### Prerequisites

* This lab assumes that you have successfully completed all of the preceding labs in the **Contents** menu on the left.

## Task 1: Navigate to the SQL Worksheet

1. Log in to the **Oracle Cloud Console**, if you are not already logged in.

2. Open the **Navigation** menu and click **Oracle Database**. Under **Oracle Database**, click **Autonomous Database**.

3. On the **Autonomous Databases** page, click your **ADW-Data-Lake** ADB instance.
    ![The Autonomous Database is displayed and highlighted.](./images/adb-page.png " ")

4. On the **Autonomous Database details** page, click the **Database actions** drop-down list, and then click **SQL**.

    ![From the Database Actions drop-down list, click SQL.](./images/click-db-actions-sql.png " ")

    The SQL Worksheet is displayed.

    ![The SQL Worksheet is displayed.](./images/sql-worksheet.png " ")

## Task 2: Create a Share Provider User and Grant Privileges to the User

As the **`admin`** user, create a **`share_provider`** user and grant this user the required role and privileges and enable REST and data sharing.

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

## Task 3: (Optional) Create a Share Consumer User and Grant Privileges to the User

1. Create a new consumer user named **`share_consumer`**. Copy and paste the following script into your SQL Worksheet, and then click the **Run Script (F5)** icon.

    ```
    <copy>
    -- Create a new user that will consume the shared data.

    CREATE USER share_consumer IDENTIFIED BY DataShare4ADW;

    -- Grant the new user the required roles.

    GRANT CONNECT TO share_consumer;
    GRANT DWROLE TO share_consumer;
    GRANT RESOURCE TO share_consumer;
    GRANT UNLIMITED TABLESPACE TO share_consumer;

    -- Enable REST.

    BEGIN
        ORDS_ADMIN.ENABLE_SCHEMA(
            p_enabled => TRUE,
            p_schema => 'SHARE_CONSUMER',
            p_url_mapping_type => 'BASE_PATH',
            p_url_mapping_pattern => 'share_consumer',
            p_auto_rest_auth=> TRUE
        );

    -- Enable data sharing
        DBMS_SHARE.ENABLE_SCHEMA(
        SCHEMA_NAME => 'SHARE_CONSUMER',
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

<!--- comment
2. Log out of the `admin` user. On the **Oracle Database Actions | SQL** banner, click the drop-down list next to the `ADMIN` user, and then select **Sign Out** from the drop-down menu. Click **Leave**.

3. Log in as the newly created user, `share_consumer`. On the **Sign-in** page, enter **`share_consumer`** as the username and **`DataShare4ADW`** as the password, and then click **Sign in**.

    ![Log in as share_consumer](images/login-share-consumer.png)

    You are now logged in as the `share_consumer` user. In the **Development** section, click the **SQL** card to display the SQL Worksheet.
--->

2. Log out of the **`admin`** user. On the **Oracle Database Actions | SQL** banner, click the drop-down list next to the **`ADMIN`** user, and then select **Sign Out** from the drop-down menu. When prompted if you want to leave the site, click **Leave**.

    ![Log out of admin](images/logout-admin.png)

3. Log in as the newly created user, **`share_provider`**. On the **Sign-in** page, enter **`share_provider`** as the username and **`DataShare4ADW`** as the password, and then click **Sign in**.

    ![Log in as share_provider](images/login-share-provider.png)

    You are now logged in as the newly created **`share_provider`** user. In the **Development** section, click the **SQL** card to display the SQL Worksheet.

    ![Logged in as share_provider](images/logged-share-provider.png)

## Task 4: Create an Oracle Object Storage Bucket

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

6. The new bucket is displayed on the **Buckets** page. The default bucket type (visibility) is **Private**.

    ![The new bucket is displayed on the Buckets page.](./images/bucket-created.png " ")

## Task 5: (Optional) Generate an RSA Key Pair and Get the Key's Fingerprint

_**IMPORTANT:** If you already have an RSA key pair in PEM format (minimum 2048 bits) and a fingerprint of the public key, you can skip this optional task and proceed to **Task 6**. To get your user's and tenancy's OCID, see [Where to Get the Tenancy's OCID and User's OCID](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five); however, going through this entire task might be easier for you as you can get all the information that you need from the **Configuration File Preview** dialog box when you create your keys._

In this task, you will get the following items that are required to create a Cloud location in the next task.

+ An RSA key pair in PEM format (minimum 2048 bits). See [How to Generate an API Signing Key](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#two).
+ The Fingerprint of the public key. See [How to Get the Key's Fingerprint](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#four).
+ The Tenancy's OCID and the user's OCID. See [Where to Get the Tenancy's OCID and User's OCID](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five).

1. In the Console banner, click the **Profile** icon. From the drop-down menu, click your **User settings**.

    ![Click the person icon at the far upper right and click your username.](./images/click-your-username.png " ")

2. The **User Details** page is displayed. Scroll down the page to the **Resources** section, and then click **API Keys**.

    ![Click Auth Tokens under Resources at the bottom left.](./images/click-api-key.png " ")

3. In the **API Keys** section, click **Add API Key**. The **Add API Key** dialog box is displayed.

    ![Click Add API Key.](./images/click-add-api-key.png " ")

4. Click **Download Private Key**. The private key is downloaded to your Web browser's default directory such as the **Downloads** folder in MS-Windows. A checkmark is displayed next to the **Download Private Key**.

    ![Download private key.](./images/download-private-key.png " ")

    The name of the downloaded private key is usually as follows:

    **`oraclecloudidentityservice_username-date.pem`**

    Rename your downloaded private key to something shorter such as:

    **`oci-api-private-key.pem`**

5. In most cases, you do not need to download the public key; however, you can download the public key for future use. click **Download Public Key**. The public key is downloaded to your Web browser's default directory such as the **Downloads** folder in MS-Windows. A checkmark is displayed next to the **Download Public Key**.

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
    
## Task 6: Define a Cloud Location and Create an OCI Credential

To access data in the Object Store, you need to enable your database user to authenticate itself with the Object Store using your OCI object store account and a credential. You do this by creating a private `CREDENTIAL` object for your user that stores this information encrypted in your Autonomous Data Warehouse. This information is only usable for your user schema. For more information on OCI Native Credentials, see the [Autonomous Database Now Supports Accessing the Object Storage with OCI Native Authentication](https://blogs.oracle.com/datawarehousing/post/autonomous-database-now-supports-accessing-the-object-storage-with-oci-native-authentication) blog and the [Create Oracle Cloud Infrastructure Native Credentials](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/create-oracle-cloud.html#GUID-4E849D62-2DB2-426E-9DF8-7E6169C20EE9) documentation.

You will set up a connection to Oracle Object Storage by defining a cloud location with a credential. _You perform this step only once_. You will define a **Cloud Location** to connect to Oracle Object Storage. To begin this process, you need to navigate back to the **DATA LOAD** page of **Database Actions**.

1. In your **Autonomous Database** browser tab, open the **Navigation** menu and click **Oracle Database**. Under **Oracle Database**, click **Autonomous Database**.

2. On the **Autonomous Databases** page, click your **ADW-Data-Lake** ADB instance.

3. On the **Autonomous Database details** page, click the **Database actions** drop-down list, and then click **Data Load**.

     ![Click Data Load from the drop-down list.](./images/click-data-load-drop-down.png " ")

4. The **Database Actions | Data Load** page is displayed in a new tab in your browser. Scroll-down to the **Administration** section and then click **CONNECTIONS**.

    ![Click the Cloud Locations card.](./images/click-connections.png " ")

5. On the **Connections** page, click the **Create** drop-down list, and then select **New Cloud Store Location** from the drop-down menu.

    ![Click New Cloud Store Location.](./images/click-new-cloud-store-location.png " ")

6. Specify the following in the **Add Cloud Store Location** panel.
    + **Name:** Enter **`delta_share_storage`**.
    + **Description:** Enter an optional description.
    + Accept the **Select Credential** option. To access data in the Object Store, you need to enable your database user to authenticate itself with the Object Store using your OCI object store account and a credential. You do this by creating a private CREDENTIAL object for your user that stores this information encrypted in your Autonomous Data Warehouse. This information is only usable for your user schema.
    + Click **Create Credential**.
    + In the **Create Credential** dialog box, specify the following:
        + **Credential Type:** Select the **Oracle Cloud Infrastructure Signing Keys** option.
        + **Credential Name:** Enter **DELTA\_SHARE\_CREDENTIAL**. **Note:** The credential name must conform to Oracle object naming conventions, which do not allow spaces or hyphens.
        + **Fingerprint:** Enter the fingerprint for your RSA key pair that you generated and copied to a text file in the previous task.
        + **Private Key:** Paste your unencrypted private key value.
        Open the private key file in a text editor, and then copy the entire content from the and _including_ **-----BEGIN PRIVATE KEY-----** line to and _including_ the **-----END PRIVATE KEY-----** line.
        ![Private key.](./images/private-key-value.png " ")

        + **Oracle Cloud Infrastructure Tenancy:** Enter your tenancy OCID that you copied earlier to a text file.
        + **Oracle Cloud Infrastructure User Name:** Enter your _**user's OCID**_ (and not the actual username).  _**Note:** If you did complete the optional **Task 5**, then the you should have already saved the user's OCID (and not the actual username) in a text file of your choice. If you didn't perform the optional **Task 5**, you can find the user's OCID as follows: Navigate to the **Oracle Cloud Console**. Click the **User's** drop-down list, and then select **User settings**. In the **User Details** page, in the **User Information** tab, click **Copy** next to the **OCID** field. Save this user OCID in your text file._

7. Click **Create Credential**.

    ![Click Create Credential.](./images/click-create-credential.png " ")
    
    The **Add Cloud Store Location** panel is re-displayed. The newly created credential is displayed. If you already have a bucket, select it from the **Select Bucket** drop-down list; otherwise, select the **Bucket URI** option, and then enter your bucket's URI in the **Bucket URI** text box. You identified your bucket's URI in **Task 4**. Remember to use this general structure, swapping in your own values. _Remember, don't include the trailing slash after the **`/o`**; otherwise, you will get an error_. 
    
    >**Note:** Substitute the URI value in the following code with your own bucket's URI. In our example, we replaced the actual tenancy name in the URI value with the **`namespace  name`** place holder for security.

    `https://objectstorage.region name.oraclecloud.com/n/namespace name/b/data-share-bucket/o`

    In our example, we selected our **data-share-bucket** from the **Select Bucket** drop-down list.

    ![Complete the Add Cloud Store Location.](./images/complete-add-cloud-store-location.png " ")

8. Click **Next** to see the available objects in the bucket that you specified. There is only one file that you uploaded to your private Object Storage bucket, `customer_promotions.csv`.

    ![Click Next to see the objects in the bucket.](./images/click-next.png " ")

9. Click **Create**. The **DELTA\_SHARE\_STORAGE** cloud location connection is displayed in the **Connections** page.

    ![The cloud store location is created.](./images/cloud-connection-created.png " ")

You may now proceed to the next lab.

## Learn More

* [The Share Tool](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/adp-data-share-tool.html#GUID-7EECE78B-336D-4853-BFC3-E78A7B8398DB)
* [Oracle Cloud Infrastructure Documentation](https://docs.cloud.oracle.com/en-us/iaas/Content/GSG/Concepts/baremetalintro.htm)
* [Using Oracle Autonomous Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)

## Acknowledgements

* **Author:** Lauran K. Serhal, Consulting User Assistance Developer
* **Contributor:** Alexey Filanovskiy, Senior Principal Product Manager
* **Last Updated By/Date:** Lauran K. Serhal, August 2023

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
