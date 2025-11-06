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

<if type="livelabs">
Your green button reservation includes an ADB instance. You can find the required credentials in the **Reservation Information** dialog box for your reservation. To log in to the Console, click the **Launch OCI** button in the **Reservation Information** dialog box, and then follow the prompts to reset your assigned password. 

 ![The Reservation Information dialog box.](./images/ll-reservation-information.png =65%x*)
</if>

1. Log in to the **Oracle Cloud Console**, if you are not already logged in; otherwise, skip to step 4.

2. Open the **Navigation** menu and click **Oracle AI Database**. Under **Oracle AI Database**, click **Autonomous AI Database**.

    ![Click Autonomous AI Database.](images/click-autonomous-ai-database.png =65%x*)

<if type="livelabs">
 
    The **Autonomous AI Databases** page is displayed. 
    
    ![The Autonomous AI Databases page.](images/ll-autonomous-ai-databases-page.png =65%x*)
 
    >**Note:** The **Couldn't load data** error on the page is due to being in the wrong compartment. You will learn how to navigate to your assigned compartment next. 

    OCI resources are organized into compartments. To navigate to your assigned sandbox reservation compartment, click the **Compartment** field. Next, enter your assigned compartment name (or partial name) from the **Reservation Information** page in the **Compartment** text box. Once your assigned compartment is displayed in the drop-down list under the **`Livelabs`** node, click it.
    
    ![Select your assigned compartment.](images/ll-select-compartment.png =65%x*)

    >**Note:** For more details on finding your assigned resources in your reservation such as the username, password, compartment and so on, review the **Get Started with LiveLabs** lab in the Navigation menu on the left.

    
</if>

3. On the **Autonomous AI Databases** page, click your **ADW-Data-Lake** ADB instance.

    <if type="freetier">
    ![The Autonomous AI Database is displayed and highlighted.](./images/adb-page.png =65%x*)
    </if>

    <if type="livelabs">
    ![The Autonomous AI Database is displayed and highlighted.](./images/ll-adb-page.png =65%x*)

    >**Note:** Since you are using a Sandbox environment, an ADB instance was created for you. To view the ADB instance details, click the **View Login Info** link to display the **Reservation Information** dialog box. The database admin password, database name, and database display name are displayed.

    </if>

4. On the **ADW-Data-Lake** Autonomous AI Database details page, click the **Database actions** drop-down list, and then click **SQL**.

    ![On the partial Autonomous AI Database Details page, the Database Actions button is highlighted.](./images/click-db-actions.png " ")

5. The SQL Worksheet is displayed. Close any informational boxes that are displayed, if any.

    ![The SQL worksheet is displayed.](./images/sql-worksheet.png " ")

## Task 2: Create a Share Provider User and Grant Privileges to the User

As the **`admin`** user, create a **share_provider** user and grant this user the required role and privileges and enable REST and data sharing.

### **The Data Share Provider**

Oracle Autonomous AI Database Serverless enables the data share provider to share existing objects such as tables with authorized recipients. The share can contain a single table, a set of related tables, a set of tables with some logical grouping. The provider could be a person, an institution, or a software system that shares the objects.

