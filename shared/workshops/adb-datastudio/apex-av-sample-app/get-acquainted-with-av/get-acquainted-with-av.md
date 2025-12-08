# Examine Hierarchies and Analytic Views

## Introduction

Hierarchy views return data from a single hierarchy.  Analytic views join one or more hierarchies to the fact table.  Analytic views include all columns from each hierarchy, facts from the fact table, and calculated measures.  Hierarchies and analytic views return rows for all levels.

In this lab, you will get acquainted with the rows and columns returned by hierarchies and analytic views.

Estimated Time:  5 minutes.

### Objectives

In this lab, you will:

- Learn about the different types of columns in hierarchies and analytic views and the rows they return.

### Prerequisites:

- Complete the previous lab.

## Task 1 - Select from the Time Hierarchy

Hierarchies include attribute columns and hierarchical columns.  Attribute columns come directly from the table(s) the hierarchy uses.  Hierarchical columns are produced by the hierarchy.  Every hierarchy has the same set of hierarchical columns.  Hierarchies return rows for each level of aggregation.

The following query selects all rows and columns from the TIME hierarchy.  The HIER_ORDER column sorts the rows in hierarchical order, with child members nested within parent members.

~~~SQL
<copy>
SELECT
  *
FROM
  time
ORDER BY
  hier_order;
  </copy>
~~~

Wow, there is a lot to work with!

## Task 2 - Select Attribute Columns at the Day Level

Selecting attribute columns from the hierarchy at the DAY level returns the original rows and columns from the TIME_DIM table.

~~~SQL
<copy>
SELECT
  day_id,
  month,
  quarter,
  year
FROM
  time
WHERE
  level_name = 'DAY'
ORDER BY
  hier_order;
  </copy>
~~~

## Task 3 - Select Primary Key, Attribute, and LEVEL_NAME Columns

The next query adds the MEMBER\_UNIQUE\_NAME and LEVEL_NAME columns and selects all rows.  MEMBER\_UNIQUE\_NAME is the primary key of the hierarchy.

~~~SQL
<copy>
SELECT
  member_unique_name,
  level_name,
  day_id,
  month,
  quarter,
  year
FROM
  time
ORDER BY
  hier_order;
</copy>
~~~

The attribute columns - DAY_ID, MONTH, QUARTER, and YEAR - will return values for the current level and ancestor levels.  They will return NULL for descendant levels.

Every hierarchy includes an ALL level with a single value.  This value represents the grand total of the hierarchy in the analytic view.

## Task 4 - Select all Hierarchical Attributes

This query returns all hierarchical columns of the TIME hierarchy.

~~~SQL
<copy>
SELECT
    member_unique_name
  , member_name
  , member_caption
  , member_description
  , hier_order
  , level_name
  , depth
  , is_leaf
  , parent_unique_name
  , parent_level_name
FROM
    time
ORDER BY
    hier_order;
</copy>
~~~

These columns a very useful for navigating hierarchies and creating lists of values in APEX items.

- MEMBER\_UNIQUE\_NAME is the primary key.
- The MEMBER\_NAME, MEMBER\_CAPTION, and MEMBER\_DESCRIPTION columns are usually used to return user-friendly descriptive information about the hierarchy member.
- HIER\_ORDER returns the nested, hierarchical sort order of members.
- LEVEL\_NAME returns the level name of the current member.
- DEPTH returns the hierarchy depth of the current member.
- IS\_LEAF returns 0 or 1, indicating if the current member is the lowest member in a branch of the hierarchy.
- PARENT\_UNIQUE\_NAME returns the primary key of the member parent.
- PARENT\_LEVEL returns the level name of the member's parent.

**Important - Do not SELECT * FROM Analytic Views**

Your first thought might be to SELECT * from the analytic view.  Resist that thought!

Analytic views return rows for all detail and aggregate rows.  The potential number of rows is the Cartesian product of all hierarchy members.  An analytic view that uses four hierarchies with 1000 members each can potentially return 1000^4 or 1,000,0000,000 rows.  Data is likely to be sparse, so the actual number of rows is expected to be smaller.

Recommendations:

- Select subsets of hierarchies.
- Use filters to limit the rows returned by the query.
- Select only the columns you need.

## Task 5 - Take a First Look at the Analytic View

Analytic views include all columns of each hierarchy and measure columns.  The hierarchical columns for each hierarchy have the name.  The attribute columns will vary by hierarchy.

You can get a list of all columns of the analytic view with the following query:

~~~SQL
<copy>
SELECT
    analytic_view_name
  , hier_name
  , column_name
  , role
FROM
  user_analytic_view_columns
ORDER BY
  order_num;
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