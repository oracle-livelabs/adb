# Introduction

## About this Workshop

The labs in this workshop walk you through all the steps to access the Data Lake using Autonomous Database (ADB) and Data Catalog. You will learn how to Synchronize ADB and Data Catalog so that you can query Oracle Object Storage buckets from ADB.

Estimated Time: 3 hours

### What is Data Catalog?
Oracle Cloud Infrastructure Data Catalog is a fully managed, self-service data discovery and governance solution for your enterprise data. With Data Catalog, you get a single collaborative environment to manage technical, business, and operational metadata. You can collect, organize, find, access, understand, enrich, and activate this metadata.

* Harvest technical metadata from a wide range of supported data sources that are accessible using public or private IPs.
* Create and manage a common enterprise vocabulary with a business glossary.
* Build a hierarchy of categories, subcategories, and terms with detailed rich text descriptions.
* Enrich the harvested technical metadata with annotations by linking data entities and attributes to the business terms or adding free-form tags.
* Find the information you need by exploring the data assets, browsing the data catalog, or using the quick search bar.
* Automate and manage harvesting jobs using schedules.
* Integrate the enterprise class capabilities of your data catalog with other applications using REST APIs and SDKs.

Watch our short overview video that explains key features in Data Catalog.

[](youtube:nY7mG2u6-Ew)

### What is a Data Lake?
A data lake enables an enterprise to store all of its data in a cost effective, elastic environment while providing the necessary processing, persistence, and analytic services to discover new business insights. A data lake stores and curates structured and unstructured data and provides methods for organizing large volumes of highly diverse data from multiple sources. In this workshop, a Data Lake refers to the Oracle Object Storage buckets that you will harvest in Data Catalog and query in ADB. See [What Is a Data Lake?](https://blogs.oracle.com/bigdata/post/what-is-a-data-lake)

### What is a Data Warehouse?
With a data warehouse, you perform data transformation and cleansing before you commit the data to the warehouse. With a data lake, you ingest data quickly and prepare it on the fly as people access it. A data lake supports operational reporting and business monitoring that require immediate access to data and flexible analysis to understand what is happening in the business while it happening. See [Cloud data lake house - process enterprise and streaming data for analysis and machine learning](https://docs.oracle.com/en/solutions/oci-curated-analysis/index.html#GUID-7FF7A024-5EB0-414B-A1A5-4718929DC7F2).

### What is a Lakehouse?
The Lakehouse combines the abilities of a data lake and a data warehouse to process a broad range of enterprise and streaming data for business analysis and machine learning. It offers an architecture that eliminates data silos – allowing you to analyze data across your data estate.

For additional information, see [What is the difference between a Data Lake, Database, and a Data Warehouse](https://www.oracle.com/a/ocom/docs/database/difference-between-data-lake-data-warehouse.pdf) and the [Oracle Cloud Data Lakehouse LiveLabs Workshop](https://apexapps.oracle.com/pls/apex/f?p=133:100:100470405399556::::SEARCH:lakehouse).

### Objectives

In this workshop, you will:
<if type="freetier">
* Set up the workshop environment.
</if>
<if type="livelabs">
* Review the workshop environment (optional).
</if>
* Create a Data Catalog instance.
* Import and review a business glossary.
* Create and harvest a data asset.
* Create, schedule, and monitor jobs to harvest data assets.
* Search, browse, explore, and update information in Data Catalog.
* Create and setup an ADB instance.
* Connect ADB to Data Catalog.
* Synchronize ADB and Data Catalog.
* Query both the Data Warehouse and the Data Lake (Oracle Object Storage buckets) from within ADB.
* Use Oracle Machine Learning Notebooks to view and analyze the data from ADB and the Data Lake.

### Prerequisites

* An Oracle Cloud Account - Please view this workshop's LiveLabs landing page to see which environments are supported. You may use your own cloud account or you can get a Free Trial account as described in the **Get Started** lab in the **Contents** menu.

  *Note: If you have a **Free Trial** account, when your Free Trial expires your account will be converted to an **Always Free** account. You will not be able to conduct Free Tier workshops unless the Always Free environment is available. **[Click here for the Free Tier FAQ page.](https://www.oracle.com/cloud/free/faq.html)***

* At least one Data Catalog user in your tenancy. This user must be created in Oracle Cloud Infrastructure Identity and Access Management (IAM).

You may now proceed to the next lab.

## Learn More

* [Get Started with Data Catalog](https://docs.oracle.com/en-us/iaas/data-catalog/using/index.htm)
* [Data Catalog Overview](https://docs.oracle.com/en-us/iaas/data-catalog/using/overview.htm)
* [Using Oracle Autonomous Database on Shared Exadata Infrastructure](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)
* [Oracle Cloud Infrastructure Documentation](https://docs.cloud.oracle.com/en-us/iaas/Content/GSG/Concepts/baremetalintro.htm)
* [What Is a Data Catalog and Why Do You Need One?](https://www.oracle.com/big-data/what-is-a-data-catalog/)

## Acknowledgements
* **Author:** Lauran Serhal, Consulting User Assistance Developer, Oracle Autonomous Database and Big Data
* **Contributor:** Marty Gubar, Product Manager, Server Technologies    
* **Last Updated By/Date:** Lauran Serhal, February 2022

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation License, Version 1.3 or any later version published by the Free Software Foundation; with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts. A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle.github.io/learning-library/data-management-library/autonomous-database/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
