# Link Data from Private Object Storage Buckets

## Introduction
In this lab, you will link to data from the MovieStream data lake on [Oracle Cloud Infrastructure Object Storage](https://www.oracle.com/cloud/storage/object-storage.html) into your Oracle Autonomous Database instance, in preparation for exploration and analysis.

You will practice linking to data from a **private** Object Storage bucket. You learn how to set up and use an authentication token and object store credentials to access sensitive data in the private object store. Instead of using the wizard-driven data loading tools of Database Actions, you practice loading data using the **DBMS_CLOUD** PL/SQL package, the preferred method for load automation.

> **Note:** While this lab uses Oracle Autonomous Data Warehouse, the steps are identical for loading data into an Oracle Autonomous Transaction Processing database.

Estimated Time: 20 minutes

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

2. The browser page downloads (**Downloads** directory by default in MS-Windows) and displays the **`potential_churners.csv`** file. This file contains customers who will stop or might stop being repeat customers.

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

## Task 6: Define a Cloud Location and Create a Credential

You will load data from the `potential_churners.csv` file you uploaded to your private Oracle Object Store in an earlier task using the `DBMS_CLOUD` PL/SQL package. There are two parts to this process:

+ Set up a connection to Oracle Object Storage by defining a cloud location with a credential. You perform this step only once.
+ Load the file using the `DBMS_CLOUD` PL/SQL package.

In this task, you define a **Cloud Location** to connect to Oracle Object Storage. To begin this process, you need to navigate back to the **DATA LOAD** page of **Database Actions**.

1. On the **Oracle Cloud Console** Home page, open the **Navigation** menu and click **Oracle Database**. Under **Oracle Database**, click **Autonomous Database**.

<if type="livelabs">
2. On the **Autonomous Databases** page, click your **DB-DCAT** ADB instance.
</if>

<if type="freetier">
2. On the **Autonomous Databases** page, click your **ADW-Data-Lake** ADB instance.
</if>

3. On the **Autonomous Database details** page, click **Database actions**.

4. The **Database Actions | Launchpad** Home page is displayed in a new tab in your browser. In the **Data Studio** section, click the **DATA LOAD** card.

    ![The Database Actions Launchpad Home page is displayed. The Data Load card in the Data Studio section is highlighted.](./images/click-data-load.png " ")

5. In the **Administration** section, click **CLOUD LOCATIONS**, and then click **Next**.

    ![Click the Cloud Locations card.](./images/click-cloud-locations.png " ")

6. On the **Manage Cloud Store** page, click **Add Cloud Store Location**.

    ![Click Add Cloud Storage.](./images/click-add-cloud-store-location.png " ")

7. Specify the following in the **Add Cloud Store Location** panel.
    + **Name:** Enter **`training-data-lake`**.
    + **Description:** Enter an optional description.
    + Select the **Create Credential** option. To access data in the Object Store, you need to enable your database user to authenticate itself with the Object Store using your OCI object store account and a credential. You do this by creating a private CREDENTIAL object for your user that stores this information encrypted in your Autonomous Data Warehouse. This information is only usable for your user schema.
    + In the **Credential** section, specify the following:
        + **Credential Type:** Select the **Oracle Cloud Infrastructure Signing Keys** option.
        + **Credential Name:** Enter **OBJ\_STORAGE\_CRED**. **Note:** The credential name must conform to Oracle object naming conventions, which do not allow spaces or hyphens.
        + **Fingerprint:** Enter the fingerprint for your RSA key pair that you copied earlier to a text file.
        + **Private Key:** Paste your unencrypted private key in the RSA key pair.
        Open the private key file in a text editor, and then copy the entire content from the (and including) **-----BEGIN PRIVATE KEY-----** line to (and including) the **-----END PRIVATE KEY-----** line.
        ![Private key.](./images/private-key-value.png " ")

        + **Oracle Cloud Infrastructure Tenancy:** Enter your tenancy OCID that you copied earlier to a text file.
        + **Oracle Cloud Infrastructure User Name:** Enter your _**user's OCID**_ (and not the actual username).  _**Note:** If you did complete the optional **Task 5**, then the you should have already saved the user's OCID (and not the actual username) in a text file of your choice. If you didn't perform the optional **Task 5**, you can find the user's OCID as follows: Navigate to the **Oracle Cloud Console**. Click the **User's** drop-down list, and then select **User settings**. In the **User Details** page, in the **User Information** tab, click **Copy** next to the **OCID** field. Save this user OCID in your text file._
    + Select the **Bucket URI** option.
    + **Bucket URI:** Enter the Bucket URI that you identified and saved in **Task 4**. Remember to use this general structure, swapping in your own values. _Remember, don't include the trailing slash after the **`/o`**; otherwise, you will get an error_.

      `https://objectstorage.region name.oraclecloud.com/n/namespace name/b/bucket name/o`

        ![Complete the Add Cloud Store Location.](./images/complete-add-cloud-store-location.png " ")

8. Click **Next** to see the available objects in the bucket that you specified. There is only one file that you uploaded to your private Object Storage bucket, `potential_churners.csv`.

    ![Click Next to see the objects in the bucket.](./images/click-next.png " ")

9. Click **Create**. The **training-data-lake** cloud location is displayed in the **Manage Cloud Store** page.

    ![The cloud store location is created.](./images/cloud-store-location-created.png " ")

## Learn more

* [Load Data from Files in the Cloud](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/autonomous-data-warehouse-cloud&id=CSWHU-GUID-07900054-CB65-490A-AF3C-39EF45505802).
* [Load Data with Autonomous Database](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/user/load-data.html#GUID-1351807C-E3F7-4C6D-AF83-2AEEADE2F83E)

You may now proceed to the next lab.

## Acknowledgements

* **Author:**
    * Lauran Serhal, Consulting User Assistance Developer, Oracle Database and Big Data
* **Contributors:**
    + Alexey Filanovskiy, Senior Principal Product Manager
    + Rick Green, Principal Developer, Database User Assistance
* **Last Updated By/Date:** Lauran Serhal, June 2023

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
