# Register an Autonomous Database with Oracle Data Safe

## Introduction

To use a database with Oracle Data Safe, you first need to register it with Oracle Data Safe. A registered database is referred to as a _target database_ in Oracle Data Safe.

Begin by registering your database by using the Autonomous Databases registration wizard. Next, navigate to Oracle Data Safe and view the list of registered target databases to confirm that yours is listed. Optionally, explore Security Center, which is the central hub for Oracle Data Safe where you can access Security Assessment, User Assessment, Data Discovery, Data Masking, Activity Auditing, Alerts, and the Oracle Data Safe dashboard.

Estimated Time: 5 minutes

### Objectives

In this lab, you will:

- Register your database with Oracle Data Safe
- View your registered target database
- (Optional) Explore Security Center

### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account
- Prepared your environment for this workshop. *Make sure that you have sample data loaded into your database.*

### Assumptions

- Your data values are most likely different than those shown in the screenshots.
- Please ignore the dates for the data. Screenshots are taken at various times and may differ between labs and within labs.

Watch the video below for a quick walk-through of the lab.
[Register an Autonomous Database with Oracle Data Safe](videohub:1_hfjj07hm)


## Task 1: Register your database with Oracle Data Safe

1. Make sure that you are on the **Autonomous Database | Oracle Cloud Infrastructure** browser tab. You last left off on the **Autonomous Database details** page.

2. From the navigation menu, select **Oracle Database**, and then **Data Safe - Database Security**. The **Overview** page is displayed. If the **Welcome to Data Safe** tour dialog box is displayed, click **Stop tour**.

    On this page, there are wizards to register the following types of databases:

    - Autonomous Databases
    - Oracle Cloud Databases
    - Oracle On-Premises Databases
    - Oracle Databases on Compute
    - Oracle Cloud@Customer Databases

    ![Registration wizards for Oracle Data Safe](images/registration-wizards.png "Registration wizards for Oracle Data Safe")

3. On the **Autonomous Databases** tile, click **Start Wizard**. 

    The first page in the wizard, **Select Database**, is displayed.

4. From the first drop-down list, select your database. If needed, click **Change Compartment**, select your compartment, and then select your database. 

5. (Optional) Change the default display name for your target database. This name is displayed in your Oracle Data Safe reports. 

6. (Optional) Select a different compartment in which to save the target database. Usually you select the compartment in which your database resides.

7. (Optional) Enter a description for your target database. 

8. Notice the message at the bottom of the page: **The selected database is configured to be securely accessible from everywhere. Steps 2 ('Connectivity Option') and 3 ('Add Security Rule') are not necessary and will be skipped.** If your database had a private IP address, you would need to configure an Oracle Data Safe private endpoint and security rules. 

    ![Autonomous Database registration wizard - Select Database page](images/ocw/ADB-wizard-select-database.png "Autonomous Database registration wizard - Select Database page")

9. Click **Next**.    

10. On the **Review and Submit** page, review the information. To make a change, you can return to the **Select Database** page. 

    ![Autonomous Database registration wizard - Review and Submit page](images/ocw/ADB-wizard-review-submit.png "Autonomous Database registration wizard - Review and Submit page")

11. Click **Register**.

    The **Registration Progress** page is displayed briefly, and then the **Target Database Details** page is displayed. 

12. Wait for the target database status to turn to **ACTIVE**, which means your target database is fully registered. While waiting, review the information and options provided on the page.

    - You can view/edit the target database name and description.
    - You can view the Oracle Cloud Identifier (OCID), when the target database was registered, the compartment name to where the target database is registered, the database type (Autonomous Database), and the connection protocol (TLS). The information varies depending on the target database type.
    - You have options to edit connection details (choose a connectivity option), move the target database to another compartment, deregister the target database, and add tags.

    ![Target Database Details page](images/ocw/target-database-details-page.png "Target Database Details page")
    

## Task 2: View your registered target database

1. In the breadcrumb at the top of the page, click **Target Databases**.

2. Under **List Scope**, make sure your compartment is selected. Your registered target database is listed on the right.

    - A target database with an **Active** status means that it is currently registered with Oracle Data Safe.
    - A target database with a **Deleted** status means that it is no longer registered with Oracle Data Safe. The listing is removed 45 days after the target database is deregistered.

    ![Target Databases page in OCI](images/ocw/target-databases-page-oci.png "Target Databases page in OCI")


## Task 3: (Optional) Explore Security Center

1. In the breadcrumb at the top of the page, click **Data Safe**.

    The **Overview** page is displayed.

2. Under **Security Center** on the left, click **Dashboard** and review the dashboard. Scroll down to view all the charts. Make sure your compartment is selected under **List Scope**. From the **Target Databases** drop-down list, select your target database so that the data in the dashboard pertains to your target database only.

    - In Security Center, you can access all the Oracle Data Safe features, including the dashboard, Security Assessment, User Assessment, Data Discovery, Data Masking, Activity Auditing, and Alerts.
    - When you register a target database, Oracle Data Safe automatically creates a security assessment and user assessment for you. That's why the **Security Assessment**, **User Assessment**, **Feature Usage**, and **Operations Summary** charts in the dashboard already have data.
    - During registration, Oracle Data Safe also discovers audit trails on your target database. That's why the **Audit Trails** chart in the dashboard shows one audit trail with the status **In Transition** for your Autonomous Database.

    ![Initial Dashboard - top half](images/ocw/dashboard-initial-top.png "Initial Dashboard - top half")

    ![Initial Dashboard - bottom half](images/ocw/dashboard-initial-bottom.png "Initial Dashboard - bottom half")

You may now **proceed to the next lab**.

## Learn More

- [Target Database Registration](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=ADMDS-GUID-B5F255A7-07DD-4731-9FA5-668F7DD51AA6)
- [Oracle Data Safe Dashboard](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=ADMDS-GUID-B4D784B8-F3F7-4020-891D-49D709B9A302)


## Acknowledgements

- **Author** - Jody Glover, Consulting User Assistance Developer, Database Development
- **Last Updated By/Date** - Jody Glover, August 17, 2023
