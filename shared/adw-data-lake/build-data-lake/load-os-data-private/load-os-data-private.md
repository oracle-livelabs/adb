# Link Data from Private Object Storage Buckets

## Introduction
In this lab, you will link to data from the MovieStream data lake on [Oracle Cloud Infrastructure Object Storage](https://www.oracle.com/cloud/storage/object-storage.html) into your Oracle Autonomous AI Database instance, in preparation for exploration and analysis.

You will practice linking to data from a **private** Object Storage bucket. You learn how to set up and use an authentication token and object store credentials to access sensitive data in the private object store.

> **Note:** While this lab uses Oracle Autonomous AI Lakehouse, the steps are identical for loading data into an Oracle Autonomous AI Transaction Processing database.

Estimated Time: 20 minutes

Watch the video below for a quick walk-through of the lab.
[](youtube:IPkjI6zd2CU)

### Objectives

In this lab, you will:

- Download to your local computer a comma-separated value (.csv) file containing a simulation of sensitive customer data
- Create a private OCI Object Storage bucket
- Upload the .csv file to the OCI private bucket
- Create an object store auth token
- Define object store credentials for your Oracle Autonomous AI Database to communicate with the bucket
- Link to data from the object store using the `DBMS_CLOUD` PL/SQL package
- Troubleshoot the data link

### Prerequisites

- This lab requires completion of **Lab 1: Set up the Workshop Environment > Task 2: Provision the Autonomous AI Database Instance**, from the **Contents** menu on the left.

## Task 1: Download Customer Data from a Public Bucket

Download a **.csv** file that contains a simulation of sensitive customer retention data. Later, you will stage the file on a private **OCI Object Storage** bucket, to populate a table in later tasks.

1. Copy and paste the following URL into a _**new tab**_ in your web browser, and then press **[ENTER]**. The **`moviestream_sandbox`** Oracle Object Storage bucket that contains the data is located in a different tenancy than yours, **c4u04**.

    ```
    <copy>
    https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/moviestream_sandbox/o/potential_churners/potential_churners.csv
    </copy>
    ```

2. The browser page downloads (**Downloads** directory by default in MS-Windows) and displays the **`potential_churners.csv`** file which contains customers who will stop or might stop being repeat customers. The data in the downloaded file is also displayed in an Excel worksheet. Close the worksheet.

  ![Download the potential_churners.csv file to your local computer.](images/potential-churners-csv-file.png =65%x*)

## Task 2: Create a Private Object Storage Bucket

Create a private Object Storage bucket to store your data. For more information about Oracle Object Storage, see [Explore more about Object Storage in Oracle Cloud.](https://docs.oracle.com/en-us/iaas/Content/Object/home.htm)

<if type="livelabs">

1. Navigate back to the Oracle Cloud Console. In your **Run Workshop** browser tab, click the **View Login Info** tab. In your **Reservation Information** panel, click **Launch OCI**.

    ![Click the Launch OCI button.](images/click-launch-oci.png =65%x*)

2. Open the **Navigation** menu in the Oracle Cloud console and click **Storage**. Under **Object Storage & Archive Storage**, click **Buckets**.

3. On the **Buckets** page, select the compartment that was assigned to you where you want to create the bucket from the **Compartment** drop-down list in the **Applied filters** section. Make sure you are in the region that was assigned to you where you will create your bucket.

4. Click **Create Bucket**.

5. In the **Create Bucket** panel, specify the following:
    - **Bucket Name:** Enter a meaningful name for the bucket.
    - **Default Storage Tier:** Accept the default **Standard** storage tier. Use this tier for storing frequently accessed data that requires fast and immediate access. For infrequent access, choose the **Archive** storage tier.
    - **Encryption:** Accept the default **Encrypt using Oracle managed keys**.

    >**Note:** Bucket names must be unique per tenancy and region.

6. Click **Create** to create the bucket.

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
    - **Bucket name:** Enter a meaningful name for the bucket. In this example, we chose **`training-data-lake`** as the name.
    - **Default storage tier:** Accept the default **Standard** storage tier. Use this tier for storing frequently accessed data that requires fast and immediate access. For infrequent access, choose the **Archive** storage tier.
    - **Encryption:** Accept the default **Encrypt using Oracle managed keys**.

    >**Note:** Bucket names must be unique per tenancy and region; otherwise an **already exists** error message is displayed.

5. Click **Create bucket** to create the bucket.

  ![The completed Create Bucket panel is displayed.](./images/create-bucket-panel.png =65%x*)

6. The new bucket is displayed on the **Buckets** page. The default bucket type (visibility) is **Private**.

  ![The new bucket is displayed on the Buckets page.](./images/bucket-created.png =65%x*)

  </if>

## Task 3: Upload Customer Data to your Private Object Storage Bucket

Upload the **`potential_churners.csv`** file that you downloaded earlier in this lab to your newly created private Object Storage bucket. Normally, you would likely upload multiple files to an OCI Object Storage bucket; However, to keep this lab simple and quick, you will upload one file.

1. On the **Buckets** page, click the new bucket name link. 

2. On the **Bucket Details** page, click **Upload objects**.

  ![The Bucket Details page is displayed.](./images/click-upload-objects.png =65%x*)

3. In the **Upload objects** panel, you can drag and drop a single or multiple files into the **Choose Files from your Computer** field or click **select files** to choose the file(s) that you want to upload from your computer. In this example, we used the drag-and-drop method to select the **`potential_churners.csv`** file from our **Downloads** folder.

  ![The Upload Objects panel is displayed.](./images/select-file.png =65%x*)

4. Click **Next**. The **Review and upload files** panel is displayed.

  ![Click Upload objects.](./images/click-upload-objects-panel2.png =65%x*)

5. Click **Upload objects** to upload the selected file to the bucket.

6. When the file is uploaded successfully, a **Done** status is displayed. 

    ![The file is uploaded. Close the panel.](./images/file-uploaded.png =65%x*)

7. Click **Close** to close the **Upload objects** panel. The **Bucket details** page is re-displayed. 

    ![The Upload file is displayed.](./images/bucket-details-page.png =65%x*)

8. Click the **Objects** tab. The newly uploaded file is displayed in the **Objects** section.

    ![The Upload file is displayed.](./images/click-objects-tab.png =65%x*)

<!---
Note to self. I need to update and include the conditional if for livelabs when I am done updating and testing the freetier

<if type="livelabs">
    ![Click on the bucket name.](images/click-bucket-name-livelabs.png " ")

2. Click the **Upload** button:

    ![Click Upload under Objects section.](images/click-upload-livelabs.png " ")
</if>
<if type="freetier">
    ![Click the bucket name.](images/click-bucket-name.png " ")

2. Click the **Upload** button:

    ![Click Upload under Objects section.](images/click-upload.png " ")
</if>
-->

## Task 4: Locate the Base URL for the Object Storage File

Find the base URL of the object you just uploaded to your private Object Storage bucket.

1. In the **Objects** section, in the row for the **`potential_churners.csv`** file, click **Actions** icon (the 3-dot ellipsis), and then select **View object details** from the context menu.

    ![Select View Object Details from the ellipsis on the right of any uploaded file.](images/view-object-details.png =70%x*)

2. In the **Object details** panel, copy the **URL Path (URI)** that points to the location of the file in your private Object Storage bucket up to the **`/o`** part. **_Do not include the trailing slash;otherwise, you will get an error message when you use the URL_**. Save the base URL in a text editor of your choice such as Notepad in MS-Windows. You will use this URL in the upcoming tasks. Next, click **Cancel** to close the **Object details** page.

    ![Copy the base URL.](images/url-path.png =65%x*)

3. The format of the URL is as follows:

    `https://objectstorage.<`**region name**`>.oraclecloud.com/n/<`**namespace name**`>/b/<`**bucket name**`>/o`

    In our example, the **region name** is `us-ashburn-1`, the **Namespace** is blurred for security, and the **bucket name** is `training-data-lake`.

    ![The URL highlighted.](images/url.png =55%x*)

## Task 5: Generate an RSA Key Pair and Get the Key's Fingerprint

[](include:adb-generate-rsa-key-pair.md)

<!-- 

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

 -->
 
## Task 6: Create a Native OCI Credential Using the DBMS_CLOUD PL/SQL Package

You will load data from the **`potential_churners.csv`** file you uploaded to your private Oracle Object Store in an earlier task using the **`DBMS_CLOUD`** PL/SQL package. First, you will create a credential in order to access your  Oracle Object Storage. You perform this step only once.

In this task, you create a credential to connect to an Oracle Object Storage bucket.

1. Navigate back to the **SQL Worksheet** in the **SQL | Oracle Database Actions** browser tab that you used in a previous lab.

    ![Navigate back to the SQL Worksheet.](./images/sql-worksheet.png =65%x*)

2. Create an OCI native credential to access your Object Store. Copy and paste the following script into your SQL Worksheet. Substitute the placeholders values for the **`user_ocid`**, **`tenancy_ocid`**, **`private_key`**, and **`fingerprint`** in the following code with the respective values that you saved from the **Configuration File Preview** dialog box from the previous task.

    >**Note:** To find your unencrypted **private_key** value that you downloaded in the previous task: Open the private key file in a text editor, and then copy the entire key value but don't include the **-----BEGIN PRIVATE KEY-----** and **-----END PRIVATE KEY-----** lines. Next, paste the copied value in the following code.

    ![Private key value.](./images/private-key-value.png =65%x*)

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

    ![Create an OCI credential.](images/credential-created.png =65%x*)

3. Query the available credentials. Copy and paste the following query into your SQL Worksheet, and then click the **Run Statement** icon in the Worksheet toolbar.

    ```
    <copy>
    SELECT credential_name, username, comments
    FROM all_credentials;
    </copy>
    ```

    ![Query credentials.](images/query-credentials.png =65%x*)

    The newly created **`OBJ_STORAGE_CRED`** is displayed.

## Task 7: (Optional) Create Native OCI Credentials, RSA Key Pairs, a Fingerprint, and Auth Tokens Using a Cloud Shell Script

> _**Note:** You can only try this optional task in your own tenancy and not in green button reservation._

In Task 6, you learned how to create an an OCI native credential to access your Object Store using the OCI Console. An alternative method to create an native OCI credential and, an RSA key pairs with a fingerprint, and an optional Auth token is to use a Cloud Shell script named **`adb-create-cred.sh`** that you will run in this task. This script is located in the **`/usr/local/bin`** directory.

### **Start the OCI Cloud Shell**

1. Start Cloud Shell. On your Oracle Console banner, click the **Developer tools** icon, and then select **Cloud Shell**. In our example, the home region is **US East (Ashburn)**.

    ![Start Cloud Shell.](images/start-cloud-shell.png =65%x*)

    >**Note:** If you do not have access to Cloud Shell, you can create OCI Native Credentials without using the `adb-create-cred.sh` script. See [Create Oracle Cloud Infrastructure Native Credentials](https://docs-uat.us.oracle.com/en/cloud/paas/query-service/adwst/adp-ld-managing-cloud-storage-connections.html#GUID-4E849D62-2DB2-426E-9DF8-7E6169C20EE9) for details.

2. After a minute or so, the Cloud Shell is displayed along with your currently selected region. In this example, our home region is **`US East (Ashburn)`** as shown in the banner and also in the Cloud Shell prompt.

    ![Click Maximize.](images/click-maximize.png =65%x*)

3. Maximize the Cloud Shell view. Click the **Maximize** icon on the Cloud Shell banner. The Cloud Shell view is maximized.

    ![Maximized screen.](images/maximized-screen.png =65%x*)

4. To clear the screen, enter the **`clear`** command at the prompt and then press the **`[Enter]`** key.

    ![Clear screen.](images/clear-screen.png =65%x*)

    The screen is cleared.

    ![Screen cleared.](images/screen-cleared.png =65%x*)

### **The Available Script's Arguments**

Let's explore some of the available arguments that you can use with the script.

* **`--help`**:    
This argument lists the available arguments that you can use with the script. Copy and paste the following command on the command prompt, and then press the **`[Enter]`** key.

    ```
    <copy>
    adb-create-cred.sh --help
    </copy>
    ```

    ![Run the script with the help argument.](images/run-script-help.png =65%x*)

* **`-r`** or **`--region`**:    
By default, the script creates the credentials in an Oracle Autonomous AI  Database in your home region; therefore, it will not prompt you for a region; In this scenario, you run the script _without the region argument_.    

    If you are in your home region and your Oracle Autonomous AI Database is in a _different region_, then you must use the **`--region`** argument. This argument enables you to select a region that contains the desired Oracle Autonomous AI Database from a list of regions that are available to you.

    ```
    adb-create-cred.sh --region
    ```
    
    >**Note:** Once you select your region, it may take few minutes to gather information about the compartments and Oracle Autonomous AI Database instances on a large Tenancy; however, the next two arguments will speed up the process of creating the credentials in a different region and a specific compartment in the selected region.
    
* **`-r=region_name`** or **`--region=region_name`**:    
This argument is similar to the **`--region`** argument except that you must provide the region name with it. In our example, our home region is **`us-ashburn-1`**. If we want to create the credentials scripts in the **`ca-toronto-1`** region, then we would run the script with the region argument as follows which is faster than using the `--region` argument.

    ```
    adb-create-cred.sh --region=ca-toronto-1
    ```

* **`-c=compartment_name`** or **`--compartment=compartment_name`**:    
If you want to create the credentials in a specific compartment instead of having the script list all of your available compartments and then have you choose the desired compartment, which can take time, you can use the **`--compartment`** argument along with the name of the compartment that contains Autonomous Databases to which you have access. This will be a faster option. If the following example, we used the argument with the name of the compartment that contains the ADB instance where we want to create the credentials.

    ```
    adb-create-cred.sh --compartment=training-adw-compartment
    ```

    Finally, we can run the script in a different region and a specific compartment as follows:

    ```
    adb-create-cred.sh --region=us-ashburn-1 --compartment=training-adw-compartment
    ```

### **Example 1: Run the Script with No Arguments**

Now that you are familiar with the arguments that you can use with the script, let's go through a simple example like we did in **Lab 3 > Task 1**. We will run the script in our **`us-ashburn-1`** home region; however, we won't run the generated script in any Oracle Autonomous AI Database instance; instead, we will opt to run the generated `.sql` credential script ourselves later in the SQL Worksheet of our Oracle Autonomous AI Database instance. In addition, we don't have any existing API keys, a fingerprint, or a wallet file. If we did, we will be prompted on whether we'd like to reuse them.

1. Run the **`adb-create-cred.sh`** Cloud Shell script. Enter its name at the command prompt, and then press the **`[Enter]`** key.

    ```
    <copy>
    adb-create-cred.sh 
    </copy>
    ```

    Notice the prompts and our selections in the following screen capture. The public and private API keys and a fingerprint are created. The following `.sql` and `json` OCI native credential scripts are also created for you:

    * **`oci_native_credential.sql`**
    * **`oci_native_credential.json`**

    ![Don't run script on any ADB instance.](images/create-credential-no-adb-run.png)

2. Next, you are prompt whether or not you want to generate the AI profile script. Enter yes. Select from the list of available models. In our example, we chose 6. The generative AI SQL file is created.

    ![Generate AI profile script?](images/generate-ai-profile.png)

3. Next, you are prompted whether or not you'd like to run the generated credentials in an Oracle Autonomous AI Database of your choice. Again, in this example, we'll keep it simple and enter **`[n]`** for no. The script is existed. Next, you copy the generated credential script and run it in your Cloud Shell window or download it or copy it and run it in SQL Developer, SQL Developer worksheet, or in any tool that runs SQL.

    ![Exit the script.](images/exit-script.png)

4. Verify the creation of the credentials. List the contents of your Cloud Shell home directory. Copy and paste the following command to the command prompt and then hit **`[Enter]`**.

    ```
    <copy>
    ls -l
    </copy>
    ```

    ![List the home directory contents.](images/list-home-directory.png =70%x*)

4. To view the generated private and public keys, copy and paste the following command to the command prompt and then hit **`[Enter]`**. Next, run the `ls -l` command again.

    ```
    <copy>
    cd ~/.oci
    </copy>
    ```

    ![List the .oci directory contents.](images/list-oci-directory.png =70%x*)

5. Return to your Home directory. Run the **`cd ..`** command. Next, use the **`cat`** command to display the content of the generated script.

    ```
    <copy>
    cd ..
    cat oci_native_credential.sql
    </copy>
    ```

    ![List the script.](images/copy-script.png " ")

6. Copy the script from the first **`BEGIN`** statement to the ending **`/`**. Highlight the code, right-mouse click, and then select **Copy** from the context menu.

7. Return to your SQL Worksheet and then paste the copied code into the SQL Worksheet. Notice that we changed the name of the credential to be created to **`OCI_NATIVE_CRED_2`**. The first script drops the credential if it already exists. The second script creates the new credential. Click the **Run Script** icon in the Toolbar.

    ![Paste the script into the SQL Worksheet.](images/paste-script.png " ")

8. Query the available credentials. Copy and paste the following query into your SQL Worksheet, and then click the **Run Statement** icon in the Worksheet toolbar.

    ```
    <copy>
    SELECT credential_name, username, comments
    FROM all_credentials;
    </copy>
    ```

    ![Query credentials again.](images/query-credentials-example-1.png =70%x*)

    The newly created **`OCI_NATIVE_CRED_2`** is displayed.

### **Example 2: Run the Script with the --region and --compartment Arguments**

In this example, we assume that we didn't run example 1. Our **`ADW-Data-Lake`** Oracle Autonomous AI Database instance is in our home region, **`us-ashburn-1`**, in the **`training-adw-compartment`** compartment.

1. Run the **`adb-create-cred.sh`** Cloud Shell script with the `--region` and `--compartment` arguments.

    ```
    <copy>
    adb-create-cred.sh --region=us-ashburn-1  --compartment=training-adw-compartment    
    </copy>
    ```

    The process is as follows: 
    * The script creates the public and private API keys and the fingerprint.
    * The native credential SQL and JSON files are created.
    * The script prompts if want to proceed with generating the AI profile script. We entered **`[y]`**.
    * We chose option **6** for the Generative AI Model.
    * We entered **`[y]`** for the verification.
    * We entered **`[y]`** to accept the term of the Llama 3.1 License Agreement. The Generative AI SQL file is created.
    * We entered **`[n]`** for the spreadsheet add-ins.
    * The script prompts as to whether or not we'd like to run the credential script in our Oracle Autonomous AI Database. We entered **`[y]`**. 
    * The Oracle Autonomous AI Database instances that are available in the selected region and compartment are displayed. We entered **1** for our only Oracle Autonomous AI Database instance.
    * The script recognized that we don't have a wallet file; therefore, it created one for us.
    * An informative message is displayed about what has been created so far. Next, the script attempts to connect to our selected Oracle Autonomous AI Database instance so that we can run the generated script file. 
    * We are prompted to enter our Oracle Autonomous AI Database instance username and password. The ADB instance username is **`admin`** and the password that we used in **Lab 1** of this workshop is **`Training4ADW`**. If the login is successful, the script is run and the **`oci_native_credential.sql`** credential is created. If the connection to the Oracle Autonomous AI Database is unsuccessful, you can execute **`cat ~/oci_native_credential.sql`**, to copy the SQL code and run it directly in the Oracle Autonomous AI Database using any SQL tool such as the SQL Worksheet similar to what we did in example 1.
    * Finally, we are prompted whether or not we want to run the credential script in another Oracle Autonomous AI Database instance. We entered **`[n]`**. The script exits.

        ![Run the script with the region and compartment arguments.](images/script-prompts-output.png =65%x*)
   
    > **Note:** If you have an Oracle Autonomous AI Database private endpoint in a Virtual Cloud Network, the adb-create-cred.sh script generates the SQL or JSON scripts and performs all the steps required to access the Oracle Autonomous AI Database private end point. However, it will fail to connect, which causes a login failure. If you have a Bastion or Jump Host you can connect yourself by utilizing the downloaded wallet file then execute the following command to copy the SQL into whatever SQL tool you have access to:

8. Query the available credentials. Copy and paste the following query into your SQL Worksheet, and then click the **Run Statement** icon in the Worksheet toolbar.

    ```
    <copy>
    SELECT credential_name, username, comments
    FROM all_credentials;
    </copy>
    ```

    ![Query credentials again.](images/query-credentials-2.png =65%x*)

    The newly created **`OCI_NATIVE_CRED`** is displayed.

### **Example 3: Run the Script in a Different Region**

In the following example, our home region is **`us-ashburn-1`**; however, we want to create the credentials in the **`ca-toronto-1`** region. The steps are the same as before; however, since we are not in our home region when we run the script, we are prompted to make one of the following choices:

* Keep the current region, **`k`**, (**`ca-toronto-1`**)
* Change to the home directory, **`h`**, (**`us-ashburn-1`**)
* Pick a different region, **`p`**. If you choose **`p`**, a list of the available regions to which you have access are displayed and then you can pick a different region. 

In this example, we will enter **`k`** to keep the current region. The remaining steps are the same as those in example 2.

![Select the region.](images/select-region.png =65%x*)

### **Create Auth Token/Swift Credential Using the Cloud Shell Script**

If you need to create an **Auth Token/Swift** credential (Oracle recommends the use of OCI Native Credentials instead), you can add the **`--all`** argument when you run the script.

1. Create both the **OCI Native** credentials and the **Auth Token/Swift** credential. Run the **`adb-create-cred.sh`** Cloud Shell script with the **`--all`** argument. The script prompts you whether you want to include an Auth Token. If you enter **`[y]`**, your Auth Token key is generated and uploaded to your OCI profile, and the **`oci_auth_token_credential.sql`** and **`auth_token.tok`** scripts are created.

    ```
    <copy>
    adb-create-cred.sh --all
    </copy>
    ```

    ![Create Auth Token.](images/create-credentials-token.png =65%x*)

    **Note:** The script recognized the existence of an `AuthToken` file. We opted to replace the existing file and create a new one.

2. List the contents of your Cloud Shell home directory.

    ```
    <copy>
    ls -l
    </copy>
    ```

    ![List the home directory contents.](images/list-home-directory-auth-token.png =65%x*)

3. You can view the Auth Token key using either of the following methods:

    * Run the **`oci_auth_token_credential.sql`** script from the Cloud Shell. This creates the Auth Token key in your database. The Auth Token key is the value of the password parameter for **`DBMS_CLOUD_CREATE_CREDENTIAL`**.
    
    * View **`auth_token.tok`** from the Cloud Shell. Your Auth Token is the value of **`token`**.

        ![The auth_token.tok value.](images/auth-token-value.png =65%x*)

## Task 8: Link to Data in the Bucket

1. Click **Database Actions | SQL** in the banner to display the **Launchpad** page. Click the **Data Studio** tab, and then click the **Data Load** tab.

    ![Navigate to Data Load page.](images/click-data-studio-data-load.png =65%x*)

2. On the **Data Load** page, click the **LINK DATA** tile.

    ![Click link data.](images/click-link-data.png =65%x*)

    The **Link Data** page is displayed. The **Cloud Store** tab is already selected. Click the **Select Cloud Store Location or enter public URL** drop-down list to see the buckets and/or Cloud Locations to which you have access. In this workshop, you already have access to the **`TRAINING-DATA-LAKE`** private bucket in your compartment after your created the OCI credential. Select this bucket.

    ![Click drop-down list on link data page.](images/click-drop-down-list.png =65%x*)

3. This bucket contains only the **`potential_churners.csv`** file that you uploaded to the bucket earlier. Drag the **`potential_churners.csv`** file and drop it onto the data linking job section.

    ![The selected bucket.](images/selected-bucket.png =65%x*)

4. The **`potential_churners.csv`** target table to be created for the selected `.csv` file is displayed in the data linking job section.

    ![Drag the potential_churners.csv file.](images/drag-drop-potential-churners.png =65%x*)

5. Click **Start**. A **Start Link From Cloud Store** dialog box is displayed. Click **Run**. When the link job is completed successfully (external table created), the data link card has the link icon next to it.

    ![The link job is completed successfully.](images/link-job-complete.png =65%x*)

6. Click the **Report** button for the link job to view a report of total rows inserted successfully and failed for the selected table.

    ![Click Report.](images/click-report.png =65%x*)

7. To view buckets and Cloud Locations in other compartments or in the root tenancy, click the **Data Studio Preferences** icon.

    ![Click the Data Studio Preferences icon.](images/click-data-studio.png =65%x*)

8. You can use the panel to select a different credential, compartment, and AI profile. Click the **Data Studio Settings** icon. In the **Data Studio Settings** panel, you can select a different compartment, and then click **Close**.

    ![Change preferences.](images/save-preferences.png =65%x*)

    The Cloud Locations and buckets that are available in the selected compartment are displayed.

## Learn more

* [Load Data from Files in the Cloud](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/autonomous-data-warehouse-cloud&id=CSWHU-GUID-07900054-CB65-490A-AF3C-39EF45505802).
* [Load Data with Autonomous AI Database](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/user/load-data.html#GUID-1351807C-E3F7-4C6D-AF83-2AEEADE2F83E)
* [Manage Credentials](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/autonomous-manage-credentials.html#GUID-863FAF80-AEDB-4128-89E7-3B93FED550ED)

You may now proceed to the next lab.

## Acknowledgements

* **Author:** Lauran K. Serhal, Consulting User Assistance Developer
* **Contributors:**
    * Alexey Filanovskiy, Senior Principal Product Manager
    * Jameson White, Principal Software Engineer
* **Last Updated By/Date:** Lauran K. Serhal, October 2025

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) 2025 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
