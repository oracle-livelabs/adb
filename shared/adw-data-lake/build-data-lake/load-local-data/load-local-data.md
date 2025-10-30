# Load Data from Local Files

## Introduction

In this lab, you will practice multiple methods for loading and linking to data into an Oracle Autonomous AI Database (either Oracle Autonomous AI Lakehouse or Oracle Autonomous AI Transaction Processing) using the Oracle Autonomous AI Database built-in Database Action tools, or using other Oracle and third party data integration tools.

You can also leave data in place in cloud object storage, and link to it from your Autonomous AI Database.

> **Note:** While this lab uses Oracle Autonomous AI Lakehouse, the steps are identical for loading data into an Oracle Autonomous AI Transaction Processing database.

Estimated Time: 10 minutes

Watch the video below for a quick walk-through of the lab.

[](youtube:B9iWOaO4RG0)

### Objectives

In this lab, you will:
* Download two **.csv** data files to your local computer from the MovieStream data lake (Oracle Object Storage buckets).
* Navigate to the Data Load utility of Oracle Autonomous AI Database Data Tools.
* Load data from the .csv files to your Oracle Autonomous AI Database instance.

### Prerequisites

This lab requires the completion of **Lab 1: Set up the Workshop Environment > Task 2: Provision the Autonomous AI Database Instance**, from the **Contents** menu on the left.

<!-- Begin liveLabs section of task -->

<if type="livelabs">

## Task 1: Launch the Workshop and Log in to the Oracle Cloud Console

_If you already launched the workshop and logged in to the Console using the instructions in the **Get Started with LiveLabs** lab, you can skip this task and proceed to **Task 2**; otherwise, start with **step 1** below._

1. On the LiveLabs Home page, click the **My Reservations** tab to display your reserved workshop on the **My Reservations** page. To start the workshop, click the **Launch Workshop** link.

    ![The My Reservations tab and the Launch Workshop link for a sample workshop are highlighted.](./images/my-reservations.png " ")

    The workshop is displayed in a new tab named **Run Workshop - Build a Data Lake with Autonomous AI Database**. Click the **View Login Info** link in the banner.

    ![Click View Login Info.](./images/ll-view-login-info.png " ")

     The **Reservation Information** panel is displayed. This displays important information that you will need throughout this workshop.

    ![The Workshop is displayed.](./images/ll-reservation-information.png " ")

2. Click **Copy Password** to copy your initial password, and then click **Launch OCI**.

3. On the Sign In page, in the **Oracle Cloud Infrastructure Direct Sign-In** section, your assigned username is already displayed in the **User Name** field. Paste your password in the **Password** field, and then click **Sign In**.

    ![The Oracle Cloud Infrastructure Direct Sign-In section with the populated username and password is displayed. The Sign In button is highlighted.](./images/ll-signin.png " ")

4. The **Change Password** dialog box is displayed. Paste your assigned password that you copied in the **Current Password**. Enter a new password in the **New Password** and **Confirm New Password** fields, and then click **Save New Password**. Make a note of your new password as you will need it in this workshop.

    ![The completed Change Password dialog box is displayed. The Save New Password button is highlighted.](./images/ll-change-password.png " ")

    The **Oracle Cloud Console** Home page is displayed. Make sure that the displayed region is the same that was assigned to you in the **Reservation Information** panel of the **Run Workshop *workshop-name*** page, **Canada Southeast (Toronto)** in this example.

    ![The Oracle Cloud Console Home page is displayed with the LiveLabs assigned region highlighted.](images/console-home.png)

    >**Note:** Bookmark the workshop page for quicker access.
</if>

<!-- Begin freetier section of the task -->
<if type="freetier">

## Task 1: Log in to the Oracle Cloud Console

1. Log in to the **Oracle Cloud Console**, if you are not already logged as the Cloud Administrator. You will complete all the labs in this workshop using this Cloud Administrator. On the **Sign In** page, select your tenancy, enter your username and password, and then click **Sign In**. The **Oracle Cloud Console** Home page is displayed.

</if>

## Task 2: Download .csv Files from the MovieStream Data Lake to your Local Computer

