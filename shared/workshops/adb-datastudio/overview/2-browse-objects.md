# Using Data Catalog to browse for your objects


## Introduction

This lab introduces the Data Catalog application built into the Oracle Autonomous Database and shows the various ways you can browse and search for you obejcts.

Estimated Time: 5 minutes

Watch the video below for a quick walk through of the lab.
[](youtube:youtubeid)

## Objectives

In this workshop, you will learn:
-	How to browse the catalog and find the data you need

### Prerequisites

To complete this lab, you need to have completed the previous labs, so that you have:

- Created an Autonomous Data Warehouse instance
- Created a new QTEAM user with appropriate roles
- demo data loaded

## Task 1: Launch Database Action

1.  Login to the Autonomous Database created earlier with your user and
    password. You can see various tools under Data Studio.

    **Note:** Bookmark the Database Actions page so that it is easier to come
    back to this later in the workshop.
    
    Click on **DATA STUDIO OVERVIEW** card.

![Screenshot of data studio overview](images/image1_datastudio_overview.png)

2.  It shows the list of recent objects in the middle. On the left, it
    has links to individual tools and on the right, link to
    documentation.

![Screenshot of sT atusio recent object list](images/image2_datastudio_overview_list.png)

Since it is a workshop, there are limited objects in the list. There
will be many objects and only the recent objects are shown here. We will
use the Catalog tool to browse the objects and find what we need.

## Task 2: Explore catalog

1.  Click on the Catalog link on the left panel.

    In a typical database there will be many objects and you need various
    ways to search and display objects. Various ways to navigate a catalog
    is shown by marked numbers in the above screenshot. These are:
    
    1: Saved searches. You can filter objects easily with one click and
    then refine the search further as per need.
    
    2: Filters to narrow down your search.
    
    3: Various display modes. Card/Grid/List view.
    
    4: Search bar where you can type in advanced search query

![Screenshot of catalog page](images/image3_catalog_ui_zones.png)

2.  Note that catalog shows all types of objects. We are interested in
    only the tables for now. Click on "Tables, views and analytic views
    owned by..." on the right zone 1.

    You can see the MOVIESALES_CA in this list. We are interested in this
    table since we were told that this table contains movie sales
    transaction data. (Referring to the meeting notes in introductory
    section of this workshop).
    
    You could explicitly search for MOVIESALES_CA by typing the name of
    the table in the search bar but in our case, it is clearly visible in
    the grid view in the middle.

![Screenshot of listing only tables and views](images/image4_catalog_tables.png)

3.  Click on the MOVIESALES_CA table.

    You can see the data preview. You can scroll right to see more columns
    and scroll down to see more rows. You can also sort the columns by
    right clicking on the columns. Using the data view, you can be sure
    that this is the data you want.
    
    Note that you also have other information such as
    lineage/impact/statistics/data definitions etc. This workshop is not
    going into the details. In-depth catalog will be explored in other
    workshops.
    
    Now close this view by clicking on the bottom right **Close** button.

![Screenshot of data preview](images/image5_catalog_data_preview.png)

4.  Look for the other tables of our interest in the main catalog page.
    If you remember the meeting notes in introductory section of this
    workshop, we are also interested in CUSTOMER_CA and GENRE tables.
    Find and click on these tables to do a data preview.

![Screenshot of desired tables](images/image6_catalog_tables_grid.png)

5.  We also need to find out whether age group information is present.

    Clear search bar and enter the following search string:
    
    **(type: COLUMN) AGE**
    
    This will search for all the columns with "AGE" in the column name.
    
    We can explicitly search for GROUP as well but we don't see any.
    It means we don't have any tables or columns with text GROUP in the name.
    

![Screenshot of searcing for column names](images/image7_catalog_search_cols.png)

This completes Data Catalog overview lab. Note that there are many more features in the Catalog tool, which are not covered here. These details will be covered in some other in-depth workshop.

You may now **proceed to the next lab**.