# Examine Analytic Queries that Select from Tables

## Introduction

As an Oracle APEX developer, you're responsible for writing or generating the SQL behind reports, charts, and other UI components. SQL for basic reports is straightforward — but building interactive, analytic applications is far more complex. Let’s explore why.

**Estimated Time:** 5 minutes

### Objectives

- Examine and run queries that aggregate data and use analytic expressions.

### Prerequisites

- Complete the previous lab.

## Task 1 - Aggregate Data to Year, Continent, and Search Genre

If you’ve built reports or charts in APEX, you’ve likely written queries like this. Filters are often parameterized using APEX items (e.g., `:P1_GENRE_NAME`).

~~~SQL
<copy>
SELECT
    t.year
  , c.continent
  , sg.genre_name
  , round(AVG(f.list_price), 2)       AS avg_list_price
  , round(AVG(f.discount_percent), 2) AS avg_discount_percent
  , SUM(f.sales)                      AS sales
  , SUM(f.quantity)                   AS quantity
FROM
    time_dim         t
  , customer_dim     c
  , search_genre_dim sg
  , movie_sales_fact f
WHERE
        t.day_id = f.day_id
    AND c.customer_id = f.cust_id
    AND sg.genre_id = f.genre_id
    --- AND sg.genre_name = :P1_GENRE_NAME
    AND sg.genre_name = 'Documentary'
GROUP BY
    t.year
  , c.continent
  , sg.genre_name
ORDER BY
    t.year
  , c.continent
  , sg.genre_name;
</copy>
~~~

## Task 2 - Aggregate Data to Quarter, Country, and Search Genre

To change aggregation levels, a new query is required. Although the structure is similar, most columns change. Supporting user-selected levels interactively requires dynamic SQL or PL/SQL, increasing the complexity significantly.

~~~SQL
<copy>
SELECT
    t.quarter
  , c.country
  , sg.genre_name
  , round(AVG(f.list_price), 2)       AS avg_list_price
  , round(AVG(f.discount_percent), 2) AS avg_discount_percent
  , SUM(f.sales)                      AS sales
  , SUM(f.quantity)                   AS quantity
FROM
    time_dim         t
  , customer_dim     c
  , search_genre_dim sg
  , movie_sales_fact f
WHERE
        t.day_id = f.day_id
    AND c.customer_id = f.cust_id
    AND sg.genre_id = f.genre_id
    -- AND sg.genre_name = :P1_GENRE_NAME
    AND sg.genre_name = 'Documentary'
GROUP BY
    t.quarter
  , c.country
  , sg.genre_name
ORDER BY
    t.quarter
  , c.country
  , sg.genre_name;
</copy>
~~~

## Task 3 - Prior Period Queries

Calculating percent change from a prior period is a common analytic requirement. This query runs in three steps:

1. Aggregate sales to the desired levels.  
2. Use `LAG()` to fetch prior period values.  
3. Compute the percent change.

A partitioned outer join is used to handle missing prior periods.

~~~SQL
<copy>
WITH sum_sales AS (
    -- First pass aggregates sales
    SELECT
        t.year
      , c.continent
      , sg.genre_name
      , SUM(f.sales) AS sales
    FROM
        time_dim         t
      , customer_dim     c
      , search_genre_dim sg
      , movie_sales_fact f
    WHERE
            t.day_id = f.day_id
        AND c.customer_id = f.cust_id
        AND sg.genre_id = f.genre_id
        AND sg.genre_name = 'Documentary'
    GROUP BY
        t.year
      , c.continent
      , sg.genre_name
), year_dim AS (
    -- A dense list of time periods to be joined to the second pass.
    SELECT DISTINCT
        year
    FROM
        time_dim
), sales_prior_period AS (
    -- Second pass densifies time periods and calculates the prior period of sales.
    SELECT
        a.year
      , a.continent
      , a.genre_name
      , a.sales
      , LAG(a.sales)
          OVER(PARTITION BY a.continent, a.genre_name
               ORDER BY
                   b.year ASC
        ) AS sales_prior_period
    FROM
        sum_sales a
        PARTITION BY ( a.continent
                     , a.genre_name ) RIGHT OUTER JOIN (
            SELECT DISTINCT
                b.year
            FROM
                year_dim b
        )         b ON ( a.year = b.year )
)
-- Third pass calculates the percent change in sales from the prior period.
SELECT
    year
  , continent
  , genre_name
  , sales
  , (sales - sales_prior_period) / sales_prior_period AS sales_pct_change_prior_period
FROM
    sales_prior_period;
</copy>
~~~

As an APEX developer, writing or generating this type of SQL can be time-consuming and complex.

There must be a better way!

You may now **proceed to the next lab**.

## Acknowledgements

- **Created By** - William (Bud) Endress, Product Manager, Autonomous Database, June 2023  
- **Last Updated By** - William (Bud) Endress, June 2025

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C) Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation License, Version 1.3 or any later version published by the Free Software Foundation;  with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.  A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
