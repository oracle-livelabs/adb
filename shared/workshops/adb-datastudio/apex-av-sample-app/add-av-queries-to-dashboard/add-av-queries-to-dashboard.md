# Add Queries that Select from the Analytic View 

## Introduction

Each APEX region needs a data source. In this lab, you’ll connect each chart to a SQL query that selects from the analytic view. You’ll configure four charts:

- Sales by time  
- Sales change from prior period  
- Sales percent change year-over-year by geography  
- Sales share of search genre  

This lab sets up static charts. Interactivity will be added in the next lab.

**Estimated Time:** 20 minutes

### Objectives

- Use simple query templates from the analytic view as data sources in APEX charts

### Prerequisites

- Complete the previous lab.

## Task 1 - Provide a Data Source to the Sales Chart

Connect the **Sales** chart to a query showing sales at the Month level.

1. Open **Sales Dashboard** in APEX App Builder  
2. Select the **Sales** chart  
3. Set **Source** to:
   - Location: `Local Database`
   - Type: `SQL Query`
   - Query:
   
~~~SQL
<copy>
SELECT
    time.member_name AS time
  , sales
FROM
  analytic view (
    USING movie_sales_av
      HIERARCHIES (
        time
    )
  )
WHERE
    time.level_name = 'MONTH'
ORDER BY
    time.hier_order;
</copy>
~~~

4. Configure **Series 1**:  
   - Source: `Region Source`  
   - Label: `TIME`  
   - Value: `SALES`  

5. In **Performance**, set **Maximum Rows to Process** to `1000`  
6. Click **Run** to view the chart

![Sales Chart](images/sales-chart.png)

## Task 2 - Provide a Data Source to the Sales Change Prior Period Chart

Connect the **Sales Change Prior Period** chart using a calculated measure at the Month level.

1. Open **Sales Dashboard**  
2. Select the **Sales Change Prior Period** chart  
3. Set **Source** to:
   - Location: `Local Database`
   - Type: `SQL Query`
   - Query:

~~~SQL
<copy>
SELECT
    time.member_name  AS time
  , sales_change_prior_period
FROM
  analytic view (
    USING movie_sales_av
      HIERARCHIES (
        time
    )
    ADD MEASURES (
      sales_change_prior_period AS (LAG_DIFF(sales) OVER (HIERARCHY time OFFSET 1 WITHIN LEVEL))
    )
  )
WHERE
    time.level_name = 'MONTH'
ORDER BY
    time.hier_order;
</copy>
~~~

4. Configure **Series 1**:  
   - Source: `Region Source`  
   - Label: `TIME`  
   - Value: `SALES_CHG_PRIOR_PERIOD`  

5. Set **Maximum Rows to Process** to `1000`  
6. Click **Run** to view the chart

![Sales Change Prior Chart](images/sales-change-prior-period-chart.png)

## Task 3 - Provide a Data Source to the Sales Percent Change Year Ago Chart

Use a query with percent change compared to the same period last year, grouped by continent.

1. Open **Sales Dashboard**  
2. Select the **Sales Percent Change Year Ago** chart  
3. Set **Source** to:
   - Location: `Local Database`
   - Type: `SQL Query`
   - Query:

~~~SQL
<copy>
SELECT
  time.member_name AS time
  , geography.member_name  AS geography
  , sales_pct_change_year_ago
FROM
  analytic view (
    USING movie_sales_av
      HIERARCHIES (
        time
        , geography
    )
    ADD MEASURES (
      sales_pct_change_year_ago AS (LAG_DIFF_PERCENT(sales) OVER (HIERARCHY time OFFSET 1 ACROSS ANCESTOR AT LEVEL YEAR))
    )
  )
WHERE
    geography.level_name = 'CONTINENT'
    AND time.level_name = 'YEAR'
    AND time.year = '2023'
ORDER BY
    sales_pct_change_year_ago;
</copy>
~~~

4. Configure **Series 1**:  
   - Source: `Region Source`  
   - Label: `GEOGRAPHY`  
   - Value: `SALES_PCT_CHG_YEAR_AGO`  

5. Set **Maximum Rows to Process** to `1000`  
6. Configure the **y-axis**:  
   - Format: `Decimal`  
   - Decimal Places: `2`  
7. Click **Run** to view the chart

![Sales Percent Change Year Ago](images/sales-percent-change-year-ago.png)

## Task 4 - Provide a Data Source to the Sales Share of Genre Chart

This chart displays each genre’s share of total sales in 2023.

1. Open **Sales Dashboard**  
2. Select the **Sales Share of Genre** chart  
3. Set **Source** to:
   - Location: `Local Database`
   - Type: `SQL Query`
   - Query:

~~~SQL
<copy>
SELECT
  search_genre.member_name  AS genre
  , sales_share_genre
FROM
  analytic view (
    USING movie_sales_av
      HIERARCHIES (
          time
        , search_genre
    )
    ADD MEASURES (
      -- The ratio of sales of the current genre to total sales
      sales_share_genre AS (SHARE_OF(sales HIERARCHY search_genre MEMBER ALL))
    )
  )
WHERE
    time.level_name = 'YEAR'
    AND time.year = '2023'
    AND search_genre.level_name = 'SEARCH_GENRE'
ORDER BY sales_share_genre;
</copy>
~~~

4. Configure **Series 1**:  
   - Source: `Region Source`  
   - Label: `GENRE`  
   - Value: `SALES_SHARE_GENRE`  

5. Configure the **y-axis**:  
   - Format: `Decimal`  
   - Decimal Places: `2`  
6. Click **Run** to view the chart

![Sales Share of Genre](images/sales-share-of-genre.png)

## Summary

You created four charts and configured each to use a SQL query that selects from an analytic view. Each query reused a shared pattern, with calculated measures added using `ADD MEASURES`.

You may now **proceed to the next lab**.

## Acknowledgements

- **Created By** - William (Bud) Endress, Product Manager, Autonomous Database, June 2023  
- **Last Updated By** - William (Bud) Endress, June 2025

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C) Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation License, Version 1.3 or any later version published by the Free Software Foundation;  with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.  A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
