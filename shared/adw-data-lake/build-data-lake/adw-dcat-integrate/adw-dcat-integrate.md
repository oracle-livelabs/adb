# Integrate ADW with Centrally Managed Data Catalogs

## Introduction

In this lab, you will learn how to connect an OCI Data Catalog instance to ADW and then load some tables from your Data Catalog into your ADW.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

* Navigate to your OCI Data Catalog and review data assets and logical entities.
* Register your Data Catalog instance in ADW.
* Link to data assets in the registered Data Catalog and create external tables.

### Prerequisites

This lab requires the completion of the following labs/tasks from the **Contents** menu on the left:

* **Lab 1**: Set up the Workshop Environment > **Task 3**: Create an Autonomous Data Warehouse Instance and **Task 4**: (Optional) Create a Data Catalog Instance. If you don't have a Data Catalog instance installed, you can simply follow the instructions in this lab.
* **Lab 4**: Link to Data in Public Object Storage Buckets > **Task 2**: Link to Data in Public Object Storage Buckets and Create Tables.

## Task 1: Navigate to the OCI Data Catalog Page

This is not a hands-on task. In this task, you will navigate to an OCI Data Catalog instance and explore a data asset named Data Lake. This data asset contains entities that were harvested from three Oracle Object Storage buckets. In the next task, you will connect to this Data Catalog instance from within ADW and link to some data assets to create external tables.

1. Log in to the **Oracle Cloud Console**. On the **Sign In** page, select your tenancy, enter your username and password, and then click **Sign In**. The **Oracle Cloud Console** Home page is displayed.

2. Open the **Navigation** menu and click **Analytics & AI**. Under **Data Lake**, click **Data Catalog**.

3. On the **Data Catalog Overview** page, click **Go to Data Catalogs**.

    ![The Go to Data Catalogs button is highlighted.](./images/data-catalog-overview.png " ")

4. On the **Data Catalogs** page, click the **`training-dcat-instance`** Data Catalog instance. In our example, this instance contains a data asset.

    ![In the Name column, the training-dcat-instance link is highlighted.](./images/click-data-catalog.png " ")

    **Note:** In our example, the Data Catalog instance is in a different compartment than where our ADW instance is located; therefore, make sure you are in the correct compartment when you access your Data Catalog and ADW instances; otherwise, you won't see the resources that you created in this workshop.

5. On the Data Catalog instance **Home** tab, click **Data assets** link.

    ![The Data Assets tab and Data Lake data asset are highlighted.](./images/data-assets-link.png " ")

6. In the **Data assets** tab, click your desired data asset, **Data Lake** in our example.

    ![The Data Assets tab and Data Lake data asset are highlighted.](./images/data-assets-tab.png " ")

7. In the **Data assets** list, click the **Data Lake** data asset. The **Oracle Object Storage: Data Lake** page is displayed. Three buckets were harvested in this data asset.

    ![The three buckets in the Data Lake asset are displayed.](./images/buckets-displayed.png " ")

8. Click the **Sandbox** bucket link. The **Bucket: Sandbox** page is displayed. Let's view the data entities in this bucket. Click the **Data entities** tab. The bucket contains three data entities.

    ![The data entities in the bucket are displayed.](./images/data-entities-sandbox.png " ")

    In the this workshop, you will learn how to access those data entities from within ADW.

## Task 2: Register your Data Catalog Instance in ADW

In this task, you will learn how to register an OCI Data Catalog instance in ADW in order to connect to that instance and link to the data asset's entities to create external tables in ADW.

1. Log in to the **Oracle Cloud Console**, if you are not already logged as the Cloud Administrator.

2. Open the **Navigation** menu and click **Oracle Database**. Under **Oracle Database**, click **Autonomous Database**.

3. On the **Autonomous Databases** page, make sure that you are in the correct compartment, and then click your **ADW-Data-Lake** ADB instance.

    **Note:** If your Data Catalog and ADW instances are in different compartments like in our example, you must select the correct compartment for your ADW instance; otherwise, you won't see the resources that you created in this workshop such as the credential and cloud store locations.

    ![Verify compartment and then click the ADW instance.](./images/select-compartment.png " ")

4. On the **Autonomous Database details** page, click **Database actions**.

5. In the **Database Actions | Launchpad** Home page, in the **Data Studio** section, click the **DATA LOAD** card.

6. In the **Administration** section, click **CLOUD LOCATIONS**, and then click **Next**.

    ![Click the Cloud Locations card.](./images/click-cloud-locations.png " ")

7. On the **Manage Cloud Store** page, click **Register Data Catalog**.

    ![Click Register Data Catalog.](./images/click-register-data-catalog.png " ")

8. In the **Register Data Catalog** panel, in **Step 1** of the wizard, **Catalog Settings**, specify the following:

    * **Catalog Name:** Enter a meaningful name. **Note:** The name must conform to the Oracle object naming conventions, which do not allow spaces or **hyphens**.
    * **Description:** Enter an optional description.
    * **Select Credential:** Select this check box (default). Select your credential that you created in **Lab 5 > Task 6**, **`OBJ_STORAGE_CRED`**.
    * **Region:** Your region should be already selected after you chose your credential.
    * **Data Catalog ID:** If you have several Data Catalog instances, select the Data Catalog instance that you want to register from the drop-down list.

        ![The completed Register Data Catalog panel is displayed.](./images/register-data-catalog-panel.png " ")

