# Prepare Autonomous AI Database for the Data Studio overview workshop


## Introduction

This lab will guide you through the steps to prepare Autonomous AI Database. 

Estimated Time: 5 minutes

<!--
Watch the video below for a quick walk-through of the lab.
[Create a database user](videohub:1_v0l1ljqo)
-->

### Prerequisites

- Created an Autonomous AI Lakehouse instance
- Created a new QTEAM user with appropriate roles

## Task 1: Access the SQL worksheet

SQL worksheet is linked from the **Database Actions** home page.

In the previous lab, you created the database user **QTEAM**, and you should still be connected as user QTEAM. If you are already logged in as QTEAM, and on the Database Actions home page, you may go directly to Step 2. 

1. There are two ways to reach the Database Actions home page, where you can find Data Studio and other useful tools for your database.

    - Via the Autonomous AI Database console page
    - Directly login to your DB user via URI

    ### Access Database Actions via the Console

    On the Autonomous AI Database Details page, click the **Database Actions** button:

    ![Screenshot of the link to Database Actions from the database console page](images/image_db_console.png)

    ### Access Database Actions directly via URI

    Login to your DB user directly.

    ![Link to open Database Actions from the user login page](images/image_user_login.png)

2. This will take you to the Autonomous AI Database **Database Actions** page (shown below), with links to the SQL worksheet under Development tools. 
    
    Click on the **SQL**.

    ![The Database Actions home page](images/image_db_action.png)


## Task 2: Execute the script

1. Go to the next step if you are first time preparing the demo data. Use this script to cleanup your previously loaded demo data.

    Simply copy and paste this code into your SQL Worksheet.

    *For copy/pasting, be sure to click the convenient __Copy__ button in the upper right corner of the following code snippet.*:
    ```
    <copy>
DROP TABLE CUSTOMER_CA;
DROP TABLE MOVIESALES_CA;
DROP TABLE GENRE;
DROP TABLE MOVIE;
DROP TABLE TIME;
DROP TABLE CUSTOMER_SALES_ANALYSIS;
DROP TABLE CUSTOMER_SALES_ANALYSIS_FULL;

    </copy>
    ```
    >**Note:** Expect to receive "ORA-00942 table or view does not exist" errors during the DROP TABLE command if you run this on an empty schema.

    ![Screenshot of SQL worksheet](images/image_sql_worksheet.png)

