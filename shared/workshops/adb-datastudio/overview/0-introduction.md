# Introduction

## About this Workshop

This is an introductory workshop for the Data Studio. It goes through “a day in the life of a data analyst” and shows how to use it to browse, load, transforms and analyze the data in the Autonomous Database.

Estimated Workshop Duration: 1 hour, 30 minutes


We will go through "a life in a day" of a data analyst. We will start with a fictious team who is assigned a task. We will learn how Data Studio helps in completing the task objectives.

Let's start with the Monday morning team meeting.


## Meeting notes from the weekly marketing team meeting

Date: Monday 1-09-2023
Attendees: All team members

Patrick wants to send discount offers to **high value** customers. 
He also wants movie genre preference based on age groups and
marital status. He also to know **whether movie genre preferences
are different across high value and low value customers**.

### Brainstorming:

Bud suggested creating five equal quintiles for customers based on movie
purchases made by a customers. 
We could then send offers only to top quintile customers.

Everyone agreed it is the right strategy.

### Where is the data?

Everyday sales data is being loaded to the object store bucket. Ashish
is going to setup a live feed from object store to **MOVIESALES_CA**
table. This table will have timestamped sales data. There are tables for
customer and movie genre as well.
(note to myself: confirm the table name. Also livefeed sounds
interesting. Learn how he sets it up in the future).

## Action Items:

### Load data:

Check for **MOVIESALES_CA** and other tables needed for this analysis and 
load any additional data needed.

### Prepare data:

Create data flow to aggregate movie sales and
populate quintile column. Schedule this to load every Sunday 9pm.

Also add denormalized columns needed for analysis to this table for
analyzing data. This table should have all the attributes needed for
analysis.

### Analyze:

 Create Analytic View to analyze sales data by various dimensions such as
age group, genre, marital status etc.

### Insight:

Is there anything more we learn from the data?

 

## Objectives

In this workshop, you will learn:
-	How to browse the catalog to find the data you need
-	How to load data from your local file
-	How to prepare your data for analysis
-	How to analyze the data (involves creating a simple dimensional model)
-	How to find hidden insights


## Prerequisites

Before you launch into this workshop, you will need the following:

- Basic knowledge of Oracle Cloud
- Basic level of understanding of SQL query language


**Let's begin!** 

If you have any questions about the topics covered in this lab and the entire workshop, please contact us by posting on our public forum on  **[cloudcustomerconnect.oracle.com](https://cloudcustomerconnect.oracle.com/resources/32a53f8587/)**  and we will respond as soon as possible.


## Acknowledgements

- Created By/Date - Jayant Mahto, Product Manager, Autonomous Database, January 2023
- Contributors - Mike Matthews, Bud Endress, Ashish Jain, Marty Gubar, Rick Green
- Last Updated By - Jayant Mahto, January 2023


Copyright (C)  Oracle Corporation.


