# Explore the Data Tables

## Introduction

In this lab, you will explore the data tables and get familiar with the dataset.

**Estimated Time:** 5 minutes

### Objectives

- Review the data used by the analytic view.

### Prerequisites

- Complete the previous lab.

## Task 1 - Examine the Dimension Tables

Run the queries below to review the dimension tables.

1. Make sure you're connected to SQL Worksheet as the **MOVIESTREAM** user (or other user created in Lab 3).
2. Run the following SQL commands:

**View the TIME\_DIM table:**

This table includes Day, Month, Quarter, and Year data over two years.

~~~SQL
<copy>

SELECT
    *
FROM
    time_dim
ORDER BY
    day_id;

</copy>
~~~

**View the CUSTOMER\_DIM table:**

This table contains customer location details such as City, State, Country, and Continent.

~~~SQL
<copy>

SELECT
    *
FROM
    customer_dim;

</copy>
~~~

**View the SEARCH\_GENRE\_DIM table:**

This table lists movie genres users searched for.

~~~SQL
<copy>

SELECT
    *
FROM
    search_genre_dim
ORDER BY
    genre_name;

</copy>
~~~

## Task 2 - Examine the Fact Table

The MOVIE\_SALES\_FACT table includes daily sales data by customer and genre, with quantity and discount information.

~~~SQL
<copy>

SELECT
    *
FROM
    movie_sales_fact
WHERE
    discount_percent IS NOT NULL
ORDER BY
    cust_id DESC;

</copy>
~~~

## Task 3 - Query a Flattened View of the Data

Join the fact table with the dimension tables to create a complete, flattened view of the data.

~~~SQL
<copy>

SELECT
    t.day_id
  , t.month
  , t.month_of_year
  , t.quarter
  , t.year
  , c.customer_id
  , c.city
  , c.state_province
  , c.country
  , c.continent
  , sg.genre_name
  , f.list_price
  , f.discount_percent
  , f.sales
  , f.quantity
FROM
    time_dim         t
  , customer_dim     c
  , search_genre_dim sg
  , movie_sales_fact f
WHERE
        t.day_id = f.day_id
    AND c.customer_id = f.cust_id
    AND sg.genre_id = f.genre_id;

</copy>
~~~

You may now **proceed to the next lab**.

## Acknowledgements

- **Created By** - William (Bud) Endress, Product Manager, Autonomous Database, June 2023  
- **Last Updated By** - William (Bud) Endress, June 2025

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C) Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation License, Version 1.3 or any later version published by the Free Software Foundation;  with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.  A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)