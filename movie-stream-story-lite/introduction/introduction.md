![moviestream](images/moviestream.jpeg)
# Introduction

## About this Workshop

Most workshops focus on teaching you about a cloud service or performing a series of tasks. This workshop is different. You will learn how to deliver high value solutions using Oracle Cloud data platform services. And, the workshop will do this in the context of a company that we all can relate to and understand.

Estimated Workshop Time: 90 minutes

There are also other workshops that focus on specific feature areas that also use the same business scenario.

Oracle MovieStream is a fictitious movie streaming service - similar to those that you currently subscribe to. They face challenges that are typical to many organizations across industries. MovieStream must:
* Gain a better understanding of their customers to ensure that they love the service  
* Offer the right products to the right customers at the right price  
* Grow the business to become a dominant player in the streaming business
* And much, much more

Oracle Cloud provides an amazing platform to productively deliver secure, insightful, scalable and performant solutions. MovieStream designed their solution leveraging the world class Oracle Autonomous Database and Oracle Cloud Infrastructure (OCI) Data Lake services. Their data architecture is following the Oracle Reference Architecture [Enterprise Data Warehousing - an Integrated Data Lake](https://docs.oracle.com/en/solutions/oci-curated-analysis/index.html#GUID-7FF7A024-5EB0-414B-A1A5-4718929DC7F2) - which is used by Oracle customers around the world. It's worthwhile to review the architecture so you can understand the value of integrating the data lake and data warehouse - as it enables you to answer more complex questions using all your data.

In this workshop, we'll start with two key components of MovieStream's architecture. MovieStream is storing their data across Oracle Object Storage and Autonomous Database. Data is captured from various sources into a landing zone in object storage. This data is then processed (cleansed, transformed and optimized) and stored in a gold zone on object storage. Once the data is curated, it is loaded into an Autonomous Database where it is analyzed by many (and varied) members of the user community.

![architecture](images/architecture.png)

You will learn how they built their solution and performed sophisticated analytics through a series of labs that highlight the following:

### Objectives
* Automatically deploy the database and data required for the workshop using Terraform and OCI Resource Manager. 
* Use advanced SQL to uncover issues and possibilities
* Query your data using natural language with Select AI
* Load data and gain insights from user feedback with AI
* Predict customer churn using Machine Learning
* Use spatial analyses and Select AI to help provide localized promotions
* Offer recommendations based on graph relationships

## Learn more

* [Data Management Reference Architectures](https://docs.oracle.com/solutions/?q=autonomous%20database%20data%20management&cType=reference-architectures%2Csolution-playbook%2Cbuilt-deployed&sort=date-desc&lang=en)
* [Autonomous Database Workshops](https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/livelabs-workshop-cards?p100_workshop_series=222)
* [Autonomous Database web site](https://www.oracle.com/autonomous-database/)


## Acknowledgements
* **Author** - Marty Gubar, Autonomous Database Product Management
* **Last Updated By/Date** - Marty Gubar, May 2025

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C)  Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
