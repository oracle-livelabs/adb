# Provision an Autonomous Data Warehouse and create a new user

## Introduction

This workshop walks you through the steps to get started using the **Oracle Autonomous Data Warehouse Database (ADW)**. You will provision a new database in just a few minutes and you will create a new user.

Oracle Autonomous Databases have the following characteristics:

**Self-driving**
Automates database provisioning, tuning, and scaling.

- Provisions highly available databases, configures and tunes for specific workloads, and scales compute resources when needed, all done automatically.

**Self-securing**
Automates data protection and security.

- Protect sensitive and regulated data automatically, patch your database for security vulnerabilities, and prevent unauthorized access—all with Oracle Autonomous Database.

**Self-repairing**
Automates failure detection, failover, and repair.

- Detect and protect from system failures and user errors automatically and provide failover to standby databases with zero data loss.

Watch our short video that explains how to provision your Autonomous Database instance:

[](youtube:IfWJhnodAxk)

Estimated Lab Time: 15 minutes.

### Objectives 
- Create an Autonomous Database with the latest features of Oracle Databases

## Task 1: Create a new Autonomous Data Warehouse database

1. Click on the hamburger **MENU** link at the upper left corner of the page.

    This will produce a drop-down menu, where you should select **Autonomous Data Warehouse**.

    ![Select Autonomous Data Warehouse](./images/select-adw-2.png)

    This will take you to the management console page.
    
2. To create a new instance, click the blue **Create Autonomous Database** button.

    ![Create ADB](./images/create-adb-2.png)

    Enter the required information and click the **Create Autonomous Database** button at the bottom of the form. For the purposes of this workshop, use the information below:

    - **Compartment:** Verify that a compartment (&lt;tenancy_name&gt;) is selected.

        By default, any OCI tenancy has a default ***root*** compartment, named after the tenancy itself. The tenancy administrator (default root compartment administrator) is any user who is a member of the default Administrators group. For the workshop purpose, you can use ***root***.
        
        To learn more about compartments, see [Managing Compartments](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcompartments.htm).

    - **Display Name:** Enter the display name for your ADW Instance. For this demo purpose, I have called my database `MODERNDW`.
        ```
        <copy>MODERNDW</copy>
        ```
    
    - **Database Name:** Enter any database name you choose that fits the requirements for ADW. The database name must consist of letters and numbers only, starting with a letter. The maximum length is 14 characters. You can leave the name provided. That field is not mandatory but for this demo purpose, I have called my database `MODERNDW`.
        ```
        <copy>MODERNDW</copy>
        ```

    - **Workload Type:** Data Warehouse  
    
    - **Deployment Type:** Shared Infrastructure
    
    - **Always Free:** On

    You can select Always Free configuration to start enjoying your Free Autonomous Database. You will have see the Always Free logo next to the name of your database:

    ![Always Free Logo](./images/always-free-logo.png)

    We have selected 'Always Free Tier On'. 

    To learn more about Always Free check the following [link](https://www.oracle.com/uk/cloud/free/#always-free).

    ![ADB Creation Details](./images/adb-creation1.png)

    - **Choose Database version:** 19c
    
    - **ECPU Count:** 2
    
    - **Storage Capacity (TB):** 1 or 0,02 Gb if you had chosen the **Always Free option**.

    - **CPU Count and Storage Capacity (TB)** are defined by default for the Always Free Tier.
    
    - **ECPU Auto scaling:** Off
    
    - **Storage Auto scaling:** Off

    ![ADB Creation Storage](./images/adb-creation2.png)

3. Under **Create administration credentials** section:

    - **Administrator Password:** We are going to use the following password: **Password123##**
        ```
        <copy>Password123##</copy>
        ```
    
    - **Reminder:** Note your password in a safe location as this cannot be easily reset.

    Under **Choose network access** section:

    - Select **'Secure access from everywhere'**: *On*
    
    ![ADB Creation Password](./images/adb-creation3.png)

4. Under **Choose a license type** section, choose **License Type: License Included**.

    When you have completed the required fields, scroll down and click on the blue **Create Autonomous Database** button at the bottom of the form:

    ![ADB Creation](./images/adb-creation4.png)

5. The Autonomous Database **Details** page will show information about your new instance. You should notice the various menu buttons that help you manage your new instance - because the instance is currently being provisioned all the management buttons are greyed out.

    ![ADB Creation Provisioning](./images/adb-provisioning.png)

6. A summary of your instance status is shown in the large box on the left. In this example, the color is amber and the status is **Provisioning**.

    ![ADB Creation Provisioning Amber](./images/provisioning.png)

7. After a short while, the status will change to **Available** and the "ADW" box will change color to green:

    ![ADB Creation Provisioning Green](./images/available.png)

8. Once the Lifecycle Status is **Available**, additional summary information about your instance is populated, including workload type and other details.

    The provisioning process should take **under 5 minutes**.

9. After having the Autonomous Database instance **created** and **available**, you can get a message window asking you to upgrade from 18c to 19c if you have selected 18c as a database version during the provisioning. You can **upgrade** the database release if you wish after the hands-on session, otherwise the upgrade process can take a **few minutes** and you can miss a few exercises during the session.

    This page is known as the **Autonomous Database Details Page**. It provides you with status information about your database, and its configuration. Get **familiar** with the buttons and tabs on this page.

    ![ADB Creation Details](./images/adb-provisioned.png)

    Remember: You will have visible the Always Free logo next to the name of your database:

    ![Always Free Logo](./images/always-free-logo.png)

You have just created an Autonomous Database with the latest features of Oracle Databases.

## Task 2: Create a new Autonomous Database user

1. In order to create a new user, we have to click on **Database Actions** button. We will connect automatically as **ADMIN** user, using the same credentials that we used on Task 1 when provisioning the database.

    ![ADB Select Database Actions](./images/adb-dbactions.png)

2. A new tab will open. Look for the option **Database Users** under the Administration section.

    ![ADB Select Database Users](./images/adb-database-users.png)

3. Click on **Create User**

    ![ADB Create Database Users](./images/adb-create-user.png)

4. We are going to create the following user:
    - **User Name:** CNVG
        ```
        <copy>CNVG</copy>
        ```

    - **Password:** Password123##
        ```
        <copy>Password123##</copy>
        ```

    - **Quota:** Unlimited
    
    - **Graph:** Enabled
    
    - **Web Access:** Enabled

    - **OML:** Enabled

    ![ADB Database User detail](./images/adb-user-details.png)

5. Click the **Create User** button:

    ![ADB Database User detail](./images/adb-user-creation.png)

6. **CNVG** user has been created.
    
    ![ADB Database User created](./images/adb-user-created.png)


You can **proceed to the next lab.**

## Acknowledgements

* **Author** - Javier de la Torre, Principal Data Management Specialist
* **Contributors** - Priscila Iruela, Technology Product Strategy Director
* **Last Updated By/Date** - Javier de la Torre, Principal Data Management Specialist, November 2024




