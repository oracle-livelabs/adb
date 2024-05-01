# Query Data from Multi-Cloud Data Lakes

## Introduction

In this demo, you will learn how to identify customers who might churn. The customers data is available in an OCI Object Storage bucket. We will load this data into our ADB instance and create database tables. The information about potential customers that will churn is found in an Amazon S3 (Simple Storage Service) bucket. We will link to that data and create an external table. Linking is preferred because if the data changes, we won't have to reload it. Finally, we will query the data from both the OCI and Amazon S3 buckets.

Estimated Time: 10 minutes

<!-- Comments:  -->

### Objectives

In this lab, we will show you how to do the following:

* Create an OCI Object Storage bucket cloud location and load customers data from this location into ADB and create database tables.
* Create an Amazon S3 bucket cloud location and link to potential customers churners and create an external table.
* Create a new table that joins the three created tables to show customers data and churners. The tables data originated from the OCI and Amazon S3 buckets.

### Prerequisites
Access to an ADW and Data Catalog instances, if you choose to perform the steps.

>**Note:**
_**This is not a hands-on lab; instead, it is a demo of how to query data from different clouds: OCI Object Storage and Amazon S3 buckets.**_

## Task 1: Navigate to the Data Load Page

If you already accessed the SQL Worksheet in the previous lab, click **Database Actions | SQL** in the banner to display the **Launchpad** page. Click the **Data Studio** tab, and then click the **Data Load** tab to display the **Data Load Dashboard**. You can now skip over to **Task 2**.

If you closed the Web browser tab where the SQL Worksheet was displayed, navigate to the **Data Load** page as follows:

1. Log in to the **Oracle Cloud Console**.

2. Open the **Navigation** menu and click **Oracle Database**. Under **Oracle Database**, click **Autonomous Database**.

<if type="livelabs">
3. On the **Autonomous Databases** page, click your **DB-DCAT** ADB instance.
</if>

<if type="freetier">
3. On the **Autonomous Databases** page, click your **ADW-Data-Lake** ADB instance.
</if>

4. On the **Autonomous Database details** page, click the **Database actions** drop-down list, and then click **Data Load**.

## Task 2: Define an OCI Oracle Cloud Location

In this task, we will get some customers information from a public OCI Object Storage bucket.

In this task, we define a **Connection** to connect to a public Oracle Object Storage bucket in order to load data from the **`customer-contact.csv`** and **`customer-extension.csv`** files to create detailed customers tables.

1. On the **Data Load** page, click the **CONNECTIONS** tile.

    ![Click the Cloud Locations card.](./images/click-connections-oci.png " ")

2. On the **Connections** page, click the **Create** drop-down list and then select **New Cloud Store Location** from the list.

    ![Click Add Cloud Storage.](./images/click-new-cloud-store-location.png " ")

3. Specify the following in the **Storage Settings** page 1 of the **Add Cloud Store Location** wizard:
    + **Name:** Enter **`oci-data-lake`**.
    + **Description:** Enter an optional description.
    + Select the **Public Bucket** option.
    + Accept the selected **Bucket URI** option.
    + **Bucket URI:** Enter the URI for the public Object Storage bucket.

        ```
        <copy>
        https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/moviestream_landing/o
        </copy>
        ```

        ![Complete the Add Cloud Store Location.](./images/oci-cloud-settings.png =65%x*)

4. Click **Next** to see the available objects in the selected bucket in the **Cloud Data** page 2 of the wizard. This bucket contains several folders. We will load the **`customer-contact.csv`** and **`customer-extension.csv`** files from their respective folders into our ADB instance and use them to create tables that will help us identify the potential customers churners.

    ![Click Next to see the objects in the bucket.](./images/oci-cloud-data.png =65%x*)

5. Click **Create**. The new **oci-data-lake** cloud location is displayed in the **Connections** page.

    ![The cloud store location is created.](./images/oci-connection-created.png =65%x*)

6. Click on the **Data Load** link in the breadcrumbs to return to the **Data Load** page.

## Task 3: Load Data from the OCI Cloud Location and Create a Table

In this task, we will load data and create the **customer\_contact** table in your Autonomous Database instance.

>**Note:** In **Lab 3: Load Data from Local Files**, we already loaded the **customer-extension.csv** file into our ADB instance; therefore, we won't perform this step. In addition, in **Lab 4: Link to Data in Public Object Storage Buckets**, we already linked to the **`customer_contact`** file and created the external table; however, in this task, we will load the same **`customer_contact`** data into our ADB instance and create a new database table under a new name. Querying data stored inside the database is much faster than querying data that is stored in external tables outside the database.

1. On the **Data Load Dashboard**, click the **LOAD DATA** tile.

    ![Click Load Data.](./images/click-load-data.png " ")

