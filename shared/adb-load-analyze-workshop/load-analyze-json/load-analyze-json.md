# Load and Analyze JSON Data

## Introduction

Load movie data that is stored in JSON format into an Autonomous AI Database collection. After loading the collection using the API, you will then analyze movie data using Oracle JSON functions.

Estimated Time: 10 minutes

Watch the video below for a quick walk-through of the lab.
[Load and Analyze JSON Data](videohub:1_9hugohpd)

### Objectives

In this lab, you will:
* Load JSON data from Oracle Object Storage using the `DBMS_CLOUD.COPY_COLLECTION` procedure
* Use SQL to analyze both simple and complex JSON attributes

### Prerequisites

- This lab requires completion of  lab 2, **Provision an Autonomous AI Database**, in the Contents menu on the left.

    >**Important:** In the **Provision an Autonomous AI Database** lab, we chose **26ai** as the database version. Some of the JSON syntax in this lab works only with version **26ai** database version.

## Task 1: Create and load JSON movie collection
[](include:adb-create-load-json-collection.md)

## Task 2: Analyze simple JSON fields to find Meryl Streep movies
[](include:adb-query-json-simple.md)

## Task 3: Analyze complex JSON arrays to find top actors
[](include:adb-query-json-arrays.md)

Please [*proceed to the next lab*](#next).

## Learn more

* [DBMS_CLOUD Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/dbms-cloud-package.html#GUID-CE359BEA-51EA-4DE2-88DB-F21A9FC10721)
* [JSON File Format](https://en.wikipedia.org/wiki/JSON).
* [COPY_COLLECTION Procedure](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/dbms-cloud-subprograms.html#GUID-0985BB63-A86D-41C0-8B5B-B9E965809F5A)
* [Dropping a Document Collection with SODA for PL/SQL](https://docs.oracle.com/en/database/oracle/oracle-database/18/adsdp/using-soda-pl-sql.html#GUID-D29C4FFF-D093-4C1B-889A-5C29B63756C6)
* [ Query JSON Data](https://docs.oracle.com/en/database/oracle/oracle-database/19/adjsn/query-json-data.html#GUID-119E5069-77F2-45DC-B6F0-A1B312945590)
* [SQL/JSON Function JSON_VALUE](https://docs.oracle.com/en/database/oracle/oracle-database/19/adjsn/function-JSON_VALUE.html#GUID-0565F0EE-5F13-44DD-8321-2AC142959215)
* [SQL/JSON Function JSON_TABLE](https://docs.oracle.com/en/database/oracle/oracle-database/19/adjsn/function-JSON_TABLE.html#GUID-0172660F-CE29-4765-BF2C-C405BDE8369A)

You may now proceed to the next lab.

## Acknowledgements

* **Author** - Marty Gubar (Retired), Autonomous AI Database Product Management
* **Contributor:** Lauran K. Serhal, Consulting User Assistance Developer
* **Last Updated By/Date:** Lauran K. Serhal, October 2025

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) 2025 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