9. Click **Next**. **Step 2** of the wizard, **Register Assets** is displayed. By default, all the buckets in your selected Data Catalog instance are selected, along with data assets they contain. Drill-down (expand) the **moviestream_sandbox** bucket. This bucket contains three data assets. Those are the same data entities that you saw earlier in the Data Catalog instance in **Task 1**.

    ![Step 2 of the wizard is displayed.](./images/register-assets-wizard-2.png " ")

10. Keep the **moviestream\_sandbox** bucket checked; however, uncheck the **moviestream\_landing** and **moviestream\_gold** buckets, and then click **Create** to register the Data Catalog instance.

    ![Click Create to register the Data Catalog instance.](./images/click-create.png " ")

    The **Manage Cloud Store** page is re-displayed. The newly registered Data Catalog instance is displayed.

    ![Click Create to register the Data Catalog instance.](./images/data-catalog-registered.png " ")

## Task 3: Link to Data Assets in the Registered Data Catalog and Create External Tables

In this task, you will link to data assets from the registered Data Catalog and create two external tables in your Autonomous Database instance based on those data assets.

1. Click **Oracle Database Actions** in the banner to display the Launchpad landing page.

    ![Click Oracle Database Actions.](images/click-database-actions.png)

2. In the **Data Studio**, click **DATA LOAD**.

3. In the **What do you want to do with your data?** section, click **LINK DATA**.

4. In the **Where is your data?** section, select **CLOUD STORE**, and then click **Next**.

    ![Select Link Data and Cloud Store.](images/select-link-data-from-cloud-store.png)

5. The **Link Cloud Object** page is displayed. Use this page to drag and drop tables from the registered Data Catalog instance to the data linking job area.

    ![Drag the data assets from the Data Catalog bucket onto the linking job section.](images/drag-and-drop-assets.png)

6. Drag the **`customer_promotions`** and **`moviestream_churn`** data assets from the **moviestream\_sandbox** bucket in our Data Catalog instance, and drop them onto the data linking job section.

     ![Click the pencil icon to open settings viewer for customer_contact load task](images/customer-promotions-settings.png)

7. Let's change the default name for the **`customer_promotions`** external table that will be created. Click the **Actions** icon (3-dot vertical ellipsis) for the **`customer_promotions`** link task, and then select **Settings** from the context menu. The **Link Data from Cloud Store Location customer\_promotions** settings panel is displayed. Change the external table name to **`CUSTOMER_PROMOTIONS_DCAT`**, and then click **Close**.

    ![Change name of the external table.](images/customer-promotions-dcat.png)

8. Let's change the default name for the **`moviestream_churn`** external table that will be created. Click the **Actions** icon (3-dot vertical ellipsis) for the **`moviestream_churn`** link task, and then select **Settings** from the context menu to view the settings for this task. The **Link Data from Cloud Store Location moviestream\_churn** settings panel is displayed. Change the name of the external table name to **`MOVIESTREAM_CHURN_DCAT`**, and then click **Close**.

9. Click **Start** to run the data link job. In the **Run Data Load Job** dialog box, click **Run**.

    ![Run the data link job](images/run-data-link.png)

10. After the load job is completed, make sure that all of the data link cards have green check marks next to them. This indicates that your data link tasks have completed successfully.

    ![The Link job tasks completed.](images/link-completed.png)

11. Click **Oracle Database Actions** in the banner to display the Launchpad landing page. In the **Development** section, click **SQL** to display your SQL Worksheet.

12. From the **Navigator** pane, drag and drop the newly created **`CUSTOMERS_PROMOTIONS_DCAT`** external table onto the Worksheet. In the **Choose Type of insertion**, click **Select**, and then click **Apply**.

    ![Drag and drop the external table onto the worksheet.](images/drag-drop-external-table.png)

13. The auto generated query is displayed in the worksheet. Click the **Run Statement** icon to run the query. The results are displayed. You just accessed the data in the registered Data Catalog instance!

    ![Run the query.](images/run-query.png)

    You can also query the **`MOVIESTREAM_CHURN_DCAT`** external table.

 You may now proceed to the next lab.

## Learn more

* [DBMS_CLOUD Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/dbms-cloud-package.html#GUID-CE359BEA-51EA-4DE2-88DB-F21A9FC10721)
* [DBMS\_CLOUD Package Format Options for EXPORT_DATA with Text Files (CSV, JSON, Parquet, or XML)](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/format-options-json.html#GUID-3CE7574F-E78B-49D6-9F32-DC00AEE418F4)
* [EXPORT_DATA Procedure](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/dbms-cloud-subprograms.html#GUID-F8A70BE2-6060-48A7-9667-0A6B39198071)
* [File Naming for Text Output (CSV, JSON, Parquet, or XML)](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/export-data-file-namingl.html#GUID-1A52F59C-2797-48A5-A058-950318DBE9AF)

You may now proceed to the next lab.

## Acknowledgements

* **Author:**
    * Lauran Serhal, Consulting User Assistance Developer, Oracle Database and Big Data
* **Contributor:**
    + Alexey Filanovskiy, Senior Principal Product Manager
* **Last Updated By/Date:** Lauran Serhal, May 2023

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)