# Check Your Understanding

## Introduction

This quiz reviews the core concepts from the Oracle Autonomous AI Lakehouse workshop. Complete the scored questions to confirm your understanding of how Oracle Autonomous AI Lakehouse works with object storage, external data, AI-assisted preparation, and performance optimization.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

* Review the core ideas behind object store-centric data lakes
* Confirm when to load data and when to link to it in place
* Check your understanding of AI-assisted preparation, data sharing, and performance techniques

### Prerequisites

Complete the previous workshop labs before taking this quiz.

```quiz-config
passing: 75
badge: images/lakehouse-badge.png
```

## Task 1: Complete the quiz

1. Review the questions before you submit your answers.

2. Complete all scored quiz blocks below. You need 75% or higher to pass.

    ```quiz score
    Q: What is a key difference between a data lake and a traditional data warehouse?
    * A data lake ingests data quickly and prepares it as people access it, while a warehouse usually transforms and cleanses data before loading it
    - A data lake can store only structured data, while a warehouse stores unstructured data
    - A data lake requires all data to be copied into database tables before analysis
    - A data warehouse cannot use SQL for analytics
    > The workshop explains that a data warehouse typically transforms data before loading it, while a data lake supports faster ingestion and prepares data on demand.
    ```

    ```quiz score
    Q: Why would you link to data in object storage instead of loading it into database tables?
    * Linking lets you analyze data in place and stay current when the source files change
    - Linking removes the need for credentials when working with private buckets
    - Linking always gives better performance than every other technique
    - Linking converts all external files into JSON collections automatically
    > A recurring theme in the workshop is that linking keeps data in object storage while still making it queryable, which reduces reloading when the source changes.
    ```

    ```quiz score
    Q: What is the purpose of a recipe in Table AI Assist?
    * It captures a series of data preparation steps such as adding, replacing, removing, or renaming columns without changing the source table directly
    - It stores cloud credentials and API keys for object storage access
    - It replaces the need for any SQL generation or review
    - It automatically exports every table to Parquet after analysis
    > The workshop describes a recipe as a reusable set of preparation steps that can produce a view, create a new table, or alter a target without directly rewriting the base table during authoring.
    ```

    ```quiz score
    Q: What do features such as Delta Sharing, AWS Glue integration, and Iceberg table access demonstrate in this workshop?
    * Oracle Autonomous AI Lakehouse can query and work with shared or external data across platforms without requiring every dataset to be copied into Oracle first
    - Oracle Autonomous AI Lakehouse works only with data stored in Oracle-managed buckets
    - External data can be used only after it is converted to CSV and downloaded locally
    - Multi-cloud access is limited to static exports with no metadata integration
    > These labs show that Oracle Autonomous AI Lakehouse can consume shared metadata and external data across OCI and AWS, enabling multi-platform analysis with less duplication.
    ```

    ```quiz score
    Q: Why does the workshop use materialized views and partitioned external tables for performance?
    * They reduce the cost of repeatedly scanning or recomputing large external datasets by precomputing summaries and improving partition-aware access
    - They are required before any object storage data can be queried at all
    - They prevent query rewrite so developers can inspect the base tables directly
    - They replace external tables with permanent copies of every source file
    > The performance lab shows that materialized views can accelerate repeated aggregations and that partition-aware external table designs help the database access only the relevant data.
    ```

## Acknowledgements

* **Author:** Linda Foinding, Principal Product Manager, Database Product Management
* **Last Updated By/Date:** Linda Foinding, March 2026