2. Below is the script you need to execute to load demo data. Simply copy and paste this code into your SQL Worksheet.

    *For copy/pasting, be sure to click the convenient __Copy__ button in the upper right corner of the following code snippet.*: 

    ```
    <copy>
CREATE TABLE CUSTOMER_CA 
    ( 
     CUST_ID        NUMBER , 
     AGE            NUMBER , 
     EDUCATION      VARCHAR2 (40) , 
     GENDER         VARCHAR2 (20) , 
     INCOME_LEVEL   VARCHAR2 (20) , 
     MARITAL_STATUS VARCHAR2 (8) , 
     PET            VARCHAR2 (40) 
    ) 
;
CREATE TABLE MOVIESALES_CA 
    ( 
     DAY_ID           DATE , 
     GENRE_ID         NUMBER , 
     MOVIE_ID         NUMBER , 
     CUST_ID          NUMBER , 
     APP              VARCHAR2 (100) , 
     DEVICE           VARCHAR2 (100) , 
     OS               VARCHAR2 (100) , 
     PAYMENT_METHOD   VARCHAR2 (100) , 
     LIST_PRICE       NUMBER , 
     DISCOUNT_TYPE    VARCHAR2 (100) , 
     DISCOUNT_PERCENT NUMBER , 
     TOTAL_SALES      NUMBER 
    ) 
;
CREATE TABLE GENRE 
    ( 
     GENRE_ID NUMBER , 
     GENRE    VARCHAR2 (30) 
    ) 
;
CREATE UNIQUE INDEX PK_GENRE_ID ON GENRE 
    ( 
     GENRE_ID ASC 
    ) 
;
ALTER TABLE GENRE 
    ADD CONSTRAINT PK_GENRE_ID PRIMARY KEY ( GENRE_ID ) 
    USING INDEX PK_GENRE_ID 
;
CREATE TABLE MOVIE 
    ( 
     MOVIE_ID     NUMBER , 
     TITLE        VARCHAR2 (200) , 
     BUDGET       NUMBER , 
     GROSS        NUMBER , 
     LIST_PRICE   NUMBER , 
     GENRES       VARCHAR2 (4000) , 
     SKU          VARCHAR2 (30) , 
     YEAR         NUMBER , 
     OPENING_DATE DATE , 
     VIEWS        NUMBER , 
     CAST         VARCHAR2 (4000) , 
     CREW         VARCHAR2 (4000) , 
     STUDIO       VARCHAR2 (4000) , 
     MAIN_SUBJECT VARCHAR2 (4000) , 
     AWARDS       VARCHAR2 (4000) , 
     NOMINATIONS  VARCHAR2 (4000) , 
     RUNTIME      NUMBER , 
     SUMMARY      VARCHAR2 (16000) 
    ) 
;
CREATE TABLE TIME 
    ( 
     DAY_ID           DATE , 
     DAY_NAME         VARCHAR2 (36) , 
     DAY_OF_WEEK      NUMBER , 
     DAY_OF_MONTH     NUMBER , 
     DAY_OF_YEAR      NUMBER , 
     WEEK_OF_MONTH    NUMBER , 
     WEEK_OF_YEAR     NUMBER , 
     MONTH_OF_YEAR    NUMBER , 
     MONTH_NAME       VARCHAR2 (36) , 
     MONTH_SHORT_NAME VARCHAR2 (12) , 
     QUARTER_NAME     VARCHAR2 (7) , 
     QUARTER_OF_YEAR  NUMBER , 
     YEAR_NAME        NUMBER 
    ) 
;
CREATE TABLE CUSTOMER_SALES_ANALYSIS
(
  MIN_AGE NUMBER(38),
GENRE VARCHAR2(30 CHAR),
AGE_GROUP VARCHAR2(4000 CHAR),
GENDER VARCHAR2(20 CHAR),
APP VARCHAR2(100 CHAR),
DEVICE VARCHAR2(100 CHAR),
OS VARCHAR2(100 CHAR),
PAYMENT_METHOD VARCHAR2(100 CHAR),
LIST_PRICE NUMBER(38),
DISCOUNT_TYPE VARCHAR2(100 CHAR),
DISCOUNT_PERCENT NUMBER(38),
TOTAL_SALES NUMBER(38),
MAX_AGE NUMBER(38),
AGE NUMBER(38),
EDUCATION VARCHAR2(40 CHAR),
INCOME_LEVEL VARCHAR2(20 CHAR),
MARITAL_STATUS VARCHAR2(8 CHAR),
PET VARCHAR2(40 CHAR),
CUST_VALUE NUMBER,
CUST_SALES NUMBER(38)
);
set define on
define file_uri_base = 'https://objectstorage.us-ashburn-1.oraclecloud.com/p/zL6bsboZrSxJP-0ilfUpROTwwyhzvkUrZu9OEwcU5_B_NAGzHKBG_WqW2OnNYxKk/n/c4u04/b/datastudio/o/prepareandanalyze'
begin
 dbms_cloud.copy_data(
    table_name =>'CUSTOMER_CA',
    file_uri_list =>'&file_uri_base/CUSTOMER_CA.csv',
    format =>'{"type" : "csv", "skipheaders" : 1}'
 );
 dbms_cloud.copy_data(
    table_name =>'MOVIESALES_CA',
    file_uri_list =>'&file_uri_base/MOVIESALES_CA.csv',
    format =>'{"type" : "csv", "skipheaders" : 1}'
 );
 dbms_cloud.copy_data(
    table_name =>'GENRE',
    file_uri_list =>'&file_uri_base/GENRE.csv',
    format =>'{"type" : "csv", "skipheaders" : 1}'
 );
 dbms_cloud.copy_data(
    table_name =>'MOVIE',
    file_uri_list =>'&file_uri_base/MOVIE.csv',
    format =>'{"type" : "csv", "skipheaders" : 1}'
 );
 dbms_cloud.copy_data(
    table_name =>'TIME',
    file_uri_list =>'&file_uri_base/TIME.csv',
    format =>'{"type" : "csv", "skipheaders" : 1}'
 );
 FOR TNAME IN (SELECT table_name FROM user_tables  where table_name like 'COPY$%') LOOP
 EXECUTE IMMEDIATE ('DROP TABLE ' || TNAME.table_name || ' CASCADE CONSTRAINTS PURGE');
 END LOOP;
end;
/
CREATE TABLE CUSTOMER_SALES_ANALYSIS_FULL
as SELECT 
GENRE,
GENDER,
AGE_GROUP,
CUST_VALUE,
PET,
MARITAL_STATUS,
EDUCATION,
INCOME_LEVEL,
TOTAL_SALES
FROM CUSTOMER_SALES_ANALYSIS
WHERE 1=2;

    </copy>
    ```

3. Paste the SQL statements in the worksheet. Click on the **Run Script** icon.

    While the script is running, you will see the message "Executing code" at the bottom of the window. 
    The message will change to "SQL executed by QTEAM" when in finishes. There should not be any errors.

    ![Screenshot of SQL worksheet](images/image_sql_worksheet.png)

You may now **proceed to the next lab**.

## Acknowledgements

- Created By/Date - Jayant Mahto, Product Manager, Autonomous AI Database, January 2023
- Contributors - Mike Matthews, Bud Endress, Ashish Jain, Marty Gubar, Rick Green
- Last Updated By - Jayant Mahto, August 2023


Copyright (C)  Oracle Corporation.