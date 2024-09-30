# Send Microsoft Teams Notifications from Autonomous Database

**Important:** This lab uses features which are not available on the Oracle LiveLabs Sandbox hosted environments (the Green button), and requires Microsoft Teams admin permissions. If you run this lab using a LiveLabs Sandbox environment, you can only review the steps and later practice the steps using your organization’s Microsoft Teams workspace.

## Introduction

Microsoft Teams serves as a comprehensive collaboration platform within the Microsoft 365 ecosystem, facilitating instant messaging, audio and video calls, and online meetings. With its seamless integration with other applications, Teams enhances productivity by streamlining communication and project management. Microsoft Teams supports a wide range of integrations with external apps and services.

This lab walks you through the steps to configure your Microsoft Teams application to receive messages, alerts and output of a query from Autonomous Database. Also, you will learn the procedures to send Microsoft Teams notifications.

Estimated Time: 25 minutes

### Objectives

In this lab, you will:

+ Create your Microsoft Teams application
+ Create and configure a bot for your Microsoft Teams application
+ Publish your Microsoft Teams application
+ Configure your Microsoft Teams application using Azure Portal
+ Create your Microsoft Teams channel
+ Create a credential object to access Microsoft Teams application from Autonomous Database
+ Configure access control to allow user access to external network services
+ Send messages to a Microsoft Teams channel
+ Send query results to a Microsoft Teams channel

### Prerequisites

+ Completion of the lab **Get Started**, and **Lab 1** from the **Contents** menu on the left.
+ Microsoft Teams account and workspace
+ Microsoft Teams app and channel
+ Microsoft 365 Developer Account

