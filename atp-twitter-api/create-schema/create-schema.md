# Create schema

## Introduction

In this lab, we will create a ATP to import a schema for the data. We will review the process for creating the Autonomous Transaction Processing (ATP) instance, Schema for the APEX workspace, and import the APEX app, along with the DDL.

Download the SQL files for the lab: [Link](https://objectstorage.us-ashburn-1.oraclecloud.com/p/LNAcA6wNFvhkvHGPcWIbKlyGkicSOVCIgWLIu6t7W2BQfwq2NSLCsXpTL9wVzjuP/n/c4u04/b/livelabsfiles/o/developer-library/Twitter_LL1_sql.zip)

Estimated Time: 20 minutes

### Objectives

In this lab, you will complete the following tasks:

- Create ATP instance
- Create Schema
- Import DDL and SQL commands
- Import APEX APP

### Prerequisites

This lab assumes you have:
- An Oracle Cloud Account

## Task 1: Create ATP instance

1. With OCI open, we will navigate to the ATP portal by selecting the hamburger menu in the top left corner, which will allow for you to select **Oracle Database** and then, **Autonomous Transaction Processing.**

![Select ATP from OCI menu](images/select-atp-menu.png) 

2. Select **Create Autonomous Database.**

    ![Select Create Autonomous Database](images/create-autonomous-database.png) 

3. (optional) Enter a display name and database name. Select a **database version** (19c), whichever default version will work also.  

    ![Enter database name](images/name-database.png) 

4. Create a password for admin credentials.

    ![Enter admin credentials](images/atp-password.png) 

5. Change network access to **allowed IPs and VCNs only** and change IP notation type to **CIDR Block.** Make sure Require mutual TLS authentication is left unchecked.

    ![Enter admin credentials](images/secure-access.png) 

6. Leave everything else default, and then select **Create Autonomous Database** at the bottom.

    ![Create ADB button at the bottom](images/create-atp.png)     

## Task 2: Create Schema

1. After ATP has been created, the status will update the color to green. Select **Tools** at the menu bar, then select **Open APEX**.

    ![Open APEX from ATP](images/open-apex.png) 

2. Enter the password you used to create the ATP.

    ![Admin login page](images/login-apex.png) 

3. Select **Create Workspace**

    ![Welcome page for new workspace](images/create-workspace.png) 

4. Select **New Schema.**

    ![Options for schema](images/new-schema.png)   

5. Enter a workspace name (Schema), username, and password.
   
    ```
    Workspace Name: TWITTER_LL
    Workspace Username: dev
    Password: <password>
    ```

    **Alternatively** if you run into an error, such as shown below you can go back to step 4 and select **Existing Schema** to enter the same schema as step 5, **TWITTER_LL.** 

    ![Options for schema](images/error-schema.png)   

    Afterwards, you will be instructed in sign in. Alternatively, you can select **Workspace Sign-In** to skip ahead to step 8.

    ![Open APEX workspace](images/login-apex.png) 

6. Sign out by clicking the **admin icon** in the top right, which will open a menu to sign out. Click **Sign out.**   

    ![Sign out menu](images/sign-out.png)

7. Select **Return to Sign In Page.**

    ![Sign in window](images/sign-in.png)

8. Enter the information that was used to make the workspace from step 6 and click **Sign in.**

    ![Sign in credentials](images/sign-in-credentials.png)

## Task 3: Import DDL and SQL commands

1.  Select **SQL Workshop** from the menu options.

     ![Open SQL Workshop homepage](images/sql-workshop.png) 

2. Select **SQL Scripts** to upload sql files provided.

     ![Open SQL scripts from menu](images/sql-scripts.png) 

3. Select **Upload** to browse and upload the sql files (Except for the apexApplicationHackathon.sql script - that will be used for task 4).

    - Download the lab files if you haven't already: [Link](https://objectstorage.us-ashburn-1.oraclecloud.com/p/LNAcA6wNFvhkvHGPcWIbKlyGkicSOVCIgWLIu6t7W2BQfwq2NSLCsXpTL9wVzjuP/n/c4u04/b/livelabsfiles/o/developer-library/Twitter_LL1_sql.zip)

    ![Upload SQL scripts from menu](images/upload-scripts.png) 

4. Starting with the **HackathonDDL** file, select the **play button (Run)** to run the individual sql files.

     ![Run SQL scripts menu](images/run-ddl.png) 

5. Observe that the statements were successfully processed. Click the **back arrow** to return to the SQL Scripts homepage and run each individual script like before.

     ![Metrics for running a SQL script](images/successful-run.png) 

6. After a successful completion of each sql script, select **App Builder** from the top menu options. 

     ![App Builder Menu options](images/app-builder.png) 

## Task 4: Import APEX APP

1. Select **Import App** to begin uploading the APEX app.

     ![App Builder import button](images/import-app.png)

2. Select the **Drag and Drop** button to upload the file **apexApplicationHackathon.sql,** and then select the **Next** button.

     ![Upload apex sql file](images/apex-app-sql.png)

3. Confirm the import on the next page by selecting **Next** at the bottom.

     ![Confirmation page for import](images/confirm-import.png)
              
4. Install the app by selecting **Install Application** at the bottom of the page.

     ![Install app page](images/run-and-build.png)

5. Select **Run Application** at the bottom to view the app homepage. We will review the app with the data in the Explore APEX lab at the end.

     ![Run the App](images/run-app.png)

You may now **proceed to the next lab.**

## Acknowledgements

- **Author**- Nicholas Cusato, Santa Monica Specialists Hub
- **Contributers**- Rodrigo Mendoza, Ethan Shmargad, Thea Lazarova
- **Last Updated By/Date** - Nicholas Cusato, January 2024