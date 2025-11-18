# Register an Autonomous Database with Oracle Data Safe

## Introduction

To use a database with Oracle Data Safe, you first need to register it with Oracle Data Safe. A registered database is referred to as a _target database_ in Oracle Data Safe.

Begin by exploring options for registering target databases, and then register your database using the wizard. Next, navigate to Oracle Data Safe and view the list of registered target databases to confirm that yours is listed. Explore Security Center, which is the central hub for Oracle Data Safe where you can access Security Assessment, User Assessment, Data Discovery, Data Masking, Activity Auditing, Alerts, and the Oracle Data Safe dashboard.

Estimated Lab Time: 10 minutes

### Objectives

In this lab, you will:

- Explore the target database registration options
- Register your database with Oracle Data Safe using the Register link on the  Autonomous Databases page
- Access Oracle Data Safe and view your list of registered target databases
- Explore the Security Center

### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account
- Prepared your environment for this workshop (see [Prepare Your Environment](?lab=prepare-environment)). *Make sure that you have sample data loaded into your database.*

### Assumptions

- Your data values are most likely different than those shown in the screenshots.
- Please ignore the dates for the data and database names. Screenshots are taken at various times and may differ between labs and within labs.

## Task 1: Explore Target Database Registration Options

You have three options for registering your Autonomous Database:
- Use the **Register** link on the **Autonomous Databases** page (one-click method with no interaction).
- Use the Autonomous Databases wizard on the **Overview** page for the Oracle Data Safe service (guided method with customization options).
- Manually register your target database from the **Registered Targets** page (advanced method without guidance).

1. Return to the **Autonomous Database | Oracle Cloud Infrastructure** browser tab. You last left off on the **Autonomous Databases** page.

    If you navigated away from this page: From the navigation menu, select **Oracle Database**, and then **Autonomous Database**. Select your compartment (if needed), and then click the name of your database.

2. Scroll down the page, and then under **Data Safe**. The current status of the target database is **Not registered**.

    ![Register option for your database](images/register-database.png "Register option for your database")

3. Click **Register**.

4. Wait for the target database status to show **Registered**. A target database with an **Active** status means that it is currently registered with Oracle Data Safe. Next, review the information and options provided on the page.

    - You can view/edit the target database name and description.
    - You can view the Oracle Cloud Identifier (OCID), the compartment name to where the target database is registered, when the target database was registered and updated, the database type (Autonomous Database), and the connection protocol (TLS). The information varies depending on the target database type.
    - You have options to edit connection details (for example, choose a connectivity option), move the target database to another compartment, deregister the target database, and add tags.

    ![Target database information page](images/target-database-details-page.png "Target database information page")
    
## Task 2: Access Oracle Data Safe and View your List of Registered Target Databases

1. In the breadcrumb at the top of the page, click **Target databases**.

2. Under **List scope**, make sure your compartment is selected. Your registered target database is listed on the right.

    - A target database with an **Active** status means that it is currently registered with Oracle Data Safe.
    - A target database with a **Deleted** status means that it is no longer registered with Oracle Data Safe. The listing is removed 45 days after the target database is deregistered.

    ![Target databases page in OCI](images/target-databases-page-oci.png "Target databases page in OCI")

## Task 3: Explore Security Center

1. In the breadcrumb at the top of the page, click **Data Safe**.

    The **Overview** page is displayed.

2. Under **Security center** on the left, click **Dashboard** and review the dashboard. Scroll down to view the security controls and feature metrics (charts). Make sure your compartment is selected under **List scope**. From the **Target databases** drop-down list, select your target database so that the data in the dashboard pertains to your target database only.

    - In Security center, you can access all the Oracle Data Safe features, including the dashboard, Security Assessment, User Assessment, Data Discovery, Data Masking, Activity Auditing, SQL Firewall, and Alerts.
    - When you register a target database, Oracle Data Safe automatically creates a security assessment and user assessment for you. That's why the **Security assessment**, **User assessment**, **Feature usage**, and **Operations summary** charts in the dashboard already have data.
    - During registration, Oracle Data Safe also discovers audit trails on your target database. That's why the **Audit trails** chart in the dashboard shows one audit trail with the status **In transition** for your Autonomous Database. Later you start this audit trail to collect audit data into Oracle Data Safe.

    ![Initial Dashboard - security controls](images/dashboard-security-controls.png "Initial Dashboard - security controls")

    ![Initial Dashboard - feature metrics top half](images/feature-metrics-top-half.png "Initial Dashboard - feature metrics top half")

    ![Initial Dashboard - feature metrics bottom half](images/feature-metrics-bottom-half.png "Initial Dashboard - feature metrics bottom half")


You may now **proceed to the next lab**.

## Learn More

- [Target Database Registration](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=ADMDS-GUID-B5F255A7-07DD-4731-9FA5-668F7DD51AA6)
- [Oracle Data Safe Dashboard](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=ADMDS-GUID-B4D784B8-F3F7-4020-891D-49D709B9A302)


## Acknowledgements

- **Author:** - Jody Glover, Consulting User Assistance Developer, Database Development
- **Contributor:** Lauran K. Serhal, Consulting User Assistance Developer, Database Development
- **Last Updated By/Date:** - Lauran K. Serhal, August 2025
