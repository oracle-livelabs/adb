# Connect Autonomous Database with Swingbench

## Introduction

This lab walks you through how to install and configure a workload generation tool called Swingbench and monitor the performance of an Autonomous Database.

Estimated Time: 10 minutes

Watch the video below for a quick walk-through of the lab.
[Simplifying @ Azure](videohub:1_xj46a62c)

### Objectives

As an administrator:
1. Install and configure Swingbench to simulate a transaction processing workload.
2. Enable Compute auto scaling in Autonomous Database and monitor the performance.


### Required Artifacts

- A pre-provisioned instance of an Autonomous database and a Developer Client image. 

Refer to Lab 2: **Connect securely with Visual Studio code**.

## Task 1: Download and install Swingbench

- Connect to your developer client machine via RDP. Detailed instructions are provided in Lab 2: **Connect securely with Visual Studio code**.

    *The remainder of this lab assumes you are connected to the Windows instance through RDP  and are operating from the Windows instance and not your local machine (except if noted).*

- Windows VM is pre-installed with Swingbench application. Verify in the below directory.

    ```
    <copy>
    cd C:\Users\opc\Downloads\swingbenchlatest
    </copy>
    ```

- If you do not see the swingbench application folder, download it from the below link. Open a Microsoft Edge browser and download the latest version of swingbench.

    ````
    <copy>
    https://www.dominicgiles.com/downloads/
    </copy>
    ````

### Transfer DB Wallet to the Swingbench client machine
If you have not downloaded the Database Wallet already to your Dev Client machine in an earlier lab, follow the steps in Lab 2: **Connect securely with Visual Studio code** to download the wallet.


## Task 2: Connect the Swingbench application to Autonomous database

Now that you have installed Swingbench, the next step is to connect the application to your Autonomous database.

- You are ready to run Swingbench workloads on Autonomous database. Workloads are simulated by users submitting transactions to the database.

- Load sample data to your Autonomous Database. To start **oewizard** to load Schema and data, navigate to Swinbench winbin folder and run oewizard.bat.


NOTE: If the Swingbench application complaints about JDBC Drivers, download from [JDBC Downloads](https://www.oracle.com/java/technologies/downloads/#jdk22-windows) and follow the on-screen instructions to install.

```
<copy>
cd C:\Users\opc\Downloads\swingbenchlatest\swingbench\winbin

oewizard.bat
</copy>
```

![This image shows the result of performing the above step.](./images/oewizard.png " ")

- Click Next and select Version 2.0.

    ![This image shows the result of performing the above step.](./images/oewizard1.png " ")

- Select Create the Order Entry Schema and click Next.

    ![This image shows the result of performing the above step.](./images/oewizard2.png " ")

- Copy the Connect string from Azure portal, and change the Username to ***Admin*** and enter your Admin password and click Next. 

    NOTE: Copy _tp connect string from Azure console.

    ![This image shows the result of performing the above step.](./images/connectstring.png " ")

    ![This image shows the result of performing the above step.](./images/oewizard3.png " ")

- Change the password to ***WElcome_123#*** and keep the remaining default and click Next.

    ![This image shows the result of performing the above step.](./images/oewizard4.png " ")

- Keep Database Options as default and click Next. 

    ![This image shows the result of performing the above step.](./images/oewizard5.png " ")

- Change User defined scale to ***0.1 GB*** and click Next and Finish. 

    ![This image shows the result of performing the above step.](./images/oewizard6.png " ")

- Building the simple order entry schema should be done in a few mins. 

    ![This image shows the result of performing the above step.](./images/oewizard7.png " ")

    ![This image shows the result of performing the above step.](./images/oewizard8.png " ")


- Once the Schema is created, start the Swingbench UI. Open CMD in your Windows instance and navigate to Swingbench winbin folder.

    ```
    <copy>
    cd C:\Users\opc\Downloads\swingbenchlatest\swingbench\winbin
    </copy>
    ```

    ![This image shows the result of performing the above step.](./images/cmd.png " ")

- Start Swingbench UI
    ```
    <copy>
    swingbench.bat
    </copy>
    ```
    
    ![This image shows the result of performing the above step.](./images/swingbench.png " ")

- Running the above command will open the Swingbench configuration tool. Select the following to connect Swingbench to Autonomous database. 

- Select SOE_Server_Side_V2 and click OK.

    ![This image shows the result of performing the above step.](./images/swingbench1.png " ")

- Enter the following in Swingbench UI
   
    ```
    Username: soe
    Password: WElcome_123#
    Connect String: adb_tp <Copy from Azure portal>
    ```

    ![This image shows the result of performing the above step.](./images/swingbench2.png " ")

    ![This image shows the result of performing the above step.](./images/connectstring.png " ")

 - Test the connection to the database by clicking on connect link in Connect String. If the entered details are correct, you should see a confirmation popup - ***Connected to database using supplied parameters***

    ![This image shows the result of performing the above step.](./images/connect.png " ")

- Start Benchmark run by clicking on the ***Green Play*** button

    ![This image shows the result of performing the above step.](./images/start.png " ")

- You should now see the Transaction happening in your Autonomous database. 

    ![This image shows the result of performing the above step.](./images/start1.png " ")

***NOTE: Do not disconnect the Swingbench application. The next steps show the Auto scaling capability of the Autonomous Database.***

## Task 3: Enable Compute Auto Scaling in Autonomous database

- Login to Azure portal and navigate to your Autonomous database overview page and expand ***Settings*** and click on ***Resource allocation*** and ***Manage***.

    ![This image shows the result of performing the above step.](./images/auto.png " ")

- Check on ***Compute auto scaling*** and click Apply.

    ![This image shows the result of performing the above step.](./images/auto1.png " ")

- Open the Swingbench application and notice how your Transactions per minute are increasing when enabling Auto scaling. 

    ![This image shows the result of performing the above step.](./images/auto2.png " ")

- Navigate back to Azure portal and turn off Auto Scaling. 

- Stop the Swingbench application. 

    ![This image shows the result of performing the above step.](./images/stop.png " ")

You may now **proceed to the next lab**.

## Acknowledgements
*Congratulations! You successfully configured the Swingbench java application with Autonomous database and observed how compute auto scaling can benfit your applications .*

- **Author** - Tejus Subrahmanya
- **Last Updated By/Date** - Tejus Subrahmanya, Autonomous Database Product Management, August 2024