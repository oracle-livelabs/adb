# Examine Lookup Queries

## Introduction

APEX developers often write queries to populate select lists, pop-up LOVs, radio lists, or trees.

**Estimated Time:** 5 minutes

### Objectives

- Examine and run queries used to provide lists of values for APEX items.

### Prerequisites

- Complete the previous lab.

## Task 1 - List of Geographies

To populate a list of values for a single level (e.g., continent or country), use a simple query like this:

~~~SQL
<copy>
SELECT
  DISTINCT continent AS d,
  continent AS r
FROM
  customer_dim
ORDER BY
  continent;
</copy>
~~~

Or for a different level:

~~~SQL
<copy>
SELECT
  DISTINCT country AS d,
  country AS r
FROM
  customer_dim
ORDER BY
  country;
</copy>
~~~

## Task 2 - A List of Geographies with Multiple Levels

To support multiple levels in a single LOV, use `UNION` to combine the results:

~~~SQL
<copy>
SELECT DISTINCT
    continent AS d
  , continent AS r
FROM
    customer_dim
UNION
SELECT DISTINCT
    country AS d
  , country AS r
FROM
    customer_dim
UNION
SELECT DISTINCT
    state_province AS d
  , state_province AS r
FROM
    customer_dim;
</copy>
~~~

## Task 3 - A List of Geographies with Multiple Levels and Hierarchical Metadata

Add level and depth metadata to support filtering and sorting:

~~~SQL
<copy>
SELECT DISTINCT
    continent   AS d
  , continent   AS r
  , 'Continent' AS "LEVEL"
  , 1           AS depth
  , continent   AS continent
  , NULL        AS country
FROM
    customer_dim
UNION
SELECT DISTINCT
    country   AS d
  , country   AS r
  , 'Country' AS "LEVEL"
  , 2         AS depth
  , continent AS continent
  , country   AS country
FROM
    customer_dim
UNION
SELECT DISTINCT
    state_province   AS d
  , state_province   AS r
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
  , d;
</copy>
~~~

You can apply the same idea to time periods:

~~~SQL
<copy>
SELECT DISTINCT
    year   AS d
  , year   AS r
  , 'Year' AS "LEVEL"
  , 1      AS depth
  , year   AS year
  , NULL   AS quarter
  , NULL   AS month
FROM
    time_dim
UNION
SELECT DISTINCT
    quarter   AS d
  , quarter   AS r
  , 'Quarter' AS "LEVEL"
  , 2         AS depth
  , year      AS year
  , quarter   AS quarter
  , NULL      AS month
FROM
    time_dim
UNION
SELECT DISTINCT
    month   AS d
  , month   AS r
  , 'Month' AS "LEVEL"
  , 3       AS depth
  , year    AS year
  , quarter AS quarter
  , NULL    AS month
FROM
    time_dim
UNION
SELECT DISTINCT
    to_char(day_id, 'DD-MON-YYYY') AS d
  , to_char(day_id, 'DD-MON-YYYY') AS r
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
  , d;
</copy>
~~~

There must be a better way!

You may now **proceed to the next lab**.

## Acknowledgements

- **Created By** - William (Bud) Endress, Product Manager, Autonomous Database, June 2023  
- **Last Updated By** - William (Bud) Endress, June 2025

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C) Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation License, Version 1.3 or any later version published by the Free Software Foundation;  with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.  A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
