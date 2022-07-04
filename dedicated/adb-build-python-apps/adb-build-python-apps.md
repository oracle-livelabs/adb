# Build and deploy Python application stacks on dedicated autonomous infrastructure

## Introduction
The Oracle Linux Cloud Developer image provides the latest development tools, languages, and Oracle Cloud Infrastructure Software Development Kits (SDKs) to rapidly deploy a comprehensive development environment. You can use the command line and GUI tools to write, debug, and run code in various languages, and develop modern applications on Oracle Cloud Infrastructure.  and drivers to build applications on autonomous databases. 
As an application developer you can now provision a developer image within minutes and connect it to your dedicated or serverless database deployment.
 As an application developer you can now provision a developer image within minutes and connect it to your dedicated or serverless database deployment.

The image is pre-configured with tools and language drivers to help you build applications written in node.js, python, java and golang.
For a complete list of features, and preinstalled components click [this documentation](https://docs.oracle.com/en-us/iaas/oracle-linux/developer/index.htm).

*In this lab we will configure and deploy a python application in a developer client VM and connect it to an autonomous database.*

Estimated time: 20 minutes

### Objectives

As an application developer,

1. Learn how to deploy a python application and connect it to your dedicated autonomous database instance.

### Required Artifacts

   - An Oracle Cloud Infrastructure account.
   - A pre-provisioned instance of Oracle Developer Client image in an application subnet. Refer to the lab **Configuring a Development System** in the **Autonomous Database Dedicated for Developers and Database Users** workshop on how provision a developer client.
   - A pre-provisioned dedicated autonomous database instance. Refer to the lab **Provisioning Databases** in the **Autonomous Database Dedicated for Developers and Database Users** workshop on how to provision an ATP database.
   - A network that provides connectivity between the application and database subnets. Refer to the lab **Prepare Private Network for OCI Implementation** in the **Autonomous Database Dedicated for Fleet Administrators** workshop.

## Task 1: Instances Setup

- Log in to your Oracle Cloud Infrastructure account and select **Compute** —> **Instances** from top left menu.
    ![This image shows the result of performing the above step.](./images/compute1.png " ")

- Select the right Oracle Developer Cloud image you created in the earlier lab, **Configure a Development System**.

- Copy the public IP address of the instance in a note pad.
    ![This image shows the result of performing the above step.](./images/compute2.png " ")

**Mac / Linux users**

- Open Terminal and SSH into linux host machine.

    ```
    <copy>
    sudo ssh -i /path_to/sshkeys/id_rsa opc@publicIP
    </copy>
    ```

    ![](./images/SSH1.png " ")

**Windows users**

- You can connect to and manage linux host machine using SSH client. Recent versions of Windows 10 provide OpenSSH client commands to create and manage SSH keys and make SSH connections from a command prompt.

- Other common Windows SSH clients you can install locally is PuTTY. Click [this link for documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ssh-from-windows) to follow the steps to connect to linux host machine from you windows using PuTTY.

## Task 2: Download sample python application

- In your developer client ssh session:

    ```
    <copy>
    cd /home/opc/
    </copy>
    ```

- Let's download a sample python application for the purpose of this lab:

    ```
    <copy>
    wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/DhTOXBBDCJI5b-lStlkobmgro1fVMUgj8yZ3NArH_t4/n/atpdpreview11/b/adb-build-python-apps/o/ATPDpython.zip
    </copy>
    ```

- Unzip the application.

    ```
    <copy>
    unzip ATPDpython.zip
    </copy>
    ```


## Task 3: Transfer database wallet to developer client

- Login to Oracle Cloud Infrastructure account and select **Autonomous Transaction Processing** from menu.
    ![This image shows the result of performing the above step.](./images/atpd1.png " ")

- Click **Autonomous Database* and select your previously created database.
    ![This image shows the result of performing the above step.](./images/atpd2.png " ")

- Click *DB Connection* and under Download Client Credential(Wallet) click **Download**.
    ![This image shows the result of performing the above step.](./images/atpd3.png " ")

- Provide a password and download the wallet to a local folder.
    ![This image shows the result of performing the above step.](./images/atpd4.png " ")

    The credentials zip file contains the encryption wallet, Java keystore and other relevant files to make a secure TLS 1.2 connection to your database from client applications. Store this file in a secure location.

    Let us now secure copy the downloaded wallet to developer client machine.

- Open Terminal in your laptop and type in the following commands:

    *Note: Please change path and name of your private ssh keyhole,  wallet and the ip address of your developer client in the command below.*

    ```
    <copy>
    sudo scp -i /Path/to/your/private_ssh_key /Path/to/your/downloaded_wallet opc@publicIP:/home/opc/
    </copy>
    ```

    ![This image shows the result of performing the above step.](./images/atpd5.png " ")


## Task 4: Run your python application

Now that you have successfully SCP'd the encryption to your client machine, let's connect to our linux host, unzip the wallet and update sqlnet.ora file to point to the wallet folder.

- Open terminal on your laptop and SSH into linux host machine. Windows users follows instructions provided above to ssh using Putty.

    ```
    <copy>
    ssh -i /path/to/your/private_ssh_key opc@PublicIP
    </copy>
    ```

- Create a new directory for wallet and unzip the wallet.

    ```
    <copy>
    cd /home/opc/ATPDpython/

    mkdir wallet

    unzip Wallet_ATPDedicatedDB.zip -d /home/opc/ATPDpython/wallet/
    </copy>
    ```

- The sqlnet.ora file in the wallet folder needs to be edited to point to the location of the wallet as shown below.

    ```
    <copy>
    vi /home/opc/ATPDpython/wallet/sqlnet.ora
    </copy>
    ```

- Change *DIRECTORY* path to /home/opc/ATPDpython/wallet/ and save the file.
    ![](./images/walletPython.png " ")

- Export TNS_ADMIN

    ```
    <copy>
    export TNS_ADMIN=/home/opc/ATPDpython/wallet/
    </copy>
    ```

- Verify TNS_ADMIN points to the wallet folder.

    ```
    <copy>
    echo $TNS_ADMIN
    </copy>
    ```
    ![This image shows the result of performing the above step.](./images/tnsadmin.png " ")

- That's all! Let's start up our python app and see if it makes a connection to the database.

    ```
    <copy>
    python exampleConnection.py ADMIN PASSWORD dbname_tp
    </copy>
    ```
    ![This image shows the result of performing the above step.](./images/pythonsuccess.png " ")

You may now **proceed to the next lab**.

## Acknowledgements

*Congratulations! You successfully deployed and connected a python app to your autonomous database.*

- **Author** - Tejus S. & Kris Bhanushali
- **Adapted by** -  Yaisah Granillo, Cloud Solution Engineer
- **Last Updated By/Date** - Kris Bhanushali, Autonomous Database Product Management, April 2022

## See an issue or have feedback?  
Please submit feedback [here](https://apexapps.oracle.com/pls/apex/f?p=133:1:::::P1_FEEDBACK:1).   Select 'Autonomous DB on Dedicated Exadata' as workshop name, include Lab name and issue / feedback details. Thank you!
