# Introduction

## About This Workshop

This workshop uses Oracle APEX and Oracle Analytic Views to build an application that analyzes sales data. The focus of the workshop is using Analytic Views to simplify SQL generation, allow more interactivity, and easily add calculations to reports and charts.

### About Analytic Views

An analytic view is a type of view in the Oracle Database that allows users to perform complex queries and calculations on data stored in one or more tables. These views provide a higher level of abstraction over the underlying data, allowing users to access and analyze the data in a more meaningful way.  They are typically used in business intelligence and data warehousing applications, and can be based on a single table or multiple tables joined together.

### Why use Analytic Views with APEX?

APEX application developers provide the SQL that powers reports, charts and other data visualizations.  Providing this SQL becomes more difficult as the requirements for interactivity and calculations increase. While a report or chart with limited interactivity and calculations might be easily powered by a simple  SELECT statement, applications that offer greater interactivity and more calculations will likely require PL/SQL code to generate SELECT statements dynamically.

Analytic views can dramatically simplify the SQL that an APEX application needs to generate. The Analytic View encapsulates the physical sources (for example, tables), joins, aggregation rules, and calculated measures and presents the data in a simple, flat view that is queried with a relatively simple SELECT statement.  The SQL statements used to query analytic views are easier to generate, maintain, and understand as compared to complex queries written directly to tables.

Analytic views also relieve the APEX developer from the need to optimize query performance. Analytic Views generate the SQL that is used for query execution. This SQL is highly tuned for specific use cases.

The bottom line is that APEX developers can simplify application development, provide more analytic content, and often improve query performance by using Analytic Views.

### Objectives

In this workshop, you will:

- Learn essential concepts about analytic views.
- Learn about the types of analytic views.
- Learn how to query analytic views using sample queries.
- Create an application using a predefined analytic view.

### Questions

If you have any questions about the topics covered in this lab and the entire workshop, please contact us by posting on our public forum on **[cloudcustomerconnect.oracle.com](https://cloudcustomerconnect.oracle.com/resources/32a53f8587/)**  and we will respond as soon as possible.

### Acknowledgements

- Created By/Date - William (Bud) Endress, Product Manager, Autonomous AI Database, June 2023
- Last Updated By - William (Bud) Endress, May 2024

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C)  Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)