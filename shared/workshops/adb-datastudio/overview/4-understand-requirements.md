# Understand the requirements of a fictitious data analysis project


## Introduction

We will go through a day in the life of a Data Analyst in a movie streaming business company. We will start with the Monday morning meeting of a fictitious team. This team is assigned a task and can use your help in completing it.

Estimated Time: 5 minutes


### Objectives

In this workshop, you will learn:
-	How to break down a project requirement and learn which tool to use

### Prerequisites

To complete this lab, you need to have completed the previous labs, so that you have:

- Created an Autonomous AI Lakehouse instance
- Created a new QTEAM user with appropriate roles
- Loaded the demo data for the workshop


## Task 1: Help a fictitious team in a data analysis project

1.  Let's start with the Monday morning team meeting.
    
    **Meeting notes from the weekly marketing team meeting**
    
    Date: Monday 1-09-2025
    Attendees: All team members
    
    John, VP of marketing, wants to send discount offers to high value customers.
    He wants to know which genres of movies are preferred by different age and marital status groups.
    He also wants to know whether movie genre preferences
    are different across high-value and low-value customers.
    
    **Brainstorming:**

    Our team member Shaun suggested creating five equal quintiles of customers based on 
    the number of movie purchases they have made. We could then send offers only to the top 
    quintile – the customers that buy the most movies.
    
    Everyone agreed it is the right strategy.

2.  Where is my data?
    
    Our next step is to look for available data in our database. We find that
    Sales data is loaded into the object store bucket every day. Another team member, Shelly,
    is going to set up a live feed from the object store to the **MOVIESALES\_CA**
    table. This table will have timestamped sales data. There are tables for
    customer and movie genres as well and we can look for them in the database.

    For our project, we can use these tables. If some data is missing then we can load it from
    an external source.

    **Note:** We will assume that live feed is setup to load **MOVIESALES\_CA** table.

3.  Action Items:

    **Find relevant data**

    Look for **MOVIESALES\_CA** and other tables needed for this analysis. Make 
    sure all needed columns are available with data populated.

    Use **Catalog** tool for browsing and searching.
    
    **Load data**

    Load any additional data needed. We have a **Data Load** tool for this.
    
    **Transform and prepare data**

    Create a data flow to aggregate movie sales and populate the column containing the quintile value. 
    Schedule this to load every Sunday at 9 pm.

    Next, add denormalized columns needed for analysis to this table for
    analyzing data. This table should have all the attributes needed for
    analysis.

    This can be done by using the **Data Transforms** tool.
    
    **Analyze**

    We need to analyze sales data by various dimensions such as age group, genre and marital status 
    using the **Analysis** tool.

    Is there anything more we learn from the data? We have a **Insights** tool to automatically
    scan the data for hidden patterns. It will be interesting to see what this tool finds.


**Data Studio** in Autonomous AI Database provides a set of tools to help in such projects, all under one umbrella. There
is no need to install and manage any additional software. It makes the job of a Data Analyst easy. They 
already have their hands full in dealing with data and finding value in it. The least they should
be worried about is which tool to use for the job at hand and where to get them from.

**Let's begin!** 

You may now **proceed to the next lab**.

## Acknowledgements

- Created By/Date - Jayant Mahto, Product Manager, Autonomous AI Database, January 2023
- Contributors - Mike Matthews, Bud Endress, Ashish Jain, Marty Gubar, Rick Green
- Last Updated By - Jayant Mahto, January 2025


Copyright (C)  Oracle Corporation.