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

    ![Click the banner.](./images/click-banner.png =65%x*)

2. Click the **Data Studio** tab, and then click the **DATA SHARE** tab.

     ![Click the data share tile.](./images/click-data-share.png =65%x*)

     >**Note:** If you do not see the **DATA SHARE** card in the **Data Studio** section, it indicates that your database user is missing the required **`DWROLE`** role.

     The **Provider and Consumer** page is displayed. The **PROVIDE SHARE** and the **CONSUME SHARE** tools enable you to create a data share as a share provider and to subscribe and consume a data share as a recipient respectively. You can click the [Quick Start Guide](https://docs.oracle.com/en/database/oracle/sql-developer-web/sdwfd/index.html) button to view step by step instructions on how to use Oracle Autonomous AI Database as a data share provider and as a data share recipient. For the complete Data Share documentation, see [The Data Share Tool](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/adp-data-share-tool.html#GUID-7EECE78B-336D-4853-BFC3-E78A7B8398DB). You can also try one of the available Data Sharing LiveLabs workshops.

    ![The Data Share Home page.](./images/data-share-home-page.png =65%x*)

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

    ![Access provide share.](./images/access-provide-share.png =65%x*)

2. On the **Provide Share** page, you must provide the details of the provider before you share the data. The share provider identification will be available to recipients with whom you grant the share. click **Provider Identification** to create a Provider ID to provide information to the recipient on how to identify you.

    ![Click provider information.](./images/click-provider-identification.png =65%x*)

    The **Data Studio Settings** panel is displayed.

3. In the **Share Provider Identity** tab, specify the following:

    * **Name:** Enter **`training_share`**.
    * **Email:** Enter the email address for the provider such as **`training_share@outlook.com`**.
    * **Description:** Enter a meaningful description of the provider (_required_).

        ![The General tab.](./images/provider-information.png =65%x*)

4. Click **Save**, and then click **Close**. The **Provide Share** page is re-displayed. Initially, there are no data shares or recipients.

    ![The Provide Share page is displayed.](./images/provide-share-page-redisplayed.png =65%x*)

5. Click **Create Share**. The **Create Share** wizard is displayed.

    ![Click create share.](./images/create-share-wizard.png =65%x*)

6. On the **General** page, enter **`training_share`** as the name for the new share, an optional description, and then click **Next**.

    ![The general page.](./images/wizard-general.png =65%x*)

7. On the **Publish Details** page, select the **`DELTA_SHARE_STORAGE`** credential that you created in the previous lab from the drop-down list, and then click **Next**.

    ![The publish details page.](./images/wizard-publish-details.png =65%x*)

8. On the **Select Tables** page, add the **`CUSTOMER_CONTACT`** table that you created in the previous lab to the **`training_share`** data share. In the **Available Tables** section, click the table name, and then click the **Select** (>) icon.

    ![Add table to share.](images/add-table-to-share.png =65%x*)

    The **`CUSTOMER_CONTACT`** table is added to the **Shared Tables** section. Click **Next**.

    ![The table is added.](images/table-added.png =65%x*)

9. On the **Recipients** page, there are no recipients available initially. Create a new recipient that will consume this data share. Click **New Recipient**.

    ![Create a new recipient.](images/create-recipient.png =65%x*)

10. In the **Create Share Recipient** panel, enter **`training_recipient`** as the name of the recipient, an optional description, and the recipient's email address. Next, click **Show Advanced Options**.

    ![Create the new recipient and show advanced options.](images/create-recipient-advanced-options.png =50%x*)

11. In the **User token lifetime** section, modify the **TOKEN_LIFETIME** for the **`training_user`** recipient to **90** days. This property specifies for how long the generated token will be valid after which the recipient loses access to the data share and must request a new token. Select **Days** from the drop-down menu. Enter **90** in the first text field.

    ![Create the new recipient.](images/click-create-recipient.png =50%x*)

12. Click **Create** to create the new recipient. The new recipient is displayed in the **Create Share** page.

    ![The recipient is created.](images/recipient-created-new.png =75%x*)

    You as the **`share_provider`** user, will share the activation link to download the `delta_share_profile.json` configuration file with the **`training_recipient`** user. This file contains the required credentials that the user will need to connect to the data share and access the **`CUSTOMER_CONTACT_SHARE`** table in the share. 

    You can provide the activation link to the **`training_recipient`** user using _one of the following four methods; **however, we will be using the method described in step c; therefore, don't try the other methods**_: 

    **a.** Click the **Copy profile activation link to clipboard** icon, paste the URL in a text editor of your choice such as Notepad on a Windows machine, and then share with the **`training_recipient`** user. This can be used as a backup in case the user didn't get the email, or   

    **b.** Click the **Email recipient profile down link** icon to generate an email with the profile activation URL. Next, you send this email to the **`training_recipient`** user, or

    **c.** Click **Create** on the **Create Share** wizard. This will create and publish the share. In addition, it will automatically generate and display an email message with the profile activation URL. Next, you send this email to the **`training_recipient`** user. that you can send to the **`training_recipient`** user. **_In this lab, we will use this method next._**. 

    **d.** In the **`TRAINING_RECIPIENT`** tile, click the **Actions** (ellipsis) icon and then select **Copy Profile Activation Link to Clipboard** or **Send Activation Mail**. This is the activation link that the recipient will use. Save this activation link to a text editor of your choice. **_Use this method if the activation email is not generated for you. This method is described in step 17 below._**

13. Click **Create** to create and publish the data share and to also generate the email. The **Provide Share** page is displayed and the new **`training_share`** user is displayed. Initially, the status of the share is **Unpublished**. It will take a few minutes to publish it depending on the size of the table in the share.

    ![The data share is created.](images/share-created.png =65%x*)

 14. After a few minutes, click the **Reload** icon to refresh the page. The status of the **training_share** changes to **Published**.

    ![The data share is published.](images/share-published.png =65%x*)

    When you publish a `versioned` share type, the tool generates and stores the data share as `parquet` files in the specified bucket such as `data-share-bucket` in our example. Any authenticated data share recipient can directly access the share in that bucket.

    ![Versioned share type.](images/versioned-share-type.png =65%x*)

15. As mentioned earlier, an email message that will be sent to the recipient was automatically generated and displayed. This email message contains the _personal authorization profile_ (activation link) URL that the recipient will use to download the **`delta_share_profile.json`** configuration file. This file is required to access the data share in the next lab. In our example, we are using Microsoft Outlook as the email client. 

    ![Click send email.](images/activation-email-new.png =65%x*)

    >**Important:** If the email message is not automatically displayed, you can still get the activation link or generate the email using 

16. Click **Send** to send the email to the recipient. The recipient gets the email with the activation link. 

     ![Recipient receives email.](images/recipient-activation-email.png =65%x*)

17. Click the **RECIPIENTS** tile. The **`training_recipient`** is displayed along with its details.

    ![Click the Actions icon.](images/click-actions-icon.png =65%x*)  

   Remember, you can get the activation profile link if you didn't do that earlier or if the email was not automatically generated. Click the **Actions** (ellipsis) icon. From the context menu, click **Copy Profile Activation Link to Clipboard** or **Send activation email**. 

    ![Click copy profile activation link.](images/click-activation-link.png =65%x*)

    You can now paste this link in a text editor of your choice and then share it with your recipient.

18. Log out of the **`SHARE_PROVIDER`** user. On the **Oracle Database Actions | Data Share** banner, click the drop-down list next to the `SHARE_PROVIDER` user, and then select **Sign Out** from the drop-down menu. If you are prompted to leave, click **Leave**.

You may now proceed to the next lab.

## Learn More

* [The Share Tool](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/adp-data-share-tool.html#GUID-7EECE78B-336D-4853-BFC3-E78A7B8398DB)
* [Oracle Cloud Infrastructure Documentation](https://docs.cloud.oracle.com/en-us/iaas/Content/GSG/Concepts/baremetalintro.htm)
* [Using Oracle Autonomous AI Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)

## Acknowledgements

* **Author:** Lauran K. Serhal, Consulting User Assistance Developer
* **Contributor:** Alexey Filanovskiy, Senior Principal Product Manager
* **Last Updated By/Date:** Lauran K. Serhal, November 2025

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) 2025, Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
