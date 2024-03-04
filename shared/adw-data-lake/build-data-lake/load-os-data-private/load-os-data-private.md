# Link Data from Private Object Storage Buckets

## Introduction
In this lab, you will link to data from the MovieStream data lake on [Oracle Cloud Infrastructure Object Storage](https://www.oracle.com/cloud/storage/object-storage.html) into your Oracle Autonomous Database instance, in preparation for exploration and analysis.

You will practice linking to data from a **private** Object Storage bucket. You learn how to set up and use an authentication token and object store credentials to access sensitive data in the private object store.

> **Note:** While this lab uses Oracle Autonomous Data Warehouse, the steps are identical for loading data into an Oracle Autonomous Transaction Processing database.

Estimated Time: 20 minutes

Watch the video below for a quick walk-through of the lab.
[](youtube:IPkjI6zd2CU)

### Objectives

In this lab, you will:

- Download to your local computer a comma-separated value (.csv) file containing a simulation of sensitive customer data
- Create a private OCI Object Storage bucket
- Upload the .csv file to the OCI private bucket
- Create an object store auth token
- Define object store credentials for your autonomous database to communicate with the bucket
- Link to data from the object store using the DBMS_CLOUD PL/SQL package
- Troubleshoot the data link

### Prerequisites

- This lab requires completion of **Lab 1: Set up the Workshop Environment > Task 3: Create an Autonomous Data Warehouse Instance**, from the **Contents** menu on the left.

## Task 1: Download Customer Data from a Public Bucket

Download a **.csv** file that contains a simulation of sensitive customer retention data. Later, you will stage the file on a private **OCI Object Storage** bucket, to populate a table in later tasks.

1. Copy and paste the following URL into a _**new tab**_ in your web browser, and then press **[ENTER]**. The **moviestream\_sandbox** Oracle Object Storage bucket that contains the data is located in a different tenancy than yours, **c4u04**.

    ```
    <copy>
    https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/moviestream_sandbox/o/potential_churners/potential_churners.csv
    </copy>
    ```

2. The browser page downloads (**Downloads** directory by default in MS-Windows) and displays the **`potential_churners.csv`** file which contains customers who will stop or might stop being repeat customers. The data in the downloaded file is also displayed in an Excel worksheet. Close the worksheet.

  ![Download the potential_churners.csv file to your local computer.](images/potential-churners-csv-file.png " ")

## Task 2: Create a Private Oracle Object Storage Bucket

Create a private Object Storage bucket to store your data. For more information about Oracle Object Storage, see [Explore more about Object Storage in Oracle Cloud.](https://docs.oracle.com/en-us/iaas/Content/Object/home.htm)

<if type="livelabs">

1. Navigate back to the Oracle Cloud Console. In your **Run Workshop** browser tab, click the **View Login Info** tab. In your **Reservation Information** panel, click the **Launch OCI** button.

    ![Click the Launch OCI button.](images/click-launch-oci.png " ")

2. Open the **Navigation** menu in the Oracle Cloud console and click **Storage**. Under **Object Storage & Archive Storage**, click **Buckets**.

3. On the **Buckets** page, select the compartment where you want to create the bucket from the **Compartment** drop-down list in the **List Scope** section. Make sure you are in the region where you want to create your bucket.

4. Click **Create Bucket**.

5. In the **Create Bucket** panel, specify the following:
    - **Bucket Name:** Enter a meaningful name for the bucket.
    - **Default Storage Tier:** Accept the default **Standard** storage tier. Use this tier for storing frequently accessed data that requires fast and immediate access. For infrequent access, choose the **Archive** storage tier.
    - **Encryption:** Accept the default **Encrypt using Oracle managed keys**.

    >**Note:** Bucket names must be unique per tenancy and region.

6. Click **Create** to create the bucket.

  ![The completed Create Bucket panel is displayed.](./images/create-bucket-panel.png " ")

7. The new bucket is displayed on the **Buckets** page. The default bucket type (visibility) is **Private**.

  ![The new bucket is displayed on the Buckets page.](./images/ll-bucket-created.png " ")
</if>

<if type="freetier">

1. In the **Autonomous Database** browser tab, open the **Navigation** menu in the Oracle Cloud console and click **Storage**. Under **Object Storage & Archive Storage**, click **Buckets**.

2. On the **Buckets** page, select the compartment where you want to create the bucket from the **Compartment** drop-down list in the **List Scope** section. Make sure you are in the region where you want to create your bucket.

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

  </if>

## Task 3: Upload Customer Data to the Private Object Storage Bucket

Upload the **`potential_churners.csv`** file that you downloaded earlier in this lab to your newly created private Object Storage bucket.

1. On the **Buckets** page, click the new bucket name link. On the **Bucket Details** page, scroll down the page to the **Objects** section, and then click **Upload**.

  ![The Bucket Details page is displayed.](./images/bucket-details.png " ")

2. In the **Upload Objects** panel, you can drag and drop a single or multiple files into the **Choose Files from your Computer** field or click **select files** to choose the file(s) that you want to upload from your computer. In this example, we used the drag-and-drop method to select the **`potential_churners.csv`** file from our **Downloads** folder.

  ![The Upload Objects panel is displayed.](./images/select-file.png " ")

6. Click **Upload** to upload the selected file to the bucket.

7. When the file is uploaded successfully, a **Finished** status is displayed next to the file's name. Click **Close** to close the **Upload Objects** panel.

    ![The file is uploaded. Close the panel.](./images/file-uploaded.png " ")

    The **Bucket Details** page is re-displayed. The newly uploaded file is displayed in the **Objects** section.

    ![The Upload file is displayed.](./images/uploaded-file-displayed.png " ")

## Task 4: Locate the Base URL for the Object Storage File

Find the base URL of the object you just uploaded to your private Object Storage bucket.

1. On the **Bucket Details** page, scroll down to the **Objects** section. In the row for the **`potential_churners.csv`** file, click the 3-dot ellipsis icon, and then select **View Object Details** from the context menu.

    ![Select View Object Details from the ellipsis on the right of any uploaded file.](images/view-object-details.png " ")

2. In the **Object Details** panel, copy the **URL Path (URI)** that points to the location of the file in your private Object Storage bucket up to the **`/o`** part. **_Do not include the trailing slash;otherwise, you will get an error message when you use the URL_**. Save the base URL in a text editor of your choice such as Notepad in MS-Windows. You will use this URL in the upcoming tasks. Next, click **Cancel** to close the **Object Details** page.

    ![Copy the base URL.](images/url-path.png " ")

3. The format of the URL is as follows:

    `https://objectstorage.<`**region name**`>.oraclecloud.com/n/<`**namespace name**`>/b/<`**bucket name**`>/o`

    In our example, the **region name** is `ca-toronto-1`, the **Namespace** is blurred for security, and the **bucket name** is `training-data-lake`.

    ![The URL highlighted.](images/url.png " ")

## Task 5: Generate an RSA Key Pair and Get the Key's Fingerprint

_**IMPORTANT:** If you already have an RSA key pair in PEM format (minimum 2048 bits) and a fingerprint of the public key, you can skip this optional task and proceed to **Task 6**. To get your user's and tenancy's OCID, see [Where to Get the Tenancy's OCID and User's OCID](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five); however, going through the entire task might be easier for you as you can get all the information that you need from the **Configuration File Preview** dialog box when you create your keys._

In this task, you will get the following items that are required to create a Cloud location in the next task.

+ An RSA key pair in PEM format (minimum 2048 bits). See [How to Generate an API Signing Key](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#two).
+ The Fingerprint of the public key. See [How to Get the Key's Fingerprint](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#four).
+ The Tenancy's OCID and the user's OCID. See [Where to Get the Tenancy's OCID and User's OCID](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five).

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

## Task 6: Create a Native OCI Credential

You will load data from the `potential_churners.csv` file you uploaded to your private Oracle Object Store in an earlier task using the `DBMS_CLOUD` PL/SQL package. First, you will create a credential in order to access your  Oracle Object Storage. You perform this step only once.

In this task, you create a credential to connect to an Oracle Object Storage bucket. To begin this process, you need to navigate back to the **DATA LOAD** page of **Database Actions**.

1. On the **Oracle Cloud Console** Home page, open the **Navigation** menu and click **Oracle Database**. Under **Oracle Database**, click **Autonomous Database**.

<if type="livelabs">
2. On the **Autonomous Databases** page, click your **DB-DCAT** ADB instance.
</if>

<if type="freetier">
2. On the **Autonomous Databases** page, click your **ADW-Data-Lake** ADB instance.
</if>

3. On the **Autonomous Database details** page, click the **Database actions** drop-down list, and then select **SQL**.

4. Create an OCI native credential to access your Object Store. Copy and paste the following script into your SQL Worksheet. Substitute the placeholders values for the `user_ocid`, `tenancy_ocid`, `private_key`, and `fingerprint` in the following code with the respective values that you saved from the **Configuration File Preview** dialog box from the previous task.

    >**Note:** To find your unencrypted **private_key** value that you downloaded in the previous task: Open the private key file in a text editor, and then copy the entire key value but don't include the **-----BEGIN PRIVATE KEY-----** and **-----END PRIVATE KEY-----** lines. Next, paste the copied value in the following code.

    ![Private key value.](./images/private-key-value.png " ")

    ```
    <copy>
    BEGIN
    dbms_cloud.create_credential(
        credential_name=>'OBJ_STORAGE_CRED',
        user_ocid=>'user_ocid',
        tenancy_ocid=>'tenancy_ocid',
        private_key=>'private_key',
        fingerprint=>'fingerprint');
    END;
    /
    </copy>
    ```

    Next, click the **Run Script (F5)** icon in the Worksheet toolbar.

    ![Create an OCI credential.](images/credential-created.png)

## Task 7: Link to Data in the Bucket

1. Click the **Database Actions | SQL** banner to display the **Database Actions | Launchpad** Home page. In the **Data Studio** section, click the **DATA LOAD** card.

2. In the **Data Load** section, click the **LINK DATA** card.

    ![Click link data.](images/click-link-data.png)

    The **Link Data** page is displayed. The **Cloud Store** tab is already selected. Click the **Select Cloud Store Location or enter public URL** drop-down list to see the buckets and/or Cloud Locations to which you have access. In this workshop, you already have access to the `TRAINING-DATA-LAKE` private bucket in your compartment after your created the OCI credential. Select this bucket.

    ![Click drop-down list on link data page.](images/click-drop-down-list.png)

3. This bucket contains only the **`potential_churners.csv`** file that you uploaded to the bucket earlier. Drag the **`potential_churners.csv`** file and drop it onto the data linking job section.

    ![The selected bucket.](images/selected-bucket.png)

4. The **`potential_churners.csv`** target table to be created for the selected `.csv` file is displayed in the data linking job section.

    ![Drag the potential_churners.csv file.](images/drag-drop-potential-churners.png)

5. Click **Start**. A **Start Link From Cloud Store** dialog box is displayed. Click **Run**. When the link job is completed successfully, a green check mark appears. Click **Done**.

    ![The link job is completed successfully.](images/link-job-complete.png)

    >**Note:** To view buckets and Cloud Locations in other compartments or in the root tenancy, click the **Data Studio Preferences** icon. You can use the panel to select a different credential, compartment, and AI profile. Click the **Data Studio Preferences** icon. In the **Data Studio Preferences** panel, you can select a different compartment, and then click **Save**.

    ![Click the Data Studio Preferences icon.](images/save-preferences.png)

    The Cloud Locations and buckets that are available in the selected compartment are displayed.

    ![The cloud locations and buckets in the selected compartment.](images/cloud-locations-buckets.png)


## Learn more

* [Load Data from Files in the Cloud](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/autonomous-data-warehouse-cloud&id=CSWHU-GUID-07900054-CB65-490A-AF3C-39EF45505802).
* [Load Data with Autonomous Database](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/user/load-data.html#GUID-1351807C-E3F7-4C6D-AF83-2AEEADE2F83E)

You may now proceed to the next lab.

## Acknowledgements

* **Author:**
    * Lauran K. Serhal, Consulting User Assistance Developer
* **Contributors:**
    + Alexey Filanovskiy, Senior Principal Product Manager
* **Last Updated By/Date:** Lauran K. Serhal, February 2024

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
