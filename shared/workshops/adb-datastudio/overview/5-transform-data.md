# Using Data Transforms to prepare data for analysis


## Introduction

This lab introduces the Data Transforms application built into the Oracle Autonomous Database and shows the various ways you can prepare data for analysis.

Estimated Time: 25 minutes

Watch the video below for a quick walkthrough of the lab.
[](youtube:youtubeid)

### Objectives

In this workshop, you will learn:
-	How to transform and prepare your data for analysis

### Prerequisites

To complete this lab, you need to have completed the previous labs, so that you have:

- Created an Autonomous Data Warehouse instance
- Created a new QTEAM user with appropriate roles
- demo data loaded
- Age group data loaded into AGE_GROUP

### Demo data for this lab
**NOTE:** Skip this section if you have demo data loaded and completed previous labs.

If you have not completed previous labs then run the following script in SQL Worksheet to load all necessary objects.

*For copy/pasting, be sure to click the convenient __Copy__ button in the upper right corner of the following code snippet.*: 

```
<copy>
DROP TABLE CUSTOMER_CA
;
 
CREATE TABLE CUSTOMER_CA 
    ( 
     CUST_ID        NUMBER , 
     AGE            NUMBER , 
     EDUCATION      VARCHAR2 (40) , 
     GENDER         VARCHAR2 (20) , 
     INCOME_LEVEL   VARCHAR2 (20) , 
     MARITAL_STATUS VARCHAR2 (8) , 
     PET            VARCHAR2 (40) 
    ) 
;

DROP TABLE MOVIESALES_CA
;
 
CREATE TABLE MOVIESALES_CA 
    ( 
     DAY_ID           DATE , 
     GENRE_ID         NUMBER , 
     MOVIE_ID         NUMBER , 
     CUST_ID          NUMBER , 
     APP              VARCHAR2 (100) , 
     DEVICE           VARCHAR2 (100) , 
     OS               VARCHAR2 (100) , 
     PAYMENT_METHOD   VARCHAR2 (100) , 
     LIST_PRICE       NUMBER , 
     DISCOUNT_TYPE    VARCHAR2 (100) , 
     DISCOUNT_PERCENT NUMBER , 
     TOTAL_SALES      NUMBER 
    ) 
;

DROP TABLE GENRE
;

CREATE TABLE GENRE 
    ( 
     GENRE_ID NUMBER , 
     GENRE    VARCHAR2 (30) 
    ) 
;


CREATE UNIQUE INDEX PK_GENRE_ID ON GENRE 
    ( 
     GENRE_ID ASC 
    ) 
;

ALTER TABLE GENRE 
    ADD CONSTRAINT PK_GENRE_ID PRIMARY KEY ( GENRE_ID ) 
    USING INDEX PK_GENRE_ID 
;

DROP TABLE MOVIE
;

CREATE TABLE MOVIE 
    ( 
     MOVIE_ID     NUMBER , 
     TITLE        VARCHAR2 (200) , 
     BUDGET       NUMBER , 
     GROSS        NUMBER , 
     LIST_PRICE   NUMBER , 
     GENRES       VARCHAR2 (4000) , 
     SKU          VARCHAR2 (30) , 
     YEAR         NUMBER , 
     OPENING_DATE DATE , 
     VIEWS        NUMBER , 
     CAST         VARCHAR2 (4000) , 
     CREW         VARCHAR2 (4000) , 
     STUDIO       VARCHAR2 (4000) , 
     MAIN_SUBJECT VARCHAR2 (4000) , 
     AWARDS       VARCHAR2 (4000) , 
     NOMINATIONS  VARCHAR2 (4000) , 
     RUNTIME      NUMBER , 
     SUMMARY      VARCHAR2 (16000) 
    ) 
;

DROP TABLE TIME
;

CREATE TABLE TIME 
    ( 
     DAY_ID           DATE , 
     DAY_NAME         VARCHAR2 (36) , 
     DAY_OF_WEEK      NUMBER , 
     DAY_OF_MONTH     NUMBER , 
     DAY_OF_YEAR      NUMBER , 
     WEEK_OF_MONTH    NUMBER , 
     WEEK_OF_YEAR     NUMBER , 
     MONTH_OF_YEAR    NUMBER , 
     MONTH_NAME       VARCHAR2 (36) , 
     MONTH_SHORT_NAME VARCHAR2 (12) , 
     QUARTER_NAME     VARCHAR2 (7) , 
     QUARTER_OF_YEAR  NUMBER , 
     YEAR_NAME        NUMBER 
    ) 
;

DROP TABLE AGE_GROUP
;

CREATE TABLE AGE_GROUP 
    ( 
     MIN_AGE   NUMBER , 
     MAX_AGE   NUMBER , 
     AGE_GROUP VARCHAR2 (4000) 
    ) 
;

set define on
define file_uri_base = 'https://objectstorage.us-ashburn-1.oraclecloud.com/p/H5wUeWmMyZrKxj7889AaM4q7RsdQYTOc9AYw3TYThkgVKLOLojID5yu56Yif6871/n/c4u04/b/datastudio/o/prepareandanalyze'

begin
 dbms_cloud.copy_data(
    table_name =>'CUSTOMER_CA',
    file_uri_list =>'&file_uri_base/CUSTOMER_CA.csv',
    format =>'{"type" : "csv", "skipheaders" : 1}'
 );
 dbms_cloud.copy_data(
    table_name =>'MOVIESALES_CA',
    file_uri_list =>'&file_uri_base/MOVIESALES_CA.csv',
    format =>'{"type" : "csv", "skipheaders" : 1}'
 );
 dbms_cloud.copy_data(
    table_name =>'GENRE',
    file_uri_list =>'&file_uri_base/GENRE.csv',
    format =>'{"type" : "csv", "skipheaders" : 1}'
 );
 dbms_cloud.copy_data(
    table_name =>'MOVIE',
    file_uri_list =>'&file_uri_base/MOVIE.csv',
    format =>'{"type" : "csv", "skipheaders" : 1}'
 );
 dbms_cloud.copy_data(
    table_name =>'TIME',
    file_uri_list =>'&file_uri_base/TIME.csv',
    format =>'{"type" : "csv", "skipheaders" : 1}'
 );
 dbms_cloud.copy_data(
    table_name =>'AGE_GROUP',
    file_uri_list =>'&file_uri_base/AGE_GROUP.csv',
    format =>'{"type" : "csv", "skipheaders" : 1}'
 );
end;
/
</copy>
```

