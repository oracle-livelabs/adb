# Create and Authorize the Data Share Recipient

## Introduction

A data share recipient is an entity such as an individual, an institution, or a software system that receives a data share from a data share provider.A recipient can access the data in the share. A recipient can have access to multiple shares. If you remove a recipient, that recipient loses access to all shares it could previously access.

In this lab, as a data share provider, you will create and authorize a new recipient that will access the **`demo_live_share`** data share that you just published and the `custsales` table in this share. You will need the sharing ID that you saved from an earlier step.

![Recipient flow.](images/recipient-diagram.png =50%x*)

Estimated Time: 5 minutes

### Objectives

In this lab, you will:

* Create a new recipient.
* Grant the recipient access privileges to the data share.

### Prerequisites

This lab assumes that you have successfully completed all of the preceding labs in the **Contents** menu on the left.

## Task 1: Create a Data Share Recipient

1. As the **`share_provider`** user, create a new data share recipient named **`live_share_oracle_user`**.     
_**Important:** Copy and paste the following script into your SQL Worksheet; **however, don't run it yet**. Replace the text place holder in the script for the **`sharing_id`** argument with your own **sharing id** value that you obtained (and saved in a text editor file) in **Lab 2 > Task 2 > Step 2**_. Next, click the **Run Script** icon.

    ```
    <copy>
    BEGIN
        dbms_share.create_share_recipient
        (recipient_name=>'live_share_oracle_user',
        sharing_id=>'Enter your share provider user sharing id here'
        );
    END;
    /
    </copy>
    ```

    ![Create recipient.](images/create-recipient.png =65%x*)

2. Query the available recipients. Copy and paste the following script into your SQL Worksheet, and then click the **Run Statement** icon.

    ```
    <copy>
    SELECT recipient_name, updated
    FROM user_share_recipients
    ORDER BY 1;
    </copy>
    ```

    ![Query recipients.](images/query-recipients.png =65%x*)

## Task 2: Grant the Recipient Access Privileges to the Data Share

1. As the **`share_provider`** user, grant the new `live_share_oracle_user` recipient access to the `demo_live_share` data share. Copy and paste the following script into your SQL Worksheet, and then click the **Run Script** icon.

    ```
    <copy>
    BEGIN
        DBMS_SHARE.GRANT_TO_RECIPIENT(
            share_name=>'demo_live_share',
            recipient_name=> 'live_share_oracle_user');
            COMMIT;
    END;
    /
    </copy>
    ```

    ![Grant access to share.](images/grant-recipient-access.png =65%x*)

2. Determine the data shares to which the `live_share_oracle_user` recipient has access privileges. Copy and paste the following script into your SQL Worksheet, and then click the **Run Script** icon.

    ```
    <copy>
    SELECT recipient_name, share_name
    FROM user_share_recipient_grants
    WHERE recipient_name = 'LIVE_SHARE_ORACLE_USER'
    ORDER BY 1;
    </copy>
    ```

    ![Check recipient access privileges.](images/query-privileges.png =65%x*)

    The **`live_share_oracle_user`** recipient has access privileges to only one data share, **`demo_live_share`**.

You may now proceed to the next lab.

## Learn More

* [Oracle Cloud Infrastructure Documentation](https://docs.cloud.oracle.com/en-us/iaas/Content/GSG/Concepts/baremetalintro.htm)
* [Using Oracle Autonomous AI Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)

## Acknowledgements

* **Author:** Lauran K. Serhal, Consulting User Assistance Developer
* **Contributor:** Alexey Filanovskiy, Senior Principal Product Manager
* **Last Updated By/Date:** Lauran K. Serhal, December 2025


Data about movies in this workshop were sourced from Wikipedia.

Copyright (c) 2025, Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)