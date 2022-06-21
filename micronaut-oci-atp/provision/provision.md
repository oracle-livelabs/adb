# Provision Oracle Autonomous Database

## Introduction
In this lab you will provision the Oracle Cloud instances needed to run a Micronaut application with Autonomous Database.

Estimated Lab Time: 20 minutes

### Objectives

In this lab you will:

* Provision an instance of Autonomous Database for use in the lab

### Prerequisites
- An Oracle Cloud account, Free Trial, LiveLabs or a Paid account

## Task 1: Create the Autonomous Database Instance

1. Go to the Oracle Cloud Menu and select "Oracle Database" and then "Autonomous Transaction Processing", then click "Create Autonomous Database".

![Click Autonomous Transaction Processing](images/db1.png)

2. Enter "mnociatp" as the database name and select "Transaction Processing".

![Entering the Database Name](images/db2.png)

3. Choose "Shared Infrastructure" and ensure to select "Always Free".

![Use Shared Infrastructure](images/db3.png)

4. Enter and take note of the Administrator password (must be at least 12 characters and contain a number and an uppercase letter) and ensure "Allow secure access from everywhere" is selected.

![Enter Administrator Password](images/db4.png)

5. Select "License Included" and then the "Create Autonomous Database" button to create your Autonomous Database Instance.

![Creating the Autonomous Database Intance](images/db5.png)

## Task 2: Creating an Autonomous Database Schema User

1. On the "Autonomous Database Details" page click the "Service Console" button.

![Opening Service Console](images/db6.png)

2. Enter "ADMIN" for the username and the password you defined in the previous section.

![Logging into Service Console](images/db6b.png)

3. Click "Development" on the left, then click the "Database Actions" tab on the right.

![Opening Database Actions](images/db6c.png)

4. Enter "ADMIN" for the username and the password you defined in the previous section.

![Logging into Database Actions](images/db7.png)

5. Under "Development" click the "SQL" button to open the SQL console.

![Accessing the SQL console](images/db8.png)

6. Create a user password (must be at least 12 characters and contain a number and an uppercase letter), then within the worksheet paste the following SQL which will create a schema user with a username of "mnocidemo", replacing the text XXXXXXXXX with the user password:

    ```
    <copy>
    CREATE USER mnocidemo IDENTIFIED BY "XXXXXXXXX";
GRANT CONNECT, RESOURCE TO mnocidemo;
GRANT UNLIMITED TABLESPACE TO mnocidemo;
    </copy>
    ```

Once you have pasted the SQL into the worksheet, click the "Run script" button to create the schema user.

![Creating the Schema user](images/db9.png)

## Task 3: Download and Configure Wallet Locally

The Oracle Autonomous Database uses an extra level of security in the form of a wallet containing access keys for your new Database.

To connect locally you need to download and configure the ATP Wallet locally.

1. In the OCI Console, click on the burger menu and select 'Autonomous Transaction Processing' under 'Oracle Database'.

    ![ATP menu](images/atp-menu.png)

2. Find the newly created instance and click on it.

    ![ATP instance](images/atp-instance-list.png)

3. In the instance details, click on 'DB Connection'.

    ![DB Connection](images/db-connection-btn.png)

4. In the 'Database Connection' dialog, select 'Instance Wallet' and click 'Download Wallet'.

    ![Wallet dialog](images/wallet-dialog.png)

5. Create a wallet password (must be at least 12 characters and contain a number and an uppercase letter), then enter (and confirm) the wallet password.

    ![Wallet password](images/wallet-password.png)

6. After the wallet zip has been downloaded, unzip it and move it to `/tmp/wallet`. You can do this with a single command in a terminal window on a Unix system, however the file can be extracted to a location of your choosing:

    ```
    <copy>
    unzip /path/to/Wallet_mnociatp.zip -d /tmp/wallet
    </copy>
    ```

7. Once downloaded your wallet directory should contain the following files:

   ![Wallet dir](images/tmp-wallet-dir.png)

## Task 4: Configure Oracle Cloud Vault for Password Storage (Optional)

Micronaut supports using Oracle Cloud Vault as a distributed configuration source. You'll use a Vault to store database passwords so they're not visible in cleartext in your application configuration files.

To securely store your passwords you need to create a vault and an encryption key, and create secrets in the vault.

1. Go to the Oracle Cloud Menu and select "Identity & Security" and then "Vault".

![Vault menu](images/vault1.png)

2. Click "Create Vault":

![Create Vault](images/vault2.png)

3. Enter "mn-oci-vault" as the vault name and click "Create Vault":

![Create Vault](images/vault3.png)

4. Click the vault in the list, then in the vault details page click the "Copy" link in the **OCID** row; this is the unique identifier for your vault and you'll need it later.

![Copy the vault OCID](images/vault4.png)

5. Click "Master Encryption Keys" under "Resources", then click "Create Key":

![Create Key](images/vault5.png)

6. Enter "mn-oci-encryption-key" as the name, and change "Protection Mode" to "Software", then click "Create Key":

![Create Key](images/vault6.png)

7. Once the key has finished provisioning, click "Secrets" under "Resources", then click "Create Secret":

![Create Secret](images/vault7.png)

8. Enter "ATP\_WALLET\_PASSWORD" as the name. Select the encryption key you created, and enter the wallet password you created earlier in the "Secret Contents" field, then click "Create Secret":

![Create Secret](images/vault8.png)

9. Create another secret, using "ATP\_USER\_PASSWORD" as the name. Select the encryption key you created, and enter the user password you created earlier in the "Secret Contents" field, then click "Create Secret":

![Create Secret](images/vault9.png)

You may now *proceed to the next lab*.

## Learn More

* [Oracle Cloud Resource Manager](https://docs.cloud.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/resourcemanager.htm)
* [Oracle Cloud Autonomous Database](https://docs.cloud.oracle.com/en-us/iaas/Content/Database/Concepts/adboverview.htm)

## Acknowledgements
- **Owners** - Graeme Rocher, Architect, Oracle Labs - Databases and Optimization
- **Contributors** - Chris Bensen, Todd Sharp, Eric Sedlar
- **Last Updated By** - Kay Malcolm, DB Product Management, August 2020