Paste the SQL statements in the worksheet. Click on the **Run Script** icon.

**Note:** Expect to receive "ORA-00942 table or view does not exist" errors during the DROP TABLE command for the first execution of the script, but you should not see any other errors.

![Alt text](images/image_sql_worksheet.png)

Now you are ready to go through the rest of the labs in this workshop.

## Task 1: Launch Data Transforms

For this lab, we will try to find high-value customers. We can use sales data to assign
customer value. We can rank the customers into five quintiles based on
how much they have paid for movies and load them into a new
**CUSTOMER_SALES_ANALYSIS** table.

We will also denormalize this table with interesting customer
attributes for analysis from the **CUSTOMER_CA, AGE_GROUP** and **GENRE** tables.

This is an example of preparing data for an intended purpose. Our
purpose is to find high-value customers and find any patterns in the
sales data by data analysis.

Transform Data tool makes such data preparation tasks easy.

1.  Click on **the DATA TRANSFORMS** card to launch the tool.

    **NOTE:** If you don't see the **DATA TRANSFORMS** card then it means you are
    missing the **DATA_TRANSFORM_USER** role for your user. Login as ADMIN and
    grant the role (make sure this role is marked "Default" as well).

![screenshot of the data transform card](images/image13_transform_card.png)

2.  Provide username and password for the database user QTEAM.

![screenshot of data transform login](images/image14_transform_login.png)

3.  You will see a provisioning screen like below.

![Screenshot of data transform service start](images/image15_transform_start.png)

4.  It will take up to 3 minutes for the service to be provisioned. Once
    provisioned you will see the following home screen.

    **Note:** Data Transforms tool is provisioned based on demand. After 15 minutes of 
    inactivity, it will go into sleep mode and needs to
    be provisioned again. Clicking on any part of the UI will provision it
    again if it has gone into sleep mode. If you get any error, then
    refresh your browser.