> **Note:** The Microsoft 365 Developer Program offers a powerful sandbox environment through its Microsoft 365 E5 developer subscription. This subscription provides developers with a dedicated space to build and test solutions without impacting production systems. For more information, see [Set up a developer subscription](https://learn.microsoft.com/en-us/office/developer-program/microsoft-365-developer-program-get-started).

## Task 1: Create your Microsoft Teams application

1. To create a Microsoft Teams application, click [this link](https://dev.teams.microsoft.com/home) to access **Developer Portal for Teams**, and then select **Apps** from the navigation menu that is located on the left side panel.

    ![Open ADB](./images/select-apps.png "")

    > **Note:** Please bookmark  [Apps](https://dev.teams.microsoft.com/apps) link as you will need it for future tasks.

2. Click the plus sign next to **New App** to create a new application.

    ![Open ADB](./images/create_new_app.png "")

3. Enter your preferred app **Name** into a placeholder, and then click **Add**.

    ![Open ADB](./images/add_app.png "")

4. Ensure that your app has been successfully created as shown in the screen capture.

    ![Open ADB](./images/app-created.png "")

5. If you want to delete your application, click the **3 dots** sign next to your application name, and then click **Delete**.

    ![Open ADB](./images/delete-app.png "")

6. Enter your application name into a placeholder, and then click **Confirm**.

    ![Open ADB](./images/enter-confirm-to-delete.png "")

7. If successfull, you will receive a message as shown in the screen capture.

    ![Open ADB](./images/receive-popup-msg.png "")

## Task 2: Create and configure a bot for your Microsoft Teams application

1. Click the **three-line sign** that is located on the left side panel.

    ![Open ADB](./images/click-lines.png "")

2. Select **Tools** from the navigation menu of the Developer Portal for Teams, and then click **Bot management**.

    ![Open ADB](./images/bot_management.png "")

3. Click the plus sign next to **New Bot** to create your bot.

    ![Open ADB](./images/select_newbot.png "")

4. Enter your preferred **Bot name** into a place holder, and then click **Add**.

    ![Open ADB](./images/enter_bot_name.png "")

5. Ensure you receive a pop-up message confirming that your bot has been successfully added.

    ![Open ADB](./images/created_bot.png "")

6. To create a secret key for your bot, click **Bot Name**.

    ![Open ADB](./images/click_bot_name.png "")

7. Select **Client Secrets**, and then click **Add a secret** to create client secrets for your bot.

    ![Open ADB](./images/add_secret.png "")

8. After creating client secret, make sure that you copy the secret by clicking **copy** near the code. Then, click **OK** to close it.

    ![Open ADB](./images/create_secret_key.png "")

9. Select **Apps** from the navigation menu, and click your application **Name**.

    ![Open ADB](./images/select-appname.png "")

10. Scroll down to the **Configure** section, click **App features**.

    ![Open ADB](./images/select_app_features.png "")

11. Click **Bot** to set up required scope and permission for your application.

   ![Open ADB](./images/select_appfeatures_bot.png "")

    > **Note:** Bots are conversational apps that carry out a predetermined set of tasks. Bots interact with people, answering their inquiries and informing them in advance of changes and other happenings. For more information, see [Build bots for Teams](https://learn.microsoft.com/en-us/microsoftteams/platform/bots/what-are-bots?referrer=developerportal).

12. Specify the following parameters that are shown in the screen capture to set up your bot's scope, and then click **Save**.

    - Identify your bot: Select **select an existing bot** 
    - What can your bot do: Click the **Only send notifications**
    - Scopes: Click the **Team** 

   ![Open ADB](./images/add_scope_permission.png "")

    > **Note:** Selecting the "team" scope provides the bot functionalities such as accessing to team channels, ability to interact with multiple users in a team, and  retrieving team-specific data. Fore more information, see [App scope](https://learn.microsoft.com/en-us/microsoftteams/platform/concepts/design/understand-use-cases?referrer=developerportal#app-scope).

## Task 3: Publish your Microsoft Teams application

After creating your application successfully, the next crucial step is to publish it to your organization. This process ensures that your application becomes accessible to all users within your organization.

1. Go to your [Apps](https://dev.teams.microsoft.com/apps), click your application **Name**.

    ![Open ADB](./images/select-appname.png "")

2. Scroll down to the **Configure** section, and then select **Basic Information**.

    ![Open ADB](./images/select-basic-info.png "")

3. On the **Basic Information** page, fill out the basic information about your application, and then click **Save**.

    ![Open ADB](./images/basic-info-example.png "")

    > **Note:** If you do not enter the information on your app details page, you will not be able to  publish your app to org. For more information, see [Create your Teams Store listing details](https://learn.microsoft.com/en-us/microsoftteams/platform/concepts/deploy-and-publish/appsource/prepare/submission-checklist?referrer=developerportal&tabs=desktop).

4. After completing the basic information, click the **Publish** button that is located on the upper right-hand side of the page to submit the app.

   ![Open ADB](./images/select_publish_app.png "")

5. Verify that the submission **Status** shows **Submitted**.

   ![Open ADB](./images/check_sub_status.png "")

## Task 4: Configure your Microsoft Teams application using Microsoft Entra ID

1. After publishing your app, ensure your Microsoft Teams admin approves your app from [Teams admin center](https://admin.teams.microsoft.com/policies/manage-apps).

    > **Note:** If your application is not approved by Microsoft Team admin, you will not be able to proceed to the next tasks.

2. Go to [Microsoft Entra admin center](https://entra.microsoft.com/#home), and then click the arrow down next to **Identity**.

   ![Open ADB](./images/select-identity.png "")

3. Scroll down to the **Applications** section, and then click the arrow down next to **Applications** section.

   ![Open ADB](./images/select-applications-arrow.png "")

4. From the drop-down list, click **App registrations**.

   ![Open ADB](./images/register_app.png "")

5. Select **Owned applications**, which will automatically populate your bot with **Application(client) ID**.

    ![Open ADB](./images/app_registry.png "")

    > **Note:** Please copy your **Application (client) ID**. It is unique identifier for an app and also known as the client ID for an app.

6. You can also enter your bot **name** in the **Search** field as shown in the screen capture.

    ![Open ADB](./images/enter-botname-field.png "")

7. Click **Display name** to see information about your application.

   ![Open ADB](./images/select_bot_name.png "")

8. Scroll down to **Manage** section, an then select **API permissions** 

   ![Open ADB](./images/select_api_perms.png "")

9. For your application, these following permissions are required:

+ **`Files.ReadWrite.All`**

    This permission will enable you to read, create, update and delete all files. For more information, see [Microsoft Graph permissions reference](https://learn.microsoft.com/en-us/graph/permissions-reference).

+ **`ChannelSettings.Read.All`**

    This permission will enable you to read all channel names, channel descriptions, and channel settings. For more information, see [Microsoft Graph permissions reference](https://learn.microsoft.com/en-us/graph/permissions-reference).

10. To request required permissions for your app, click **Add a permission**.

   ![Open ADB](./images/click_add_permis.png "")

11. On the Request API permissions page,  set the following parameters, and then click **Add permissions**.

    - Microsoft APIs: Select **Microsoft Graph**
    - Type of permissions: Select **Application permissions**
    - Select permissions: Enter **ChannelSettings.Read.All** in the **search** field
    - Channel Settings: Click the **ChannelSettings.Read.All** box

    ![Open ADB](./images/add_permis_channel.png "")

    > **Note:** Microsoft Graph API for Teams offers powerful capabilities to enhance your applications. It provides access to crucial data about teams, channels, users, and messages, enabling the creation of rich features. Additionally, the notification APIs simplify sending alerts from your app directly to the Teams activity feed. For more information, see [Use the Microsoft Graph API to work with Microsoft Teams](https://learn.microsoft.com/en-us/graph/api/resources/teams-api-overview?view=graph-rest-1.0).

12. Repeat the step 11 to add `Files.ReadWrite.All` permission as well.

13. After adding permissions, ensure your admin approve requested permissions from **Microsoft Entra admin center**.

    ![Open ADB](./images/grant_permis.png "")

## Task 5: Create your Microsoft Teams Channel

1. Log into your [Microsoft Teams](https://www.microsoft.com/en-us/microsoft-teams/log-in), click **Teams** , click **+** sign next to **Teams**.

    ![Open ADB](./images/select-teams.png "")

2. Select **Create channel** from the drop-down list.

    ![Open ADB](./images/create_teams_channel.png "")

3. To create a channel, specify the following parameters as shown in the screen capture and click **Create**.

    - Add the channel to a team: Select your preferred **team** and click **Done**.
    - Channel name: Enter your preferred **channel name** into a place holder.
    - Description: Enter your preferred **Description**
    - Channel type: Select **channel type** as **Standard** so people on your team has access.

    ![Open ADB](./images/click_create_channel.png "")

4. If successful, you will see your channel, which was created under your preferred team.

    ![Open ADB](./images/created-new-chnl.png "")

5. Select **Apps** from navigation menu, enter your **application name** in the search field, and then click **Add** to add your app to your channel.

    ![Open ADB](./images/add_app_to_channel.png "")

6. Select **Add to a team**.

   ![Open ADB](./images/select-add-team.png "")

7. Enter your channel name into place holder or click the **search** icon to find your channel, and then select your **team or your channel** from the dropdown.

    ![Open ADB](./images/search_team.png "")

8. Click **Set up a bot** to proceed.

    ![Open ADB](./images/add_bot_to_team.png "")

9. Click **OK** for the pop-up message.

    ![Open ADB](./images/click_ok_msg.png "")

    > **Note:** To send a query result to a Microsoft Teams channel, you need to obtain your **team ID**, and  **tenant ID**. The tenant ID is a globally unique identifier (GUID) that differs from your organization’s name or domain.

10. Click on the **three dots(...)** next to your channel name, and then click **Get link to channel**.

    ![Open ADB](./images/click_three_dots.png "")

    ![Open ADB](./images/get_link_channel.png "")

11. Click **Copy** to copy the link as shown in the screen capture.

    ![Open ADB](./images/copy_the_link.png "")

    > **Note:** Please save the URL to be able to proceed to next tasks.

12. Paste the URL into the text editor to copy your **tenant ID**, which is located at the end of the URL.

    ![Open ADB](./images/copy_tenant_id.png "")

    > **Note:** For more information, see [Find your Microsoft 365 tenant ID](https://learn.microsoft.com/en-us/sharepoint/find-your-office-365-tenant-id).

13. Copy your **team ID** from the URL as shown in the screen capture.

    ![Open ADB](./images/copy_team_id.png "")

14. Copy the **channel ID** from the URL as shown in the screen capture.

    ![Open ADB](./images/copy_channel_id.png "")

## Task 6: Create a credential object to access Microsoft Teams application from Autonomous Database

For this task, you will use **`DBMS_CLOUD.CREATE_CREDENTIAL`** procedure which enables you to access the cloud service for data loading, and querying external data in the cloud. For more information, see [`CREATE_CREDENTIAL procedure`](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-subprograms.html#GUID-742FC365-AA09-48A8-922C-1987795CF36A).

1. In the Oracle Cloud console, open the **Navigation menu**, navigate to **Oracle Database**, and then select **Autonomous Data Warehouse**.

    ![Open ADB](./images/click-adb.png "")

2. Select your **Autonomous Database instance**.

    ![Open ADB](./images/click-adb-name.png "")

3. Click **Database actions** dropdown, and then select **SQL** .

    ![Open ADB](./images/select-database-actions.png "")

4. To create a credential object to access the Microsoft Teams app from Autonomous Database, specify the following parameters that are used in the following code example.

    - credential_name: Enter your preferred name such as **`TEAMS_CRED`**
    - username: Substitute **bot_id** with your **Application (client) ID**. 
    - password: Substitute **bot_secret** with your **client secret**.

    > **Note:** You will not be able to run the code without having your **Application (client) ID** and **client secret**. Please see task 2, step 8 for **client secret** and task 4, step 5 for **Application (client) ID**

5. Copy and paste the following code into your SQL Worksheet, and then click the **Run Script (F5)** icon in the Worksheet toolbar.

    ```
    <copy>
       BEGIN
          DBMS_CLOUD.CREATE_CREDENTIAL(
                    credential_name => 'TEAMS_CRED',
                    username        => 'bot_id',
                    password        => 'bot_secret');
       END;
    </copy>
    ```

    ![Open ADB](./images/create_credential.png "")

    > **Note:** To use Microsoft Teams app with **`DBMS_CLOUD_NOTIFICATION`** procedure, you need to run the procedure successfully. If you can not run the **`CREATE_CREDENTIAL`** procedure successfully, you can consult the ADMIN user to grant execute access on **`DBMS_CLOUD`** packages. For more information, see[`DBMS_CLOUD`](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-subprograms.html#GUID-3D0A5361-672C-467D-AA90-656B1B4D4E37).

    You can leave the SQL window open and continue with the next task.

## Task 7: Send messages to a Microsoft Teams Channel

After creating the Microsoft Teams credential object, you can use the **`DBMS_CLOUD_NOTIFICATION.SEND_MESSAGE`** procedure to send a message to your Microsoft Teams channel. For more information, see [SEND_MESSAGE Procedure](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/autonomous-dbms-cloud-notification.html#GUID-8A557984-BEC3-4F82-909E-4451E86F66E0).

1. In the source database SQL window, specify the following parameters that are used in the following code example.

    - provider: Enter **msteams**
    - credential_name: Enter your credential name such as **`TEAMS_CRED`**
    - message: Enter your preferred message such as **`text from new teams api`**
    - params: Substitute **`C0....08`** with your own  **channel ID**

    > **Note:** You will not be able to run the code without having your **channel ID**. Please see task 5, step 13 to obtain your **channel ID**.

2. Copy and paste the following code into your SQL Worksheet, and enter your **Team ID**, then click the **Run Script (F5)**.

    ```
    <copy>
       BEGIN
         DBMS_CLOUD_NOTIFICATION.SEND_MESSAGE(
             provider        => 'msteams',
             credential_name => 'TEAMS_CRED',
             message         => 'text from new teams api',
             params          => json_object('channel' value 'channel ID'));
        END;
    </copy>
    ```

    ![Open ADB](./images/run_send_notif_pkg.png "")

3. Open your Teams channel, and confirm the receipt of the message.

    ![Open ADB](./images/confirm_msg.png "")

## Task 8: Send query results to a Microsoft Teams Channel

After creating required credential and configuration, you can use the **`DBMS_CLOUD_NOTIFICATION.SEND_DATA`** procedure to send the output of a query to your Microsoft Teams Channel. For more information, see [`SEND_DATA Procedure`](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/autonomous-dbms-cloud-notification.html#GUID-B3375A5B-79B1-43A5-B043-A7FA646FBF54).

1. Specify the following parameters that are used in the following code example.

    - provider: Enter **msteams**
    - credential_name: Enter your credential name such as **`TEAMS_CRED`**
    - query: Enter your preferred query such as **`SELECT tablespace_name FROM dba_tablespaces`**
    - tenant: Enter your **tenant ID**
    - team: Enter your **team ID**
    - channel: Enter **channel ID**
    - title: Enter your preferred **title of the file**
    - type: Output format can be `csv` or `json`

2. Copy and paste the following code into your SQL Worksheet, substitute previously specified parameters, and then click the **Run Script (F5)**.

    ```
     <copy>
      BEGIN
          DBMS_CLOUD_NOTIFICATION.SEND_DATA(
             provider => 'msteams',
             credential_name => 'TEAMS_CRED',
             query => 'SELECT tablespace_name FROM dba_tablespaces',
             params => json_object(
                'tenant'value '5b743bc******c0286',
                'team'value '0ae401*********5d2bd',
                'channel'value '19%3a94be023*****%40thread.tacv2',
                'title'value 'today',
                'type'value 'csv'));
        END;
     </copy>
    ```

    ![Open ADB](./images/send_results_query.png "")

    > **Note:** The maximum file size supported when using `DBMS_CLOUD_NOTIFICATION.SEND_DATA` for Microsoft Teams is `4MB`. For more information, see ['SEND_DATA Procedure'](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/autonomous-dbms-cloud-notification.html#GUID-B3375A5B-79B1-43A5-B043-A7FA646FBF54)

3. Go to your Teams channel, and confirm the receipt of the query result.

    ![Open ADB](./images/confirm_query_result.png "")

4. Repeat step 2 and substitute **json** into type value.

5. Copy and paste the following code into your SQL Worksheet, substitute previously specified parameters, and then click the **Run Script (F5)**.

    ```
     <copy>
      BEGIN
          DBMS_CLOUD_NOTIFICATION.SEND_DATA(
             provider => 'msteams',
             credential_name => 'TEAMS_CRED',
             query => 'SELECT tablespace_name FROM dba_tablespaces',
             params => json_object(
                'tenant'value '5b743bc******c0286',
                'team'value '0ae401*********5d2bd',
                'channel'value '19%3a94be023*****%40thread.tacv2',
                'title'value 'today',
                'type'value 'json'));
        END;
     </copy>
    ```

    ![Open ADB](./images/send-results-json.png "")

6. Go to your Teams channel, and confirm the receipt of the query result.

    ![Open ADB](./images/confirm-query-json.png "")

## Summary
You learned how to create  and configure a Microsoft app to receive messages and query results form Autonomous Database. Autonomous Database supports sending alerts,messages and query results directly to your channels to enhance productivity.

## Acknowledgements

+ **Author:** Yonca Aksit, User Assistance Developer Intern

+ **Contributors:**

    * Lauran K. Serhal, Consulting User Assistance Developer
    * Nilay Panchal, Principal Product Manager, Autonomous Database
    * Marty Gubar, Director of Product Management, Autonomous Database

+ **Last Updated By/Date:** Yonca Aksit, October 2024

Copyright (C) 2024 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