Oracle MovieStream is a fictitious movie streaming service - similar to those that to which you currently subscribe. MovieStream is storing (and linking to) their data across Oracle Object Storage and Oracle Autonomous AI Database. Data is captured from various sources into a landing zone in object storage. This data is then processed (cleansed, transformed and optimized) and stored in a gold zone on object storage. Once the data is curated, it is loaded into an Oracle Autonomous AI Database where it is analyzed by many (and varied) members of the user community.

1. Right-click on each of the links below, and then click **Save link as...** from the context menu to download the files to a folder on your local computer.

    * [Download customer\_segment.csv](https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/moviestream_landing/o/customer_segment/customer_segment.csv)
    * [Download customer-extension.csv](https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/moviestream_landing/o/customer_extension/customer-extension.csv)

2. Close the Excel files and make a note of your folder location as you will use the two downloaded files in a later task in this lab.

## Task 3: Navigate to the Data Load Page

<if type="livelabs">
Your green button reservation includes an ADB instance. You can find the required credentials in the **Reservation Information** dialog box for your reservation. To log in to the Console, click the **Launch OCI** button in the **Reservation Information** dialog box, and then follow the prompts to reset your assigned password. 

 ![The Reservation Information dialog box.](./images/ll-reservation-information.png =75%x*)
</if>

1. Log in to the **Oracle Cloud Console**, if you are not already logged in; otherwise, skip to step 4.

2. Open the **Navigation** menu and click **Oracle AI Database**. Under **Oracle AI Database**, click **Autonomous AI Database**.

<if type="livelabs">
    > **_Important:** At the time of updating this workshop (July 15, 2025), there was a known issue with some OCI regions and using the sandbox environment reservations (the green button). The old Autonomous Databases UI (brown) page is displayed instead of the new Redwood UI page. If the new Redwood UI page is displayed in your environment, please ignore this note and continue with the note about the **Couldn't load data** error below._

    ![The old Autonomous Databases page.](images/old-adb-page.png =75%x*)

    To correct this issue, simply click **Reload this page** icon in your browser. The newly designed **Autonomous Databases** page is displayed. 
    
    >**Note:** The **Couldn't load data** error on the page is due to being in the wrong compartment. You will learn how to navigate to your assigned compartment next. 

    ![Forbidden error.](images/forbidden-error.png =75%x*)

    OCI resources are organized into compartments. To navigate to your assigned sandbox reservation compartment, click the **Compartment** field. Next, enter your assigned compartment name (or partial name) from the **Reservation Information** page in the **Compartment** text box. Once your assigned compartment is displayed in the drop-down list under the **`Livelabs`** node, click it.
    
    ![Select your assigned compartment.](images/ll-select-compartment.png =65%x*)

    >**Note:** For more details on finding your assigned resources in your reservation such as the username, password, compartment and so on, review the **Get Started with LiveLabs** lab in the Navigation menu on the left.

    
</if>

3. On the **Autonomous AI Databases** page, click your **ADW-Data-Lake** ADB instance.

    <if type="freetier">
    ![The Autonomous AI Database is displayed and highlighted.](./images/adb-page.png =75%x*)
    </if>

    <if type="livelabs">
    ![The Autonomous AI Database is displayed and highlighted.](./images/ll-adb-page.png =75%x*)

    >**Note:** Since you are using a Sandbox environment, an ADB instance was created for you. To view the ADB instance details, click the **View Login Info** link to display the **Reservation Information** dialog box. The database admin password, database name, and database display name are displayed.

    </if>

4. On the **ADW-Data-Lake** Autonomous AI Database page, click the **Database actions** drop-down list, and then click **Data Load**.

    ![On the partial Autonomous AI Database Details page, the Database Actions button is highlighted.](./images/click-db-actions.png " ")

5. The **Data Load** Home page is displayed in a _**new tab in your browser**_.

    ![The Data Load Home page is displayed.](./images/data-load-home.png " ")

    >**Note:** You can close the **No Credential and AI Profile Found** section.

</if>

<if type="freetier">

1. Log in to the **Oracle Cloud Console**, if you are not already logged as the Cloud Administrator.

2. Open the **Navigation** menu and click **Oracle Database**. Under **Oracle Database**, click **Autonomous AI Database**.

