# Introduction

Data sharing enables you to share the same data with one or more consumers. Nowadays, the ever-growing amount of data has become a strategic asset for any company. Sharing data - within your organization or externally - is an enabling technology for new business opportunities. Sharing data and consuming data from external sources enables collaboration with partners, establishes new partnerships, and generates new revenue streams with data monetization.

## About this Workshop

The labs in this workshop walk you through all the steps on how to set up and consume data sharing using:

* PL/SQL
* Database Actions in Autonomous Data Warehouse (ADW)
* Cloud links

Estimated Time: 1.5 hours

### Objectives

In this workshop, you will:

* Set up the workshop environment
* Create a data share provider user that creates and manages the data share and the recipients of the data share
* Create an Object Storage bucket to store the shared data
* Create an OCI credential and associate it with the Object Storage bucket
* Create, populate, and publish a data share
* Create and authorize a data share recipient
* Consume the data as a recipient

### Prerequisites

* An Oracle account

### Traditional Methods to Share Data

Some examples of how users traditionally shared data are:

* Send data via email
* Share data through an FTP server
* Use application-specific APIs for data extraction
* Leverage vendor specific tools to copy relevant data

While the traditional methods work in general, they come with certain drawbacks:

* Managing separate processes for data extraction, preparation or remote access are labor-intensive.
* Extracting and duplicating data is prone to data staleness.
* Architectures and processes can become very difficult to maintain and hard to scale.
* Redundant data extraction can introduce format compatibility issues.
* Data extraction and preparation must handle sensitive information properly.

### The Modern Way for Sharing Data

Modern data sharing must be open, secure, real-time, vendor-agnostic, and avoid the pitfalls of extracting and duplicating data for individual consumers of data in a collaborative environment. Delta Sharing is an open protocol for secure real-time data exchange of large datasets that satisfies all these criteria, supported by multiple clients and program languages, and vendor agnostic.

The open Delta Sharing protocol is aimed to solve the following problems:

* Share data without copying it to another system
* Producer controls the state of data (version of data)
* Be an open cross-platform solution
* Support a wide range of clients such as Power BI, Tableau, Apache Spark, pandas and Java
* Provide flexibility to consume data using the tools of choice for BI, machine learning and AI use cases
* Provide strong security, auditing, and governance
* Scale to massive data sets

### How Does Delta Sharing Work?

At the high level, when a user consumes data made available through delta sharing protocol, the following happens:

* The Delta Sharing client issues a request to the Delta Sharing Server and provides a bearer token.
* If the token is valid, the Delta Sharing server authenticates the user and provides pre-authenticated links for the Delta Sharing client.
* The Delta Sharing client directly accesses the shared data - files in the object store – that correspond to the shared data such as a table.

You may now proceed to the next lab.

## Learn More

* [The Share Tool](https://docs.oracle.com/en/database/oracle/sql-developer-web/sdwad/adp-data-share-tool.html#GUID-7EECE78B-336D-4853-BFC3-E78A7B8398DB)
* [Using Oracle Database Actions for Oracle Cloud](https://docs.oracle.com/en/database/oracle/sql-developer-web/sdwad/index.html)
* [Using Oracle Autonomous Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)
* [Oracle Cloud Infrastructure Documentation](https://docs.cloud.oracle.com/en-us/iaas/Content/GSG/Concepts/baremetalintro.htm)

## Acknowledgements

* **Author:** Lauran K. Serhal, Consulting User Assistance Developer
* **Contributor:**
  * Alexey Filanovskiy, Senior Product Manager

* **Last Updated By/Date:** Lauran K. Serhal, July 2023

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation License, Version 1.3 or any later version published by the Free Software Foundation; with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts. A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle.github.io/learning-library/data-management-library/autonomous-database/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
