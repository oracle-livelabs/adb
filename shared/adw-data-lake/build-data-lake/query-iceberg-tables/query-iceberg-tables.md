# Query Iceberg Tables

## Introduction

This lab demonstrates the integration of AWS Athena and Oracle Autonomous AI Database (ADB). It explores how AWS Athena creates and manages Iceberg tables and how ADB in OCI accesses metadata through AWS Glue. You will learn how to query the Iceberg tables as external tables directly within ADB, using efficient cross-cloud data querying without data replication.

![Iceberg diagram.](images/iceberg-diagram.png =70%x*)

Estimated Time: 5 minutes

<!-- Comments:  -->

### Objectives

In this lab, we will show you how to do the following:

* Create and populate an Iceberg table in AWS Athena.
* Create an external table in ADB that will access the Iceberg table from within ADB.
* Add a new row to the Iceberg table and query the updated table in ADB and see the new row of data.

### Prerequisites

Access to an ADW and AWS Athena if you choose to perform the steps.

_**Note:** This is not a hands-on task; instead, it is a demo of how to access Amazon Athena data in Oracle Autonomous AI Database using external tables._

### About Querying Apache Iceberg Tables

Oracle Autonomous AI Database supports querying of Apache Iceberg tables stored in Amazon Web Services (AWS) or in Oracle Cloud Infrastructure (OCI) Object Storage

### About Amazon Athena

Amazon Athena is an interactive query service that makes it easy to analyze data directly in Amazon Simple Storage Service (Amazon S3) using standard SQL. With a few actions in the AWS Management Console, you can point Athena at your data stored in Amazon S3 and begin using standard SQL to run ad-hoc queries and get results in seconds.

### About Apache Iceberg Tables

Apache Iceberg is a distributed, community-driven, Apache 2.0-licensed, 100% open-source data table format that helps simplify data processing on large datasets stored in data lakes. Data engineers use Apache Iceberg because it is fast, efficient, and reliable at any scale and keeps records of how datasets change over time. Apache Iceberg offers easy integrations with popular data processing frameworks such as Apache Spark, Apache Flink, Apache Hive, Presto, and more.

<!-- Comments:  -->

## Task 1: Create and Populate an Iceberg Table in AWS Athena

1. Log in to Amazon AWS. Navigate to https://aws.amazon.com/, and then click **Sign in to the Console**.

    ![Navigate to Amazon AWS.](images/amazon-aws.png =70%x*)

2. On the **Sign in as IAM user** page, enter your Account ID, IAM user name, and Password, and then click **Sign in**.

    ![Sign in to Amazon AWS.](images/sign-in-page.png =45%x*)

3. On the **Console Home** page, click the **Services** menu and then click **Analytics**. Under **Analytics**, click **Athena**.

    ![Click Athena.](images/click-athena.png =65%x*)

4. On the **Athena** home page, click the **Explore the query editor** button. The **Query editor** page is displayed. In the **Tables and views** section, click the **Create** drop-down list, and then select **CREATE TABLE** from the context menu.

    ![The Query editor page.](images/query-editor.png =65%x*)

5. In the Editor, create an Iceberg table named **`movie_promotion_training`** as follows, and then click **Run**.

    ```
    CREATE TABLE movie_promotion_training
    ( id int, movie_name string, is_active boolean, discount int)
    LOCATION 's3://iceberg-bkt-us-west-1/movie_promotion'
    TBLPROPERTIES ('table_type' = 'ICEBERG')
    ```

    ![Create an Iceberg table.](images/create-table.png =65%x*)

    The new table is created and displayed in the list of available tables.

    ![The Iceberg table is created.](images/table-created.png =65%x*)

6. Populate the **`movie_promotion_training`** table with some data as follows, and then click **Run**.

    ```
    -- Insert data into the newly created table
    INSERT INTO movie_promotion_training (id ,movie_name, is_active, discount)
    values
    (1, 'Rocky', true, 10),
    (2, 'Avatar', true, 10),
    (3, 'Big Jake', true, 15);
    ```

    The new table is populated.

    ![The Iceberg table is populated.](images/table-populated.png =65%x*)

7. Query the **`movie_promotion_training`** table. The newly added data is displayed.

    ![Query the Iceberg table.](images/query-table-athena.png =65%x*)

## Task 2: Navigate to the SQL Worksheet and Create an External Table

1. Navigate to the browser tab that displays the **Data Load** page from the previous lab, and then click **Database Actions** in the banner. On the **Launchpad** page, click the **Development** tab, and then click the **SQL** tab.

    ![Navigate to the SQL Worksheet.](images/navigate-sql-worksheet.png =65%x*)

2. Create an external table named **`movie_promotion_training`**. This table points to the Glue catalog that contains the metadata that points to the actual data stored in Amazon Cloud. Copy and paste the following code into your SQL Worksheet, and then click the **Run Script** icon.

    ```
    <copy>
    BEGIN
    DBMS_CLOUD.CREATE_EXTERNAL_TABLE(
        table_name => 'movie_promotion_training',
        credential_name => 'aws_s3_credential',
        file_uri_list => NULL,
        format => '{
        "access_protocol": {
            "protocol_type": "iceberg",
            "protocol_config": {
            "iceberg_catalog_type": "aws_glue",
            "iceberg_glue_region": "us-west-1",
            "iceberg_table_path": "default.movie_promotion_training"
            }
        }
        }'
    );
    END;
    </copy>
    ```
    
    ![Create external table.](images/create-external-table.png =65%x*)

3. Query the data from the **`movie_promotion_training`** Amazon Iceberg table using the external table.

    ```
    <copy>
    SELECT *
    FROM movie_promotion_training;
    </copy>
    ```

    ![Query Iceberg table.](images/query-iceberg-table.png =65%x*)

## Task 3: Add a New Row of Data to the Iceberg Table

1. Let's go back to Amazon Athena and add one more row of data to the **`movie_promotion_training`** table. Copy and paste the following in the Query editor in Athena, and then click **Run**.

    ```
    <copy>
    -- Insert one more row into the movie_promotion_training table
    INSERT INTO movie_promotion_training (id ,movie_name, is_active, discount)
    values
    (4, 'The Outlaw Josey Wales', true, 10);
    </copy>
    ```

    ![Add one more row into the Iceberg table.](images/add-row.png =65%x*)

2. Query the **`movie_promotion_training`** table again. The newly added row is displayed.

    ![Query the Iceberg table.](images/query-table-athena-2.png =65%x*)

3. Navigate back to your Autonomous SQL Worksheet. Query the data from the **`movie_promotion_training`** Amazon Iceberg table using the external table.

    ```
    <copy>
    SELECT *
    FROM movie_promotion_training;
    </copy>
    ```

    ![Query Iceberg table.](images/query-iceberg-table-2.png =65%x*)

    The changes to the **`movie_promotion_training`** table in Athena are automatically reflected in Oracle Autonomous AI Database.

## Learn more

* [Getting Started with Amazon Athena](https://docs.aws.amazon.com/athena/latest/ug/getting-started.html)
* [Apache Iceberg](https://iceberg.apache.org/)

You may now proceed to the next lab.

## Acknowledgements

* **Author:** Lauran K. Serhal, Consulting User Assistance Developer
* **Contributor:** Alexey Filanovskiy, Senior Principal Product Manager
* **Last Updated By/Date:** Lauran K. Serhal, October 2025

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) 2025 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
