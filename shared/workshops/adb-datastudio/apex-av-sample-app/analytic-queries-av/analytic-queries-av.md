# Examine Queries that Select from the Analytic View

## Introduction

In Lab 7, you ran queries against tables. In this lab, you’ll run similar queries against an analytic view — returning the same data with simpler, more flexible SQL.

**Estimated Time:** 5 minutes

### Objectives

- Use hierarchical columns
- Aggregate data
- Add calculated measures
- Compare to table-based queries

### Prerequisites

- Complete the previous lab.

## Task 1 - Aggregate Data to Year, Continent, and Search Genre

Queries against analytic views follow the standard `SELECT ... FROM ... WHERE ... ORDER BY` pattern.  
Instead of `JOIN` and `GROUP BY`, use the `HIERARCHIES` clause.

- Use `LEVEL_NAME` to select levels of aggregation  
- Use `MEMBER_NAME` for display values  
- Use `HIER_ORDER` for proper hierarchical sorting

~~~SQL
<copy>
SELECT
    time.member_name               AS time
  , geography.member_name          AS geography
  , search_genre.member_name       AS search_genre
  , round(avg_list_price, 2)       AS avg_list_price
  , round(avg_discount_percent, 2) AS avg_discount_percent
  , sales
  , quantity
FROM
    movie_sales_av HIERARCHIES (
      time
    , geography
    , search_genre
    )
WHERE
    time.level_name = 'YEAR'
    AND geography.level_name = 'CONTINENT'
    AND search_genre.level_name = 'SEARCH_GENRE'
ORDER BY
    time.hier_order
  , geography.hier_order
  , search_genre.hier_order;
</copy>
~~~

## Task 2 - Aggregate Data to Quarter, Country, and Search Genre

To change the aggregation levels, update the `LEVEL_NAME` values.  
No need to rewrite the entire query — it’s the same pattern.

~~~SQL
<copy>
SELECT
    time.member_name               AS time
  , geography.member_name          AS geography
  , search_genre.member_name       AS search_genre
  , round(avg_list_price, 2)       AS avg_list_price
  , round(avg_discount_percent, 2) AS avg_discount_percent
  , sales
  , quantity
FROM
    movie_sales_av HIERARCHIES (
      time
    , geography
    , search_genre
    )
WHERE
    time.level_name = 'QUARTER'
    AND geography.level_name = 'YEAR'
    AND search_genre.level_name = 'SEARCH_GENRE'
ORDER BY
    time.hier_order
  , geography.hier_order
  , search_genre.hier_order;
</copy>
~~~

This query returns both Year and Quarter level data.  
Same structure, just adjusted filters.

~~~SQL
<copy>
SELECT
    time.member_name               AS time
  , geography.member_name          AS geography
  , search_genre.member_name       AS search_genre
  , round(avg_list_price, 2)       AS avg_list_price
  , round(avg_discount_percent, 2) AS avg_discount_percent
  , sales
  , quantity
FROM
    movie_sales_av HIERARCHIES (
      time
    , geography
    , search_genre
    )
WHERE
    time.level_name IN ('YEAR','QUARTER')
    AND geography.level_name = 'CONTINENT'
    AND search_genre.level_name = 'SEARCH_GENRE'
ORDER BY
    time.hier_order
  , geography.hier_order
  , search_genre.hier_order;
</copy>
~~~

## Task 3 - Prior Period Queries

You can define calculations inside the analytic view or dynamically in the query using the `ADD MEASURES` clause.

Dynamic calculations use:

- Analytic view expressions (e.g., `LAG_DIFF`, `LAG_DIFF_PERCENT`)  
- No need to reference table column names  
- Fully reusable as levels or hierarchies change

Use the `USING` form of the `FROM` clause for dynamic expressions.

~~~SQL
<copy>
SELECT
    time.member_name               AS time
  , geography.member_name          AS geography
  , search_genre.member_name       AS search_genre
  , sales
  , sales_pct_change_prior_period
FROM
  analytic view (
    USING movie_sales_av
      HIERARCHIES (
        time
      , geography
      , search_genre
    )
  ADD MEASURES (
    sales_pct_change_prior_period AS (LAG_DIFF_PERCENT(sales) OVER (HIERARCHY time OFFSET 1 WITHIN LEVEL))
    )
  )
WHERE
    time.level_name = 'YEAR'
    AND geography.level_name = 'CONTINENT'
    AND search_genre.level_name = 'SEARCH_GENRE'
    AND search_genre.genre_name = 'Documentary'
ORDER BY
    time.hier_order
  , geography.hier_order
  , search_genre.hier_order;
</copy>
~~~

This version includes both change and percent change measures:

~~~SQL
<copy>
SELECT
    time.member_name               AS time
  , geography.member_name          AS geography
  , search_genre.member_name       AS search_genre
  , sales
  , sales_change_prior_period
  , sales_pct_change_prior_period
FROM
  analytic view (
    USING movie_sales_av
      HIERARCHIES (
        time
      , geography
      , search_genre
    )
  ADD MEASURES (
      sales_change_prior_period AS (LAG_DIFF(sales) OVER (HIERARCHY time OFFSET 1 WITHIN LEVEL))
    , sales_pct_change_prior_period AS (LAG_DIFF_PERCENT(sales) OVER (HIERARCHY time OFFSET 1 WITHIN LEVEL))
    )
  )
WHERE
    time.level_name IN ('YEAR','QUARTER')
    AND geography.level_name = 'CONTINENT'
    AND search_genre.level_name = 'SEARCH_GENRE'
    AND search_genre.genre_name = 'Documentary'
ORDER BY
    time.hier_order
  , geography.hier_order
  , search_genre.hier_order;
</copy>
~~~

## Summary

**Why use analytic views in APEX?**

- Abstracts physical data model  
- No need for joins or GROUP BY  
- Simplifies complex calculations  
- Enables reusable query templates

You may now **proceed to the next lab** and apply what you’ve learned!

## Acknowledgements

- **Created By** - William (Bud) Endress, Product Manager, Autonomous Database, June 2023  
- **Last Updated By** - William (Bud) Endress, June 2025

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C) Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation License, Version 1.3 or any later version published by the Free Software Foundation;  with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.  A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)