# Examine Queries that Select from the Analytic View


## Introduction

In Lab 7, you ran several queries that selected data from tables.  In this lab, you will run queries that select data from the analytic view, returning the same data as the queries in lab 7.

You will observe that each of the queries selecting from the analytic view follows the same pattern, using the same column name regardless of the levels of aggregation.

Estimated Time:  5 minutes.

### Objectives

In this lab, you will observe how queries selecting from an analytic view:

- Use hierarchical columns.
- Aggregate data.
- Add calculated measures to queries.
- Compare to queries that select from tables.

### Prerequisites:

- Complete the previous lab.

## Task 1 - Aggregate Data to Year, Continent, and Search Genre

Queries that select from analytic views follow the typical SELECT ... FROM ... WHERE ... ORDER BY pattern.  In a query that selects from an analytic view, the HIERARCHIES clause replaces joins and GROUP BY.

Note that hierarchy columns are qualified with the hierarchy name.  For example, TIME.MEMBER_NAME.

Filtering on the LEVEL\_NAME column is a simple method of requesting data at specific levels of aggregation.  Selecting the MEMBER\_NAME columns eliminates the need to change column names when selecting data at different levels of aggregation.

This query returns data from the Year, Continent, and Search Genre levels.

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

The following query selects quarter, country, and search genre level data.  The only changes required to the query are the LEVEL\_NAME values.  Using the hierarchical columns (MEMBER\_NAME, LEVEL\_NAME, and HIER\_ORDER) allows the query to be reusable across different levels of aggregation with only minor changes.  In an APEX application, you would pass the level values into the query as bind variables from an APEX item such as a list box.

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

The query same query template can return data at multiple levels of aggregation.  In this example, YEAR and QUARTER.  Once again, notice that the same query template is used.

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

Calculations can be defined as part of the analytic view or be expressed dynamically in queries that select from an analytic view.  Calculation expressions can use analytic view expressions, SQL single-row functions, or reference PL/SQL functions.  Analytic view expressions reference elements of the analytic view, such as hierarchies and levels.  Because calculation expressions do not usually reference column names, they do not need to be changed as hierarchies are added or removed from the query or levels of aggregation change.

A query with a dynamic calculated measure expression uses the USING form of the FROM clause.  The next query uses the USING form of the FROM clause and the ADD MEASURE clause to include a calculation expression.  The ability to express calculations in the query provides the APEX developer with many opportunities to enhance applications.

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

This query template is reused to query data at the Year and Quarter levels and adds the Sales Change from Prior Prior measure.

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

Let's summarize some of the advantages of using analytic views in APEX.

- The physical implementation is hidden from the application.  The physical model can change without affecting the application querying the analytic view.
- Joins and GROUP BY are not needed.
- Calculations are easily added to queries.
- Queries are easily generated from reusable templates.

You may now **proceed to the next lab** and start applying this knowledge to APEX!

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