![Screenshot of Data Transforms home page](images/image16_transform_home.png)

## Task 2: Setup connection

1.  Click on **Connections** on the left side to look at available
    connections.

![Screenshot of connection menu](images/image17_transform_conn.png)

2.  You will notice that there is one connection already defined. Click
    on the connection to establish the connection. This is a one-time
    activity.

![Screenshot of connection configuration](images/image18_transform_adb_conn.png)

3.  Enter username and password and click on Test Connection. After
    a successful connection (a notification message will appear on the top
    right).

![Screenshot of connection user and password](images/image19_transform_conn_usrpwd.png)

4.  If the notification message disappears then you can get it back by
    clicking on the bell icon on the top right. Throughout this tool, you
    will have notification messages available by clicking on the bell
    icon.

![Screenshot of the connection test](images/image20_transform_conn_test.png)

**Note:** In this workshop, we are working with only the data available in
our Autonomous Database, but you can create connections to other
databases, object stores and applications as well as load and transform
data from those sources to your Autonomous Database. Data Transforms is
a complete tool for complex data integration projects.

Now we are ready to prepare the data.

## Task 3: Create data flow to load customer sales analysis table

1.  Click on the **Home** button on the left side to go back to the home
    screen. You have wizards to load data from other sources (as defined
    in connections) and transform data. Since our data is already
    loaded in our Autonomous Database in the previous lab, we will click
    on the **Transform Data** wizard.

![Screenshot of transforms wizard](images/image21_transform_home_wiz.png)

2.  Enter the name and description of the data flow.

    Name: **load_customer_sales_analysis**
    
    Description: **Load customer sales table with quintiles and other
    attributes**
    
    A good description helps you understand the objective of the data
    flow.
    
    Since we are working on this tool for the first time, we don't have a
    project. Click on + to create a project. Accept the default name for
    the project name.
    
    Click **Next**.

![Screenshot of data flow name](images/image22_transform_name.png)

3.  Select the only connection from the dropdown list and pick **QTEAM**
    from the schema drop-down list.
    
    Click on **Save**.

![Screenshot of data flow source connection](images/image23_transform_source.png)

4.  This will bring up the data flow editing screen. On the left side, you
    will see the message "Importing Data Entities" next to the **QTEAM**
    user. It will take approximately 2-3 minutes to import all data
    entity definitions and then the message will disappear.

    You can also refresh the data entities at any time with the refresh icon.

    **Note:** Import of data entities takes place as part of data flow creation only for 
    the first time you are using the connection. Other times you need to 
    explicitly import the data entity definitions from your connection before 
    creating the data flow. The **Data Entity** menu is accessed from the Home page. 

    While the import is taking place, you can go to the next step to learn 
    navigation on the data flow editor page.


![Screenshot of data flow edit page](images/image24_transform_entity.png)

