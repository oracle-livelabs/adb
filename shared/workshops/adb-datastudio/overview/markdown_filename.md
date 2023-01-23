# Using Data Studio to load, prepare and analyze data in the Autonomous Database

# Workshop Request

+----------------+-----------------------------------------------------+
| Workshop Title | Using Data Studio to load, prepare and analyze data |
|                | in the Autonomous Database                          |
+================+=====================================================+
| Short          | A day in the life of a data analyst. Learn how to   |
| Description    | use different tools in Data Studio for your data    |
|                | analysis needs that involves loading, transforming, |
|                | and analyzing data                                  |
+----------------+-----------------------------------------------------+
| Long           | This workshop will teach you how to use the         |
| Description    | following tools in Data Studio for your data        |
|                | analysis need:                                      |
|                |                                                     |
|                | -   Data Catalog                                    |
|                |                                                     |
|                | -   Data Load                                       |
|                |                                                     |
|                | -   Data Transforms                                 |
|                |                                                     |
|                | -   Data Analysis                                   |
|                |                                                     |
|                | -   Data Insight                                    |
+----------------+-----------------------------------------------------+
| Stakeholder    |                                                     |
+----------------+-----------------------------------------------------+
| Abstract       | >> **Workshop Elevator Pitch/Messaging**: Data       |
|                | >> Studio provides all the tools needed to help in   |
|                | >> the job of data analyst under one roof. These are |
|                | >> built-in Autonomous Database with rich capability |
|                | >> in loading, transforming, and analyzing any data. |
|                | >> It addresses the need of citizen data scientist   |
|                | >> looking for easy to use tools with no code        |
|                | >> environment.                                      |
|                | >>                                                   |
|                | >> **Workshop Description**: Learn how to use        |
|                | >> different tools in Data Studio for your data      |
|                | >> analysis needs that involves loading,             |
|                | >> transforming, and analyzing data                  |
|                | >>                                                   |
|                | >> **Why is this workshop needed?** We need an       |
|                | >> overview/introductory workshop for Data Studio.   |
|                | >>                                                   |
|                | >> **What products/technologies are used?** ADB,     |
|                | >> Data Transforms, Analytic Views, and Data Studio  |
|                | >> Analysis application.                             |
|                | >>                                                   |
|                | >> **Is there a primary Oracle product/technology    |
|                | >> being showcased? If so, what is it?** Data        |
|                | >> Transforms, Analytic Views and Data Studio        |
|                | >> Analysis application.                             |
+----------------+-----------------------------------------------------+
| Workshop       | Lab 1: Create an Oracle Autonomous Database         |
| Outline        |                                                     |
|                | Lab 2: Create user                                  |
|                |                                                     |
|                | Lab 3: Browse data                                  |
|                |                                                     |
|                | Lab 4: Load Data                                    |
|                |                                                     |
|                | Lab 5: Transform data                               |
|                |                                                     |
|                | Lab 6: Data analysis                                |
|                |                                                     |
|                | Lab 7: Data insights                                |
+----------------+-----------------------------------------------------+
|                |                                                     |
+----------------+-----------------------------------------------------+
|                |                                                     |
+----------------+-----------------------------------------------------+

# Introduction

## About This Workshop

This is an introductory workshop for the tools in Data Studio. It goes
through "a day in the life of a data analyst" and shows how to use the
tools to browse, load, transforms and analyze the data.

Workshops starts with the fictious weekly marketing team meeting and
follows along a team member who is assigned a task. For next one hour
this team member uses different tools to complete his assigned task.

## Meeting notes from the weekly marketing team meeting

Date: Monday 1-09-2023

Patrick wants to send discount offers to high value customers every
week. He also wants movie genre preference based on age groups and
marital status. It is also interesting to know whether these preferences
are different across high value and low value customers.

Brainstorming:

Bud suggested creating quintiles for customers based on 2022 movie
sales. We should send offers only to top quintile customers.

Everyone agreed it is the right strategy.

Where is the data?

Everyday sales data is being loaded to the object store bucket. Ashish
is going to setup a live feed from object store to **MOVIESALES_CA**
table. This table will have timestamped sales data. There are tables for
customer and movie genre as well.\
(note to myself: confirm the table name. Also livefeed sounds
interesting. Learn how he sets it up in the future).

TODO:

Data Prep:

Create data flow to aggregate rolling 3 months of movie sales and
populate quintile column. Schedule this to load every Sunday 9pm.

Also add denormalized columns needed for analysis to this table for
analyzing data. This table should have all the attributes needed for
analysis.

Analyze:

Create Analytic View to analyze sales data by various dimensions such as
age group, genre, marital status etc.

Insight:

Is there anything more we learn from the data?

## Objectives

In this workshop, you will:

-   Browse the catalog to find the data you need

-   Load data from your laptop

-   Transform data to create new tables for analysis

-   Analyze the data (involves creating a simple dimensional model)

-   Find hidden insights

# About the Data

The data set used in this Live Lab is a variation of the MovieStream
data set used by many other Autonomous Database labs. MovieStream is a
fictious video streaming service. The version of the data set used by
this lab is slightly modified to suit this workshop.

The tables used are:

-   CUSTOMER_CA

-   MOVIESALES_CA

-   GENRE

Loaded from laptop during workshop:

-   AGE_GROUP

**Steps to create sample data:**

-   **Login as ADMIN**

-   Install workshop utility using following lab.

    -   https://oracle-livelabs.github.io/common/building-blocks/how-to-author-with-blocks/workshop/index.html?lab=data-sets#Accessingthedata

-   **Login as QTEAM**

