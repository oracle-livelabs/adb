# Create, Populate, and Publish a Data Share

## Introduction

A data share is a named entity in the provider’s instance. It can be a group of datasets shared as a single entity. The share is the logical container that contains objects such as tables that you will share with recipients. An authorized data share recipient can  access the share and all the tables in it.

In this lab, as a share provider user, you will create a data share and add a table to it. Next, you will create a new recipient that will have access to this data share. Finally, you will publish the data share and send the recipient the activation link needed to access the data share.

 ![Create a data share diagram.](images/data-share-diagram.png =55%x*)

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

* Create a new data share as the **`share_provider`** user.
* Add the **`customer_contact`** table from the previous lab to the data share.
* Create a new data share recipient named **`training_recipient`**.
* Publish the data share to make it available to authorized recipients.
* Share the data share activation link with the recipient to download the `delta_share_profile.json` configuration file.

### Prerequisites

* This lab assumes that you have successfully completed all of the preceding labs in the **Contents** menu on the left.

## Task 1: Navigate to Data Share

1. Make sure you are still logged in as the **share_provider** user. Click **Oracle Database Actions** in the banner to display the **Database Actions Launchpad** page.

    ![Click the banner.](./images/click-banner.png " ")

2. Click the **Data Studio** tab, and then click the **DATA SHARE** tab.

     ![Click the data share tile.](./images/click-data-share.png " ")

     >**Note:** If you do not see the **DATA SHARE** card in the **Data Studio** section, it indicates that your database user is missing the required **`DWROLE`** role.

     The **Provider and Consumer** page is displayed. The **PROVIDE SHARE** and the **CONSUME SHARE** tools enable you to create a data share as a share provider and to subscribe and consume a data share as a recipient respectively. You can click the [Quick Start Guide](https://docs.oracle.com/en/database/oracle/sql-developer-web/sdwfd/index.html) button to view step by step instructions on how to use Oracle Autonomous Database as a data share provider and as a data share recipient. For the complete Data Share documentation, see [The Data Share Tool](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/adp-data-share-tool.html#GUID-7EECE78B-336D-4853-BFC3-E78A7B8398DB). You can also try one of the available Data Sharing LiveLabs workshops.

    ![The Data Share Home page.](./images/data-share-home-page.png " ")

## Task 2: Create and Publish a Data Share

_**Important:**_    
_If you are using an **Always Free** ADB instance, you must run the following script in your SQL Worksheet as the **`share_provider`** user <u>before</u> you proceed with **step 1** below:_

```
<copy>
BEGIN
    DBMS_SHARE.UPDATE_DEFAULT_SHARE_PROPERTY('job_type', 'DBMS_CLOUD');
END;
/
</copy>
```

As the **`share_provider`** user, create a new data share named **`training_share`**.

1. To create a new data share, click the **PROVIDE SHARE** tool on the Home page. Alternatively, in the Navigation pane on the left, drill-down on the **Data Share** node, and then click **Provide Share**.

    ![Access provide share.](./images/access-provide-share.png " ")

2. On the **Provide Share** page, you must provide the details of the provider before you share the data. The share provider identification will be available to recipients with whom you grant the share. click **Provider Identification** to create a Provider ID to provide information to the recipient on how to identify you.

    ![Click provider information.](./images/click-provider-identification.png " ")

    The **Provider Identification** panel is displayed.

3. In the **General** tab, specify the following:

    * **Name:** Enter **`training_share`**.
    * **Email:** Enter the email address for the provider such as **`training_share@outlook.com`**.
    * **Description:** Enter a meaningful description of the provider (_required_).

    ![The General tab.](./images/provider-information.png " ")

4. Click **Save**. The **Provide Share** page is re-displayed. Initially, there are no data shares or recipients.

    ![The Provide Share page is displayed.](./images/provide-share-page-redisplayed.png " ")

5. Click **Create Share**. The **Create Share** wizard is displayed.

    ![Click create share.](./images/create-share-wizard.png " ")

6. On the **General** page, enter **`training_share`** as the name for the new share, an optional description, and then click **Next**.

    ![The general page.](./images/wizard-general.png " ")

7. On the **Publish Details** page, select the **`DELTA_SHARE_STORAGE`** credential that you created in the previous lab from the drop-down list, and then click **Next**.

    ![The publish details page.](./images/wizard-publish-details.png " ")

8. On the **Select Tables** page, add the **`CUSTOMER_CONTACT`** table that you created in the previous lab to the **`training_share`** data share. In the **Available Tables** section, click the table name, and then click the **Select** (>) icon.

    ![Add table to share.](images/add-table-to-share.png)

    The **`CUSTOMER_CONTACT`** table is added to the **Shared Tables** section. Click **Next**.

    ![The table is added.](images/table-added.png)

9. On the **Recipients** page, there are no recipients available initially. Create a new recipient that will consume this data share. Click **New Recipient**.

    ![Create a new recipient.](images/create-recipient.png)

10. In the **Create Share Recipient** panel, enter **`training_recipient`** as the name of the recipient, an optional description, and the recipient's email address. Next, click **Show Advanced Options**.

    ![Create the new recipient and show advanced options.](images/create-recipient-advanced-options.png =65%x*)

11. In the **User token lifetime** section, modify the **TOKEN_LIFETIME** for the **`training_user`** recipient to **90** days. This property specifies for how long the generated token will be valid after which the recipient loses access to the data share and must request a new token. Enter **90** in the first text field. Select **Days** from the drop-down menu. Next, click **Create** to create the new recipient.

    ![Create the new recipient.](images/click-create-recipient.png =65%x*)

12. The new recipient is displayed in the **Create Share** page.

    ![The recipient is created.](images/recipient-created.png =75%x*)

_Next, you will learn how to get the activation link that the recipient will need using two methods. In this lab, you'll use the activation link that is generated using the **second method**._

**Method 1**

13. Click the **Email recipient profile download link** icon to email the activation link to the recipient. 

    ![Click email recipient](images/email-recipient.png =70%x*)

    >**Note:** You can also click the **Copy Profile activation link to clipboard** icon as a backup in case the user didn't get the email.

    ![Copy activation link to clipboard.](images/copy-activation-link-clipboard.png =70%x*)

14. An email message that will be sent to the recipient is automatically generated and displayed. This email message contains the _personal authorization profile_ (activation link) URL that the recipient will use to download the **`delta_share_profile.json`** configuration file. This file is required to access the data share in the next lab. In our example, we are using Microsoft Outlook as the email client. Next, you would click **Send** to send the email to the recipient. _**Don't click the Send button. You will use the activation link generated using the second method next.**_

    ![Click send email.](images/activation-email.png)

    The recipient gets the email with the activation link. 

     ![Recipient recieves email.](images/recipient-activation-email.png)

15. In the **Create Share** wizard, click **Create** to create and publish the data share. The **Provide Share** page is displayed. Two information boxes are displayed briefly to indicate that the share is created and that publishing is in progress. The **training_share** is displayed along with its details such as the entity type, owner, shared objects, and the recipients. Note the status of the share is **Unpublished**. It will take a few minutes to publish it depending on the size of the table in the share.

    ![The data share is created.](images/share-created.png)

    If you click the **Reload** icon, the status of the publishing will be **share**, `share publish in process`.

    ![Share publish in process.](images/share-publish-in-process.png)

16. After a few minutes, click the **Reload** icon to refresh the page. The status of the **training_share** is now **Published**.

    ![The data share is published.](images/share-published.png)

17. Click the **RECIPIENTS** tile. The **`training_recipient`** is displayed along with its details.

    ![Click the recipients tile.](images/click-recipients-tile.png)

    When you publish a `versioned` share type, the tool generates and stores the data share as `parquet` files in the specified bucket such as `data-share-bucket` in our example. Any authenticated data share recipient can directly access the share in that bucket.

    ![Versioned share type.](images/versioned-share-type.png)

**Method 2**

18. In the **TRAINING_RECIPIENT** tile, click the **Actions** (ellipsis) icon and then select **Copy Profile Activation Link to Profile**. This is the activation link that the recipient will use. Save this activation link to a text editor of your choice as you will need it in the next lab.

    ![Method 2 activation link.](images/method2-activation-link.png)

19. Log out of the **`SHARE_PROVIDER`** user. On the **Oracle Database Actions | Data Share** banner, click the drop-down list next to the `SHARE_PROVIDER` user, and then select **Sign Out** from the drop-down menu. If you are prompted to leave, click **Leave**.

You may now proceed to the next lab.

## Learn More

* [The Share Tool](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/adp-data-share-tool.html#GUID-7EECE78B-336D-4853-BFC3-E78A7B8398DB)
* [Oracle Cloud Infrastructure Documentation](https://docs.cloud.oracle.com/en-us/iaas/Content/GSG/Concepts/baremetalintro.htm)
* [Using Oracle Autonomous Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)

## Acknowledgements

* **Author:** Lauran K. Serhal, Consulting User Assistance Developer
* **Contributor:** Alexey Filanovskiy, Senior Principal Product Manager
* **Last Updated By/Date:** Lauran K. Serhal, July 2025

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) 2025, Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
