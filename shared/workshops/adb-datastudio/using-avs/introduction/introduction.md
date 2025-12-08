# Introduction

## About This Workshop

This workshop introduces creating Analytic Views in Oracle Autonomous AI Database Using the Data Studio Analysis application.  This Live Lab is designed to be short and approachable.

The Analytic View that you will design is simple and easy to understand.  It introduces the business model and key features.  You will also use the Analysis tool to view your Analytic View and verify the design.

The Data Studio Analysis tool generates all the DDL needed to create Analytic Views. You can view the DDL in the tool.  If you would like to look more closely at Analytic View DDL, consider running the **[Oracle Free SQL Tutorial Creating Analytic Views – Getting Started tutorial](https://freesql.com/worksheet?tutorial=creating-analytic-views-deep-dive-b9Hibz)**.

### About Analytic Views

An Analytic View is a type of view in the Oracle Database that allows users to perform complex queries and calculations on data stored in one or more tables. These views provide a higher level of abstraction over the underlying data, allowing users to access and analyze the data in a more meaningful way. They are typically used in business intelligence and data warehousing applications. For the application developers, analytic views can simplify SQL generation and calculation expressions.

### Objectives

In this workshop, you will:

- Learn how to quickly create a simple Analytic View using the Data Studio Analysis application.
- Learn about the main features of the analytic view.
- Create dimensions, hierarchies, and fact measures.
- Add calculated measures.
- View the analytic view in the Data Studio Analysis application.

### About the Data

The data set used in this Live Lab is a variation of the MovieStream data set used by many other Autonomous AI Database labs.  MovieStream is a fictitious video streaming service.  The version of the data set used by this lab is highly simplified to allow you to focus on the core aspects of designing an Analytic View. It supports the analysis of sales data by time, geography, and genre used when searching for movies.

### Prerequisites

Before you launch into this workshop, you will need the following:

1. Basic knowledge of Oracle Cloud
2. Basic level of understanding of SQL query language

If you have any questions about the topics covered in this lab and the entire workshop, please contact us by posting on our public forum on **[cloudcustomerconnect.oracle.com](https://cloudcustomerconnect.oracle.com/resources/32a53f8587/)**  and we will respond as soon as possible.

### Acknowledgements

- Created By/Date - William (Bud) Endress, Product Manager, Autonomous AI Database, February 2023
- Last Updated By - Mike Matthews, November 2025

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C)  Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)