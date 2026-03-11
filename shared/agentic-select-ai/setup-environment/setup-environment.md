# Set up the Workshop Environment

<!---
comments syntax
--->

## Introduction

This workshop focuses on teaching you how to setup your Autonomous AI Database and install Select AI Ask Oracle Chatbot application to query your data using natural language. The **Ask Oracle** APEX application, powered by Select AI running on Autonomous AI Database, offers a conversational interface for interacting with your data. 

This short demo showcases how the app leverages Natural Language to SQL (NL2SQL), Retrieval-Augmented Generation (RAG), and AI agents to transform natural language queries into actionable insights.

[Ask Oracle Chatbot Demo](youtube:p595Io2cxyw:medium)





Estimated Time: 5 minutes.

### Objectives

In this lab, you will:

* Provision your Autonomous AI Database instance
* Install the Select AI Ask Oracle Chatbot application


## Task 1: Create the Autonomous AI Database Instance
[](include:adb-provision-body.md)

## Task 2: Create an Autonomous AI Database User
To create a user:
1. If you are not already signed in, sign into your OCI account, click the cloud menu on the left to open the left navigation pane, and click **Oracle AI Database**. On the right, click **Autonomous AI Database**.
    ![Create Autonomous AI Database](./images/select-adb.png =70%x*)

2. Click the Oracle Autonomous AI Database that you have provisioned for this workshop. Here, click the instance `Training-Database`.
    ![Click Training-Database](./images/click-dbinstance.png =70%x*)

3. On the Autonomous AI Database details page, click **Database Actions**, and then select the **Database Users** option.
    ![Click Database Users](./images/db-user.png =70%x*)

4. Before you get to the Oracle Database Actions Launchpad page, you might be asked to log in, depending on the browser you are using. If this is the case make sure to enter `ADMIN` and the password you gave the administrator user.
5. Click **Create User**. The Create User dialog opens. 
    ![Click Create User](./images/db-actions-create-user.png =70%x*)

6. On the Create User dialog, enter the following details and click **Create User**: 

    ![Create ADB_USER](./images/create_adb_user.png =70%x*)
    
    - **User Name**: Enter the user name ADB_USER.
    - **Password**: Enter a password for this user. The password must be 12 to 30 characters and contain at least one uppercase letter, one lowercase letter, and one number. The password cannot contain the double quote (") character or the username itself.
    - **Confirm Password**: Re-enter the password that you entered in the Password field.
    - **Quota of tablespace data**: Click on the drop-down list and select an option. For this lab and a typical Always Free ADB, UNLIMITED is selected.
    - **Password Expired**: Select this option if you want the user to reset their own password.
    - **Account is locked**: Use this option to lock the account.
    - **OML**: Select this option to allow this user to access Oracle Machine Learning. This is a required field.
    - **Graph**: Optionally, select this option to enable graph for this user.
    - **Web Access**: Select this option to allow Web and DB Actions access to this user via its own url. This is an optional field.
    - **Show Code**: Click this option to view the code to create the user and grant roles to the user. You also have the option to copy the code.

7. After the user is created successfully, the message _User ADB\_USER created successfully_ is displayed.    

## Task 3: Grant Privileges

1. Click on your database instance and navigate to the **Tool Configuration** tab. 
2. Click **Copy** to copy the **Database Actions** URL. 
    ![Copy the Database Actions URL](./images/db-actions-url.png =70%x*)

3. Paste the URL in your browser.
4. Login as an `ADMIN` user. 
5. Click **Development** tab and click **SQL** on the left-hand navigation in the Database    Actions|Launchpad screen. This opens the SQL worksheet.
6. Grant the following to the schema user:

    ```
    <copy>
    GRANT EXECUTE on DBMS_CLOUD_AI to ADB_USER;
    GRANT EXECUTE on DBMS_CLOUD_AI_AGENT to ADB_USER;
    GRANT EXECUTE on DBMS_CLOUD_PIPELINE to ADB_USER;
    GRANT EXECUTE on DBMS_VECTOR to ADB_USER;
    GRANT CREATE ANY INDEX to ADB_USER;
    </copy>
    ```
> Replace `ADB_USER` with the schema user name.

## Task 4: Install Ask Oracle Chatbot Application
Here is a video that walks you through the **Ask Oracle** chatbot app installation:
[Ask Oracle App Installation](youtube:kjeQ2AC3TFo:small)

Perform the following steps to install the Ask Oracle Chatbot app. The application is available on GitHub.

1. Download the `ADB-AskOracle-Chatbot-yyyy-mm-dd.sql` file from the [GitHub repository](https://github.com/oracle-devrel/oracle-autonomous-database-samples/tree/main/apex/Ask-Oracle) and store it in your local directory. 

2. From your Autonomous AI Database console, navigate to **Tool configuration** and copy the APEX URL.

3. Paste the URL in your web browser and **Sign In** with the workspace associated with the created schema.
    > If you have not created an APEX workspace, the URL copied from **Tool Configuration** opens Administrative Services. Only the `ADMIN` user can access this page. The `ADMIN` user must first create an APEX workspace, along with a workspace username and password. For guidance, see [Get Started with Oracle APEX on the Oracle Autonomous AI Database](https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=3509). Once the workspace exists, the **Tool Configuration** URL opens the APEX login screen, where a schema user can sign in.

4. In APEX, go to **App Builder** → **Import**.

5. Click the **Drag and Drop** selection and navigate to the `ADB-AskOracle-Chatbot-yyyy-mm-dd.sql` file that you stored in your local directory and click **Open**.

6. Keep the defaults and click **Next**.

7. Next screen, click **Install Application**. This may take a while. Once the application is installed, click **Next**.

8. Review the supporting objects and click **Install Supporting Objects**.

9. Next screen shows a confirmation screen with the supporting objects installed, click **Run Application**.

10. You'll be prompted with a login screen. Enter the APEX username and password. You are ready with a prompt screen.





You may now proceed to the next lab.

## Learn More

* [Using Oracle Autonomous AI Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)
* [Select AI Examples](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai-examples.html#GUID-8BEF8CA8-D98D-41FB-A819-6C2F862099DC)

## Acknowledgements

* **Author:** Sarika Surampudi, Principal User Assistance Developer
* **Contributor:** Mark Hornick, Product Manager
<!--* **Last Updated By/Date:** Sarika Surampudi, August 2025
-->


Copyright (c) 2026 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
