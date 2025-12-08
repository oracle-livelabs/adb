# Explore the Data Tables


## Introduction

You will explore the table in this lab and become familiar with the data.

Estimated Time:  5 minutes.

### Objectives

In this lab, you will:

- Understand the data in the tables used by the analytic view.

### Prerequisites:

- Complete the previous lab.

## Task 1 - Examine the Dimension Tables

Run queries that select from the dimension tables to become familiar with the data.

1.  You should already be connected to SQL Worksheet as the **MOVIESTREAM** users.  If you are not, connect to the database using the  **MOVIESTREAM** (or other) user created in Lab 3.
1.  Run the following commands in SQL Worksheet.

The TIME_DIM tables contain data at the Day, Month, Quarter, and Year levels over two years.

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

The CUSTOMER\_DIM table contains data at the City, State, Country, and Continent levels.

~~~SQL
<copy>

SELECT
    *
FROM
    customer_dim;

</copy>
~~~

The SEARCH\_GENRE\_DIM table contains a list of movie genre.  In the MovieStream data set, this was the genre that the user searched on while browsing for movies.

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

The MOVIE\_SALES\_FACT table contains Sales, Quantity, and Discount Percent by day, customer, and search genre.

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

## Task 3 - Query a  Flattened View of the Data

The MOVIE\_SALES\_FACT table can be joined to the dimension tables to provide a full, 'flattened' view of the data.

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