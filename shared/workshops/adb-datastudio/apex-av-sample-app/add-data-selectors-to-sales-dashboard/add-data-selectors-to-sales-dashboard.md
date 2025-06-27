# Add Data Selectors to the Sales Dashboard

## Introduction

In this lab, you’ll add interactive selectors to your Sales Dashboard. These selectors allow users to filter data by time period and geography.

**Estimated Time:** 20 minutes

### Objectives

- Create select lists using SQL queries on analytic views and dictionary metadata  
- Modify chart queries to use selector values

### Prerequisites

- Complete the previous lab.

## Task 1 - Add Time Level Selector

The Sales and Sales Change Prior Period charts currently use static time levels. You’ll add a **Popup LOV** to let users choose a time level dynamically.

1. Add a **Popup LOV** to the page  
2. Set **Name** to `P1_TIME_LEVEL`  
3. Label: `Time Level`  
4. Under **Layout**, set **Column Span** to `3`

![P1_TIME_LEVEL item](images/p1-time-level-position.png)

5. In **List of Values**, choose:
   - Type: `SQL Query`  
   - SQL:

~~~SQL
<copy>
SELECT
    level_name as d,
    level_name as r
FROM
    user_hier_levels
WHERE
    hier_name = 'TIME'
ORDER BY
    order_num;
</copy>
~~~

6. In **Settings**:  
   - Display Extra Values: `Off`  
   - Display Null Value: `Off`

7. In **Default**:  
   - Type: `Static`  
   - Static Value: `MONTH`

8. Add a **Dynamic Action**:  
   - Event: `Change`  
   - True Action: `Submit Page`

You can now test the control. It won’t affect charts yet — that comes next.

## Task 2 - Add Geography Member Selector

Add a **Popup LOV** that allows selection of a geography member from the hierarchy.

1. Add a **Popup LOV**  
2. Set **Name** to `P1_GEOGRAPHY`  
3. Label: `Geography`  
4. Ensure **Start New Row** and **New Column** are `Off`

![P1_GEOGRAPHY item](images/p1-geography-position.png)

5. Set **List of Values**:
   - Type: `SQL Query`  
   - SQL:

~~~SQL
<copy>
SELECT
    member_name        d
  , member_unique_name r
FROM
    geography
WHERE
    level_name IN ('ALL', 'CONTINENT', 'COUNTRY')
ORDER BY
    hier_order;
</copy>
~~~

6. In **Settings**:  
   - Display Extra Values: `Off`  
   - Display Null Value: `Off`

7. In **Default**:  
   - Type: `Static`  
   - Static Value: `[ALL].[ALL]`

8. Add a **Dynamic Action**:  
   - Event: `Change`  
   - True Action: `Submit Page`

Now test the Geography selector. It will become active in the next step.

## Task 3 - Update the Sales Chart Query

Update the chart to use the selector values.

1. Edit the Sales chart query:

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
        , geography
    )
  )
WHERE
    time.level_name = NVL(:P1_TIME_LEVEL,'MONTH')
    AND geography.member_unique_name = NVL(:P1_GEOGRAPHY,'[ALL].[ALL]')
ORDER BY
    time.hier_order;
</copy>
~~~

Run the page — the chart now reflects user selections.

## Task 4 - Update the Sales Change Prior Period Chart Query

Update this chart to use both selectors and a calculated measure.

1. Edit the Sales Change Prior Period chart query:

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
        , geography
    )
    ADD MEASURES (
      sales_change_prior_period AS (LAG_DIFF(sales) OVER (HIERARCHY time OFFSET 1 WITHIN LEVEL))
    )
  )
WHERE
    time.level_name = NVL(:P1_TIME_LEVEL,'MONTH')
    AND geography.member_unique_name = NVL(:P1_GEOGRAPHY,'[ALL].[ALL]')
ORDER BY
    time.hier_order;
</copy>
~~~

Test the chart. It now uses the time level and geography selected by the user.

## Task 5 - Update the Sales Percent Change Year Ago Chart Query

Update this chart to return child values based on the selected geography.

1. Replace the chart query with:

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
    geography.parent_unique_name = NVL(:P1_GEOGRAPHY,'[ALL].[ALL]')
    AND time.level_name = 'YEAR'
    AND time.year = '2023'
ORDER BY
    sales_pct_change_year_ago;
</copy>
~~~

Run the page and confirm the Geography selector now filters this chart.

## Task 6 - Update the Sales Share of Genre Query

Add geography filtering to this chart, and include a `SHARE_OF` calculation.

1. Replace the query with:

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
        , geography
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
    AND geography.member_unique_name = NVL(:P1_GEOGRAPHY,'[ALL].[ALL]')
ORDER BY sales_share_genre;
</copy>
~~~

Run the page and test the updated chart.

## Notes About the Queries

Your charts now support user-driven filtering by time and geography.

With analytic views:
- No joins or GROUP BY needed  
- Column names stay consistent  
- Only level or hierarchy filters change  
- Reusable query templates simplify development  

The final Sales Dashboard should resemble this:

![Completed Sales Dashboard](images/completed-sales_dashboard.png)

## Summary

You added selectors and updated queries to create a fully interactive Sales Dashboard. Only small changes to the queries were required — analytic views handled the complexity behind the scenes.

Analytic views make it easy to build flexible APEX apps by:

- Replacing joins and GROUP BY with HIERARCHIES  
- Supporting consistent, reusable SQL  
- Providing calculated measures and hierarchy-aware filtering  

You may now **proceed to the next lab**.

## Acknowledgements

- **Created By** - William (Bud) Endress, Product Manager, Autonomous Database, June 2023  
- **Last Updated By** - William (Bud) Endress, June 2025

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C) Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation License, Version 1.3 or any later version published by the Free Software Foundation;  with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.  A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)