Autonomous AI Database comes with a predefined database role named `DWROLE`. This role provides the privileges necessary for most database users;however, The DWROLE role does not allocate any tablespace quota to the user. If the user is going to be adding data or other objects, you need to grant the user tablespace quota. For more information about this role, see [Manage Database User Privileges](https://docs.oracle.com/en-us/iaas/autonomous-database/doc/managing-database-users.html).

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

    ![Log in as share_provider](images/login-share-provider.png =65%x*)

4. Click the **Development** tab, and then click the **SQL** tab to display the SQL Worksheet.

    ![Logged in as share_provider](images/share-provider.png)

    A **Run Statement** informational box is displayed. Close the box.

    ![SQL Worksheet for the share_provider](images/sql-worksheet-share-provider.png)

4. Run the following query to determine if the user has the required privileges to share objects. Copy and paste the following query into your SQL Worksheet, and then click the **Run Statement** icon. 

    >**Note:** The first time you try to paste content from your clipboard into your SQL Worksheet, a dialog box is displayed. Click **Allow**.

    ![Click Allow](images/click-allow.png =50%x*)

    ```
    <copy>
    SELECT dbms_share.can_create_share
    FROM dual;
    </copy>
    ```

    ![Determine if the user has the privilege to share](images/can-user-share.png)

    A **`1`** result indicates that the user has the required privileges to share objects. A **`0`** result indicates that the user doesn't have the privileges to share objects. The user must revisit the previous steps.


## Task 3: Create an Oracle Object Storage Bucket

Create a private Object Storage bucket to store your data. For more information about Oracle Object Storage, see [Explore more about Object Storage in Oracle Cloud.](https://docs.oracle.com/en-us/iaas/Content/Object/home.htm)

<if type="livelabs">

1. Navigate back to the Oracle Cloud Console. In your **Run Workshop** browser tab, click the **View Login Info** tab. In your **Reservation Information** panel, click **Launch OCI**.

    ![Click the Launch OCI button.](images/click-launch-oci.png =65%x*)

2. Open the **Navigation** menu in the Oracle Cloud console and click **Storage**. Under **Object Storage & Archive Storage**, click **Buckets**.

    ![Navigate to Buckets.](images/navigate-buckets.png =65%x*)

3. On the **Buckets** page, select the compartment that was assigned to you where you want to create the bucket from the **Compartment** drop-down list in the **Applied filters** section. Make sure you are in the region that was assigned to you where you will create your bucket.

    ![The Buckets page.](images/buckets-page.png =65%x*)

4. Click **Create Bucket**.

5. In the **Create bucket** panel, specify the following:
    - **Bucket name:** Enter a meaningful name for the bucket such as **`data-share-bucket`**.
    - **Default storage tier:** Accept the default **Standard** storage tier. Use this tier for storing frequently accessed data that requires fast and immediate access. For infrequent access, choose the **Archive** storage tier.
    - **Encryption:** Accept the default **Encrypt using Oracle managed keys**.

    >**Note:** Bucket names must be unique per tenancy and region.

6. Click **Create bucket** to create the bucket.

  ![The completed Create Bucket panel is displayed.](./images/create-bucket-panel.png =65%x*)

7. The new bucket is displayed on the **Buckets** page. The default bucket type (visibility) is **Private**.

  ![The new bucket is displayed on the Buckets page.](./images/bucket-created.png =65%x*)
</if>

<if type="freetier">

1. In the **Autonomous AI Database** browser tab, open the **Navigation** menu in the Oracle Cloud console and click **Storage**. Under **Object Storage & Archive Storage**, click **Buckets**.

    ![Navigate to buckets.](./images/navigate-buckets.png =65%x*)

2. On the **Buckets** page, select the compartment where you want to create the bucket from the **Compartment** drop-down list in the **Apply filters** section. In this example, we chose a compartment named **`training-adw-compartment`**. Make sure you are in the region where you want to create your bucket.

    ![The buckets page is displayed.](./images/buckets-page.png =65%x*)

3. Click **Create bucket**.

4. In the **Create bucket** panel, specify the following:
    - **Bucket name:** Enter a meaningful name for the bucket. In this example, we chose **`data-share-bucket`** as the name.
    - **Default storage tier:** Accept the default **Standard** storage tier. Use this tier for storing frequently accessed data that requires fast and immediate access. For infrequent access, choose the **Archive** storage tier.
    - **Encryption:** Accept the default **Encrypt using Oracle managed keys**.

    >**Note:** Bucket names must be unique per tenancy and region; otherwise an **already exists** error message is displayed.

5. Click **Create bucket** to create the bucket.

  ![The completed Create Bucket panel is displayed.](./images/create-bucket-panel.png =65%x*)

6. The new bucket is displayed on the **Buckets** page. The default bucket type (visibility) is **Private**.

  ![The new bucket is displayed on the Buckets page.](./images/bucket-created.png =65%x*)

  </if>

7. Next, _you need to get the name of the namespace (tenancy) where this new bucket was created_. You will need this namespace name in this workshop. In the row for the bucket, click the **Actions** icon (ellipsis), and then select **View bucket details** from the context menu.

    ![Get the bucket's namespace.](./images/view-bucket-details.png " ")

    The **Bucket** details page is displayed. The **Namespace** field displays the name of the namespace. The name is blurred for security reasons. Copy this name to your choice of text editor such as Notepad in Windows as you will need it in later steps.

    ![Copy the bucket's namespace.](./images/copy-bucket-namespace.png " ")

    </if>

## Task 4: (Optional) Generate an RSA Key Pair and Get the Key's Fingerprint

[](include:adb-generate-rsa-key-pair.md)

<!-- 
1. In the Console banner, click the **Profile** icon. From the drop-down menu, click your **User settings**.

    ![Click the person icon at the far upper right and click your username.](./images/click-my-profile.png =65%x*)

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
-->

## Task 5: Create an OCI Native Credential as the share_provider User

To access data in the Object Store, you need to enable your database user to authenticate itself with the Object Store using your OCI object store account and a credential. You do this by creating a private `CREDENTIAL` object for your user that stores this information encrypted in your Oracle Autonomous AI Lakehouse. This information is only usable for your user schema. For more information on OCI Native Credentials, see the [Autonomous AI Database Now Supports Accessing the Object Storage with OCI Native Authentication](https://blogs.oracle.com/datawarehousing/post/autonomous-database-now-supports-accessing-the-object-storage-with-oci-native-authentication) blog and the [Create Oracle Cloud Infrastructure Native Credentials](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/create-oracle-cloud.html#GUID-4E849D62-2DB2-426E-9DF8-7E6169C20EE9) documentation.

1. Return to the browser tab that contains the SQL Worksheet, if not already there. **IMPORTANT:** Make sure you are logged in as the **`share_provider`** user. Create a storage link that points to the Object Storage bucket URI that you created in the previous task. The URL's format is as follows:

    `https://objectstorage.<`**region name**`>.oraclecloud.com/n/<`**namespace name**`>/b/<`**bucket name**`>/o`

    In our example, the **region name** is `us-ashburn-1`, the **Namespace** is blurred for security, and the **bucket name** is **`data-share-bucket`**. If you are using a Sandbox reservation (green button), you can find the region name in the **Reservation Information** dialog box. You already saved the bucket's namespace in **Task 3** and saved it to a text editor file of your choice.

    <if type="livelabs">
    ![Reservation Information dialog box.](images/reservation-information.png)
    </if>

2. Create a named storage link that points to your Object Storage bucket's URI. Make sure that the user has `WRITE` privileges to the specified bucket. Copy and paste the following script into your SQL Worksheet. _Don't run the script yet_.

    >**Note:** Substitute the URI value (region and tenancy namespace) in the following code with your own bucket's URI. In our example, we replaced the actual tenancy name in the URI value with the **`tenancy-name`** place holder for security.

    ```
    <copy>
    BEGIN
        DBMS_SHARE.CREATE_CLOUD_STORAGE_LINK(
            STORAGE_LINK_NAME => 'data_share_storage_link',
            URI => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/tenancy-name/b/data-share-bucket/o/'
        );
    END;
    /
    </copy>
    ```

    Click the **Run Script** icon in the Worksheet toolbar.

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
        LOCATION_URI => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/tenancy-name/b/data-share-bucket/o/');
    </copy>
    ```

    You are able to access the bucket but since you have not uploaded any files to it, you will get the message **No data found** in the **Query Result** tab.

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
* [Using Oracle Autonomous AI Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)

## Acknowledgements

* **Author:** Lauran K. Serhal, Consulting User Assistance Developer
* **Contributor:** Alexey Filanovskiy, Senior Principal Product Manager
* **Last Updated By/Date:** Lauran K. Serhal, November 2025

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) 2025, Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)