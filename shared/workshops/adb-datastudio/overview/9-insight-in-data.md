# Explore hidden patterns in your data


## Introduction

This lab introduces Data Studio’s Insights tool built into the Oracle Autonomous AI Database and shows how to search for and interpret data insights.

Estimated Time: 15 minutes

<!--
Watch the video below for a quick walk-through of the lab.
[Create a database user](videohub:1_0o150ib2)
-->

### Objectives

In this workshop, you will learn how to find hidden insights in your data using Data Studio's Data Insights tool.

### Prerequisites

To complete this lab, you need to have completed the previous labs, so that you have:

- Created an Autonomous AI Database instance
- Created a new QTEAM user with appropriate roles

## Task 1: Use Data Insights

Data Studio's insights process runs in the background, finding interesting patterns 
in the data. This is a hands-off approach to
finding insights that are lurking out of sight in the data.

In this lab, we will investigate a few sample insights produced by the tool.
We will learn how to interpret the results and will cross-check them with manual
analysis.

>**Note:** The insight process can run for some time depending on the
complexity of the data set and available compute resources. Our data set
is small enough that it will complete in a reasonable time. But you might
see the insight list being refreshed while it is executing.


1.  From the Data Studio Overview page launch the **Data Insights** tool.

    ![screenshot of the Data Insights card](images/image76_inst_card.png)

2.  On the **Insights** page click on the top right icon to get a tour of the
    tool.

    ![screenshot of Insights home page](images/image77_inst_home.png)

3.  Click Next to go through each area and learn about it.

    ![screenshot of Insights tour](images/image78_inst_tour.png)

4.  You can pick any table or Analytic View run insights on. 
    if you want to run insights against a single table then you can pick any column
    which you think is a measure.

    >**TIP**: Although you can run Insights on any table, it is best to prepare the data in such a way that there is one measure column and rest are related attribute columns. Not having any superfluous columns helps Insights tool run faster since it has to compare less permutations and combinations of attribute columns. You can use Data Transforms tool or SQL script to prepare the data as needed.

    Pick **CUSTOMER\_SALES\_ANALYSIS\_FULL** for the table, and **TOTAL\_SALES**
    for the column. 
    
    Click **Search**.
    
    >**NOTE:** The search process will take couple of minutes to complete. These insights are stored in the database and can be accessed at any
    time for review. You can also regenerate the analysis if the data in
    the underlying AV/table has changed. The order of
    insights may vary if the data is different or the insight is still
    running, therefore refer to the labels on each tile to identify it.

    A list of various insights will appear on the page. The Insights tool has gone through the data and discovered
    many interesting behavioral patterns based on the movie sales data.
    
    For our workshop we will focus on three insights labeled in the screenshot:

      1: Purchasing behavior of married people across age groups

      2: Purchasing behavior of singles across movie genre

      3: Interest in adventure genre across age groups

      4: Purchasing behavior of dog owners across customer value
        
    ![screenshot of the list of insights](images/image79_t_inst_list.png)

5.  Click on the tile marked **M** on the top and **AGE\_GROUP** at the
    bottom. It shows

    1: **TOTAL\_SALES** (our measure driving the insight) in **blue** bars for
    **MARITAL\_STATUS=M** across **AGE\_GROUP**. This is the actual value.
    
    2: Each bar has a **green** horizontal line depicting the average,
    without the **MARITAL\_STATUS=M** filter. It is called the **expected** value.
    It can differ from the blue level if the data is skewed for the filter
    on the top (**MARITAL\_STATUS=M**).
    
    3: A few bars are surrounded by a black border (pointed by arrows). These
    are highlighted exceptions.
    
    Another way to read this is:
    
    **Married Millennials** are purchasing more movies than average and **Married GenZ** are watching less movies than average.
    
    That is an interesting insight.  
    
    ![screenshot of insights on married and age groups](images/image80_t_inst_married_agegroup.png)

    Click on the **Back** button to go back to the list.

