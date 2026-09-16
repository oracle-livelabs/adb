# Connect to Autonomous AI Database on Dedicated Exadata Infrastructure from Oracle Enterprise Manager

## Introduction

Oracle Cloud Infrastructure Marketplace provides a prebuilt image with the necessary client tools and drivers to deploy compute instances and connect to Autonomous AI Database on Dedicated Exadata Infrastructure (Autonomous AI Database) from Oracle Enterprise Manager. Oracle Enterprise Manager is a complete, integrated, business-driven management solution for traditional and cloud environments. It takes advantage of the built-in management capabilities of the Oracle stack and enables monitoring and management of your entire infrastructure from a single console. A database administrator can use Oracle Enterprise Manager to connect to an Autonomous AI Database and monitor its performance.

*In this lab, you will configure access to an Autonomous AI Database from Oracle Enterprise Manager.*

Estimated Time: 60 minutes

### Objectives

As a database administrator:

1. Learn how to connect an Autonomous AI Database to Oracle Enterprise Manager.

### Required Artifacts

- An Oracle Cloud Infrastructure account.
- A pre-provisioned Autonomous Database Dedicated instance. Refer to [Provisioning Databases](https://livelabs.oracle.com/ords/r/dbpm/livelabs/run-workshop?p210_wid=3197) lab for details.

## Task 1: Set up Oracle Enterprise Manager on Oracle Cloud Infrastructure (OCI)

You can set up Oracle Enterprise Manager on OCI using images available in OCI Marketplace.

- Sign in to your Oracle Cloud Infrastructure account and navigate to **Marketplace** > **All Applications**.

  ![Navigate to OCI Marketplace.](./images/install-oem-1.png " ")

- Search **Enterprise Manager** and choose the version you want to use.

  ![Search Enterprise Manager](./images/install-oem-2.png " ")

- Click **Launch Stack**.

  ![Launch Stack.](./images/install-oem-3.png " ")

- Review the Oracle Enterprise Manager overview, select the compartment where the stack will be located. Checkmark the Oracle Standard Terms and Restrictions and click **Launch Stack**.

  ![Choose Enterprise Manager Version](./images/install-oem-4.png " ")

- In Edit Stack, under Stack Information enter the Name and Description for your stack. Click **Next**.

- Enter the Configuration Details, select Simple in **Enterprise Manager Deployment Size** and check **Advanced Deployment** to allow reuse of existing VCN and subnets.

  ![Enterprise manager Configuration details.](./images/install-oem-5.png " ")

- Select your Compartment, select Use Existing VCN and, from drop down menu, choose your existing VCN.

  ![This image shows the result of performing the above step.](./images/install-oem-6.png " ")

- Pick the Compartment where your existing public subnet exists, in many cases this will be your VCN compartment. Then, select **Use Existing EM/DB subnet**, of type **Use Public Subnet** and, lastly, select your existing public subnet from the drop down menu.
  
  ![Enterprise manager Networking details.](./images/install-oem-7.png " ")

- In the following section, **Oracle Management Server Details**, pick the Compartment where you are planing to provision Enterprise Manager, fill Host name prefix and Passwords, pick the right Shape, Boot volume, Availability Domain and insert public SSH key.

- In the **Repository Database System Details** section enter your Passwords and click on **Next**.

- Review the configuration variables entered, check **Run apply** and click on **Create** to initiate stack deployment.

- Click **Apply** to create the OCI Resources and deploy Enterprise Manager.

- In the **Resources** section under **Jobs** you can track the Stack creation process. The Apply job takes 20 minutes for the single node. On successful completion of the job, access to Enterprise Manager can be viewed in the **Application Information** tab.  Copy the public IP address of the Enterprise Manager instance.

## Task 2: Transfer the database wallet to the client machine

- Navigate to OCI console. Click the hamburger menu icon on the top left of the screen. Click **Oracle AI Database**.

- Click **Autonomous AI Database on Dedicated Infrastructure**. You get a list of ADB instances that have been created.
- Click on the ADB instance that was created in the earlier lab.
  ![List Autonomous AI database.](./images/listadb.png " ")
- Click **Database Connection** to open the Database Connection pop-up window.
  ![Database Connection.](./images/dbconnection.png " ")
- Click **Download wallet** to supply a password for the wallet and download your client credentials.
  ![Download Wallet.](./images/downloadwallet.png " ")
    Please use below Keystore password to download the client credentials.

    ```
    <copy>
    WElcome#1234
    </copy>
    ```

    ![Confirm Download wallet.](./images/downloadwallet-confirmpwd.png " ")

## Task 3: Connect to Oracle Enterprise Manager from a web browser

- In your browser, open the URL: https://<public_ip_address_of_oem_compute>:7803/em
- On the Login screen, enter the user name sysman, and the password you provided for this user account at the time of installation, and click **Login**.

## Task 4: Add Autonomous AI Database as a target in Oracle Enterprise Manager

- Click **Setup**, select **Add Target**, and then click **Add Targets Manually**.

    ![Add target Manually.](./images/add-adbd-1.png " ")

- Click **Add Target Declaratively**.

    ![Add target Declaratively.](./images/add-adbd-2.png " ")

- Search for the host name and select the name of your host. For example, **emcc.marketplace.com**.

    ![List Hosts available.](./images/add-adbd-3.png " ")

    ![Choose Host for target.](./images/add-adbd-4.png " ")

- Select the target type **Autonomous AI Database** and click **Add**.

    ![Choose Autonomous AI Database.](./images/add-adbd-5.png " ")

- Enter the following details: 
    - Enter the target name **ADBEM** (you can use any name you prefer).
    - Select **OCI Client Credential (Wallet)** as the wallet downloaded from the console.
    - Select the service name **<ATPD_Name>_low**.
    - Enter the monitoring username **ADMIN**.
    - Enter the monitoring password that you used for the wallet download.

    ![Add Database instance](./images/add-adbd-6.png " ")

- Click **Test Connection**.

    ![Test connection.](./images/add-adbd-7.png " ")

- When the connection test succeeds, click **Next** and then **Submit**.

    ![Click Next.](./images/add-adbd-8.png " ")

    ![Add Database instance properties.](./images/add-adbd-9.png " ")

    ![Add Database instance properties.](./images/add-adbd-10.png " ")

    ![Submit creation.](./images/add-adbd-11.png " ")

## Task 5: Test the connection

- Click **Targets** and select **All Targets**.

    ![List All targets.](./images/test-conn-1.png " ")

- Under **Databases**, select your database type, For example **Autonomous Transaction Processing**.

    ![Select Database type.](./images/test-conn-2.png " ")

    ![Choose the Autonomous AI Database.](./images/test-conn-3.png " ")

- Select the target name **ADBEM**.

## Task 6: Unlock the ADBSNMP user

- Under **Security**, select **Users**.

    ![Navigate to Users.](./images/upd-01.png " ")

- The default Oracle Enterprise Manager user, **ADBSNMP**, may be locked. Click the **ADBSNMP** user.

    ![Click ADBSNMP user.](./images/upd-02.png " ")

- Click **Edit**.

    ![Edit user.](./images/upd-03.png " ")

- Select the **Unlocked** radio button, enter a new password for the **ADBSNMP** user, and click **Apply**.

    ![Unlock user.](./images/upd-04.png " ")

- After the change is saved, return to **Users** under **Security**. The **ADBSNMP** user should be listed as **Open**.

    ![Verify user detail.](./images/upd-05.png " ")

## Task 7: Establish a connection by using the ADBSNMP user

- Repeat Task 4 with the following changes:

- Use the target name **ADBEM2** (you can use any name you prefer).

- Select **OCI Client Credential (Wallet)** as the wallet downloaded from the console.

- Select the service name **<ATPD_Name>_low**.

- Enter the monitoring username **ADBSNMP**.

- Enter the monitoring password for the ADBSNMP user and click **Test Connection**.

    ![Test connection.](./images/upd-07.png " ")

- When the connection test succeeds, click **OK** and then **Next**.

    ![Click Next.](./images/upd-08.png " ")

- Click **Submit** to establish the connection.

    ![Verify connection details.](./images/upd-09.png " ")

    ![Submit connection.](./images/upd-10.png " ")

*Congratulations! You have successfully established a connection to Autonomous AI Database on Dedicated Exadata Infrastructure from Oracle Enterprise Manager.*

You may now **proceed to the next lab**.

## Acknowledgements

- **Authors** - Navya M S & Padma Priya Natarajan
- **Adapted by** - Vandana Rajamani, Consulting UA Developer, July 2026
- **Last Updated By/Date** - Vandana Rajamani, Consulting UA Developer, July 2026

