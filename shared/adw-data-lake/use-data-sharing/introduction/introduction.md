# Introduction

Data sharing is making the same data available to one or more consumers. Nowadays, the ever-growing amount of data has become a strategic asset for any company. Sharing data - within your organization or externally - is an enabling technology for new business opportunities. Sharing data and consuming data from external sources allows to collaborate with partners, establish new partnerships and generate new revenue streams with data monetization.

### Why Use Data Sharing?

Data Sharing allows customers to improve their business and open up new opportunities. Examples of Data Sharing scenarios:

* One organization shares data across LOBs where an HR department can share statistical employee data with the Financial department for cost analysis.
* Business to Business (B2B) where a retailer shares regional sales and inventory data with a supplier to help improve the supplier's production line and locations.
* Business to Customers (B2C) where a restaurant shares historical time-based pattern of busyness to allow customers to plan for their reservations.

### About this Workshop

The labs in this workshop walk you through all the steps to ...

  ![The architecture diagram.](images/architecture-diagram.png)

Estimated Time: 1.5 hours

### Traditional ways to share data

Sharing data is nothing new and users did this before. Some examples of how users used to do data sharing in the past are:

* Send data via email
* Share data through an FTP server
* Use application-specific APIs for data extraction
* Leverage vendor specific tools to copy relevant data

While these methods work in general, they come with certain drawbacks:

* Managing separate processes for data extraction, preparation or remote access are labor-intensive.
* Extracting and duplicating data is prone to data staleness.
* Architectures and processes can become very difficult to maintain and hard to scale.
* Redundant data extraction can introduce format compatibility issues.
* Data extraction and preparation must handle sensitive information properly.

### The modern way of sharing data

Modern data sharing must be open, secure, real-time, vendor-agnostic, and avoid the pitfalls of extracting and duplicating data for individual consumers of data in a collaborative environment. Delta Sharing is an open protocol for secure real-time data exchange of large datasets that satisfies all these criteria, supported by multiple clients and program languages, and vendor agnostic.

The open Delta Sharing protocol is aimed to solve the following problems:

* Share data without copying it to another system
* Producer controls the state of data (version of data)
* Be an open cross-platform solution
* Support a wide range of clients such as Power BI, Tableau, Apache Spark, pandas and Java
* Provide flexibility to consume data using the tools of choice for BI, machine learning and AI use cases
* Provide strong security, auditing, and governance
* Scale to massive data sets

### Objectives

In this workshop, you will:

* Set up the workshop environment.
* 

You can ... .

 ![The diagram shows the sources for creating tables.](images/table-sources-diagram.png)

### Prerequisites

* An Oracle Cloud Account - Please view this workshop's LiveLabs landing page to see which environments are supported. You may use your own cloud account or you can get a Free Trial account as described in the **Get Started** lab in the **Contents** menu.

  *Note: If you have a **Free Trial** account, when your Free Trial expires your account will be converted to an **Always Free** account. You will not be able to conduct Free Tier workshops unless the Always Free environment is available. **[Click here for the Free Tier FAQ page.](https://www.oracle.com/cloud/free/faq.html)***

* This lab requires the completion of **Lab 1: Set up the Workshop Environment > Task 3: Create an Autonomous Data Warehouse Instance**, from the **Contents** menu on the left.

You may now proceed to the next lab.

## Learn More

* [Get Started with Data Catalog](https://docs.oracle.com/en-us/iaas/data-catalog/using/index.htm)
* [Data Catalog Overview](https://docs.oracle.com/en-us/iaas/data-catalog/using/overview.htm)
* [Using Oracle Autonomous Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)
* [Oracle Cloud Infrastructure Documentation](https://docs.cloud.oracle.com/en-us/iaas/Content/GSG/Concepts/baremetalintro.htm)
* [What Is a Data Catalog and Why Do You Need One?](https://www.oracle.com/big-data/what-is-a-data-catalog/)
* [What is the difference between a Data Lake, Database, and a Data Warehouse](https://www.oracle.com/a/ocom/docs/database/difference-between-data-lake-data-warehouse.pdf) and the [Oracle Cloud Data Lakehouse LiveLabs Workshop](https://apexapps.oracle.com/pls/apex/f?p=133:100:100470405399556::::SEARCH:lakehouse).

## Acknowledgements

* **Author:** Lauran K. Serhal, Consulting User Assistance Developer
* **Contributor:**
  * Alexey Filanovskiy, Senior Product Manager

* **Last Updated By/Date:** Lauran K. Serhal, July 2023

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation License, Version 1.3 or any later version published by the Free Software Foundation; with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts. A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle.github.io/learning-library/data-management-library/autonomous-database/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
