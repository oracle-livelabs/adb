# Understand the requirements of a fictitious data analysis project


## Introduction

We will go through "a life in a day" of a data analyst. We will start with the Monday morning of a fictitious team. This team is assigned a task and can use your help in completing it.

Estimated Time: 5 minutes


### Objectives

In this workshop, you will learn:
-	How to break down a project requirement and learn which tool to use

### Prerequisites

To complete this lab, you need to have completed the previous labs, so that you have:

- Created an Autonomous Data Warehouse instance
- Created a new QTEAM user with appropriate roles
- demo data loaded


## Task 1: Help a fictitious team in a data analysis project

1.  Let's start with the Monday morning team meeting.
    
    **Meeting notes from the weekly marketing team meeting**
    
    Date: Monday 1-09-2023
    Attendees: All team members
    
    Patrick, VP of marketing, wants to send discount offers to **high-value** customers. 
    He also wants movie genre preferences based on age groups and
    marital status. He also wants to know **whether movie genre preferences
    are different across high-value and low-value customers**.
    
    **Brainstorming:**

    Our team member Bud suggested creating five equal quintiles for customers based on movie
    purchases made by a customer. We could then send offers only to top quintile customers.
    
    Everyone agreed it is the right strategy.

2.  Where is my data?
    
    Our next step is to look for available data in our database. We find that
    Sales data is loaded into the object store bucket every day. Another team member, Ashish
    is going to set up a live feed from the object store to the **MOVIESALES_CA**
    table. This table will have timestamped sales data. There are tables for
    customer and movie genres as well and we can look for them in the database.

    For our project, we can use these tables. If some data is missing then we can load it from
    an external source too.

    **Note to myself:** live feed sounds interesting. Learn how he sets it up in some other workshop.

3.  Action Items:

    **Find relevant data**

    Look for **MOVIESALES_CA** and other tables needed for this analysis. Makes 
    sure all needed columns are available with data populated.

    Use the data catalog for browsing and searching.
    
    **Load data**

    Load any additional data needed. we have a data load tool for this.
    
    **Transform and prepare data**

    Create data flow to aggregate movie sales and populate the column containing quintile value. 
    Schedule this to load every Sunday at 9 pm.

    Next, add denormalized columns needed for analysis to this table for
    analyzing data. This table should have all the attributes needed for
    analysis.

    This can be done by using the data transforms tool.
    
    **Analyze**

    We need to create a dimensional model for data analysis.
    Create an Analytic View to analyze sales data by various dimensions such as age group, genre, marital status etc 
    using the data analysis tool.

    Is there anything more we learn from the data? We have a data insights tool to automatically
    scan the data for hidden patterns. It will be interesting to see what this tool finds.


**Data Studio** in Autonomous Database provides a set of tools to help in such projects, all under one umbrella. There
is no need to install and manage any additional tool. It makes the job of a data analyst easy. They 
already have their hands full in dealing with data and finding value in it. The least they should
be worried about is which tool to use for the job at hand and where to get them from.

**Let's begin!** 

You may now **proceed to the next lab**.

## Acknowledgements

- Created By/Date - Jayant Mahto, Product Manager, Autonomous Database, January 2023
- Contributors - Mike Matthews, Bud Endress, Ashish Jain, Marty Gubar, Rick Green
- Last Updated By - Jayant Mahto, January 2023


Copyright (C)  Oracle Corporation.