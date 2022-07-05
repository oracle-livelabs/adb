# Build and deploy Java application stacks on dedicated autonomous infrastructure

## Introduction
The Oracle Linux Cloud Developer image provides the latest development tools, languages, and Oracle Cloud Infrastructure Software Development Kits (SDKs) to rapidly deploy a comprehensive development environment. You can use the command line and GUI tools to write, debug, and run code in various languages, and develop modern applications on Oracle Cloud Infrastructure.  and drivers to build applications on autonomous databases. 
As an application developer you can now provision a developer image within minutes and connect it to your dedicated or serverless database deployment.
 As an application developer you can now provision a developer image within minutes and connect it to your dedicated or serverless database deployment.

The image is pre-configured with tools and language drivers to help you build applications written in node.js, python, java and golang.
For a complete list of features, and preinstalled components click [this documentation](https://docs.oracle.com/en-us/iaas/oracle-linux/developer/index.htm).

In this lab we will configure and deploy a java application in a developer client VM and connect it to an autonomous database.

Estimated Time: 20 minutes

### Objectives

As an application developer,
- Learn how to deploy a java application and connect it to your dedicated autonomous database instance.

### Required Artifacts

- An Oracle Cloud Infrastructure account.
- A pre-provisioned instance of Oracle Developer Client image in an application subnet. Refer to the lab **Configuring a Development System** in the **Autonomous Database Dedicated for Developers and Database Users** workshop on how provision a developer client.
- A pre-provisioned dedicated autonomous database instance. Refer to the lab **Provisioning Databases** in the **Autonomous Database Dedicated for Developers and Database Users** workshop on how to provision an ATP database.
- A network that provides connectivity between the application and database subnets. Refer to the lab **Prepare Private Network for OCI Implementation** in the **Autonomous Database Dedicated for Fleet Administrators* workshop.

## Task 1: Download sample java application

- Log in to your Oracle Cloud Infrastructure account and select **Compute** and **Instances** from the hamburger menu top left.
    ![This image shows the result of performing the above step.](./images/compute1.png " ")

- Select the right Oracle Developer Cloud image you created in earlier labs.

- Copy the public IP address of the instance on to a note pad.
    ![This image shows the result of performing the above step.](./images/compute2.png " ")


**Mac users**

- Open Terminal and SSH into linux host machine.

    ```
    <copy>
    sudo ssh -i /path_to/sshkeys/id_rsa opc@publicIP
    </copy>
    ```

    ![This image shows the result of performing the above step.](./images/ssh1.png " ")

**Windows users**

- You can connect to and manage linux host machine using SSH client. Recent versions of Windows 10 provide OpenSSH client commands to create and manage SSH keys and make SSH connections from a command prompt.

- Other common Windows SSH clients you can install locally is PuTTY. Click [here](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ssh-from-windows) to follow the steps to connect to linux host machine from you windows using PuTTY.


- Download a sample java application for the purpose of this lab as follows:

    ```
    <copy>
    cd /home/opc/
    wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/v3Wdc2lzrxStw775qXuXEtQY-oV3uKKOpPuAjMCtgEA/n/atpdpreview11/b/adb-build-java-apps/o/ATPDjava.zip
    </copy>
    ```

- Unzip the application in /home/opc:

    ```
    <copy>
    unzip /home/opc/ATPDjava.zip
    </copy>
    ```

*Note: The package unzips to a folder /home/opc/atpjava*

- Next, download ojdbc8 drivers needed for connectivity:

    ```
    <copy>
    cd /home/opc/atpjava/
    mkdir ojdbc
    cd ojdbc/
    wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/iv-ms2lpLm5NuFkTVm_PErpN0HeI_clDBUM7c7s1l9A/n/atpdpreview11/b/adb-build-java-apps/o/ojdbc8-full.tar.gz
    tar xzfv ojdbc8-full.tar.gz
    </copy>
    ```

## Task 2: Transfer database wallet to developer client

- Log in to Oracle Cloud Infrastructure account and click **Autonomous Transaction Processing** from top left menu.
    ![This image shows the result of performing the above step.](./images/atpd1.png " ")

- Click **Autonomous Database* and select your previously created database.
    ![This image shows the result of performing the above step.](./images/atpd2.png " ")

- Click **DB Connection** and under Download Client Credential(Wallet) click **Download**.
    ![This image shows the result of performing the above step.](./images/atpd3.png " ")

- Database connections to your Autonomous Database use a secure connection. You will be asked to create a password for your wallet.

- Enter **Password** and **Confirm password** and click **Download**.
    ![This image shows the result of performing the above step.](./images/atpd4.png " ")

- The credentials zip file contains the encryption wallet, Java keystore and other relevant files to make a secure TLS 1.2 connection to your database from client applications. Store this file in a secure location on your local machine.

- Let us now scp the downloaded wallet to our developer client machine.

**Mac Users**
- Open a terminal window on your laptop and type in the following commands:

    *Note: Please change the path and file name for your ssh keyfile and the encryption wallet. Also provide the IP address of your developer client machine.*

    ```
    <copy>
    sudo scp -i /Path/to/your/private_ssh_key /Path/to/your/downloaded_wallet opc@publicIP:/home/opc/ATPDjava
    </copy>
    ```
    ![This image shows the result of performing the above step.](./images/atpd5.png " ")

**Windows Users**

- Use a scp client such as winSCP to move your wallet to the client machine.

## Task 3: Run your java application

Now that you have successfully SCP'd the encryption to your client machine, let's connect to our linux host, unzip the wallet and update sqlnet.ora file to point to the wallet folder.

- Open terminal in your laptop and SSH into linux host machine.

    ```
    <copy>
    ssh -i /path/to/your/private_ssh_key opc@PublicIP
    </copy>
    ```
    Once logged in:

    ```
    <copy>
    cd /home/opc/atpjava/
    mkdir wallet

    unzip Wallet_ATPDedicatedDB.zip -d /home/opc/atpjava/wallet/
    </copy>
    ```

- Edit sqlnet.ora to update the directory path.

    ```
    <copy>
    cd /home/opc/atpjava/wallet/

    vi sqlnet.ora
    </copy>
    ```

- Change **DIRECTORY** path to /home/opc/ATPDjava/wallet/ and save the file.

    ![This image shows the result of performing the above step.](./images/atpd6.png " ")

- Next, configure your java applications DB config file.

    ```
    <copy>
    cd /home/opc/atpjava/atpjava/src

    vi dbconfig.properties
    </copy>
    ```

- Change **dbinstance**, **dbcredpath**, **dbuser**, **dbpassword** as per the autonomous database you created earlier.

    ![This image shows the result of performing the above step.](./images/db_parameters.png " ")

    ![This image shows the result of performing the above step.](./images/atpd7.png " ")

- Next, let's set the TNS_ADMIN environment variable to point to the wallet and set the java classpath.

    ```
    <copy>
    export TNS_ADMIN=/home/opc/atpjava/wallet/
    </copy>
    ```

- Verify TNS_ADMIN path.

    ```
    <copy>
    echo $TNS_ADMIN
    </copy>
    ```
    ![This image shows the result of performing the above step.](./images/atpd8.png " ")

- Set java class path.

    ```
    <copy>
    javac -cp .:/home/opc/atpjava/ojdbc/ojdbc8-full/ojdbc8.jar com/oracle/autonomous/GetAutonomousConnection.java
    </copy>
    ```

- Run the application.

    ```
    <copy>
    java -cp .:/home/opc/atpjava/ojdbc/ojdbc8-full/ojdbc8.jar com/oracle/autonomous/GetAutonomousConnection
    </copy>
    ```

    ![This image shows the result of performing the above step.](./images/atpd9.png " ")

You may now **proceed to the next lab**.

## Acknowledgements

*Congratulations! You successfully deployed and connected a java app to your autonomous database.*

- **Author** - Tejus S. & Kris Bhanushali
- **Adapted by** -  Yaisah Granillo, Cloud Solution Engineer
- **Last Updated By/Date** - Kris Bhanushali, Autonomous Database Product Management, April 2022

## See an issue or have feedback?  
Please submit feedback [here](https://apexapps.oracle.com/pls/apex/f?p=133:1:::::P1_FEEDBACK:1).   Select 'Autonomous DB on Dedicated Exadata' as workshop name, include Lab name and issue / feedback details. Thank you!
