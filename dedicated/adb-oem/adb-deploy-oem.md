# Connecting to Autonomous Transaction Processing Dedicated from Oracle Enterprise Manager

## Introduction
The Oracle Cloud Infrastructure marketplace provides a pre-built image with necessary client tools and drivers to deploy compute instances and connect to Autonomous Transaction Processing Dedicated. A database administrator can now connect to ATPD from Oracle Enterprise Manager and monitor the performance.

The image is pre-configured and installed with Oracle Enterprise manager.
For a complete list of features, log in to your OCI account, select **Marketplace** from the top left menu and browse details on the **Enterprise Manager 13c Workshop v3.0**.

*In this lab we will configure and access Autonomous dedicated Transaction Processing database from Oracle Enterprise Manager.*

Estimated Time: 60 minutes

### Objectives

As a Database Administrator:

1. Learn how to connect to Autonomous Dedicated Transaction Processing Database from Oracle Enterprise Manager.

### Required Artifacts

   - An Oracle Cloud Infrastructure account.
   - A pre-provisioned dedicated autonomous database instance. Refer to the **Provisioning Databases** lab in the **Introduction to ADB Dedicated for Developers and Database Users** workshop.
   - A pre-provisioned compute instance of Image type "Enterprise Manager 13c Workshop v3.0"

## Task 1: Create a Compute Instance with OEM installed in it

- Log in to your Oracle Cloud Infrastructure account and select **Compute** > **Instances** from top left menu.

    ![This image shows the result of performing the above step.](./images/compute1.png " ")

- Click **Create Instance**.

    ![This image shows the result of performing the above step.](./images/compute3.png " ")

- A pop-up dialog opens. Select the compartment in which you create compute and click **Change Image**.

    ![This image shows the result of performing the above step.](./images/compute4.png " ")

- Select **Enterprise Manager 13c Workshop v3.0** under **Oracle images**.

    ![This image shows the result of performing the above step.](./images/compute5.png " ")

- Select VCN compartment and VCN, subnet compartment and subnet and then click **Create**, which will create compute with EM installed.

    ![This image shows the result of performing the above step.](./images/compute6.png " ")

- Copy the public IP address of the instance in a note pad.

    ![This image shows the result of performing the above step.](./images/compute2.png " ")

**Mac / Linux users**

- Open Terminal and SSH into linux host machine.

    ```
    <copy>
    sudo ssh -i /path_to/sshkeys/id_rsa opc@publicIP
    </copy>
    ```

**Windows users**

- You can connect to and manage linux host machine using SSH client. Recent versions of Windows 10 provide OpenSSH client commands to create and manage SSH keys and make SSH connections from a command prompt.

- Other common Windows SSH clients you can install locally is PuTTY. Click [this documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ssh-from-windows) to follow the steps to connect to linux host machine from your windows using PuTTY.

## Task 2: Connect to Oracle Enterprise Manager from web browser

- In your browser, type the URL as "https://publicipaddress\_of\_oem\_compute:7803/em"

## Task 3: Transfer database wallet to developer client

- Log in to your Oracle Cloud Infrastructure account and select **Autonomous Transaction Processing** from the menu.
    ![](./images/atpd1.png " ")

- Click **Autonomous Database** and select your previously created database.
    ![](./images/atpd2.png " ")

- Click **DB Connection**. Under **Download Client Credential(Wallet)**, click **Download**.
    ![](./images/atpd3.png " ")

- Provide a password and download the wallet to a local folder.
    ![](./images/atpd4.png " ")

    The credentials zip file contains the encryption wallet, Java keystore and other relevant files to make a secure TLS 1.2 connection to your database from client applications. Store this file in a secure location.

## Task 4: Add Autonomous Transaction Processing Database dedicated as Target in OEM

- Click **Setup** and select **Add Target** and click **Add Targets Manually**.

    ![This image shows the result of performing the above step.](./images/atpd5.png " ")

- Click **Add Target Declaratively**.

    ![This image shows the result of performing the above step.](./images/atpd6.png " ")

