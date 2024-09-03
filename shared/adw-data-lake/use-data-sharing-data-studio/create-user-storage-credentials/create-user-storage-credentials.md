# Create a Share Provider User and an OCI Credential

## Introduction

In this lab, as the **`admin`** user, you will create a **data share provider** and a **data share consumer** users and grant the two users the necessary role and privileges. You will optionally create an RSA key pair, if you don't have one. This will provide you with the private key, the user's and tenancy's OCIDs, and the fingerprint which you will need to create the OCI credential. Finally, you'll create an OCI credential.

![Create a user and an OCI credential.](./images/user-bucket-credential-diagram.png =70%x*" ")

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

* As an **`admin`** user, you will do the following:
    * create a data share provider user and grant this user the necessary role and privileges.
    * Create a data share consumer user and grant this user the necessary role and privileges.
* As the **`share_provider`** user, you will do the following:
    * Generate an RSA key pair to generate a private key and a fingerprint (if you need that)
    * Create an OCI native credential and associate the buckets' URL with the credential.

### Prerequisites

* This lab assumes that you have successfully completed all of the preceding labs in the **Contents** menu on the left.

## Task 1: Navigate to the SQL Worksheet

After you provisioned an ADB instance in the **Set up the Workshop Environment** lab, the **Autonomous Database details** page was displayed. If the page is active, start with **step 4** below. If the page had timed out, start with **step 1** below.

1. Log in to the **Oracle Cloud Console**, if you are not already logged in.

2. Open the **Navigation** menu and click **Oracle Database**. Under **Oracle Database**, click **Autonomous Database**.

3. On the **Autonomous Databases** page, click your **ADW-Data-Lake** ADB instance.
    ![The Autonomous Database is displayed and highlighted.](./images/adb-page.png " ")

    >**Note:** If you get a _Forbidden_ message on the **Autonomous Databases** page, that indicates that you are in the wrong compartment. Refer to the **Reservation Information** panel for your reservation and make a note of your assigned compartment. Next, on the same page, click the **Compartment** drop-down list in the **Scope** section, and selected your assigned compartment.

4. On the **Autonomous Database details** page, click the **Database actions** drop-down list, and then click **SQL**.

    ![From the Database Actions drop-down list, click SQL.](./images/click-db-actions-sql.png " ")

5. The first time you open the SQL Worksheet, a series of pop-up informational boxes may appear, providing you with a tour that introduces the main features. If not, click the **Tour** icon (binoculars) in the upper right corner of the toolbar. To take the tour through the informational boxes, click **Next**. To exit the tour, click the **X** control.

    ![SQL Worksheet.](./images/adb-sql-worksheet-opening-tour.png " ")

6. Click the **X** control to exit the tour. The SQL Worksheet is displayed.

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

2. Log out of the **`admin`** user. On the **Oracle Database Actions | SQL** banner, click the drop-down list next to the **`ADMIN`** user, and then select **Sign Out** from the drop-down menu.

    ![Log out of admin](images/logout-admin.png)

3. Log in as the newly created user, **`share_provider`**. On the **Sign-in** page, enter **`share_provider`** as the username and **`DataShare4ADW`** as the password, and then click **Sign in**. The Database Actions Launchpad page is displayed.

    ![Log in as share_provider](images/login-share-provider.png)

    You are now logged in as the newly created **`share_provider`** user. 

4. Click the **Development** tab and then click the **SQL** tab to display the SQL Worksheet.

    ![Logged in as share_provider](images/launchpad-share-provider.png)

## Task 4: (Optional) Create an Oracle Object Storage Bucket

You should store the data share data in Object Storage. You will then create a link to your Object Storage bucket and associate the access credentials with that bucket.

>**Note:** If you already have an Object Storage bucket, you don't need to create a new one. You can use your own bucket.

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

## Task 5: (Optional) Generate an RSA Key Pair and Get the Key's Fingerprint
[](include:adb-generate-rsa-key-pair.md)

