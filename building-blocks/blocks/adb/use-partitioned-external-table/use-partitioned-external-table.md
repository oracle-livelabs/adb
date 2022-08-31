# Access and Load Partitioned Object Storage Data

## Introduction

Data lakes oftentimes have data sets that are experimental, potentially useful but sparse (think log data), un-curated or staging data. It is extremely beneficial to be able to query that data from the data warehouse using existing tools and applications. Blending data from the warehouse with data from the lake allows for new insights that would otherwise be unachievable.

Data lakes typically organize data files in object storage using a particular format:

![Tables and partitions in object store](images/obj-organization.png)

In the example above:
* Tables map to folders (`customer_contact`, `custsales`).
* Partitions map to subfolders. `month=201901` is equivalent to a month partition column with the value `201901`. There are often multiple levels of subfolders.
* Data is found in files at the leaf.

Autonomous Database understands common data lake organization patterns and makes it easy to create and synchronize partitioned external tables with these sources. Queries against these sources benefit from Oracle Database partition pruning query optimization - minimizing the amount of data scanned and improving performance.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:
* Create an external table over data in object storage
* Create a partitioned external table over data in object storage
* Load data from the partitioned external table
* Compare query performance against these stores

### Prerequisites

- This lab requires completion of the lab, **Provision an Autonomous Database**, in the Contents menu on the left.

## Task 1: Navigate to SQL worksheet
[](include:adb-goto-sql-worksheet.md)

## Task 2: Query the contents of the object store
[](query-object-store-contents-with-sql.md)

You can query the list of files available in object storage using SQL. Simply pass the location of the source data to the ``DBMS_CLOUD.LIST_OBJECTS`` function. You can [learn more about this function in the documentation](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/dbms-cloud-subprograms.html#GUID-52801F96-8280-4FE0-8782-E194F4360E6F).

> Because the files used in this exercise are in a public bucket, a credential is not required to access OCI Object Storage.

1. Query MovieStream's public bucket to see the target files that you will access. Copy and paste the following query into the worksheet. Run the query by pressing [control-enter] or by clicking the play button in the toolbar.

    ```
    <copy>
    --===============================
    -- view the files in object storage
    --===============================
    select object_name, bytes
    from
        dbms_cloud.list_objects (            
            location_uri => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/moviestream_gold/o/')
    where object_name like '%.parquet'
    order by 1
    ;
    </copy>
    ```

2. Notice the monthly partitions in the ``custsales`` folder. The files are stored in an optimized Apache Parquet file type. Parquet files capture data in compressed columnar format. Autonomous Database optimizes queries against these file types, extracting only the necessary columns and filtering data blocks - minimizing the amount of data scanned and returned by queries:

    ![Object storage listing](images/adb-obj-store-query-list.png)

## Task 3: Create and query an external table over Parquet data files

1. Let's create a simple external table over this data set using the ``dbms_cloud.create_external_table`` procedure:

    ```
    <copy>
    --==============================
    -- simple table
    --==============================
    begin
        dbms_cloud.create_external_table
        (
          table_name => 'ext_custsales',
          file_uri_list => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/moviestream_gold/o/custsales/*.parquet',
          format => '{"type":"parquet", "schema": "first"}'

        );
    end;
    /
    </copy>
    ```

2. Run the following query to view the first few rows of data:

    ```
    <copy>
    select *
    from ext_custsales where rownum < 5;
    </copy>
    ```

    Listed below are the results. You can see the movies that were rented or viewed for free using different devices:

    ![No partitions - simple query](images/adb-simple-table-query-few-rows.png)

3. View performance of a count(*) query against a single month of data by running the following query:

    ```
    <copy>
    select count(*)
    from ext_custsales
    where to_char(day_id, 'YYYY-MM') = '2019-01';
    </copy>
    ```
    Your query performance will vary depending on your region. Also, this query is not running in parallel since you are running in the LOW consumer group:

    ![Simple count query](images/adb-simple-table-query-count.png)

    The query executed in a bit over a minute. Remember this number - we'll compare it next to a query that uses a partitioned external table.

## Task 4: Create and query a partitioned external table over Parquet data files
[](include:adb-use-partitioned-external-table-body.md)

## Task 5: Create, load and query an Oracle table from the object storage source

1. Now that we have the external table, it's easy to create and load an Oracle Database table from the object storage source. Let's use the power of SQL and partition pruning by selecting only 6 months in the year 2020:
    ```
    <copy>create table custsales as
select * from ext_custsales_part where month in ('2020-07', '2020-08', '2020-09', '2020-10', '2020-11', '2020-12');
    </copy>
    ```
    ``CREATE TABLE AS SELECT``, or CTAS, is a shortcut for both creating and populating a table.

2. Run the same count query against the internal table:
    ```
    <copy>select count(*)
from custsales
where month='2019-01';
    </copy>
    ```
    This time, the query returns in just a fraction of a second (or 12x faster than the partitioned external table query):

    ![Super fast query against internal table](images/adb-simple-int-table-query-count.png)

## Learn More
There's lots of good material on working with external data:
* Oracle Autonomous Database dbms_cloud documentation
* Oracle Autonomous Database documentation [Query External Data with Data Catalog](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/query-external-data-catalog.html#GUID-480FAF23-453D-4B15-BF92-8435805EB8A5)
* Oracle Data Warehouse Insider Blog:
    * [Creating and managing Partitioned External Tables just got simple](https://blogs.oracle.com/post/simplified-partitioning-xt)
    * [Use any AWS S3 compatible object store with Autonomous Database](https://blogs.oracle.com/datawarehousing/post/use-any-aws-s3-compatible-object-store-with-autonomous-database)

Please *proceed to the next lab*.

## Acknowledgements

* **Author** - Marty Gubar, Autonomous Database Product Management
* **Last Updated By/Date** - Marty Gubar, June 2022
