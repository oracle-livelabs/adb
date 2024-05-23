# Use Data Tools to Load Data from Object Storage Buckets

## Introduction

Load data on [Oracle Cloud Infrastructure Object Storage](https://www.oracle.com/cloud/storage/object-storage.html) into an Oracle Autonomous Database instance in preparation for exploration and analysis.

Estimated Time: 5 minutes

### Objectives

In this lab, you will:
* Use Autonomous Database tools to create and load database tables sourced from public files in Oracle Object Storage


### Prerequisites

- This lab requires completion of Lab 1, **Provision an ADB Instance**, in the Contents menu on the left.

## Task 1: Navigate to Database Actions and Open the Data Load Utility

[](include:adb-goto-data-load-utility.md)

## Task 2: Create Tables and Load Data from Files in Public Object Storage Buckets

Autonomous Database supports a variety of object stores, including Oracle Object Storage, Amazon S3, Azure Blob Storage, Google Cloud Storage and Wasabi Hot Cloud Storage ([see the documentation for more details](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/data-load.html#GUID-E810061A-42B3-485F-92B8-3B872D790D85)). In this step, we will use Database Actions to create Autonomous Database tables and then load those tables from csv files stored in Oracle Object Storage.

[](include:adb-load-public-db-actions-15-min-quickstart.md)

This completes the Data Load lab. We now have a full set of structured tables loaded into Autonomous Database instance from files on object storage. We will be working with these tables in the next lab.

You may now **proceed to the next lab**.

## Acknowledgements

* **Author:** Mike Matthews, Autonomous Database Product Management
* **Contributors:**
    - Marty Gubar, Autonomous Database Product Management
    - Lauran K. Serhal, Consulting User Assistance Developer
* **Last Updated By/Date:** Lauran K. Serhal, April 2024