6.  Click on the tile marked **S** on the top and the **GENRE** at
    the bottom.

    It shows that unmarried customers are watching less drama.

    ![screenshot of insights on singles and genre](images/image81_t_inst_single_genre.png)

    Click on the **Back** button to go back to the list.

7.  Click on the tile marked **Adventure** on the top and the **AGE\_GROUP** at
    the bottom.

    This shows that GenZ customers are watching lots of adventure movies.

    ![screenshot of insights on adventure and age group](images/image81_t_inst_adventure_agegroup.png)

    Click on the **Back** button to go back to the list.

8.  Now, just for fun let's look at the pet ownership and movie purchase
    relationship.

    Click on the tile marked **Dog** on the top and **CUST\_VALUE**.
    
    Here we can see that the highest value (5) dog owners are purchasing far more movies than average compared to non-dog owners. It may be just a correlation but perhaps you could use this data to offer dog grooming products to high-value customers!
    
    The Insights tool has discovered all these hidden patterns just by crawling through the data.

    ![screenshot of insights on pet ownership and customer value](images/image82_t_inst_pet_custvalue.png)

    Wow! That's quite an insight!

    Click on the **Back** button to go back to the list.

There are many other insights in the list. Go back to the list and look at a few others. See if you find any other interesting insight. The Insights tool has discovered all these hidden patterns just by crawling through the data.

## Task 2: Peeling the layers of Insights

This section is an attempt to explain the insights by manually doing the analysis and correlating them with what we can see in insights.

1.  Let's go back and look at the first insight again.

    Click on the tile marked **S** on the top and the **GENRE** at
    the bottom. It showed single customers are purchasing 
    adventure and comedy more than the average, and purchasing less drama genre than 
    the average.

    ![screenshot of singles by genre insight](images/image81_t_inst_single_genre.png)

2.  We can go back to the **Analysis** tool to confirm this insight. Click on CUSTOMER\_SALES\_ANALYSIS\_FULL to create a new analysis.

    ![screenshot of applying the filter for marital status](images/image84_t_analyze_peeling_layer_home.png)

3.  In this new report we will analyze **sales** by **Genre** for married and single customers alternately.

    Use chart format. Drag **GENRE** on X-Axis and **TOTAL\_SALES** on Y-Axis.
    Pick **S** for single in the filter box on the right for marital status. Notice the total sales for drama genre by hovering your mouse on the bar. It is approx 68k. 

    ![screenshot of applying the filter for marital status](images/image84_t_analyze_filter.png)

4.  Now let's compare it for married couples. Deselect **S** and select **M** in the right hand side filter for marital status.

    This is what you get. Notice high purchases in the **Drama** genre by married couples. It is approx 225k.

    ![screenshot of sales analysis to married by genre](images/image86_t_analyze_married_genre.png)

**This confirms what the Insights tool told us - that singles are less into the drama genre! It discovered that without any input from us!**

While doing manual analysis in the **Analysis** tool, 
we must actively look at and compare the data for
certain hierarchies. There are many combinations, but people use their
experience to guide their analysis steps. In comparison, the **Data Insights** tool is a hands-off approach and it finds patterns without
understanding what hierarchies mean.

We think that both are complementary to each other and provide valuable
tools to use in "a day in the life of a data analyst".

## RECAP

In this lab, we examined various insights discovered by the Data Insights tool. 
They were interesting insights and not very obvious without digging into the data.

We also compared the results with the Analysis tool by doing manual analysis, illustrating 
the value of automated insights.

Now all the assigned tasks have been completed successfully.

You may now **proceed to the next lab**.

## Acknowledgements

- Created By/Date - Jayant Mahto, Product Manager, Autonomous AI Database, January 2023
- Contributors - Mike Matthews, Bud Endress, Ashish Jain, Marty Gubar, Rick Green
- Last Updated By - Jayant Mahto, September 2025


Copyright (C)  Oracle Corporation.