2. On the **Load Data** page, click the **Cloud Store** tab. Select the newly created **oci-data-lake** cloud location that you created, if not already selected in the **Select Cloud Store Location or enter public URL** drop-down list. A list of the folders in the selected Object Storage bucket is displayed on left side section of the page. You can drag and drop the desired folders from this section to the data loading job section.

    ![Load Data page.](./images/load-data-page.png " ")

3. Drag the **`customer_contact`** folder and drop it onto the data loading job section.

    ![Drag the customer_contact folder](images/drag-drop-customer-contact.png)

4. A dialog box is displayed to prompt you whether or not if you want to load all objects in this folder matching **.csv** to a single target table. This folder contains a single file, **`customer_contact.csv`**. In general, data lake folders contain many files of the same type, as you will see with sales data. Click **Yes**.

    ![Click yes to load objects to a single table.](images/load-to-single-table.png =60%x*)

    The **`customer_contact`** target table to be created for the selected **`.csv`** file is displayed in the data loading job section. If a warning message box is displayed, close it. Again, since we already have linked to the **`customer_contact`** file in a previous lab, the data load utility changed the name of the newly created external table to **`customer_contact_1`**.

    >**Note:** You can click the **`customer_contact (23 MB)`** link to display the settings for the table that will be created. You can preview the external table and change its name, data type, and so on.

    ![The customer_contact target table is displayed.](images/customer-contact-1-created.png)

5. Click **Start** to start the load job. The **Start Load From Cloud Store** dialog box is displayed. Click **Run** to start the load job and to create the new external table.

    ![Run the load job.](images/click-run.png)

    If the load job is completed successfully, the data load card has a copy icon next to it. You can click the **Report** button for the load job to view a report of total rows processed successfully and failed for the selected table.

    ![Load job completed.](images/customer-contact-created.png)

6. Navigate to the SQL Worksheet. Click **Database Actions | Data Load** in the banner to display the **Launchpad** page.

7. Click the **Development** tab, and then click the **SQL** tab to display the SQL Worksheet.

    ![Navigate to SQL Worksheet.](images/navigate-sql-worksheet.png)

    The two tables that we created and will use in this demo are displayed in the **Navigator** tab, namely, **`CUSTOMER_CONTACT_1`** and **`CUSTOMER_EXTENSION`**.

    ![The two tables are displayed.](images/two-tables-displayed.png)

## Task 4: Define an Amazon S3 Cloud Location

_**Note:** This is not a hands-on task; instead, it is a demo of how to define an Amazon S3 location._

In this task, we define a **Connection** to connect to our **`moviestream-churn`** AWS S3 bucket that contains the **`potential_churners.csv`** file. We will use this file in our demo to identify potential customers who might churn.

![The potential_churners.csv file in the S3 bucket.](images/aws-s3-bucket.png)

1. Navigate to the **Data Load Dashboard**. Click **Database Actions | SQL** in the banner to display the **Launchpad** page. Click the **Data Studio** tab, and then click the **Data Load** tab.

2. Click the **CONNECTIONS** tile.

    ![Click Connections.](images/click-connections.png)

2. On the **Connections** page, click the **Create** drop-down list, and then select **New Cloud Store Location**.

    ![Create new cloud store location.](images/create-aws-s3-location.png)

3. Specify the following in the **Add Cloud Store Location** panel.
    + **Name:** Enter **`aws-s3-data-lake`**.
    + **Description:** Enter an optional description.
    
        Click **Create Credential**. The **Create Credential** dialog box is displayed. Specify the following:
    
        + **Cloud Username and Password:** Select this option, if not already selected.
        + **Cloud Store:** Select **Amazon S3** option from the drop-down list.
        + **Credential Name:** Enter **`aws_s3_credential`**.
        + **AWS access key ID:** Enter the access key id.
        + **AWS secret access key:** Enter the secret access key.
    
            ![The Amazon S3 credential.](images/aws-s3-credential.png)

        Click **Create Credential**. The **Add Cloud Store Location** panel is re-displayed. Specify the following: 

        + **Bucket URI option:** Leave this option as selected which is the default.
        + **Bucket URI text box:** Enter your AWS endpoint. The URL format is as follows:

            `https://<bucket-name>.s3.<region>.amazonaws.com/`

            ![Complete the Add Cloud Store Location.](./images/complete-add-aws-connection.png " ")

4. Click **Next** to see the available objects in the bucket that you specified. We will only use the **`potential_churners.csv`** file.

    ![Click Next to see the objects in the bucket.](./images/cloud-data.png " ")

5. Click **Create**. The **aws-s3-data-lake** cloud location is displayed in the **Connections** page.

    ![The cloud store location is created.](./images/aws-connection-created.png " ")

6. Click on the **Data Load** link in the breadcrumbs to return to the **Data Load** page.

## Task 5: Link to Data from the AWS S3 Cloud Location and Create an External Table