5.  Now let us learn how to navigate in the data flow editing screen.
    Refer to the numbered zones in the screenshot.

    1: Main editing canvas to create data flow by combining various
    transforms
    
    2: Data Entity browser. Data Entities can be used as a source or
    target for the data flow. You can add more connections by clicking on
    the + icon (we don't need to) and filter entities by name or tag if
    the list is big. Entities are dragged into the main canvas to build a
    data flow.
    
    3: List of transformations are grouped under various categories. Click on
    different groups to see what kinds of transforms are available. Basic
    transforms are under the **DATA TRANSFORM** and **DATA PREPARATION**
    groups. These transforms are dragged into the main canvas to build a
    data flow.
    
    4: Properties: By clicking on any source/target entity or on a
    transform step, you can view and edit various properties.
    
    5: Save, validate, and execute. We can also schedule the execution
    from an in-built scheduler.
    
    6: When you click on the empty part of the main canvas then it gives
    you the execution status of the data flow.

![Screenshot of data flow edit page zones](images/image25_transform_zones.png)

6.  Now we are ready to build the data flow. We want to aggregate the
    sales per customer to create 5 quintile buckets to determine
    customer value.

    First, we will drag **MOVIESALES_CA** into the canvas and drag
    **Aggregate** transform from above under the **DATA TRANSFORM** group.
    Next, drag **QuintileBinning** transform into the canvas. This
    transform is in the **DATA PREPARATION** group above.
    
    There are many transforms available under different groups to build
    the desired data flow. For this workshop, we will use a few of them.
    
    This should look like the below screenshot.

![Screenshot of bring source table and transforms](images/image26_transform_drag_source.png)

7.  Click on **MOVIESALES_CA,** and Link it to the **Aggregate**
    transform by dragging the little arrow on top of the **Aggregate**
    transforms. Follow this process to link transform steps in the rest
    of the workshop.

![Screenshot of linking transform steps](images/image27_transform_link.png)

8.  Now let's edit the properties of the aggregate transform. Click on
    the aggregate transform and then click on the attribute icon on the
    right-side properties panel. You should also expand the properties
    panel by clicking on the extreme right corner icon.

    Use this process to edit properties for the transform component for the remaining
    lab.

![Screenshot of aggregate attributes](images/image28_agg_attr.png)

9.  Click on Attributes on the left side. You can edit this attribute
    list. We will remove everything except **CUST_ID** and
    **TOTAL_SALES**. Click on the checkbox and click the delete icon on the
    right side.

![Screenshot of aggregate attribute edit](images/image29_agg_edit.png)

10. Now change the name of **TOTAL_SALES** to **CUST_SALES** to make it
    more meaningful. This will be aggregated sales for the customer. It
    should look like the below screenshot.

![Screenshot of aggregate attribute name edit](images/image30_agg_edit_name.png)

11. Now click on Column mapping on the left side to define the aggregate
    expression. You can populate these expressions by **Auto Map** and
    edit them as needed. Click on **Auto Map** to populate it by name.

![Screenshot of aggregate mapping expression](images/image31_agg_map_exp.png)

12. Auto Map populated only the **CUST_ID** and could not find a match for
    **CUST_SALES** since we had changed the attribute name. We can either
    type in the aggregate expression directly in the blank space or use
    the expression editor on the right side. Click on the expression
    edition icon.

![Screenshot of aggregate mapping expression edit](images/image32_agg_map_exp_edit.png)

13. This will open the expression editor. You can drag source attributes
    from the left side in the editor and write a suitable expression.

    Enter the following expression: **SUM ( MOVIESALES_CA.TOTAL_SALES )**

    Click **OK**

![Screenshot of the mapping expression editor](images/image33_agg_map_exp_edit_ui.png)

14. Review the screenshot below. The **CUST_SALES** attribute is mapped to
    the sum of **TOTAL_SALES** grouped by **CUST_ID**.

    Now collapse the properties panel by clicking on the icon in the right
    corner.

    You will follow a similar process for editing the properties in the rest
    of the workshop.

![Screenshot for closing property page](images/image34_agg_prop_collapse.png)

15. Now link the aggregate transform to the QuintileBinning transform,
    click on the QuintileBinning transform and open the properties
    panel.

![Screenshot of binning transform](images/image35_binning.png)

16. In the attribute section, click on **OUTPUT1**.

    Change the name **Return** to **CUST_VALUE**. QuintileBinning output
    will go into the **CUST_VALUE** attribute.

    Confirm that you have changed the name.

![Screenshot of binning output name change](images/image36_binning_output.png)

17. Click on the Column Mapping and enter 5 for the **number of
    buckets** expression. Drag **CUST_SALES** from the aggregate into the
    **order** expression.

    It means that aggregate customer sales will be used to divide
    customers into 5 buckets. This will be used as customer value.

![Screenshot of binning mapping expression](images/image37_binning_mapping.png)

18. Close the property panel by clicking on the right corner and come to
    the main canvas.

    Now you have the basic skills to add data sources, add transforms, and
    edit its properties. Now bring the **Join** transform into the canvas,
    drag the **CUSTOMER_CA** table and join it with the previous flow as below.
    
    Click on the Attribute property of the Join and notice that it has
    populated the join automatically. You can also edit it manually if it
    is not what you expect.
    
    Make sure the join is: **Aggregate.CUST_ID=CUSTOMER_CA.CUST_ID**

![Screenshot of joining with customer](images/image38_cust_join.png)

19. Now bring in the **AGE_GROUP** table and use Lookup transform. Link it as
    described below.

    First link the end of the data flow to Lookup and then link **AGE_GROUP** to lookup.

    **Note:** The order of linking matters for lookup transform. **AGE_GROUP**
    Should be the lookup source. Check the property panel on the right. If it is not correct
    then remove the links and link it again.

    Make sure the lookup expression is: **CUSTOMER_CA.AGE between
    AGE_GROUP.MIN_AGE and AGE_GROUP.MAX_AGE**
    
    Note that you can also optionally use the expression editor.
    
    **Note:** Take a moment to notice that we are building the data flow step by
    step and this way it is easy to understand. This is an advantage of
    using UI to define a complete data preparation task which could be
    quite complex.

![Screenshot of age group lookup](images/image39_agegroup_lookup.png)

20. Now we need to bring in the transaction data again which will be
    used for analysis later. Drag **MOVIESALES_CA** into the canvas and
    join it.

    Make sure the join is: **Aggregate.CUST_ID=MOVIESALES_CA1.CUST_ID**
    
    **NOTE:** Notice that the display name for this is MOVIESALES_CA1
    (suffixed by 1). This is because this table is used twice in the data
    flow. First for calculating the quintile and the second time to bring
    individual sales transaction data.
    
    Next, bring in the movie GENRE table and join it.
    
    Make sure the join is: **MOVIESALES_CA1.GENRE_ID=GENRE.GENRE_ID**
    
    The above join expression should be populated automatically.
    
    It should look like the below screenshot.
    
    It is good practice to keep saving it by clicking on the **Save** icon
    on the top left.

![Screenshot of movie sales and genre join](images/image40_sales_genre_join.png)

21. We have completed the data flow. It may look complex, but one can
    visualize the step-by-step transformations. Now we need to write it
    to a new **CUSTOMER_SALES_ANALYSIS** table.

    Click on the tiny grid at the corner to the end of the data flow (last
    Join transform) to open the target table property dialog. Note that if
    we already had a target table then we could simply drag that table in
    to complete the flow. But in our case, the target table doesn't exist
    yet.

![Screenshot of creating target table entity](images/image41_create_target.png)

22. Enter the name and connection properties.

    Name: **CUSTOMER_SALES_ANALYSIS**
    
    Alias: **CUSTOMER_SALES_ANALYSIS**
    
    Connection: your connection name    
    
    Schema: **QTEAM**
    
    Click **Next** for **Add Data Entity** dialog

![Screenshot of adding entity](images/image42_add_entity.png)

23. Now you can edit the target column names. The initial list is
    populated by the columns in all the tables in the data flow.

    Remove the columns ending with **_ID**. They don't help in any meaningful
    analysis. The attributes are always denormalized by the joins. Click
    on the checkbox and then click on the delete icon in the top right corner.
    
    Click **Next**

![Screenshot of entity column edit](images/image43_target_edit.png)

24. Review the columns. You can go back to make any changes. If you
    accidentally removed a column and want it back then you can add it
    manually if you know the name and data type, or you can cancel it
    and redo the process again.

    Click **Save**

![Screenshot of reviewing target columns](images/image44_target_review.png)

25. You can see that the target table is added to the end of the data
    flow.

    Please note that the target table definition has been stored in
    the entity list and if you want to recreate/edit the data flow then it will
    be available on the left side entity list for drag and drop, instead of going
    through **Add Data Entity** dialog.
    
    Now we need to make sure the target load properties are correct. Click on
    the target table in the canvas and expand the property panel by
    clicking on the top right corner.

![Screenshot of target properties](images/image45_target_property.png)

26. Click on Attributes mapping and verify the expressions. Notice that
    all have been populated properly. You can also edit them manually if
    you want to make changes. Make sure all the columns are mapped. You
    can also use auto-mapping functionality if you create new
    attributes or if some expressions are blank.

    These mapping expressions are the key to populating the target columns 
    from the right source and with the right expression.

![Screenshot of target mapping](images/image46_target_mapping.png)

27. Now to the final step. Click on **Options**.

    Make sure the property **Drop and create target table** is **true**.
    
    This makes sure that you always have the correct definition.
    
    You can also choose to load data into an existing table with or without
    truncating. Data can also be loaded incrementally. These are advanced
    modes. For now, we will simply drop and create the table in every
    execution.

![Screenshot of target options](images/image47_target_option.png)

28. Collapse the property panel and go back to the main canvas. Save it
    and validate it by clicking on the validate icon (looks like a small
    check mark).

    It should show no errors. If you do get an error then go back to your data 
    flow steps and fix it. Most probably errors are due to unmapped attributes 
    or incorrect expressions.

![Screenshot of validating data flow](images/image48_transform_validate.png)

29. Now execute it by clicking on the small triangle in the circle.
    Confirm **Start**.

![Screenshot of executing data flow](images/image49_transform_start.png)

30. Our data flow execution status is on the bottom right-side panel. Click
    anywhere on the empty canvas to make it visible. Now we need to look
    at the data.

![Screenshot of execution status](images/image50_transform_status.png)

31. Click on the target table and do the data preview by clicking on
    the small eye icon. Expand the panel to see more.

![Screenshot of target data preview](images/image51_transform_datapreview.png)

32. Check that all columns are populated. If some columns are blank,
    then it means some mapping expression in the data flow was blank or
    incorrect. Go back and fix it and re-execute it.

![Screenshot of transformed and loaded data](images/image52_transform_data.png)

33. Next, check the **Statistics** tab for a quick data profile.

![Screenshot of data statistics](images/image53_transform_stats.png)

For now, it is just a cursory data glance. We will need to use the **DATA ANALYSIS** 
tool to analyze this data and find many interesting patterns.

**Important note on this lab:**

We have scratched only the surface of possibilities in Data Transforms.
Other features are:

-   Variety of data sources: Databases, Object Store, REST API and Fusion
    Application

-   **Load Data:** Load multiple tables in a schema from another data
    source. It also integrates optionally with Golden Gate data service for advanced
    replication. This complements the Data Load tool explored in the earlier
    lab.

-   **Workflow:** Combine various data flows in the sequential or parallel
    execution flow.

-   **Schedule:** In-built scheduler for periodic execution.

## Task 4: How to debug

**Note:** This is for advanced users. Skip if you don't have any errors and you want 
to straight go to the next lab.

1.  Go back to the data flow canvas and click on the empty space in the
    canvas. On the top, there is a Code Simulation icon. Click on it. This
    will show you the code to be generated.

![Screenshot of data flow simulation](images/image54_transform_simul.png)

2.  Look at the generated SQL. Imagine writing this SQL without the
    graphical interface. It is complex. Isn't it? 
    Advanced users will find this useful for debugging purposes.

![data flow simulation SQL](images/image55_transform_simul_code.png)

3.  Next, look at the **Data flow Status** on the right side. If there are
    any errors, then you can click on the **Execution Job** in the
    **Data Flow Status** panel to debug. It will take you to the jobs
    screen where you can look at the executed steps, processed row
    counts and corresponding SQL.

![Screenshot of data flow execution job log](images/image56_transform_log.png)

4.  Notice different steps in the execution. You can also get the
    executed SQL (same as the simulated SQL seen earlier) by clicking
    on the step.
    
    To go back to your data flow, click on the **Design Object** link.
    
    From anywhere in the UI, you can go back to the Home screen by clicking on
    the top left link.

![Screenshot of job log details](images/image57_transform_log_detail.png)

This completes the lab for data transformation and preparation. There are many more features to explore for advanced users. These details will be covered in other in-depth workshops.

You may now **proceed to the next lab**.

## Acknowledgments

- Created By/Date - Jayant Mahto, Product Manager, Autonomous Database, January 2023
- Contributors - Mike Matthews, Bud Endress, Ashish Jain, Marty Gubar, Rick Green
- Last Updated By - Jayant Mahto, January 2023


Copyright (C)  Oracle Corporation.