-   Use SQL Web and run the following

exec workshop.add_dataset(\'CUSTSALES, CUSTOMER, GENRE, TIME\');

\-- wait for the utility to finish. It will take around 5 minutes

\--Create 2021 and 2022 rows

insert into TIME (DAY_ID)

SELECT

DAY_ID+2\*365+1

FROM

TIME;

\--Create 2023 rows

insert into TIME (DAY_ID)

SELECT

DAY_ID+365

FROM

TIME where DAY_ID \>> to_date(\'01-JAN-2022\');

\--Create MOVIESALES_CA

DROP TABLE MOVIESALES_CA;

CREATE TABLE MOVIESALES_CA

(

DAY_ID DATE ,

GENRE_ID NUMBER ,

MOVIE_ID NUMBER ,

CUST_ID NUMBER ,

APP VARCHAR2 (100) ,

DEVICE VARCHAR2 (100) ,

OS VARCHAR2 (100) ,

PAYMENT_METHOD VARCHAR2 (100) ,

LIST_PRICE NUMBER ,

DISCOUNT_TYPE VARCHAR2 (100) ,

DISCOUNT_PERCENT NUMBER ,

TOTAL_SALES NUMBER

);

INSERT

/\*+ APPEND PARALLEL \*/

INTO MOVIESALES_CA

( DAY_ID,

GENRE_ID,

MOVIE_ID,

CUST_ID,

APP,

DEVICE,

OS,

PAYMENT_METHOD,

LIST_PRICE,

DISCOUNT_TYPE,

DISCOUNT_PERCENT,

TOTAL_SALES

)

SELECT

DAY_ID+3\*365 DAY_ID,

GENRE_ID,

MOVIE_ID,

CUST_ID,

APP,

DEVICE,

OS,

PAYMENT_METHOD,

LIST_PRICE,

DISCOUNT_TYPE,

DISCOUNT_PERCENT,

ACTUAL_PRICE

from CUSTSALES T1

where exists (select \'x\' from CUSTOMER T2 where T1.CUST_ID =
T2.CUST_ID and T2.STATE_PROVINCE = \'California\' );

\--Create CUSTOMER_CA

CREATE TABLE CUSTOMER_CA

(

CUST_ID,

AGE,

EDUCATION,

GENDER,

INCOME_LEVEL,

MARITAL_STATUS,

PET

) AS

(SELECT

CUST_ID,

AGE,

EDUCATION,

GENDER,

INCOME_LEVEL,

MARITAL_STATUS,

PET

FROM

CUSTOMER

where STATE_PROVINCE = \'California\');

\--rename columns

ALTER TABLE GENRE RENAME COLUMN NAME TO GENRE;

\--Drop unwanted tables

DROP TABLE CUSTSALES;

DROP TABLE CUSTOMER;

DROP TABLE CUSTOMER_CONTACT;

DROP TABLE CUSTOMER_EXTENSION;

\--Check row count

SELECT COUNT(\*) FROM MOVIESALES_CA;

\--Should be 901582

\--Check row count

SELECT COUNT(\*) FROM CUSTOMER_CA;

\--Should be 5261

# Lab 1: Create an Oracle Autonomous Database 

# Lab 2: Create user

Make sure this user has DATA_TRANSFORM_USER role with default also
checked.

# Lab 3: Browse data

## Introduction

Data Studio has a collection of tools for various needs. We will start
with Data Catalog to look for the data we need.

**Task 1 -- Launch Database Action**

1.  Login to the Autonomous Database created earlier with your user and
    password. You can see various tools under Data Studio.

>> Note: Bookmark the Database Actions page so that it is easier to come
>> back to this later in the workshop.
>>
>> Click on **DATA STUDIO OVERVIEW** card.

![](media/image1.png){width="6.5in" height="3.04376312335958in"}

2.  It shows the list of recent objects in the middle. On the left, it
    has links to individual tools and on the right, link to
    documentation.

![](media/image2.png){width="6.444933289588802in"
height="3.0479166666666666in"}

Since it is a workshop, there are limited objects in the list. There
will be many objects and only the recent objects are shown here. We will
use the Catalog tool to browse the objects and find what we need.

**Task 2 -- Explore Catalog**

1.  Click on the Catalog link on the left panel.

>> In a typical database there will be many objects and you need various
>> ways to search and display objects. Various ways to navigate a catalog
>> is shown by marked numbers in the above screenshot. These are:
>>
>> 1: Saved searches. You can filter objects easily with one click and
>> then refine the search further as per need.
>>
>> 2: Filters to narrow down your search.
>>
>> 3: Various display modes. Card/Grid/List view.
>>
>> 4: Search bar where you can type in advanced search query

![](media/image3.png){width="6.455540244969379in"
height="3.057638888888889in"}

2.  Note that catalog shows all types of objects. We are interested in
    only the tables for now. Click on "Tables, views and analytic views
    owned by..." on the right zone 1.

>> You can see the MOVIESALES_CA in this list. We are interested in this
>> table since we were told that this table contains movie sales
>> transaction data. (Referring to the meeting notes in introductory
>> section of this workshop).
>>
>> You could explicitly search for MOVIESALES_CA by typing the name of
>> the table in the search bar but in our case, it is clearly visible in
>> the grid view in the middle.

![](media/image4.png){width="6.466951006124234in"
height="3.027083333333333in"}

3.  Click on the MOVIESALES_CA table.

>> You can see the data preview. You can scroll right to see more columns
>> and scroll down to see more rows. You can also sort the columns by
>> right clicking on the columns. Using the data view, you can be sure
>> that this is the data you want.
>>
>> Note that you also have other information such as
>> lineage/impact/statistics/data definitions etc. This workshop is not
>> going into the details. In-depth catalog will be explored in other
>> workshops.
>>
>> Now close this view by clicking on the bottom right **Close** button.

![](media/image5.png){width="6.3258027121609794in"
height="3.060416666666667in"}

4.  Look for the other tables of our interest in the main catalog page.
    If you remember the meeting notes in introductory section of this
    workshop, we are also interested in CUSTOMER_CA and GENRE tables.
    Find and click on these tables to do a data preview.

![](media/image6.png){width="6.457644356955381in"
height="3.021725721784777in"}

5.  We also need to find out whether age group information is present.

>> Clear search bar and enter the following search string:
>>
>> **(type: COLUMN) AGE**
>>
>> This will search for all the columns with "AGE" in the column name.
>>
>> We can explicitly search for GROUP as well but we don't see any.
>>
>> Looks like we need to load a new table for age group.

![](media/image7.png){width="6.448788276465442in"
height="3.040277777777778in"}

# Lab 4: Load data

## Introduction

If you remember our assignment (in the introduction section), we need to
analyze the movie sales data by age group as well. In our previous lab
we noticed that there is no age group information, and we need to load a
new table for age group.

For this we will go back to our database actions page by clicking on the
top left button and use Load Data tool.

![](media/image8.png){width="6.432541557305337in"
height="3.060416666666667in"}

**Task 1 -- Create local data file for AGE_GROUP**

1.  We need to create a local data file for AGE_GROUP. Launch Excel on
    your desktop to create this dataset. Note that you can also use a
    text editor to create this data set since it is small.

Save this as AGE_GROUP Excel workbook.

>> If you don't have Excel then create a csv file with the data as below
>> and save it as AGE_GROUP.csv.
>>
>> \-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--

\"MIN_AGE\",\"MAX_AGE\",\"AGE_GROUP\",

0,20,\"00-20\",

21,30,\"21-30\",

31,40,\"31-40\",

41,50,\"41-50\",

51,60,\"51-60\",

61,70,\"61-70\",

71,80,\"71-80\",

81,200,\"Older than 81\",

>> \-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--

![](media/image9.png){width="2.741903980752406in"
height="2.275196850393701in"}

**Task 2 -- Load data file for AGE_GROUP**

1.  Launch Data Load from Database Actions page by clicking on **DATA
    LOAD** card.

>> Note that you have various modes for loading data. You can either
>> directly load data or leave it in place simply linking it. You can
>> also create ongoing feed to load data to Autonomous Database.
>>
>> You can also load data from either your local file, database or from a
>> cloud storage.
>>
>> In this lab we are loading data from the local file created in earlier
>> task. Selected **LOCAL FILE** and press **Next**.

![](media/image10.png){width="6.5in" height="4.054166666666666in"}

2.  Drag your local file AGE_GROUP.xlsx to the load window.

![](media/image11.png){width="6.5in" height="3.05in"}

3.  Press on the green triangle button to start the load.

>> After the load is complete, click on the Database Actions link on top
>> of the page to go back to the main menu.
>>
>> Now we all the data sets that we need to complete our assignment.

![](media/image12.png){width="6.5in" height="2.2840277777777778in"}

# Lab 5: Transform data

## Introduction

Now let us refer to our assignment again. We are supposed to find high
value customers. It was decided that we can use sales data to assign
customer value. We can rank the customers into five quintiles based on
how much they have paid for movies and load into a new
**CUSTOMER_SALES_ANALYSIS** table.

We will also denormalized this table with interesting customer
attributes for analysis from **CUSTOMER_CA, AGE_GROUP** and **GENRE**
table.

This is an example of preparing data for an intended purpose. Our
purpose is to find high value customers and find any patterns in the
sales data by analyzing it.

Transform Data tool makes such data preparation tasks easy.

**Task 1 -- Launch Data Transforms**

1.  Click on DATA TRANSFORMS card to launch the tool.

>> NOTE: If you don't see the DATA TRANSFORMS card then it means you are
>> missing DATA_TRANSFORM_USER role for your user. Login as ADMIN and
>> grant the role (make sure this role is marked "Default" as well).

![](media/image13.png){width="6.5in" height="3.65625in"}

2.  Provide username and password for the database user QTEAM.

![](media/image14.png){width="6.5in" height="3.1006944444444446in"}

3.  You will see a provisioning screen like below.

![](media/image15.png){width="6.5in" height="3.1145833333333335in"}

4.  It will take up to 3 minutes for the service to be provisioned. Once
    provisioned you will see the following home screen.

>> Note: Data Transforms tool is provisioned based on demand. If there is
>> inactivity for 15 minutes, then it goes into sleep mode and needs to
>> be provisioned again. Clicking on any part of the UI will provision it
>> again if it has gone into sleep mode. If you get any error, then
>> refresh your browser.

![](media/image16.png){width="6.5in" height="2.8256944444444443in"}

**Task 2 -- Setup Connection**

1.  Click on **Connections** on the left side to look at available
    connections.

![](media/image17.png){width="6.5in" height="2.790277777777778in"}

2.  You will notice that there is one connection already defined. Click
    on the connection to establish the connection. This is one time
    activity.

![](media/image18.png){width="6.158562992125984in"
height="3.4756944444444446in"}

3.  Enter username and password and click on Test Connection. After
    successful connection (notification message will appear on top
    right).

![](media/image19.png){width="6.40924321959755in"
height="3.167030839895013in"}

4.  If the notification message disappears then you can get it back by
    clicking on the bell icon on the top right. Throughout this tool you
    will have notification messages available by clicking on the bell
    icon.

![](media/image20.png){width="6.456453412073491in"
height="3.157638888888889in"}

Note: In this workshop we are working with only the data available in
our Autonomous Database, but you can create connections to other
databases, object stores and applications as well and load and transform
data from those sources to your Autonomous Database. Data Transforms is
a complete tool for complex data integration projects.

Note: Any database user who has DATA_TRANSFORM_USER role, can access the
connection setup in this step (and any other connections or data flows
created later). All the objects created in the Transforms are also
shared with other users with this role. Because of this you need to be
very selective on giving out this role.

Now we are ready to prepare the data.

**Task 3 -- Create data flow to load customer sales analysis table**

1.  Click on the **Home** button on the left side to go back to the home
    screen. You have wizards to load data from other sources (as defined
    in connections) and to transform data. Since our data is already
    loaded in our Autonomous Database in the previous lab, we will click
    on the **Transform Data** wizard.

![](media/image21.png){width="6.5in" height="3.176388888888889in"}

2.  Enter name and description of data flow.

>> Name: **load_customer_sales_analysis**
>>
>> Description: **Load customer sales table with quintiles and other
>> attributes**
>>
>> A good description helps you understand the objective of the data
>> flow.
>>
>> Since we are working on this tool for the first time, we don't have a
>> project. Click on + to create a project. Accept the default name for
>> project name.
>>
>> Click **Next**.

![](media/image22.png){width="6.5in" height="3.4783169291338583in"}

3.  Select the only connection from the dropdown list and pick **QTEAM**
    from the schema drop down list.\
    \
    Click on **Save**.

![](media/image23.png){width="6.481306867891513in"
height="4.952083333333333in"}

4.  This will bring up data flow editing screen. On the left side you
    will see message as "Importing Data Entities" next to **QTEAM**
    user. It will take approximately 2-3 minute to import all data
    entity definitions and then message will disappear.

You can also refresh the data entities any time with the refresh icon.

![](media/image24.png){width="6.475527121609799in" height="3.15in"}

5.  Now let us learn how to navigate in the data flow editing screen.
    Refer to the numbered zones in the screenshot.

>> 1: Main editing canvas to create data flow by combining various
>> transforms
>>
>> 2: Data Entity browser. Data Entities can be used as a source or
>> target for the data flow. You can add more connections by clicking on
>> the + icon (we don't need to) and filter entities by name or tag if
>> the list is big. Entities are dragged into the main canvas to build a
>> data flow.
>>
>> 3: List of transformations grouped under various buckets. Click on
>> different buckets to see what kind of transforms are available. Basic
>> transforms are under **DATA TRANSFORM** and **DATA PREPARATION**
>> bucket. These transforms are dragged into the main canvas to build a
>> data flow.
>>
>> 4: Properties: By clicking on any source/target entity or on a
>> transform step, you can view and edit various properties.
>>
>> 5: Save, validate, and execute. We can also schedule the execution
>> from in built scheduler.
>>
>> 6: When you click on the empty part of the main canvas then it gives
>> you execution status of the data flow.

![](media/image25.png){width="6.445417760279965in"
height="3.145138888888889in"}

6.  Now we are ready to build the data flow. We want to aggregate the
    sales per customer to create 5 quintile buckets to determine
    customer value.

>> First, we will drag **MOVIESALES_CA** into the canvas and drag
>> **Aggregate** transform from above under **DATA TRANSFORM** bucket.
>> Also drag **QuintileBinning** transform into the canvas. This
>> transform is in **DATA PREPARATION** bucket above.
>>
>> There are many transforms available under different buckets to build
>> the desired data flow. For this workshop, we will use few of them.
>>
>> This should like below.

![](media/image26.png){width="6.5in" height="3.0292180664916883in"}

7.  Click on **MOVIESALES_CA,** and Link it to the **Aggregate**
    transform by dragging the little arrow on top of the **Aggregate**
    transforms. Follow this process to link transform steps in the rest
    of the workshop.

![](media/image27.png){width="6.5in" height="3.4340277777777777in"}

8.  Now let's edit the properties of the aggregate transform. Click on
    the aggregate transform and then click on the attribute icon on the
    right-side properties panel. You should also expand the properties
    panel by clicking on the extreme right corner icon.

Use this process to edit properties for the transforms for the remaining
of the workshop.

![](media/image28.png){width="6.5in" height="3.2423611111111112in"}

9.  Click on Attributes on the left side. You can edit this attribute
    list. We will remove everything except **CUST_ID** and
    **TOTAL_SALES**. Click on the checkbox and click delete icon on the
    right side.

![](media/image29.png){width="6.5in" height="3.2526531058617674in"}

10. Now change the name of **TOTAL_SALES** to **CUST_SALES** to make it
    more meaningful. This will be aggregated sales for the customer. It
    should look like below.

![](media/image30.png){width="6.5in" height="2.0416666666666665in"}

11. Now click on Column mapping on the left side to define aggregate
    expression. You can populate these expressions by **Auto Map** and
    edit it as needed. Click on **Auto Map** to populate it by name.

![](media/image31.png){width="6.5in" height="1.3138888888888889in"}

12. Auto Map populated only the CUST_ID and could not find a match for
    CUST_SALES since we had changed the attribute name. We can either
    type in the aggregate expression directly in the blank space or use
    the expression editor on the right side. Click on the expression
    edition icon.

![](media/image32.png){width="6.5in" height="1.5805555555555555in"}

13. This will open the expression editor. You can drag source attributes
    from the left side in the editor and write a suitable expression.

Enter the following expression: **SUM ( MOVIESALES_CA.TOTAL_SALES )**

Click **OK**

![](media/image33.png){width="6.5in" height="3.167361111111111in"}

14. Review the screenshot below. **CUST_SALES** attribute is mapped to
    the sum of **TOTAL_SALES** grouped by **CUST_ID**.

Now collapse the properties panel by clicking on icon on the right
corner.

You will follow similar process for editing the properties in the rest
of the workshop.

![](media/image34.png){width="6.5in" height="2.438888888888889in"}

15. Now link the aggregate transform to the QuintileBinning transform,
    click on the QuintileBinning transform and open the properties
    panel.

![](media/image35.png){width="6.5in" height="2.6215277777777777in"}

16. In the Attribute section, click on the **OUTPUT1**.

Change the name **Return** to **CUST_VALUE**. QuintileBinning output
will go into **CUST_VALUE** attribute.

Confirm that you have changed the name.

![](media/image36.png){width="6.5in" height="1.8083333333333333in"}

17. Click on the Column Mapping and enter 5 for the **number of
    buckets** expression. Drag **CUST_SALES** from aggregate into the
    **order** expression.

>> **It means that aggregate customer sales will be used to divide
>> customers into 5 buckets. This will be used as customer value.**

![](media/image37.png){width="6.5in" height="2.154166666666667in"}

18. Close the property panel by clicking on the right corner and come to
    the main canvas.

>> Now you have the basic skills to add data sources, add transforms, and
>> edit its properties. Now bring **Join** transform into the canvas,
>> drag **CUSTOMER_CA** table and join it with previous flow as below.
>>
>> Click on the Attribute property of the Join and notice that it has
>> populated the join automatically. You can also edit it manually if it
>> is not what you expect.
>>
>> Make sure the join is: **Aggregate.CUST_ID=CUSTOMER_CA.CUST_ID**

![](media/image38.png){width="6.5in" height="2.329861111111111in"}

19. Now bring in AGE_GROUP table and use Lookup transform. Link it as
    below.

>> Make sure lookup expression is: **CUSTOMER_CA.AGE between
>> AGE_GROUP.MIN_AGE and AGE_GROUP.MAX_AGE**
>>
>> Note that you can also optionally use the expression editor.
>>
>> **Take a moment to notice that we are building the data flow step by
>> step and this way it is easy to understand. This is an advantage of
>> using UI to define a complete data preparation task which could be
>> quite complex.**

![](media/image39.png){width="6.5in" height="3.373611111111111in"}

20. Now we need to bring in the transaction data again which will be
    used for analysis later. Drag **MOVIESALES_CA** into the canvas and
    join it.

>> Make sure the join is: **Aggregate.CUST_ID=MOVIESALES_CA1.CUST_ID**
>>
>> **NOTE: Notice that the display name for this is MOVIESALES_CA1
>> (suffixed by 1). This is because this table is used twice in the data
>> flow. First for calculating the quintile and the second time to bring
>> individual sales transaction data.**
>>
>> Also bring in movie GENRE table and join it.
>>
>> Make sure the join is: **MOVIESALES_CA1.GENRE_ID=GENRE.GENRE_ID**
>>
>> The above join expression should be populated automatically.
>>
>> It should look like below.
>>
>> It is good practice to keep saving it by clicking on the **Save** icon
>> on the top left.

![](media/image40.png){width="6.5in" height="3.2801377952755906in"}

21. We have completed the data flow. It may look complex, but one can
    visualize it step by step transformations. Now we need to write it
    to a new **CUSTOMER_SALES \_ANALYSIS** table.

>> Click on the tiny grid at the corner to the end of the data flow (last
>> Join transform) to open the target table property dialog. Note that if
>> we already had a target table then we could simply drag that table in
>> to complete the flow. But in our case, the target table doesn't exist
>> yet.

![](media/image41.png){width="6.5in" height="3.386111111111111in"}

22. Enter the name and connection properties.

>> Name: **CUSTOMER_SALES_ANALYSIS**
>>
>> Alias: **CUSTOMER_SALES_ANALYSIS**
>>
>> Connection:\<your connection name\>>
>>
>> Schema:**QTEAM**
>>
>> Click **Next** for **Add Data Entity** dialog

![](media/image42.png){width="6.5in" height="3.8493055555555555in"}

23. Now you can edit the target column names. The initial list is
    populated by the columns in all the tables in the data flow.

>> Remove the columns ending with \_ID. They don't help in any meaningful
>> analysis. The attributes are always denormalized by the joins. Click
>> on the checkbox and then click on the delete icon on top right.
>>
>> Click **Next**

![](media/image43.png){width="6.489390857392826in"
height="3.8555555555555556in"}

24. Review the columns. You can go back to make any changes. If you
    accidently removed a column and want it back then you can add it
    manually if you know the name and data type, or you can cancel it
    and redo the process again.

Click **Save**

![](media/image44.png){width="6.471868985126859in"
height="3.8506944444444446in"}

25. You can see that the target table is added to the end of the data
    flow.

>> Also note that the target table definition has been stored in
>> transforms and if you want to recreate/edit the data flow then it will
>> be available on the left side for drag and drop, instead of going
>> through **Add Data Entity** dialog.
>>
>> Now we need to make sure target load properties are correct. Click on
>> the target table in the canvas and expand the property panel by
>> clicking on the top right corner.

![](media/image45.png){width="6.5in" height="2.8012139107611547in"}

26. Click on Attributes mapping and verify the expressions. Notice that
    all have been populated properly. You can also edit them manually if
    you want to make changes. Make sure all the columns are mapped. You
    can also use auto mapping functionality if you have create new
    attributes.

![](media/image46.png){width="6.5in" height="3.692361111111111in"}

27. Now to the final step. Click of **Options**.

>> Make sure you have the **Drop and create target table** is **true**.
>>
>> This makes sure that you always have the correct definition.
>>
>> You can also choose to load data into existing table with or without
>> truncating. Data can also be loaded incrementally. These are advanced
>> modes. For now we will simply drop and create the table in every
>> execution.

![](media/image47.png){width="6.5in" height="3.701388888888889in"}

28. Collapse the property panel and go back to the main canvas. Save it
    and validate it by clicking on the validate icon (looks like small
    check mark).

![](media/image48.png){width="6.5in" height="3.1486111111111112in"}

29. Now execute it by clicking on the small triangle in the circle.
    Confirm **Start**.

![](media/image49.png){width="6.5in" height="4.6305555555555555in"}

30. Data flow execution status is on the bottom right-side panel. Click
    anywhere on the empty canvas to make it visible. Now we need to look
    at the data.

![](media/image50.png){width="6.5in" height="3.327777777777778in"}

31. Click on the target table and do the data preview by clicking on
    small eye icon. Expand the panel to see more.

![](media/image51.png){width="6.5in" height="3.178472222222222in"}

32. Check that all columns are populated. If some columns are blank,
    then it means some mapping expression in the data flow was blank or
    incorrect. Go back and fix it and re-execute it.

![](media/image52.png){width="6.5in" height="3.7444444444444445in"}

33. Also check the **Statistics** tab for quick data profile.

![](media/image53.png){width="6.5in" height="3.8618055555555557in"}

For now, it is just a cursory data glance. Next, we will use **DATA
ANYSIS** tool to analyze this data and find many interesting patterns.

**Important note on this lab:**

We have scratched only the surface of possibilities in Data Transforms.
Other features are:

-   Verity of data sources: Databases, Object Store, REST API and Fusion
    Application

-   Load Data: Loading multiple tables in a schema from another data
    source. It integrates with Golden Gate data service for advanced
    replication. This completes the Data Load tool explored in earlier
    lab.

-   Work flow: Combining various data flows in sequential or parallel
    execution flow.

-   Schedule: In built scheduler for periodic execution.

**Task 4 -- For Advanced users: How to debug**

**Note: skip if you don't have any errors and you want to straight go to
the next task.**

1.  Go back to data flow canvas and click on the empty space in the
    canvas. On the top there is Code Simulation icon. Click on it. This
    will show you the code to be generated.

![](media/image54.png){width="6.5in" height="3.0805555555555557in"}

2.  Look at the generated SQL. Imagine writing this SQL without the
    graphical interface. Still some advanced users might find this
    useful for debugging purposes.

![](media/image55.png){width="6.5in" height="4.299305555555556in"}

3.  Now look at the **Data flow Status** on the right side. If there are
    any errors, then you can click on the **Execution Job** in the
    **Data Flow Status** panel to debug. It will take you to the jobs
    screen where you can look at the executed steps, processed row
    counts and corresponding SQL.\
    \
    ![](media/image56.png){width="6.135285433070866in"
    height="2.894002624671916in"}

4.  Notice different steps in the execution. You can also get the
    executed SQL (as opposed to simulated SQL seen earlier) by clicking
    on the step.

To go back to your data flow, click on the **Design Object** link.

From anywhere in the UI, you can go back to Home screen by clicking on
the top left link.

![](media/image57.png){width="6.5in" height="2.264576771653543in"}

There are many more features to explore for the advanced users. In this
workshop we are limiting to creating a data flow and executing it on
demand.

# Lab 6: Data analysis

## Introduction

Now let us refer to our assignment again. We are supposed to find high
value customers. In our previous lab we created a table with list of
customer ids against 1 to 5 values based on movie consumption. This
table can be used for sending promotional offers to customers with value
5.

Now on to the 2^nd^ part of our task. We were asked to find movie genre
preference based on age groups and marital status and whether these
preferences are different across high value and low value customers.

We need to analyze our customer sales data along with age group, genre,
and customer value dataset. We will use **DATA ANALYSIS** tool for this
task.

**Task 1 -- Create AV for data analysis**

1.  Navigate to Database Actions page and launch DATA ANALYSIS tool.

![](media/image58.png){width="6.5in" height="3.0548611111111112in"}

2.  First time when you access data analysis tool, you will see a
    guiding wizard that will describe various parts of the UI. Since you
    are doing this lab anyways, click on X to cancel it and start using
    the tool right away.

![](media/image59.png){width="6.5in" height="3.229861111111111in"}

3.  To Analyze your data, create an Analytic View (AV) first. Analytic
    Views organize data using a dimensional model, allowing you to
    easily add aggregations and calculations to data sets and present
    data in views that can be queried with relatively simple SQL.

>> We don't have any AV yet, therefore we are going to create one.
>>
>> Select your schema QTEAM and click on **Create** button.

![](media/image60.png){width="6.449922353455818in"
height="2.3208333333333333in"}

4.  Default AV name is derived by the fact table. Enter various fields
    as follows:

>> Name: **CUSTOMER_SALES_ANALYSIS_AV**
>>
>> Caption: **Customer sales analysis av**
>>
>> Description: **Customer sales analysis av**
>>
>> Schema: **QTEAM**
>>
>> Fact Table: Pick **CUSTOMER_SALES_ANALYSIS** from the list
>>
>> You can find related tables and hierarchies by clicking on **Generate
>> Hierarchy and Measures** button. This will scan your schema and find
>> all the tables related to CUSTOMER_SALES_ANALYSIS and give you a
>> starting point.
>>
>> However, in our case, we have prepared the data in such a way that all
>> analysis attributes are in one table. We don't need to run this
>> automated process.

![](media/image61.png){width="5.853778433945757in"
height="2.8946784776902885in"}

5.  Now click on Data Sources on left side to verify that
    CUSTOMER_SALES_ANALYSIS is the data source.

![](media/image62.png){width="6.246150481189852in"
height="3.0593383639545055in"}

6.  Now click on the Hierarchies on the left side and add the attributes
    we want in our analysis. We want to add **AGE_GROUP, CUST_VALUE,
    DEVICE, MARITAL_STATUS, GENRE,** and **PET**. It will be interesting
    to do movie preference analysis with pets.

NOTE: These are all single level hierarchies. Adding multiple level
hierarchies is advanced topic and will not be covered. However, we will
see that even with single level hierarchies, we can do interesting
analysis.

![](media/image63.png){width="5.914523184601925in"
height="4.138888888888889in"}

7.  If you don't see your column, then click on More columns at the end
    at search for your columns. Then add it by clicking on it.

![](media/image64.png){width="5.1216338582677166in"
height="3.2381944444444444in"}

8.  After you add all, it should look like below.

![](media/image65.png){width="6.338054461942257in"
height="3.176388888888889in"}

9.  Now click on Measures and add a measure with TOTAL_SALES column

![](media/image66.png){width="6.302256124234471in"
height="3.1858070866141732in"}

10. We have completed our AV. Click on **Create** it and confirm OK.

![](media/image67.png){width="6.5in" height="3.204861111111111in"}

11. Our AV is ready now and we can start analyzing data. You can see
    that there are no errors. By clicking on the Data Quality tab.

>> You can also go back and edit the AV by clicking on three vertical
>> dots.

![](media/image68.png){width="6.452022090988627in"
height="3.1095231846019247in"}

**Task 2 -- Analyze data**

Now the fun part starts. All this time we were preparing the data and
creating dimensional model in AV. We will start creating reports, charts
and start finding hidden patterns in the data.

First let's learn how to navigate in the analysis tool.

1.  Select your AV and click on **Analyze**.

>> These zones are:
>>
>> 1: Hierarchies and measures
>>
>> 2: Columns, Rows, Values and Filters where you can drag components
>> from the zone 1 to slice and dice the data.
>>
>> 3: Main area for displaying reports and charts.
>>
>> 4: Table/Pivot/Chart view. For remainder of the lab we will use chart
>> view.
>>
>> 5: Insights. Automated algorithm to search for hidden patterns. This
>> is the topic of our last lab. For now, we will click on the right side
>> bar to collapse it.

![](media/image69.png){width="6.419293525809274in"
height="3.064391951006124in"}

2.  Now we can start doing our first analysis.

>> **Analysis: show me \"SALES_AMOUNT\" by \"AGE_GROUP\"**
>>
>> Select chart mode. Clear all hierarchies from X-Axis and drag **Age
>> group** to X-Axis and **Total Sales** to Y-Axis.
>>
>> This chart is showing you total sales across age group. We can
>> conclude that seniors (71-80) are not watching many movies whereas age
>> group 21-30 and 31-40 are watching most.

![](media/image70.png){width="6.479812992125984in"
height="3.1179615048118987in"}

3.  Next let us analyze sales by marital status.

>> Clear X-Axis and drag **Marital status**.
>>
>> You will have to expand the left side tree node to drag the level.
>> Level is under hierarchy node (with the same name for convenience).
>>
>> We can see that singles are watching more movies than married people.

![](media/image71.png){width="6.3939479440069995in"
height="3.0579757217847767in"}

4.  Now we can mix two hierarchies. Drag **Age group** above **Marital
    status** in X-Axis.

>> We notice that although singles watch overall more movies, married
>> people watch more than singles in young age group (21-30, 31-40).
>>
>> This was not obvious before.

![](media/image72.png){width="6.417255030621172in"
height="3.1113965441819773in"}

5.  Now we are curious to know which genre sells most.

>> Clear X-Axis and drag **Genre**.
>>
>> Drama Sells! Followed by Action.

![](media/image73.png){width="6.406935695538058in" height="3.10625in"}

6.  We had earlier ranked our customers in high and low value buckets.
    It will be interesting to find out whether there is a movie genre
    preference of high value customers.

>> Clear X-Axis and drag **GENRE** and **CUST_VALUE**.
>>
>> The chart is very wide, and you can't see all the way to the right. To
>> fit the entire width you can drag the right edge of lower window
>> towards right till all customer values are visible in one page.

![](media/image74.png){width="6.5in" height="3.120833333333333in"}

7.  Let's look at this chart. We can see that Drama is very popular with
    high value (Cust value=5) customers, whereas Action is more popular
    with low value customers (Cust value=1).

>> Of course, most of the bars are taller for high value customers
>> because overall they spend more.

![](media/image75.png){width="6.4224453193350834in" height="3.10625in"}

Go ahead and see if you can find any other interesting pattern. What
movie genre are popular in different age groups?

We can spend lots of time in the analysis tool visualizing the data with
different combinations of attributes.

So far, we are looking at only the charts, but this data can be
displayed in tabular format and in a pivot table as well. Switch the
display mode to see how it works. Advanced uses can access the data in
this AV from Excel or from Googlesheet. This is out of scope for this
lab.

# Lab 7: Data Insights

## Introduction

While we are doing data analysis, Data Studio is busy in the background
finding interesting patterns in the data. This is hands off approach to
finding insights that are lurking out of sight in the data.

In this lab we will investigate various insights produced by the tool.
We will learn how to interpret it and will cross-check with manual
analysis.

Note that insight process can run for some time depending on the
complexity of the data set and available compute resources. Our data set
is small enough that it will complete in reasonable time. But you might
see the insight list being refreshed while it is executing.

**Task 1 -- Use Data Insights**

1.  Launch Data Insights by clicking on the Database Actions link on the
    top and then click on the **DATA INSIGHTS** card.

![](media/image76.png){width="6.5in" height="3.057638888888889in"}

2.  On the insight page click on the top right icon to get a tour of the
    tool.

![](media/image77.png){width="6.469770341207349in" height="3.1in"}

3.  Click Next to go through each area and learn about it.

![](media/image78.png){width="6.169071522309712in"
height="3.022222222222222in"}

4.  you can pick AV or any table to run insights on. In case of AV, you
    can pick any measure to run insight against whereas if you want to
    run insights against a single table then you can pick any column
    which you think is a measure.

>> In our case, AV built in the previous lab had only one measure
>> (TOTAL_SALES). Insight tool has gone through the data and discovered
>> many interesting behavioral patterns (of movie buying).
>>
>> NOTE: These insights are stored in the database and can be queried any
>> time for a review. You can also regenerate the analysis if the data in
>> underlying AV/table has changed.
>>
>> Let's look at few of such patterns. For this lab, we will look at 3
>> examples:
>>
>> 1: Purchasing pattern of singles across Genre
>>
>> 2: Representation of seniors (61-70) across customer value
>>
>> 3: Purchasing behavior of dog owners across age groups
>>
>> You can find them in the screenshot below. **Note that the order of
>> insights may vary if data is different or the insight is still
>> running, therefore refer to the labels on each tile to identify it.**

![](media/image79.png){width="6.1465693350831145in"
height="3.0428565179352582in"}

5.  Click on the tile marked **S** on the top and **Genre** at the
    bottom. It shows

>> 1: TOTAL_SALES (our measure driving the insight) in **blue** bars for
>> **Marital Status=S** across **Genre**
>>
>> 2: Each bar has a **green** horizontal line depicting average
>> **without Marital Status=S filter**. It is called **expected** value.
>> It can differ form the blue level if the data is skewed for the filter
>> on the top (**Marital Status=S**).
>>
>> 3: Few bars are surrounded by black border (pointed by arrows). These
>> are highlighted exceptions.
>>
>> Another way to read this is as:
>>
>> **Singles** are purchasing **Adventure** and **Comedy** more than
>> average and not much interested in **Drama**.
>>
>> WOW! That is quite an insight.

![](media/image80.png){width="6.5in" height="3.0145833333333334in"}

6.  Now to the next insight.

>> Click on the tile marked **61-70** on the top and **Cust value** at
>> the bottom. It shows
>>
>> It shows that seniors 61-70 overrepresented in 4^th^ customer value
>> bucket. Probably they have lots of disposable income!

![](media/image81.png){width="6.5in" height="2.897222222222222in"}

7.  Now, just for fun lets look at pet ownership and movie purchase
    relationship.

>> Click on the tile marked **Dog** on the top and **Cust Value**.
>>
>> It shows that highest value (5) dog owners are purchasing more movies
>> than average compared to non-dog owners.
>>
>> It is just a correlation but you could use this data to offer dog
>> grooming products to high value customers!!
>>
>> Interesting. Isn't it! Insight tool has discovered all these hidden
>> patterns just by crawling through the data.

![](media/image82.png){width="6.193623140857393in"
height="2.9879024496937885in"}

**Concluding thought**: If we are doing manual analysis in **DATA
ANALYSIS** tool, then we must actively look at and compare the data for
certain hierarchies. There are many combinations, but people use their
experience to guide their analysis steps. In comparison, **DATA
INSIGHTS** is hands off approach and it finds patterns without
understanding what hierarchies mean.

We think that both are complimentary to each other and provide valuable
tools to use in "a day in the life of a data analyst". That is how we
started this workshop!

Now all the assigned tasks from our Monday meeting have been completed
successfully. Ready for the next meeting.

**Task 2 -- Advanced users: Peeling the layers for Data Insights**

This section is an attempt to explain the insights by manually running
queries and correlating them with what we can see in insights.

1.  Let's go back and look at the 1^st^ insight again.

Click on the tile marked **S** on the top and **Genre** at the bottom

![](media/image83.png){width="6.5in" height="2.8618055555555557in"}

2.  We can go back to DATA ANALYSIS tool in another tab to confirm this
    insight. Go back to the data analysis and analyze by Genre and
    filter for Marital status=M and S alternately.

>> Drag Genre on X-Axis (you will have to expand the tree on the left)
>> and Marital Status on Filters. Pick M in the filter box.

![](media/image84.png){width="6.466311242344707in" height="3.1375in"}

3.  Married people are watching **Drama** a lot and not much
    **Adventure** and **Comedy**.

![](media/image85.png){width="6.5in" height="3.123611111111111in"}

4.  Now let's compare it by changing the filter to S (singles).

>> This is what you get. Notice high purchases in **Adventure** and
>> **Comedy** genre by singles and not much **Drama** (compared to
>> married people).

![](media/image86.png){width="6.5in" height="3.1066174540682416in"}

**Isn't that what our insight told us!!**
