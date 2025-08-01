# Connect Autonomous Database with Swingbench

## Introduction

This lab walks you through how to install and configure a workload generation tool called Swingbench and monitor the performance of an Autonomous Database.

Swingbench is a free load generator (and benchmarks) designed to stress test an Oracle database (12c, 18c, 19c, 21c, 23c). The software enables a load to be generated and the transactions/response times to be charted. The tool has both graphical and command line functionality. Learn more about Swingbench from the official [website](https://www.dominicgiles.com/swingbench/).

We will be installing Swingbench and running some fabricated workloads that can be monitored later.

Estimated Time: 10 minutes

### Objectives

As an administrator:

1. Install and configure Swingbench to simulate a transaction processing workload.

### Required Artifacts

- A pre-provisioned instance of an Autonomous Database and a Developer Client image. 

## Task 1: Connect to Compute VM Instance

1. Launch a terminal session and ssh to the Compute VM instance using the IP address and the private key corresponding to the public key that was entered during Compute VM instance provisioning. After connecting to the VM instance update the softwares installed.

    ```
    <copy>
    sudo apt update
    </copy>
    ```

    ![Connect to VM instance](./images/vm-connect.png " ")

2. Verify the version of java installed on the VM instance and install java if the same is missing.

- Verify java

    ```
    <copy>
    java -version
    </copy>
    ```

- Install java

    ```
    <copy>
    sudo apt install default-jre
    </copy>
    ```
    ![Verify and install java](./images/vm-java-check.png " ")

- Verify java post installation

    ```
    <copy>
    java -version
    </copy>
    ```

    ![Verify java](./images/vm-java-post.png " ")

## Task 2: Download and install Swingbench

1. Download Swingbench for Linux.

    On the VM instance downlowd Swingbench by running the following on command prompt.

    ```
    <copy>
    wget https://www.dominicgiles.com/site_downloads/swingbenchlatest.zip
    </copy>
    ```

    ![Download Swingbench](./images/vm-download-swing.png " ")

2. Download zip and unzip Swingbench.

    Install zip on the VM instance and unzip Swingbench.

    ```
    <copy>
    sudo apt install zip
    unzip swingbenchlatest.zip
    cd swingbench
    ls -ltr
    </copy>
    ```
    
    ![Download zip](./images/vm-install-zip.png " ")
    ![Download zip](./images/vm-unzip-swing.png " ")
    ![Download zip](./images/vm-list-swing.png " ")

3. Download the Autonomous Database wallet file

    **Oracle Autonomous Database** only accepts secure connections to the database. This requires a **'wallet'** file that contains the SQL\*NET configuration files and the secure connection information. Wallets are used by client utilities such as SQL Developer, SQL\*Plus etc. For this workshop, you will use this same wallet mechanism to make a connection from Swingbench to the **Autonomous Database**.

- On the **Autonomous Database** page click the Autonomous Database that was provisioned.

    ![Download zip](./images/vm-adb-details.png " ")

- Go to the **CONNECTIONS** tab.

    ![Download zip](./images/adb-details-connection.png " ")

- Click **DOWNLOAD WALLET** on the **Connections** page.

    ![Download zip](./images/adb-download.png " ")

- Set a password for the wallet on the **Download your wallet** page and click **DOWNLOAD**

    ![Download zip](./images/adb-download-wallet.png " ")

- Scp or Copy over the Wallet zip file to VM instance. If you are using a Linux Terminal, run the following command to copy over the wallet to the VM instance -

    ```
    <copy>
    scp -i <private_key_file> Wallet_adbgcp.zip <Compute_VM_IP>:/tmp/.
    </copy>
    ```

## Task 3: Connect the Swingbench application to Autonomous Database

Now that you have installed Swingbench and copied over the Autonomous Database wallet to the VM instance, the next step is to connect the application to your Autonomous Database.

- You are ready to run Swingbench workloads on Autonomous Database. Workloads are simulated by users submitting transactions to the database.

- Load sample data to your Autonomous Database. To start **oewizard** to load Schema and data, navigate to Swinbench bin folder and run oewizard.

    - admin\_user_password is the Autonomous Database admin user password
    - soe\_user_password is the password for soe schema that will get created
    - adbgcp\_high is the TNS String to connect to the database

    ```
    <copy>
    cd ~/swingbench/bin

    ./oewizard -cf /tmp/Wallet_adbgcp.zip -cs adbgcp_high -ts DATA -dbap admin_user_password -dba admin -u soe -p soe_user_password -async_off -scale 0.2 -hashpart -create -cl -v
    </copy>
    ```

    ![oewizard](./images/oewizard.png " ")

- Validate the schema created correctly using the following command

    ```
    <copy>
    cd ~/swingbench/bin

    ./sbutil -soe -cf /tmp/Wallet_adbgcp.zip -cs adbgcp_high -u soe -p soe_user_password -val
    </copy>
    ```

    ![oewizard](./images/oewizard-verify.png " ")

- Edit the config file :

    Run the following command from command line 

    ```
    <copy>
    sed -i -e 's/<LogonGroupCount>1<\/LogonGroupCount>/<LogonGroupCount>5<\/LogonGroupCount>/' \
        -e 's/<LogonDelay>0<\/LogonDelay>/<LogonDelay>300<\/LogonDelay>/' \
        -e 's/<WaitTillAllLogon>true<\/WaitTillAllLogon>/<WaitTillAllLogon>false<\/WaitTillAllLogon>/' \
        ../configs/SOE_Server_Side_V2.xml
    </copy>
    ```

- Once the Schema is created, run a workload against the newly created schema

    Run the following command to run a workload against the soe schema

    ```
    <copy>
    ./charbench -c ../configs/SOE_Server_Side_V2.xml \
            -cf /tmp/Wallet_adbgcp.zip \
            -cs adbgcp_low \
            -u soe \
            -p soe_user_password \
            -v users,tpm,tps,vresp \
            -intermin 0 \
            -intermax 0 \
            -min 0 \
            -max 0 \
            -uc 150 \
            -di SQ,WQ,WA \
            -rt 1:0.0
    </copy>
    ```

    ![Swingbench wizard](./images/swingbench-load-run.png " ")

- You should now see the Transaction happening in your Autonomous Database. 

- We are going to monitor the Autonomous Database using Google Cloud Monitoring in the next lab.

***NOTE: Do not disconnect the Swingbench application***

You may now **proceed to the next lab**.

## Acknowledgements

*Congratulations! You successfully configured the Swingbench java application with Autonomous Database.*

- **Authors/Contributors** - Vivek Verma, Master Principal Cloud Architect, North America Cloud Engineering
- **Last Updated By/Date** - Vivek Verma, Jan 2025
