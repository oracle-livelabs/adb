# Cleaning demo data for the Data Studio overview workshop


## Introduction

This lab will guide you through the steps to clean demo data. 

## Task 1: Execute the script

1. Below is the script you need to execute to load demo data. Simply copy and paste this code into your SQL Worksheet.

*For copy/pasting, be sure to click the convenient __Copy__ button in the upper right corner of the following code snippet. You need to hover your mouse at the upper right corner of the script box to see the copy icon.*: 

![Screenshot of copy icon](images/image_copy_icon.png)


```
DROP TABLE CUSTOMER_CA
;

DROP TABLE MOVIESALES_CA
;
 

DROP TABLE GENRE
;


DROP TABLE MOVIE
;


DROP TABLE TIME
;

DROP TABLE AGE_GROUP
;

DROP TABLE CUSTOMER_SALES_ANALYSIS
;

DROP ANALYTIC VIEW CUSTOMER_SALES_ANALYSIS_AV
;


```
2. Paste the SQL statements in the worksheet. Click on the **Run Script** icon.

>**Note:** Expect to receive "ORA-00942 table or view does not exist" or "ORA-18307: analytic view XYZ does not exist" errors during the DROP command if objects are already dropped, but you should not see any other errors.

![Screenshot of SQL worksheet](images/image_sql_worksheet.png)

Now you have cleaned the tables and analytic view created in this workshop.

## Acknowledgments

- Created By/Date - Jayant Mahto, Product Manager, Autonomous Database, January 2023
- Contributors - Mike Matthews, Bud Endress, Ashish Jain, Marty Gubar, Rick Green
- Last Updated By - Jayant Mahto, January 2023


Copyright (C)  Oracle Corporation.