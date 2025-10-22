# Load Data from Object Storage Public Buckets

## Introduction

In this lab, you will load and link data from the MovieStream data lake on [Oracle Cloud Infrastructure Object Storage](https://www.oracle.com/cloud/storage/object-storage.html) into an Oracle Autonomous AI Database instance in preparation for exploration and analysis.

You can load data into your Autonomous AI Database (either Oracle Autonomous Data Warehouse or Oracle Autonomous Transaction Processing) using the built-in tools as in this lab, or you can use other Oracle and third party data integration tools. With the built-in tools, you can load data from the following:

+ Files in your local device
+ Tables in remote databases
+ Files stored in cloud-based object storage (Oracle Cloud Infrastructure Object Storage, Amazon S3, Microsoft Azure Blob Storage, and Google Cloud Storage)

You can also leave data in place in a cloud object storage, and then link to it from your Autonomous AI Database.

> **Note:** While this lab uses Oracle Autonomous Data Warehouse, the steps are identical for loading data into an Oracle Autonomous Transaction Processing database.

This workshop explores several methods for loading data into an Oracle Autonomous AI Database. In this first data loading lab, we practice loading data from public object storage buckets.

Estimated Time: 10 minutes

Watch the video below for a quick walk-through of the lab.
[Load Data from Object Storage Public Buckets](videohub:1_skl03gxs)

### Objectives

In this lab, you will:
* Navigate to the Data Load utility of Oracle Autonomous AI Database Data Tools
* Learn how to create tables and load data from public object storage buckets using Data Tools built-in to Oracle Autonomous AI Database

### Prerequisites

- This lab requires completion of the lab **Provision an Autonomous AI Database**, from the **Contents** menu on the left.

## Task 1: Navigate to the Data Load Page

[](include:adb-goto-data-load-utility.md)

## Task 2: Load Data from a Public Object Storage Bucket and Create Tables

In this task, you will load data from files in a public storage bucket and create the following tables in your Autonomous AI Database instance: **`customer_contact`**, **`genre`**, **`pizza_locations`**, and **`sales_sample`**.

[](include:adb-load-public-db-actions.md)

You may now **proceed to the next lab**.

## Acknowledgements

* **Authors:**
    * Lauran K. Serhal, Consulting User Assistance Developer
    * Mike Matthews, Autonomous AI Database Product Management
    * Marty Gubar (Retired), Autonomous AI Database Product Management
* **Last Updated By/Date:** Lauran K. Serhal, October 2025

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) 2025 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)