3. On the **Autonomous AI Databases** page, click your **ADW-Data-Lake** ADB instance.
    ![The Autonomous AI Database is displayed and highlighted.](./images/adb-page.png " ")

4. On the **Autonomous AI Database details** page, click the **Database actions** drop-down list, and then click **Data Load**.

    ![On the partial Autonomous AI Database Details page, the Database Actions button is highlighted.](./images/click-db-actions.png " ")

5. The **Data Load** Home page is displayed in a _**new tab in your browser**_.

    ![The Data Load Home page is displayed.](./images/data-load-home.png " ")

6. Close the **No Credential and AI Profile Found** section. Click the **X** control.

</if>

## Task 4: Load Data from the CSV Files Using the LOAD DATA Tool

In this task you will load the two .csv files that you downloaded earlier into two different tables in your Autonomous AI Database instance.

1. On the **Data Load** page, click the **Load Data** card.

2. On the **Load Data** page, the **Local File** button is selected by default. In the **Load data from local files** section, you can either drag and drop files to upload, or click **Select Files** to select the files to upload. Click **Select Files**.

    ![Select LOAD DATA and LOCAL FILE and click Next.](./images/select-load-data-and-local-file.png " ")

3. In the **Open** dialog box, navigate to the directory that contains the two **.csv** files that you downloaded earlier. Select the **`customer_segment.csv`** and **`customer_extension.csv`** files, and then click **Open**.

    ![Select the two files.](./images/open-dialog-box.png " ")

    >**Note:** If you have an issue uploading both files simultaneously, you can select one file at a time. Select the first downloaded file using step 3. When the file is uploaded, click the **Select Files** icon on the **Load Data** page, and then select the second file.

4. When the upload is complete, you will make a small change to the default table name that will be created for the **`customer-extension.csv`** file. Click the **Settings** (pencil) icon to the right of **`customer-extension.csv`**.

    ![Update the data load job settings.](./images/click-settings.png " ")

5. The **Load Data from Local File customer-extension.csv** page is displayed. Take a moment to examine the settings. The tool makes intelligent choices for target table name and its properties. Since this is an initial load, accept the default option of **Create Table** to create the target table in your Autonomous AI Database. In the mappings section, you can change the target column names, data types, and length/precision.

    ![Examine the editor of the data load job.](./images/preview-table.png " ")

6. In the **Name** field, change the table name that will be created from **`CUSTOMEREXTENSION`** to **`CUSTOMER_EXTENSION`**. Click **Close** in the lower right corner of the page.

    ![Examine the editor of the data load job.](./images/change-table-name.png " ")

7. Click **Start**. A **Start Load from Local Files** confirmation dialog box is displayed. Click **Run**.

    ![Click Start to run the data load.](./images/click-start.png " ")

    ![Click run.](./images/click-run.png =65%x*)

8. After the load job is completed, make sure that the data load card has the copy icon next to it. You can click the **Report** button for the load job to view a report of total rows processed successfully and failed for the selected table.

    ![The data load icons are displayed.](./images/load-successful.png " ")

9. You can click a table name to display its data. In this example, click the **ellipsis** icon for the **`CUSTOMER_SEGMENT`** load task to view its settings among other things. Next, click **Table > View Details** from the context menu.

    ![Click customer_segment to display its data.](./images/preview-customer-segment.png " ")

10. The **Preview** tab is selected by default. This shows the **`CUSTOMER_SEGMENT`** data.

    ![The customer_segment data.](./images/customer-segment-data.png " ")

10. When finished, click **Close** to return to the Data Load Dashboard.

    ![Click Close.](./images/data-load-dashboard.png " ")

This completes the lab on loading .csv files from your local computer to new tables in your ADB instance.

You may now proceed to the next lab.

## Learn More

* [Oracle Cloud Infrastructure Documentation](https://docs.cloud.oracle.com/en-us/iaas/Content/GSG/Concepts/baremetalintro.htm)
* [Using Oracle Autonomous AI Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)

## Acknowledgements

* **Author:** Lauran K. Serhal, Consulting User Assistance Developer
* **Contributors:**
    * Mike Matthews, Autonomous AI Database Product Management
* **Last Updated By/Date:** Lauran K. Serhal, October 2025

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) 2025 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
