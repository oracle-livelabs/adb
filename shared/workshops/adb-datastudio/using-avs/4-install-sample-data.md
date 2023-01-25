# Introduction

This lab uses sample data that is loaded into the Autonomous Database from a OCI cloud store.

# Load Sample Data

To load sample data this lab.

1. Using SQL Worksheet, connect to the database using the  **MOVIESTREAM** (or other) user created in Lab 3.
2. Run the following commands in SQL Worksheet.

~~~
 -- -------------------------------------------------------------------------------
 -- Table:  CUSTOMER_DIM
 -- -------------------------------------------------------------------------------

CREATE TABLE customer_dim (
    "CUSTOMER_ID"                   NUMBER,
    "CITY"                          VARCHAR2(202),
    "STATE_PROVINCE"                VARCHAR2(104),
    "COUNTRY"                       VARCHAR2(400),
    "COUNTRY_CODE"                  VARCHAR2(2),
    "CONTINENT"                     VARCHAR2(400),
    "CUSTOMER_SEGMENT"              VARCHAR2(100),
    "CUSTOMER_SEGMENT_SHORT_NAME"   VARCHAR2(100),
    "CUSTOMER_JOB_TYPE"             VARCHAR2(200),
    "MARITAL_STATUS"                VARCHAR2(7),
    "AGE_GROUP"                     VARCHAR2(11),
    "INCOME_LEVEL"                  VARCHAR2(20),
    "EDUCATION"                     VARCHAR2(14),
    "HOUSEHOLD_SIZE"                NUMBER,
    "EMPLOYED_FULL_TIME"            VARCHAR2(9)
);

 -- -------------------------------------------------------------------------------
 -- Load Data
 -- -------------------------------------------------------------------------------

BEGIN
  DBMS_CLOUD.COPY_DATA (
  table_name => 'CUSTOMER_DIM',
    file_uri_list => 'https://objectstorage.uk-london-1.oraclecloud.com/p/myKeII2pFaBpdwYdbKOHLQSpw9m-gL2HCXD3M-Bm6_sfOY1zw2F3unzEuISUpDIC/n/adwc4pm/b/data_library/o/d1846/table=CUSTOMER_DIM/*.csv',
  format => '{"delimiter":",","recorddelimiter":"newline","skipheaders":"1","quote":"\\\"","rejectlimit":"1000","trimspaces":"rtrim","ignoreblanklines":"false","ignoremissingcolumns":"true","dateformat":"DD-MON-YYYY HH24:MI:SS"}'
  );
END;
/
 -- -------------------------------------------------------------------------------
 -- Table:  MOVIE_SALES_FACT
 -- -------------------------------------------------------------------------------

CREATE TABLE movie_sales_fact (
    "DAY"                DATE,
    "DAY_OF_WEEK"        VARCHAR2(38),
    "MONTH"              VARCHAR2(7),
    "QUARTER"            VARCHAR2(7),
    "YEAR"               VARCHAR2(4),
    "CUST_ID"            NUMBER,
    "MOVIE_ID"           NUMBER,
    "SEARCH_GENRE"       VARCHAR2(30),
    "DEVICE"             VARCHAR2(100),
    "OPERATING_SYSTEM"   VARCHAR2(100),
    "APPLICATION"        VARCHAR2(100),
    "DISCOUNT_TYPE"      VARCHAR2(100),
    "PAYMENT_METHOD"     VARCHAR2(100),
    "LIST_PRICE"         NUMBER,
    "DISCOUNT_PERCENT"   NUMBER,
    "SALES"              NUMBER,
    "QUANTITY"           NUMBER
);

-- -------------------------------------------------------------------------------
-- Load Data
-- -------------------------------------------------------------------------------


BEGIN
  DBMS_CLOUD.COPY_DATA (
  table_name => 'MOVIE_SALES_FACT',
    file_uri_list => 'https://objectstorage.uk-london-1.oraclecloud.com/p/myKeII2pFaBpdwYdbKOHLQSpw9m-gL2HCXD3M-Bm6_sfOY1zw2F3unzEuISUpDIC/n/adwc4pm/b/data_library/o/d1846/table=MOVIE_SALES_FACT/*.csv',
  format => '{"delimiter":",","recorddelimiter":"newline","skipheaders":"1","quote":"\\\"","rejectlimit":"1000","trimspaces":"rtrim","ignoreblanklines":"false","ignoremissingcolumns":"true","dateformat":"DD-MON-YYYY HH24:MI:SS"}'
  );
END;
/
~~~

## Acknowledgements

- Created By/Date - William (Bud) Endress, Product Manager, Autonomous Database, January 2023
- Last Updated By - William (Bud) Endress, January 2023

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C)  Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)