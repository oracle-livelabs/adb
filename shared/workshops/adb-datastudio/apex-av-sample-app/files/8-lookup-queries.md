# Lookup Queries

## Introduction

There are many times when the APEX developer also needs to write queries to provide a list of values for a select list, a pop-up list of values, a radio list, or a tree.

Estimated Time:  5 minutes.

### Objectives

In this lab, you will:

- Examine and run queries used to provide lists of values for APEX items.

### Prerequisites:

- Complete the previous lab.

## Task 1 - List of Geographies

You may need a list of all geographies from the CUSTOMER_DIM table for a pop-up LOV (list of values) item on a page in your APEX application.  If the list of values is for a single level, for example, countries, you can provide a SQL Query like this.

~~~SQL
<copy>
SELECT
  DISTINCT continent AS display_value,
  continent AS return_value
FROM
  customer_dim
ORDER BY
  continent;
  </copy>
~~~

You need another query if you need a list for a different level.  For example:

~~~SQL
<copy>
SELECT
  DISTINCT country AS display_value,
  country return_value
FROM
  customer_dim
ORDER BY
  country;
  </copy>
~~~

## Task 2 - A list of Geographies with Multiple Levels

If you need a list with more than one level, you might use a query such as this:

~~~SQL
<copy>
SELECT DISTINCT
    continent AS AS display_value
  , continent AS return_value
FROM
    customer_dim
UNION
SELECT DISTINCT
    country AS AS display_value
  , country AS return_value
FROM
    customer_dim
UNION
SELECT DISTINCT
    state_province AS display_value
  , state_province AS return_value
FROM
    customer_dim;
</copy>
~~~

## Task 3 - A list of Geographies with Multiple Levels and Hierarchical Metadata

Including hierarchical metadata enriches the list of geographies, allowing for filters using levels or hierarchy depth.  You might use a query such as this.

~~~SQL
<copy>
SELECT DISTINCT
    continent   AS display_value
  , continent   AS return_value
  , 'Continent' AS "LEVEL"
  , 1           AS depth
  , continent   AS continent
  , NULL        AS country
FROM
    customer_dim
UNION
SELECT DISTINCT
    country   AS display_value
  , country   AS return_value
  , 'Country' AS "LEVEL"
  , 2         AS depth
  , continent AS continent
  , country   AS country
FROM
    customer_dim
UNION
SELECT DISTINCT
    state_province   AS display_value
  , state_province   AS return_value
  , 'State/Province' AS "LEVEL"
  , 3                AS depth
  , continent        AS continent
  , country          AS country
FROM
    customer_dim
ORDER BY
    depth
  , continent
  , country
  , display_value;
  </copy>
  ~~~

You could create a similar query for time periods.

~~~SQL
<copy>
SELECT DISTINCT
    year   AS display_value
  , year   AS return_value
  , 'Year' AS "LEVEL"
  , 1      AS depth
  , year   AS year
  , NULL   AS quarter
  , NULL   AS month
FROM
    time_dim
UNION
SELECT DISTINCT
    quarter   AS display_value
  , quarter   AS return_value
  , 'Quarter' AS "LEVEL"
  , 2         AS depth
  , year      AS year
  , quarter   AS quarter
  , NULL      AS month
FROM
    time_dim
UNION
SELECT DISTINCT
    month   AS display_value
  , month   AS return_value
  , 'Month' AS "LEVEL"
  , 3       AS depth
  , year    AS year
  , quarter AS quarter
  , NULL    AS month
FROM
    time_dim
UNION
SELECT DISTINCT
    to_char(day_id, 'DD-MON-YYYY') AS display_value
  , to_char(day_id, 'DD-MON-YYYY') AS return_value
  , 'Day'                          AS "LEVEL"
  , 5                              AS depth
  , year                           AS year
  , quarter                        AS quarter
  , month                          AS month
FROM
    time_dim
ORDER BY
    depth
  , year
  , quarter
  , month
  , display_value;
</copy>
~~~

There must be a better way!

You may now **proceed to the next lab**

## Acknowledgements

- Created By/Date - William (Bud) Endress, Product Manager, Autonomous Database, February 2023
- Last Updated By - William (Bud) Endress, February 2023

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C)  Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)