## Task 6: Define a Cloud Location and Create an OCI Credential

To access data in the Object Store, you need to enable your database user to authenticate itself with the Object Store using your OCI object store account and a credential. You do this by creating a private `CREDENTIAL` object for your user that stores this information encrypted in your Autonomous Data Warehouse. This information is only usable for your user schema. For more information on OCI Native Credentials, see the [Autonomous Database Now Supports Accessing the Object Storage with OCI Native Authentication](https://blogs.oracle.com/datawarehousing/post/autonomous-database-now-supports-accessing-the-object-storage-with-oci-native-authentication) blog and the [Create Oracle Cloud Infrastructure Native Credentials](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/create-oracle-cloud.html#GUID-4E849D62-2DB2-426E-9DF8-7E6169C20EE9) documentation.

You will set up a connection to Oracle Object Storage by defining a cloud location with a credential. _You perform this step only once_. You will define a **Cloud Location** to connect to Oracle Object Storage. To begin this process, you need to navigate back to the **DATA LOAD** page of **Database Actions** as the **share_provider** user. You should already have the SQL Worksheet open from a previous task in this lab.

1. From the SQL Worksheet, click the **Database Actions | SQL** banner to display the Launchpad page.

    ![Click the SQL banner.](./images/click-sql-banner.png " ")

2. On the **Database Actions | Launchpad** page, click the **Data Studio** tab and then click the **Data Load** tab.

    ![Navigate to Data Load.](./images/click-data-studio-data-load.png " ")

    The **Data Load** Home page is displayed. Click **CONNECTIONS**.

    ![The Data Load Home page.](./images/data-load-home-page.png " ")

3. On the **Connections** page, click the **Create** drop-down list, and then select **New Cloud Store Location** from the drop-down menu.

    ![Click New Cloud Store Location.](./images/click-new-cloud-store-location.png " ")

4. Specify the following in the **Add Cloud Store Location** panel.
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

5. Click **Create Credential**.

    ![Click Create Credential.](./images/click-create-credential.png " ")
    
    The **Add Cloud Store Location** panel is re-displayed. The newly created credential is displayed. If you already have a bucket, select it from the **Select Bucket** drop-down list. This populates the **Bucket URI** text box; otherwise, select the **Bucket URI** option, and then enter your bucket's URI in the **Bucket URI** text box. You identified your bucket's URI in **Task 4**. Remember to use this general structure, swapping in your own values. _Remember, don't include the trailing slash after the **`/o`**; otherwise, you will get an error_.
    
    >**Note:** Substitute the URI value in the following code with your own bucket's URI. In our example, we replaced the actual tenancy name in the URI value with the **`namespace  name`** place holder for security.

    `https://objectstorage.region name.oraclecloud.com/n/namespace name/b/data-share-bucket/o`

    In our example, we selected our **data-share-bucket** from the **Select Bucket** drop-down list.

    ![Complete the Add Cloud Store Location.](./images/complete-add-cloud-store-location.png " ")

6. Click **Next** to see the available objects in the bucket that you specified. Our selected bucket is empty.

    ![Click Next to see the objects in the bucket.](./images/click-next.png " ")

7. Click **Create**. The **DELTA\_SHARE\_STORAGE** cloud location connection is displayed in the **Connections** page.

    ![The cloud store location is created.](./images/cloud-connection-created.png " ")

You may now proceed to the next lab.

## Learn More

* [The Share Tool](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/adp-data-share-tool.html#GUID-7EECE78B-336D-4853-BFC3-E78A7B8398DB)
* [Oracle Cloud Infrastructure Documentation](https://docs.cloud.oracle.com/en-us/iaas/Content/GSG/Concepts/baremetalintro.htm)
* [Using Oracle Autonomous Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)

## Acknowledgements

* **Author:** Lauran K. Serhal, Consulting User Assistance Developer
* **Contributor:** Alexey Filanovskiy, Senior Principal Product Manager
* **Last Updated By/Date:** Lauran K. Serhal, June 2024

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) 2024, Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
