# Introduction

## About this Workshop

In this workshop, you will learn how to use **Autonomous Database DBMS_CLOUD_AI.GENERATE** to query your data using natural language; you don't need prior knowledge of the data structure or how that data is accessed. Next, you'll use those capabilities to interact with an open-source developer friendly application built on React with typescript. Using the MovieStream data, the end user is able to get tailored movie reccomendations along with pizza recomendations. The open-source OpenStreetMap is used to help the user find local pizza shops and take full advantage of the spatial capability of the Autonomous Database. 

The purpose of this lab is to highlight the business logic required to integrate Generative AI with data from the Autonomous Database using both **DBMS_CLOUD_AI.CREATE_PROFILE** and **DBMS_CLOUD_AI.GENERATE.**  

![Introduction Slide](./images/intro-slide.png "")

### What is Natural Language?

Natural language processing is the ability of a computer application to understand human language as it is spoken and written. It is a component of artificial intelligence (AI).

### What is Generative AI?

Generative AI enables users to quickly generate new content based on a variety of inputs. Inputs and outputs to these models can include text, images, sounds, animation, 3D models, and other types of data.

### Objectives

In this workshop, you will:

* Configure your Autonomous Database to leverage a generative AI model for querying data using natural language
* Use **`DBMS_CLOUD_AI.GENERATE`** to query data using natural language
* Learn about using business logic to enhance your APIs 
* Learn about using custom modules and AutoREST to connect your app to ADB 
* Learn about deploying a React App from OCI Console to Object Storage 

### Oracle MovieStream Business Scenario

![MovieStream Logo](./images/moviestream-logo.png "")

The workshop's business scenario is based on Oracle MovieStream - a fictitious movie streaming service that is similar to services to which you currently subscribe. You'll be able to query most recently watched films by CUST_ID, which will trigger Select AI process. The business logic will suggest films from the promoted movie list as well as pizza and their locations. 

You may now proceed to the next lab.

## Learn more

* [Oracle Autonomous Database Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/index.html)
* [Additional Autonomous Database Tutorials](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/tutorials.html)
* [Overview of Generative AI Service](https://docs.oracle.com/en-us/iaas/Content/generative-ai/overview.htm)

## Acknowledgements
  * **Author:** Marty Gubar, Product Management Lauran K. Serhal, Consulting User Assistance Developer
  * **Contributors:** Stephen Stuart, Nicholas Cusato, Olivia Maxwell, Taylor Rees, Joanna Espinosa, Cloud Engineers 
* **Last Updated By/Date:** Stephen Stuart, February 2024

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C)  Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
