# Install Sample Data

## Introduction

This lab uses sample data loaded into the Autonomous AI Database from Oracle Cloud Infrastructure Object Store.  You will create four tables and load data from Object Storage using the DBMS\_CLOUD.COPY\_DATA procedure. 

Estimated Time:  10 minutes with one ocpu.

### Objectives

In this lab, you will:

- Install sample data.

### Prerequisites:

- Complete the previous lab.

**Author's note.  Before publication, replace PAR with PAR to final bucket.**

## Task 1 - Load Sample Data

To load sample data in this lab.

1.  Log out of Database Actions/SQL Worksheet as the ADMIN user.
1.  Using SQL Worksheet, connect to the database using the **MOVIESTREAM** user created in Lab 3.
1.  Run the following commands in SQL Worksheet.  They can be run all at once as a script or individually, as you prefer.


~~~SQL
<copy>
 -- -------------------------------------------------------------------------------
 -- Table:  TIME_DIM
 -- -------------------------------------------------------------------------------

CREATE TABLE time_dim (
    "DAY_ID"          DATE,
    "MONTH"           VARCHAR2(7),
    "MONTH_OF_YEAR"   VARCHAR2(36),
    "QUARTER"         VARCHAR2(7),
    "YEAR"            VARCHAR2(4)
);

BEGIN
  DBMS_CLOUD.COPY_DATA (
  table_name => 'TIME_DIM',
    file_uri_list => 'https://objectstorage.us-ashburn-1.oraclecloud.com/p/zL6bsboZrSxJP-0ilfUpROTwwyhzvkUrZu9OEwcU5_B_NAGzHKBG_WqW2OnNYxKk/n/c4u04/b/datastudio/o/av-getting-started-data-studio-11349/table=TIME_DIM/*.csv',
  format => '{"delimiter":",","recorddelimiter":"newline","skipheaders":"1","quote":"\\\"","rejectlimit":"1000","trimspaces":"rtrim","ignoreblanklines":"false","ignoremissingcolumns":"true","dateformat":"DD-MON-YYYY HH24:MI:SS"}'
  );
END;
/

-- Year 2024 less than one month of data.  This distorts some charts, so it is deleted for this lab.
DELETE FROM time_dim WHERE year = '2024';
COMMIT;

 -- -------------------------------------------------------------------------------
 -- Table:  CUSTOMER_DIM
 -- -------------------------------------------------------------------------------

CREATE TABLE customer_dim (
    "CUSTOMER_ID"      NUMBER,
    "CITY"             VARCHAR2(202),
    "STATE_PROVINCE"   VARCHAR2(104),
    "COUNTRY"          VARCHAR2(400),
    "CONTINENT"        VARCHAR2(400)
);

BEGIN
  DBMS_CLOUD.COPY_DATA (
  table_name => 'CUSTOMER_DIM',
    file_uri_list => 'https://objectstorage.us-ashburn-1.oraclecloud.com/p/zL6bsboZrSxJP-0ilfUpROTwwyhzvkUrZu9OEwcU5_B_NAGzHKBG_WqW2OnNYxKk/n/c4u04/b/datastudio/o/av-getting-started-data-studio-11349/table=CUSTOMER_DIM/*.csv',
  format => '{"delimiter":",","recorddelimiter":"newline","skipheaders":"1","quote":"\\\"","rejectlimit":"1000","trimspaces":"rtrim","ignoreblanklines":"false","ignoremissingcolumns":"true","dateformat":"DD-MON-YYYY HH24:MI:SS"}'
  );
END;
/

 -- -------------------------------------------------------------------------------
 -- Table:  SEARCH_GENRE_DIM
 -- -------------------------------------------------------------------------------

CREATE TABLE search_genre_dim (
    "GENRE_ID"     NUMBER,
    "GENRE_NAME"   VARCHAR2(30)
);


BEGIN
  DBMS_CLOUD.COPY_DATA (
  table_name => 'SEARCH_GENRE_DIM',
    file_uri_list => 'https://objectstorage.us-ashburn-1.oraclecloud.com/p/zL6bsboZrSxJP-0ilfUpROTwwyhzvkUrZu9OEwcU5_B_NAGzHKBG_WqW2OnNYxKk/n/c4u04/b/datastudio/o/av-getting-started-data-studio-11349/table=SEARCH_GENRE_DIM/*.csv',
  format => '{"delimiter":",","recorddelimiter":"newline","skipheaders":"1","quote":"\\\"","rejectlimit":"1000","trimspaces":"rtrim","ignoreblanklines":"false","ignoremissingcolumns":"true","dateformat":"DD-MON-YYYY HH24:MI:SS"}'
  );
END;
/

 -- -------------------------------------------------------------------------------
 -- Table:  MOVIE_SALES_FACT
 -- -------------------------------------------------------------------------------

CREATE TABLE movie_sales_fact (
    "DAY_ID"             DATE,
    "CUST_ID"            NUMBER,
    "GENRE_ID"           NUMBER,
    "LIST_PRICE"         NUMBER,
    "DISCOUNT_PERCENT"   NUMBER,
    "SALES"              NUMBER,
    "QUANTITY"           NUMBER
);

BEGIN
  DBMS_CLOUD.COPY_DATA (
  table_name => 'MOVIE_SALES_FACT',
    file_uri_list => 'https://objectstorage.us-ashburn-1.oraclecloud.com/p/zL6bsboZrSxJP-0ilfUpROTwwyhzvkUrZu9OEwcU5_B_NAGzHKBG_WqW2OnNYxKk/n/c4u04/b/datastudio/o/av-getting-started-data-studio-11349/table=MOVIE_SALES_FACT/*.csv',
  format => '{"delimiter":",","recorddelimiter":"newline","skipheaders":"1","quote":"\\\"","rejectlimit":"1000","trimspaces":"rtrim","ignoreblanklines":"false","ignoremissingcolumns":"true","dateformat":"DD-MON-YYYY HH24:MI:SS"}'
  );
END;
/
</copy>
~~~

## Task 2 - Confirm That Data is Loaded

You can view the tables you just created using the following commands in SQL Worksheet.

~~~SQL
<copy>
SELECT * FROM time_dim;

SELECT * FROM search_genre_dim;

SELECT * FROM customer_dim;

SELECT * FROM movie_sales_fact;
</copy>
~~~

You may now **proceed to the next lab**

## Acknowledgements

- Created By/Date - William (Bud) Endress, Product Manager, Autonomous AI Database, June 2023
- Last Updated By - William (Bud) Endress, May 2024

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C)  Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)