In this task, we will link to the `potential_churners.csv` data from the AWS S3 cloud location that we created. A link is preferred so that if the data changes, we don't have to re-load the data. We are always looking at up-to-date data.

1. On the **Data Load** page, click the **LINK DATA** tile.

2. The **Link Data** page is displayed and the **CLOUD STORE** tab is selected. Select the **`aws-s3-data-lake`** from the **Select Cloud Store Location or enter public URL** drop-down list.

    ![Select the aws-s3 cloud location](images/select-aws-s3.png)

3. Drag and drop the **`potential_churners`** table from the Amazon S3 public bucket to the data linking job.

    ![Drag and drop the potential_churners folder](images/drag-drop-potential-churners.png)

4. Click **Start** and then click **Run**. If the **`potential_churners`** link job completes successfully, the data link card has the link icon next to it. You can click the Report button for the link job to view a report of total rows processed successfully and failed for the selected table.

    ![The potential_churners target table is displayed.](images/link-job-completed.png)

## Task 6: Query Data from the OCI and Amazon Data lakes

We now have the needed tables to analyze the data and identify the potential customers that might churn.

1. Click **Database Actions | Data Load** in the banner to display the **Launchpad** page. Click the **Development** tab, and then click the **SQL** tab to display the SQL Worksheet.

2. Let's query the **`POTENTIAL_CHURNERS`** table. Copy and paste the following code into your SQL Worksheet, and then click the **Run Statement** icon in the Worksheet toolbar.

    ```
    <copy>
    select *
    from POTENTIAL_CHURNERS pc;
    </copy>
    ```

    The output shows whether or not the customer will churn and the probability of the churn by **`CUST_ID`**.

    ![Query potential_churners.](./images/query-potential-churners.png " ")

4. Let's query the **`CUSTOMER_EXTENSION`** table. Copy and paste the following code into your SQL Worksheet, and then click the **Run Statement** icon in the Worksheet toolbar.

    ```
    <copy>
    select *
    from CUSTOMER_EXTENSION e;
    </copy>
    ```

    The output shows typical information about the customers by `CUST_ID`.

    ![Query customer_extension.](./images/query-customer-extension.png " ")

5. Let's query the `CUSTOMER_CONTACT_1` table. In the SQL Worksheet, copy and paste the following code into your SQL Worksheet to query the data, and then click the **Run Statement** icon in the Worksheet toolbar.

    ```
    <copy>
    select *
    from CUSTOMER_CONTACT_1 cc;
    </copy>
    ```

    The output shows the customers geographical contact information by **`CUST_ID`**.

    ![Query customer_contact_1.](./images/query-customer-contact-1.png " ")

6. Create a new table that joins all three tables that originated from the OCI and AWS S3 data lakes based on the **`cust_id`** column. This table will show the customers that will churn (from the **`POTENTIAL_CHURNERS`** table), the detailed customer information (from the **`customer_extension`** table), and the geographical customers information (from the **`CUSTOMER_CONTACT_1`** table). Copy and paste the following code into your SQL Worksheet, and then click the **Run Script (F5)** icon in the Worksheet toolbar.

    ```
    <copy>
    create table potential_churn_customers as
        select
        pc.prob_churn,
        e.*,
        cc.STREET_ADDRESS,
        cc.POSTAL_CODE,
        cc.CITY,
        cc.STATE_PROVINCE,
        cc.COUNTRY,
        cc.COUNTRY_CODE,
        cc.CONTINENT,
        cc.YRS_CUSTOMER,
        cc.PROMOTION_RESPONSE,
        cc.LOC_LAT,
        cc.LOC_LONG
        from POTENTIAL_CHURNERS pc, CUSTOMER_EXTENSION e, CUSTOMER_CONTACT_1 cc
        where
        pc.cust_id=e.cust_id
        and cc.cust_id=pc.cust_id
        and pc.will_churn=1
        and pc.prob_churn>0.99;
    /
    </copy>
    ```

    The table is created.

    ![Create a new potential_churn_customers .](./images/create-new-table.png " ")

7.  Query the table. Copy and paste the following code into your SQL Worksheet, and then click the **Run Statement** icon in the Worksheet toolbar.

    ```
    <copy>
    select *
    from potential_churn_customers cc;
    </copy>
    ```

    ![Query the potential_churn_customers table .](./images/query-potential_churn_customers.png " ")

    
    You may now proceed to the next lab.
    
## Learn more

* [Load Data with Autonomous Database](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/user/load-data.html#GUID-1351807C-E3F7-4C6D-AF83-2AEEADE2F83E)

You may now proceed to the next lab.

## Acknowledgements

* **Author:** Lauran K. Serhal, Consulting User Assistance Developer
* **Contributor:** Alexey Filanovskiy, Senior Principal Product Manager
* **Last Updated By/Date:** Lauran K. Serhal, April 2024

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) 2024 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)