- Search the host name and select **emcc.marketplace.com**.

    ![This image shows the result of performing the above step.](./images/atpd7.png " ")

    ![This image shows the result of performing the above step.](./images/atpd8.png " ")

- Select Target Type **Autonomous Transaction Processing** and click **Add..**.

    ![This image shows the result of performing the above step.](./images/atpd9.png " ")

- Give the Target Name **ADBEM** (Target name can be anything you want.)

- Select **OCI Client Credential (Wallet)** as ATPD instance wallet downloaded from console.

- Select **Service Name** **<ATPD_Name>_low**.

- Give the **Monitoring Username** **ADMIN**.

- Give **Monitoring Password** as your wallet (.zip file) download password.

    ![This image shows the result of performing the above step.](./images/atpd10.png " ")

- Click **Test Connection**.

    ![This image shows the result of performing the above step.](./images/atpd11.png " ")

- Once the connection test is successful, click **Next** and click **Submit**.

    ![This image shows the result of performing the above step.](./images/atpd12.png " ")

    ![This image shows the result of performing the above step.](./images/atpd13.png " ")

    ![This image shows the result of performing the above step.](./images/atpd14.png " ")

    ![This image shows the result of performing the above step.](./images/atpd15.png " ")

## Task 5: Test the connection

- Click **Targets** and select **All Targets**.

    ![This image shows the result of performing the above step.](./images/atpd16.png " ")

- Under **Databases** select **Autonomous Transaction Processing**.

    ![This image shows the result of performing the above step.](./images/atpd17.png " ")

    ![This image shows the result of performing the above step.](./images/atpd18.png " ")

- Under **Target Name** select **ADBEM**.

## Task 6: Unlock "ADBSNMP" user

- Select **Users** under **Security**.

    ![This image shows the result of performing the above step.](./images/upd-01.png " ")

- The default user for OEM, **ADBSNMP**, will be locked by default. Click the user **ADBSNMP**.

    ![This image shows the result of performing the above step.](./images/upd-02.png " ")

- Click **Edit**.

    ![This image shows the result of performing the above step.](./images/upd-03.png " ")

- Select the **Unlocked** radio button and give the new password for **ADBSNMP** user and click **Apply**.

    ![This image shows the result of performing the above step.](./images/upd-04.png " ")

- Once the change is saved check under **Users** in **Security**. The user **ADBSNMP** will be **Open**.

    ![This image shows the result of performing the above step.](./images/upd-05.png " ")

## Task 7: Establish connection with ATP as "ADBSNMP" user

- Repeat Task 4 with the following changes:

- Give the Target Name as **ADBEM2** (target name can be anything you want.)

- Select **OCI Client Credential (Wallet)** as the ATPD instance wallet downloaded from the console.

- Select **Service Name** as **<ATPD_Name>_low**.

- Give the **Monitoring Username** as **ADBSNMP**.

- Give **Monitoring Password** as ADBSNMP user password and click **Test Connection**.

    ![This image shows the result of performing the above step.](./images/upd-07.png " ")

- Once the connection test is successful, Click **OK** and click **Next**.

    ![This image shows the result of performing the above step.](./images/upd-08.png " ")

- Click **Submit** to establish the connection.

    ![This image shows the result of performing the above step.](./images/upd-09.png " ")

    ![This image shows the result of performing the above step.](./images/upd-10.png " ")

You may now **proceed to the next lab**.

## Acknowledgements
*Congratulations! You have successfully established connection to Autonomous Transaction Processing Dedicated Database from OEM .*

- **Authors** - Navya M S & Padma Priya Natarajan
- **Last Updated By/Date** - Kris Bhanushali, March 2022

## See an issue or have feedback?
Please submit feedback [here](https://apexapps.oracle.com/pls/apex/f?p=133:1:::::P1_FEEDBACK:1).   Select 'Autonomous DB on Dedicated Exadata' as workshop name, include Lab name and issue / feedback details. Thank you!
