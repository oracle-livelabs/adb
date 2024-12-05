# Provisioning a new Autonomous Data Database

## Introduction

This workshop walks you through the steps to get started using the Oracle Autonomous Database. For this workshop we're going to use an always free **Autonomous Database optimized for Analytics and Warehousing (ADW)**. You will provision a new database in just a few minutes.

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

## Task 1: Create a new Always Free Autonomous Data Warehouse Database

1. Click on the navigation menu at the upper left corner of the page.

    This will produce a drop-down menu, click **Oracle Database** and then select **Autonomous Data Warehouse**.

    ![Oracle Cloud Web Console](./images/prov-1.png " ")

    This will take you to the management console page.

    To learn more about comparments, see [Managing Compartments](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcompartments.htm).
    
2. To create a new instance, click the **Create Autonomous Database** button.

    ![Create ADB](./images/prov-2.png)

    Enter the required information and click the **Create Autonomous Database** button at the bottom of the form. For the purposes of this workshop, use the information below:

    - **Compartment:** Verify that a compartment ( &lt;tenancy_name&gt; ) is selected.

        By default, any OCI tenancy has a default ***root*** compartment, named after the tenancy itself. The tenancy administrator (default root compartment administrator) is any user who is a member of the default Administrators group. For the workshop purpose, you can use ***root***.

    - **Display Name:** Enter the display name for your ADW Instance.
    
    - **Database Name:** Enter any database name you choose that fits the requirements for ADW. The database name must consist of letters and numbers only, starting with a letter. The maximum length is 14 characters. You can leave the name provided. That field is not a mandatory one.
    - **Workload Type:** Autonomous Data Warehouse  
    
    - **Deployment Type:** Serverless
    
    - **Always Free:** On

    You will see the Always Free logo next to the name of your database:

    ![Always Free Logo](./images/always_free_logo.png)

    ![ADB Creation Details](./images/prov-3.png)

3. Under **Create administration credentials** and **Choose network access** sections:

    - **Administrator Password:** Enter any password you wish to use noting the specific requirements imposed by ADW.
    
    - **Reminder:** Note your password in a safe location.

    - **Access type**: Choose **Secure access from everywhere**

    - **Contact email**: Enter a contact email address.

    ![ADB Creation](./images/prov-4.png)

4. Create the database.

    When you have completed the required fields, scroll down and click on the **Create Autonomous Database** button at the bottom of the form:

    ![ADB Creation](./images/prov-5.png)

5. The Autonomous Database **Details** page will show information about your new instance. You should notice the various menu buttons that help you manage your new instance - because the instance is currently being provisioned all the management buttons are greyed out.

    ![ADB Creation Provisioning](./images/prov-6.png)

    The provisioning process should take **under 5 minutes**.

6. After a short while, the status will change to **Available** and the "ADW" box will change color:

    ![ADB Creation Provisioning Green](./images/prov-7.png)

You have just created an Autonomous Database with the latest features of Oracle Databases.

## Acknowledgements

- **Author** - Priscila Iruela - Technology Product Strategy Director, Juan Antonio Martin Pedro - Analytics Business Development
- **Contributors** - Victor Martin, Melanie Ashworth-March, Andrea Zengin
- **Last Updated By/Date** - Nigel Bayliss, Dec 2025
