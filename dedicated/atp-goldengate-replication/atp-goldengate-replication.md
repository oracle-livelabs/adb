
# Live Migration to ATP-Dedicated Using Oracle GoldenGate Replication

## Introduction
Data Replication is an essential part of your efforts and tasks when you are migrating your Oracle databases. While data migration can be achieved in many ways, there are fewer options when downtime tolerance is low and live, trickle feed replication may be the only way. Oracle Cloud Infrastructure Marketplace provides a GoldenGate microservice that can easily be set up for logical data replication between a variety of databases. In this hands-on lab, we will set up GoldenGate to replicate data from a 12.2 Oracle database comparable to an 'on-prem' source database to an ATP Dedicated database in OCI. This approach is recommended while migrating most production or business critical applications to Autonomous Database Dedicated.

**Why GoldenGate?**

- Oracle GoldenGate is an enterprise grade tool that can provide near real time data replication from one database to another.
- Oracle GoldenGate offers a real-time, log-based change data capture (CDC) and replication software platform to meet the needs of today’s transaction-driven applications. Capture, routing, transformation, and delivery of transactional data across heterogeneous environments in real time can be achieved using GoldenGate.
- Oracle GoldenGate only captures and moves committed database transactions to ensure that transactional integrity is maintained at all times. The application carefully ensures the integrity of data as it is moved from the source database or messaging system, and is applied to any number of target databases or messaging systems.

    [Learn More about GoldenGate](http://www.oracle.com/us/products/middleware/data-integration/oracle-goldengate-realtime-access-2031152.pdf).

Estimated Time: 60 minutes

### Objectives

1. Set up real time data replication from on-premise database to an Autonomous Transaction Processing-Dedicated database instance.

### Required Artifacts

- Access to an Oracle Cloud Infrastructure tenancy.
- Access to an Oracle 12c database configured as source database.
- An Autonomous Transaction Processing-Dedicated instance as target database.
- Access to Autonomous Transaction Processing-Dedicated network via jump server or VPN.
- VNC Viewer or other suitable VNC client on your laptop.

### Background and Architecture

- There are three components to this lab. The *source database* that you are planning to migrate to Autonomous, the *target autonomous database* in OCI and an instance of *Oracle GoldenGate* server with access to both source and target databases.

- The source database can be any Oracle database version 11.2.0.4 or higher with at least one application schema that you wish to replicate to an autonomous database in OCI. For the purpose of this lab, you may provision a 12.2.0.1 DBCS instance in your compartment in OCI and configure it as source.

- The ATP Dedicated database instance you provisioned can be used as a target database in this lab. Since this database is in a private network with no direct access over the internet, you need to either VPN into this network or set up a developer client / bastion host via which you can connect to your target Autonomous Transaction Processing-Dedicated instance using SQL*Plus or SQL Developer client.

    **Note:** You cannot complete this lab without setting up access to your Autonomous Transaction Processing-Dedicated instance. Therefore, set up a jump server or set up VPN (see the lab "Configure VPN Connectivity in your Exadata Network" earlier in this workshop.)

    - The GoldenGate software is going to be deployed on a linux server in a public network which has access to both the source database and the target database via the GoldenGate marketplace image in OCI.

## Task 1: Provision a GoldenGate Microservice from OCI Marketplace

- Connect to your OCI tenancy and select **Marketplace**. Click **All Applications** in the top left menu.

- Browse for **Oracle Goldengate for Oracle**. The image is a terraform orchestration that deploys GoldenGate on a compute image along with required resources.

- Click **Image** and choose your compartment to deploy the GoldenGate instance. For example, as a workshop user with assigned compartment userX-Compartment, pick userX-Compartment from the drop down list.

- Launch Stack and provide details as described below.

    - **Name:** Any descriptive name, or you could leave default.

    - Click **Next**. The rest of the items are filled in or optional.

- Enter the following network setting. This is essentially to select the network you wish to deploy your GoldenGate image.
    ![This image shows the result of performing the above step.](./images/network1.png " ")

- Click **Next**. For instance details, pick an AD with sufficient compute capacity. *Note: this deployment needs a minimum 2 OCPU instances*.

    Make sure you check the **ASSIGN PUBLIC IP** checkbox. You will use this later to ssh into the instance and also connect to the GoldenGate admin console.
    ![This image shows the result of performing the above step.](./images/network2.png " ")

- Next, under **Create OGG Deployment** check **Deployment - Autonomous Database**. Choose your deployment compartment and deployment Autonomous Database Instance.

- In this lab, we choose a single deployment called Databases.
    ![This image shows the result of performing the above step.](./images/source-target.png " ")

- Next, paste your public key and click **Create**.

- Your GoldenGate instance should be ready in a few minutes and you will come back to configure it.

## Task 2: Configure the source database

It is assumed that you either have an Oracle 12c database configured as source or know how to provision a 12c DBCS instance in OCI.

[This Medium blog provides step by step directions to deploying a DBCS instance in OCI.](https://medium.com/@fathi.ria/oracle-database-on-oci-cloud-ee144b86648c)

The source database requires a Common (CDB) user that has DBA privileges over all PDBs in that database.

Let's also assume that the schema we wish to replicate with GoldenGate is the 'appschema' in PDB1. So for a freshly provisioned DBCS instance as source, we create the common user and application schema as follows.

- Connect as *sys* to your source database and execute the following SQL commands.

    ````
    <copy>
    create user C##user01 identified by WElcome_123#;
    grant connect, resource, dba to c##user01;
    alter database add supplemental log data;
    exec dbms_goldengate_auth.grant_admin_privilege('C##user01', container=>'all');
    alter system set ENABLE_GOLDENGATE_REPLICATION=true scope=both;
    </copy>
    ````

    Check if GoldenGate replication is enabled:

    ````
    <copy>
    show parameter ENABLE_GOLDENGATE_REPLICATION;
    </copy>
    ````

    This should return *True*.

- Next, let's create a schema user to replicate called *appschema* in PDB1 and add a table to it. A sample 'Comments' table is provided here. You may add one or more tables of your choice to the appschema.

    ````
    <copy>
    alter session set container=pdb1;
    create user appschema identified by WElcome_123# default tablespace users;
    grant connect, resource, dba to appschema;
    CREATE TABLE appschema.COMMENTS
    (  "COMMENT_ID" NUMBER(10,0),
    "ITEM_ID" NUMBER(10,0),
    "COMMENT_BY" NUMBER(10,0),
    "COMMENT_CREATE_DATE" DATE DEFAULT sysdate,
    "COMMENT_TEXT" VARCHAR2(500)
    ) ;
    </copy>
    ````

    The source database is all set. Next, let's set up the target ATPD instance.

## Task 3: Configure the target ATP Dedicated database

- Connect to the ATPD database service instance you created earlier as user *admin*.

    *Note: You will need to be VPN'd into the network or VNC to a jump server. Refer to the related labs.*

- First, let's unlock the GoldenGate user that comes pre-created in ATP-D.

    ````
    <copy>
    alter user ggadmin identified by WElcome_123# account unlock;
    alter user ggadmin quota unlimited on data;
    </copy>
    ````

- Next, create an 'appschema' user similar to source and create the same set of tables as source.

    ````
    <copy>
    create user appschema identified by WElcome_123# default tablespace data;
    grant connect, resource to appschema;
    alter user appschema quota unlimited on data;
    CREATE TABLE appschema.COMMENTS
    (  "COMMENT_ID" NUMBER(10,0),
    "ITEM_ID" NUMBER(10,0),
    "COMMENT_BY" NUMBER(10,0),
    "COMMENT_CREATE_DATE" DATE DEFAULT sysdate,
    "COMMENT_TEXT" VARCHAR2(500)
    ) ;
    </copy>
    ````
That is it! Your target database is now ready.

## Task 4: Configure GoldenGate service
- By now, your GoldenGate service instance must be deployed. On your OCI console navigate to *Compute* from the top left menu and *choose your compartment*.

- Click your GoldenGate compute instance to get to the details page that appears as follows.
    ![This image shows the result of performing the above step.](./images/ggcompute.png " ")

    *Note down the public IP address of your instance. We will use this IP to ssh into the virtual machine.*

- Before we launch the GoldenGate admin console and start configuring the service, we need to provide connection information for both source and target databases.

    - Therefore, gather your source database connection TNS entries for both the common user and the appschema user. Remember, the CDB and PDB run different services, therefore the TNS entries differ.

    - A tns entry is typically found in your database's *tnsnames.ora* file and looks like this.

    ```
    <copy>
    mySourceDB=(DESCRIPTION=(CONNECT_TIMEOUT=120)(RETRY_COUNT=20)(RETRY_DELAY=3)(TRANSPORT_CONNECT_TIMEOUT=3)(ADDRESS_LIST=(LOAD_BALANCE=on)(ADDRESS=(PROTOCOL=TCP)(HOST=129.30.xxx.xxx)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=pdb1.atp.oraclecloud.com)))
    </copy>
    ```

- Also get your ATPD wallet zip file ready to upload / SCP to the GoldenGate instance.

    *This file needs to go into the folder /u02/deployments/Databases/etc.*

    Remember the deployment name 'Databases' provided while provisioning the GoldenGate image? That is what it does. By providing just one deployment, we can configure both source and target database entries in one place for simplicity.

    ````
    <copy>
    $ scp -i ~/id_rsa Wallet_MyATPDB.zip opc@129.xxx.234.11:/u02/deployments/Databases/etc
    </copy>
    ````

- Next, ssh into the instance and unzip the wallet.

    ```
    <copy>
    $ ssh -i ~/id_rsa opc@129.xxx.234.11
    $ cd /u02/deployments/Databases/etc
    $ unzip Wallet_MyATPDB.zip
    </copy>
    ```

- Edit the *sqlnet.ora* file and update the WALLET_LOCATION parameter to point to the wallet folder.

    ````
    <copy>
    WALLET_LOCATION = (SOURCE=(METHOD=FILE)(METHOD_DATA=(DIRECTORY="/u02/deployments/Databases/etc")))
    </copy>
    ````

- Next we edit the *tnsnames.ora* file and add entries for the source common user and the source appschema user. This single tnsnames.ora will serve to connect to both source and target.

- Open *tnsnames.ora* in vi and add TNS connection entries as shown in the example screenshot below. Note the 2 new TNS entries added at the bottom for the source database in addition to the pre-existing entries for target.
    ![This image shows the result of performing the above step.](./images/tns-entries.png " ")

    - Also, source DB is in a public network in this example hence hostname is the public IP address.

    *Note: All IP addresses in the lab guide are scrubbed for security purposes. None of the instances in the screenshots are accessible using the information provided.*

- We are now ready to access the GoldenGate admin console and configure our *extract* and *replicat* processes.

- The credentials to access the admin console are provided in a file named *ogg-credentials.json* in the home folder /home/opc .

    - Open the file and save the credentials on a notepad.

    ````
    <copy>
    $ cd
    $ cat ogg-credentials.json
    {"username": "oggadmin", "credential": "E-kqQH8.MPA0u0.g"}
    </copy>
    ````
- Next we log on to the GoldenGate admin console using the credentials above.

    *Open a browser and navigate to https://(ip\_address\_of\_goldengate\_image)*.

    If you have browser issues or get Unicode warning, try using Firefox browser. Fixing browser issues is beyond scope for this lab guide.
    ![This image shows the result of performing the above step.](./images/ogg1.png " ")

- Once logged on, click on the port # for Admin server to get into configuration mode as shown below.
    ![This image shows the result of performing the above step.](./images/ogg2.png " ")

    If prompted, log in with the same credentials one more time.

- From the top left hamburger menu, select *Configuration* as shown below:
    ![This image shows the result of performing the above step.](./images/ogg3.png " ")

    Here we configure connectivity to our source and target databases. We will set up 3 connections - The Source DB common user, Source DB appschema user and Target DB ggadmin user.
    ![This image shows the result of performing the above step.](./images/creds1.png " ")

- Add the first credential for C##user01 you created earlier in the lab in the source database.
    ![This image shows the result of performing the above step.](./images/creds2.png " ")

    *Note the userid format is userid@connectString. The connect string is how it knows which database to connect to. It looks for this connect string in /u02/deployments/Databases/etc/tnsnames.ora*

- Submit credentials and test connectivity as shown in the screenshot below.
    ![This image shows the result of performing the above step.](./images/creds3.png " ")

- Similarly, add credentials for source DB appschema and target ATPD ggadmin schema as shown below. Note the ggadmin user connects using the same tns entry as 'admin' user.
    ![This image shows the result of performing the above step.](./images/creds4.png " ")

    *Make sure you test connectivity for each credential.*

- Next, we create **checkpoint tables** in source and target databases. Checkpoint tables keep track of changes in the database. We need one in the appschema in source and another in the ggadmin schema in target.

    - Let's start with appschema in source. Connect and click the + sign to add a checkpoint table as shown below.
        ![This image shows the result of performing the above step.](./images/chkpt1.png " ")
        ![This image shows the result of performing the above step.](./images/chkpt2.png " ")

    - We also specify the schema we want to replicate here. In the Transaction Information section below checkpoint, add the schema first by clicking the + sign and click  **Submit**.
        ![This image shows the result of performing the above step.](./images/chkpt3.png " ")

    - Now when you enter the schema name and search for it, it shows up as shown below with 3 tables: 2 checkpoint tables and one 'comments' table we created earlier.
        ![This image shows the result of performing the above step.](./images/chkpt4.png " ")

- Next, we **add a checkpoint table** to the target instance and also set the 'heartbeat'.

    - Connect to the target DB from the GoldenGate admin console just like you did for the source database. Let's also add a checkpoint table here.
        ![This image shows the result of performing the above step.](./images/chkpt5.png " ")
        ![This image shows the result of performing the above step.](./images/chkpt6.png " ")

    - Scroll down and set the heartbeat for target. Use default configuration for the purpose of this lab.
        ![This image shows the result of performing the above step.](./images/heartbeat.png " ")

- As a final step, we now **create an 'extract' and a 'replicate' process** to conduct the replication from source to target.

    - Navigate back to the GoldenGate Admin server dashboard so you can see both the extract and replicat setup as shown below.
        ![This image shows the result of performing the above step.](./images/extract1.png " ")

    - Choose **Integrated Extract** on the next screen and click **Next**.

    - Entries on the following screen may be entered as follows:
        ![This image shows the result of performing the above step.](./images/extract2.png " ")

        *Process Name:* Provide any name of choice

        *Credential Domain:* Pick **OracleGoldenGate** from the drop down

        *Credential Alias:*  Pick the common user alias for source database. In this lab we created **sourceCommonUser** alias.

        *Trail Name:* Any 2 character name

    - Scroll down and click in the text box **Register to PDBs**. **PDB1** should pop up as shown.
        ![This image shows the result of performing the above step.](./images/extract3.png " ")

        *If you do not see the Register to PDBs text box, make sure you have picked the 'Common User' alias and provided all mandatory entries.*

    - Click **Next**. As a final step, add this entry at the end of your parameter file as shown below.

        ````
        <copy>
        extract ext1
        useridalias sourceCommonUser domain OracleGoldenGate
        exttrail rt
        table pdb1.appschema.*;
        </copy>
        ````

        ![This image shows the result of performing the above step.](./images/extract4.png " ")

        This tells GoldenGate to capture changes on all tables in pdb1.appschema.

    - Click **Create and Run**. If all goes well, you should now see the extract running on source.
        ![This image shows the result of performing the above step.](./images/extract5.png " ")


- Next, we configure a replicat on the target. On the same screen, click the *+* sign on the *Replicats* side to start configuring one.

    - Pick *Non-Integrated Replicat*
        ![This image shows the result of performing the above step.](./images/rep1.png " ")

- Fill out the mandatory items in *Basic Information* on the next screen as follows. You may leave the rest at default values.

    *Process Name:*  Rep1

    *Credential Domain:*  Oracle GoldenGate from drop down

    *Credential Alias:* targetGGAdmin (or the alias name you provided for ggadmin user on your ATP-D instance)

    *Trail Name:* rt (or any 2 character name)

    *Checkpoint Table:* The checkpoint table you configured for ggadmin user should show up in the drop down

    Click **Next**.

    ![This image shows the result of performing the above step.](./images/rep2.png " ")
    ![This image shows the result of performing the above step.](./images/rep3.png " ")

- On the last and final screen (finally!) edit the parameter file to REPLACE the line mapping the source and target schemas as show below.

    *Note: Please remove the original line MAP \*.\*, TARGET \*.\*;*

    ![This image shows the result of performing the above step.](./images/rep4.png " ")

- Click **Create and Run**. If all goes well, you should now see both extract and replicat processes running on the dashboard.
    ![This image shows the result of performing the above step.](./images/rep5.png " ")

Congratulations! You have completed the replication setup. To test, simply connect to your source database, insert and commit some rows. Then check your corresponding target table and in a few seconds you should see the data appear.

- A sample Insert script for the Comments table is provided below.

    ````
    <copy>
    Insert into appschema.COMMENTS (COMMENT_ID,ITEM_ID,COMMENT_BY,COMMENT_CREATE_DATE,COMMENT_TEXT) values (7,4,4,to_date('06-JUL-15','DD-MON-RR'),'Im putting an offer. Can you meet me at the apple store this evening?');
    commit;
    </copy>
    ````

You may now **proceed to the next lab**.

## Acknowledgements
- **Author** - Tejus S. & Kris Bhanushali
- **Adapted by** -  Yaisah Granillo, Cloud Solution Engineer
- **Last Updated By/Date** - Yaisah Granillo, April 2022


## See an issue or have feedback?
Please submit feedback [here](https://apexapps.oracle.com/pls/apex/f?p=133:1:::::P1_FEEDBACK:1).   Select 'Autonomous DB on Dedicated Exadata' as workshop name, include Lab name and issue / feedback details. Thank you!
