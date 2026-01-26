# Wrap up of the Data Studio overview workshop


## Introduction

This lab will summarize the workshop and guide you through the process to clean demo data. 

## Task 1: Wrap up

We started this workshop with a Monday morning team meeting. John, VP of marketing, wanted to send discount offers to high-value customers. He also had questions about individual preferences of movie genre based on age groups, marital status, customer value etc.

Let's go through the action items again. 

1. Find relevant data

    We learned how to use the catalog tool to look for desired tables. There are different ways to search, preview the data and do a quick profile check.

2. Load data

    Age group data was missing from the database. There are many ways to 
    import data from various sources into an Autonomous AI Database. We imported it from the object store.

3. Transform and prepare data

    Now we had all the tables we needed. However, the data needed to be prepared for our analysis that requires transformation. We learned how to transform the data and load into an analysis table. The Transforms tool made this task easy with a drag-and-drop user interface. 

4. Analyze data

    Finally, we learned how to analyze the data across various customer attributes. We also found interesting results unearthed by the Insights process. 

Various tools of Data Studio worked seamlessly with each other, helping us complete all the action items successfully.

Now we are ready for our next Monday meeting.



## Task 2: Clean demo data

>**Note:** Cleaning demo data is optional. If you want to keep the demo data then skip it.

1. To remove the tables and views created during this workshop from your database simply copy and paste this code into your SQL Worksheet.

    *For copy/pasting, be sure to click the convenient __Copy__ button in the upper right corner of the following code snippet.*: 

    ```
    <copy>
DROP TABLE CUSTOMER_CA;
DROP TABLE MOVIESALES_CA;
DROP TABLE GENRE;
DROP TABLE MOVIE;
DROP TABLE TIME;
DROP TABLE AGE_GROUP;
DROP TABLE CUSTOMER_SALES_ANALYSIS;
    </copy>
    ```
2. Paste the SQL statements in the worksheet. Click on the **Run Script** icon.

    >**Note:** Expect to receive "ORA-00942 table or view does not exist" or "ORA-18307: analytic view CUSTOMER\_SALES\_ANALYSIS\_AV does not exist" errors during the DROP command if objects are already dropped, but you should not see any other errors.

    ![Screenshot of SQL worksheet](images/image_sql_worksheet.png)

    Now you have cleaned the tables and analytic view created in this workshop.

## Acknowledgements

- Created By/Date - Jayant Mahto, Product Manager, Autonomous AI Database, January 2023
- Contributors - Mike Matthews, Bud Endress, Ashish Jain, Marty Gubar, Rick Green
- Last Updated By - Jayant Mahto, August 2025


Copyright (C)  Oracle Corporation.