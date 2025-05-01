# Configure the Slack Application

**Important:** This lab uses features which are not available on the Oracle LiveLabs Sandbox hosted environments (the Green button), and requires Slack admin permissions.

## Introduction

Slack, a leading collaboration tool, enables teams with the ability to have seamless communication and efficient data management. Slack has cool integrations with external apps and sources.

This lab walks you through the steps to create your Slack application and channel to receive messages, alerts, and the output of a query from an Autonomous Database.

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

+ Create your Slack application
+ Configure your Slack application
+ Create your Slack channel

### Prerequisites

+ Completion of the lab **Get Started** from the **Contents** menu on the left.
+ Slack account and workspace
+ Slack app
+ Slack channel

> **Note:** A Slack workspace is made up of channels, where team members can communicate and work together. To join a workspace, you can [create a Slack account](https://slack.com/get-started#/createnew) using your email address.

## Task 1: Create Your Slack application

1. To create a Slack application, click [this link](https://api.slack.com/apps) to access the **Your Apps** page, and select **Create an App**.

    ![Open ADB](./images/create-a-new-app.png "")

    > **Note:** Please bookmark the [Your Apps](https://api.slack.com/apps) link as you will need it for future tasks.

2. Select **From scratch**.

    ![Open ADB](./images/select-from-scratch.png "")

3. Enter your **App Name**, select your **Workspace**, and then click **Create App**.

    ![Open ADB](./images/select-appname.png "")

    > **Note:** To create a Slack app successfully, you must select your preferred workspace as shown in the previous screen capture. After creating your app, you need to have your Slack admin approve your application.

4. Under the **Settings** section, you will see the **Basic Information** page after creating your Slack app. You can update your information, and then click **Save Changes** or you can click **Discard Changes** not to apply changes.

    ![Open ADB](./images/see-basic-information.png "")

5. At the bottom of the **Basic Information** page, you will see **Delete App** section. If you want to delete your Slack app, you can click **Delete App**.

    ![Open ADB](./images/delete-slack-app.png "")

## Task 2: Configure your Slack application

After creating your application, you must request scopes which will grant your application permissions to perform actions such as viewing basic information, posting messages, and uploading files in your selected workspace.

These following scopes are  required:

+ **channels:read**

    This permission scope will enable you to view basic information about public channels in your workspace. For more information, see [channels:read](https://api.slack.com/scopes/channels:read).
+ **chat:write**

    This permission scope will enable you to post messages in approved channels and conversations. For more information, see [chat:write](https://api.slack.com/scopes/chat:write).
+ **files:write**

    This permission scope will enable you to upload, edit, and delete files from your Slack app. For more information, see [files:write](https://api.slack.com/scopes/files:write).

1. Go to [Your Apps](https://api.slack.com/apps), and then click your **App Name**.

    ![Open ADB](./images/click-app-name.png "")

2. Scroll down to the **Features** section, and click **OAuth & Permissions**.

    ![Open ADB](./images/click-oa-permissions.png "")

3. Scroll down to the **Scopes** section, and then click **Add an OAuth Scope**.

    ![Open ADB](./images/click-add-scope.png "")

4. For OAuth Scope, enter **channels:read**, and then select **channels:read** from dropdown. This scope allows your app to access public Slack channels.

    ![Open ADB](./images/enter-channels-read.png "")

5. If successful, you will see the recently added **OAuth Scope** with the **Description**.

    ![Open ADB](./images/added-scope.png "")

6. Repeat step 4, to add the scopes **chat:write** and  **files:write** to your application as well.

    ![Open ADB](./images/added-scopes.png "")

7. After adding scopes, scroll up to the **OAuth Tokens** section, and then click **Request to Install**.

    ![Open ADB](./images/request-to-install.png "")

8. To request to install your application, add an **optional message** for your Slack admin, and then click **Submit Request**.

    ![Open ADB](./images/request-info-install.png "")

9. After submitting request, you will see the following message as shown in the screen capture.

    ![Open ADB](./images/oauth-tokens.png "")

    > **Note:** Have your Slack admin grant you access to install your Slack application in your workspace to proceed with the following tasks in this lab.

## Task 3: Create a  Slack channel

For this task, you will use **`DBMS_CLOUD_NOTIFICATION`** package which enables you to send messages, and the output of query to the supported providers. For more information, see [`DBMS_CLOUD_NOTIFICATION`](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/autonomous-dbms-cloud-notification.html#GUID-F3347243-2C65-4E9A-84AA-5FA93200058F) package.

You will learn how to add your Slack app to your channel so that you can send message through the **Integrations** in the channel by using the **`DBMS_CLOUD_NOTIFICATION`** procedure.

1. Open the Slack app, click the plus icon next to **Add channels**, and then select **Create a new channel**.

    ![Open ADB](./images/create-new-channel.png "")

2. Select your workspace, and click **Next**.

    ![Open ADB](./images/click-next.png "")

3. Enter a **Name** for your channel, and then click **Next**.

    ![Open ADB](./images/click-next2.png "")

4. Select the **Visibility** of your channel based on your preference, and then click **Create**.

    ![Open ADB](./images/create-channel.png "")

5. If you can want to add people to your new channel, enter the **username or email** address, and then click **Add**. Click **Skip for now**.

   ![Open ADB](./images/add-people-to-ch.png "")

6. If successful, you will see your channel in your workspace. Click the arrow icon next to your **Channel name**.

    ![Open ADB](./images/overview-channel.png "")

7. Select **Integrations**.

    ![Open ADB](./images/select-integrations.png "")

8. Click **Add an App** to integrate the application into your channel.

    ![Open ADB](./images/add-an-app.png "")

9. Enter your Slack app name in the **Search** field. Select your workspace from the drop-down list. Click your desired application from the **In your workspace** section, and then click **Add**.

    ![Open ADB](./images/select-add.png "")

    > **Note:** Have your Slack admin grant you access to install your Slack application in your workspace to proceed with the following tasks in this lab.

   **ADBS Notifications** is an internal Slack app developed for sending notifications from Autonomous Database to Slack channels. Due to restrictions, the Slack app (Slack-ADB) created in Task 2, Step 3, cannot be installed in the workspace. Therefore, an existing app is being used to test in this workshop.

    The Slack app uses the Slack Web API to communicate with an Autonomous Database. The Slack Web API is an interface for making changes and retrieving information from a Slack workplace. For more information, see [Using the Slack Web API](https://api.slack.com/web).

10. If successful, you will receive a message as shown in the screen capture below.

    ![Open ADB](./images/app-added-channel.png "")

## Summary

You learned how to create a Slack app and a Slack channel to receive messages and query results from Autonomous Database. Autonomous Database supports sending alerts,messages and query results directly to your channels to enhance productivity. Next, let's see how to create Microsoft Teams application and channel.

You may now **proceed to the next lab**.

## Acknowledgements

+ **Author:** Yonca Aksit, User Assistance Developer Intern

+ **Contributors:**

    * Lauran K. Serhal, Consulting User Assistance Developer
    * Marty Gubar, Director of Product Management, Autonomous Database

+ **Last Updated By/Date:** Yonca Aksit, October 2024

Copyright (C) 2024 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
