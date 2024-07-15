# Introduction

## About this Workshop

This workshop will show you how to use Data Transforms tool to create a data pipeline for data analysis, data science or for any ad-hoc data preparation need. Data can be loaded from a wide selection of heterogenous sources (databases and applications) and can go through complex transformations. You will learn how to define the data load and transforms process and schedule them for periodic execution.

Estimated Workshop Duration: 02 hour, 30 minutes

### Who should use this Workshop?

This workshop is useful for anyone who needs to have a detailed knowledge of loading and transforming data in the Autonomous Database. 

### Objectives

In this workshop, you will learn:
-	How to create a connection to your data sources and targets
-   How to import entity definitions
-	How to load data without any transformation
-	How to load and transform data 
-   How to create data flows
-   How to schedule your execution

### Prerequisites

Before you launch into this workshop, you will need the following:

- Basic knowledge of Oracle Cloud
- Basic level of understanding of SQL query language

### How to use the Workshop

The labs are ordered in a sequence. Start with creating the users and importing the data. If you have the pre-created environment then you can skip these. Rest of the workshop takes you through various tasks you need to execute in order to build a data pipeline in Data Transforms tool.

Data pipeline consists of the following objects:
- Data Load: For extracting data from the source and loading to the target without any transformations. It loads multiple tables at the same time and can also be used to extract data from all the source tables in the schema and load corresponding tables in the target in a single load job.
- Data Flow: You can write complex transformations in a data flow from any set of source tables to your target table.
- Workflow: You can execute multiple data load jobs and data flow jobs in a single workflow so that they can be executed as an unit.

For this workshop we will use a fictional movie streaming demo data and customer demographics data. The goal of creating the pipeline is to populate a set of tables that can be used to analyze customer movie watching behavior. The details will be explained further in individual labs.


If you have any questions about the topics covered in this lab and the entire workshop, please contact us by posting on our public forum on  **[cloudcustomerconnect.oracle.com](https://cloudcustomerconnect.oracle.com/resources/32a53f8587/)**  and we will respond as soon as possible.

## Acknowledgements

- Created By/Date - Jayant Mahto, Product Manager, Autonomous Database, January 2023
- Contributors - Mike Matthews
- Last Updated By - Jayant Mahto, June 2024


Copyright (C)  Oracle Corporation.


