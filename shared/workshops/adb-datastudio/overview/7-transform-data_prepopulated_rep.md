# Transform your data for analysis


## Introduction

This lab introduces the Data Transforms application built into the Oracle Autonomous AI Database and shows the various ways you can prepare data for analysis.

Estimated Time: 15 minutes

<!--
Watch the video below for a quick walk-through of the lab.
[Create a database user](videohub:1_t22mdnao)
-->

### Objectives

In this workshop, you will learn:
-	How to transform and prepare your data for analysis

### Prerequisites

To complete this lab, you need to have completed the previous labs, so that you have:

- Created an Autonomous AI Database instance
- Created a new QTEAM user with appropriate roles
- Loaded the demo data 
- Loaded Age group data into AGE\_GROUP 
- Optional: Downloaded the wallet file to connect to your Autonomous AI Database. This is an optional step for the last section.

### Demo data for this lab
>**NOTE:** Skip this section if you have demo data loaded and have completed previous labs.

If you have not completed the previous labs then run the following script in SQL Worksheet to load all necessary objects.

*For copy/pasting, be sure to click the convenient __Copy__ button in the upper right corner of the following code snippet.*: 

```
<copy>
DROP TABLE CUSTOMER_CA;
 
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

DROP TABLE MOVIESALES_CA;
 
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

DROP TABLE GENRE;

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

DROP TABLE MOVIE;

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

DROP TABLE TIME;

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

DROP TABLE AGE_GROUP;

CREATE TABLE AGE_GROUP 
    ( 
     MIN_AGE   NUMBER , 
     MAX_AGE   NUMBER , 
     AGE_GROUP VARCHAR2 (4000) 
    ) 
;

DROP TABLE CUSTOMER_SALES_ANALYSIS;

CREATE TABLE CUSTOMER_SALES_ANALYSIS
(
  MIN_AGE NUMBER(38),
GENRE VARCHAR2(30 CHAR),
AGE_GROUP VARCHAR2(4000 CHAR),
GENDER VARCHAR2(20 CHAR),
APP VARCHAR2(100 CHAR),
DEVICE VARCHAR2(100 CHAR),
OS VARCHAR2(100 CHAR),
PAYMENT_METHOD VARCHAR2(100 CHAR),
LIST_PRICE NUMBER(38),
DISCOUNT_TYPE VARCHAR2(100 CHAR),
DISCOUNT_PERCENT NUMBER(38),
TOTAL_SALES NUMBER(38),
MAX_AGE NUMBER(38),
AGE NUMBER(38),
EDUCATION VARCHAR2(40 CHAR),
INCOME_LEVEL VARCHAR2(20 CHAR),
MARITAL_STATUS VARCHAR2(8 CHAR),
PET VARCHAR2(40 CHAR),
CUST_VALUE NUMBER,
CUST_SALES NUMBER(38)
);

set define on
define file_uri_base = 'https://objectstorage.us-ashburn-1.oraclecloud.com/p/zL6bsboZrSxJP-0ilfUpROTwwyhzvkUrZu9OEwcU5_B_NAGzHKBG_WqW2OnNYxKk/n/c4u04/b/datastudio/o/prepareandanalyze'

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
 FOR TNAME IN (SELECT table_name FROM user_tables  where table_name like 'COPY$%') LOOP
 EXECUTE IMMEDIATE ('DROP TABLE ' || TNAME.table_name || ' CASCADE CONSTRAINTS PURGE');
 END LOOP;
end;
/
DROP TABLE CUSTOMER_SALES_ANALYSIS_FULL;
CREATE TABLE CUSTOMER_SALES_ANALYSIS_FULL
as SELECT 
GENRE,
GENDER,
AGE_GROUP,
CUST_VALUE,
PET,
MARITAL_STATUS,
EDUCATION,
INCOME_LEVEL,
TOTAL_SALES
FROM CUSTOMER_SALES_ANALYSIS
WHERE 1=2;
</copy>
```

Paste the SQL statements in the worksheet. Click on the **Run Script** icon.

While the script is running, you will see the message "Executing code" at the bottom of the window. 
The message will change to "SQL executed by QTEAM" when in finishes. There should not be any errors.

>**Note:** Expect to receive "ORA-00942 table or view does not exist" errors during the DROP TABLE command for the first execution of the script, but you should not see any other errors.

![Alt text](images/image_sql_worksheet.png)

Now you are ready to go through the rest of the labs in this workshop.

## Task 1: Launch Data Transforms

1.  Click on the **Data Transforms** card in the overview page.

    >**NOTE:** If you don't see the **Data Transforms** card then it means you are
    missing the **DATA\_TRANSFORM\_USER** role for your user. Login as ADMIN and
    grant the role (make sure this role is marked "Default" as well).

    ![screenshot of the data transform link](images/image_dt_001_transforms_overview.png)

2.  You can also start it from the Database Actions page under Data Studio.

    ![screenshot of data transform link in DB Action](images/image_dt_002_transforms.png)

3. If you are using Data Transforms for the first time or the Transforms service has logged you out then you will get the following login screen. Enter your database user and password.

    ![screenshot of data transform login](images/image_dt_003_transforms_login.png)

4.  You will see a provisioning screen like below.

    ![screenshot of data transform service start](images/image15_transform_start.png)

5.  It will take up to 2-3 minutes for the service to be started for the first time. Once
    provisioned you will see the following Home page.

    >**Note:** The Data Transforms tool is provisioned based on demand. After 10 minutes of 
    inactivity, it will go into sleep mode and needs to
    be started again. The maximum timeout can be configured in the tools configuration menu from the Autonomous AI Database OCI console. Subsequent start time will be much smaller than the first time.  Clicking on any part of the UI will start the service again if it has gone into sleep mode. If you get any error, then refresh your browser.

    Look at the Home page. You can load data from various databases and applications using **Load Data**, and transform data to any desired shape using **Transform Data**. You can also move your data integration project from one environment to another using **Export** and **Import**. In our next section we will show you the available data sources and use the **Import** wizard to get a pre-populated data flow.

    ![screenshot of Data Transforms home page](images/image16_transform_home.png)

## Task 2: Import Data Transforms data flow

For this lab, we will try to create a table suitable for analysis by joining a table of movie sales transactions with the customer table, and aggregate the sales amount for each customer. This is achieved by creating a data flow with various transformations, such as, Join, Aggregate, Data Cleanse etc.

Since this is an overview workshop, instead of creating a new data flow, we will import a pre-created data flow and review the steps. 

1.  First, we will create a connection to cloud object storage, from where we will import the pre-created data flow. Click on **Connections** on the left side.

    ![screenshot of the connection menu](images/image17_transform_conn.png)

2.  There maybe other connections already defined. We will create a new one. Click on **Create Connection**.

    ![screenshot of creating connection](images/image_dt_003_create_connection.png)

3.  You will see various data sources supported by Data Transforms. Browse the Database and Applications tabs to review the list of data sources. All these connectors are provided out of the box in Data Studio and very simple to use. All we need to do is to provide login credentials to the data source and create a connection.

    In this workshop we are going to connect to cloud object storage to import the pre-populated data flow. Go back to the Database section and click on **Oracle Object Storage** icon. Then click **Next**.

    ![screenshot of creating a connection to object storage](images/image_dt_003_1_create_connection_ObjectStore.png)

4. Configure connection details as follows:

    Connection Name: DT\_demo\_rep\_bucket

    Object Storage URL: 
    ```
    <copy>
    https://adwc4pm.objectstorage.us-phoenix-1.oci.customer-oci.com/n/adwc4pm/b/DataTransforms_demo_rep/o
    ```

    User Name: 
    ```
    <copy>    
    123
    ```

    Token: 
    ```
    <copy>
    123
    ```

    Click on **Create**

    ![screenshot of connection configuration](images/image_dt_004_create_connection_config.png)

5. Open the DT\_demo\_rep\_bucket connection again for editing and this time configure as follows:

    User Name: `<blank>`

    Token: 
    ```
    <copy>
    123
    ```

    Click on **Update**

    This will update the connection without user or token information. Since in this case the object storage bucket is public, we will be able to connect successfully.

6. From Home page click on **Import**.

    ![screenshot of import](images/image_dt_005_create_import.png)

7. Configure the import task as follows:

    Object Store Location: DT\_demo\_rep\_bucket

    Import File Name: 
    ```
    <copy>
    Export_SalesDW_20250827000738_DTR.zip
    ```
    
    Click on **Import**

    ![screenshot of import configuration](images/image_dt_006_create_import_config.png)

    Click **OK** on the next dialog.

8. An import job is submitted. Click **OK** to acknowledge. It will take 1-2 minutes for the import to finish. 

    We are now ready to learn how Data Transforms helps in transforming the data to any desired shape.

    ![screenshot of import configuration OK Job](images/image_dt_008_create_import_config_OK_job.png)

## Task 3: Review data flow

As mentioned earlier, we are taking a shortcut by reviewing the pre-created data flow to learn how it works. Let's get started.

1. Click on Projects on the left side and select **SalesDW** project. This project has been imported in the previous section.

    ![screenshot of Projects](images/image_dt_009_Projects.png)

2. A project consists of various objects, such as:

    **Data Load**: Configuration to load data from various databases and applications
    
    **Data Flows**: Flows to transform data
    
    **Workflows**: Orchestration of data pipelines with integration steps
    
    **Variables**: Parameterize data flow and control workflow steps
    
    **Scheduler**: Schedule data integration jobs

    **Jobs**: Monitoring jobs for success/failure and debugging

    We have a detailed Data Transforms workshop in Oracle Livelabs if you want in-depth knowledge of these features. For now, let's look at the imported data flow.

    Click on the data flow **Load\_Sales\_Analysis** under **Data Flow**.

    ![screenshot of Projects](images/image_dt_010_Projects.png)

3. This is the user interface for defining and editing data flows. The sections are as follows:

    1. Main panel for defining the data flow

    2. Available data entities from databases or applications 

    3. Transforms tools. These are categorized under various sections. Click on these to learn about what transformations are possible.

    4. Property page. This page can be expanded or collapsed by clicking on the top right marker. 

    5. Action bar for saving, validating, execution etc.

    6. Execution status (success/fail) and link to jobs menu for debugging.

    ![screenshot of dataflow UI](images/image_dt_011_dataflow_UI.png)

4. Now let's review the data flow. 

    MOVIESALES\_CA is the transaction table which is aggregated (Aggregate\_sales step) and then joined with CUSTOMER\_CA table, which is our main customer table. Then the flow moves through the data cleaning step (DataCleanse step) which trims white spaces for a few columns, and converts them into title case. Finally the data is loaded into the final target table CUSTOMER\_SALES.

    Click on any object in the data flow to review the properties. For example click on the join step to review the join condition. You may need to expand or collapse the property window by clicking on the top right marker to view it fully.

    Imagine creating your own data flow step by step with this drag and drop UI. It is easy to visualize any complex transformations by breaking them down into individual steps in the flow.

    ![screenshot of dataflow UI properties](images/image_dt_012_dataflow_UI_properties.png)

5. Now let's look at the target table properties. Click on the CUSTOMER\_SALES target table and click on the **Options** icon (looks like a cube in the property window). Expand the property window to see full details.

    ![screenshot of dataflow target properties](images/image_dt_013_dataflow_target_properties.png)

6. Look at the loading **Mode** which is **Append**. If needed you can load data incrementally as well, but then you will need to define the key columns for updates. We will not change the mode.

    Make sure the options look like as below. **Drop and create target table** should be **Yes**, since we want this data flow to create a fresh table every time for our execution. For periodic execution this may be set to **No**. Collapse the property window by clicking on the top right marker.

    ![screenshot of dataflow target properties collapse](images/image_dt_014_dataflow_target_properties_collapse.png)

7. We have completed our review of the data flow. In a real project, there will commonly be many data flows defined (for example, one for each target table). Multiple data flows can be combined into a single workflow so that all flows can be executed at once.

    The next two tasks (tasks 4 and 5) are optional. In these tasks, you can see how a more complex data flow can be defined, and you will be introduced to workflows and scheduling. 
    
    In the last task (task 6) we will execute this data flow.

## Task 4: (Optional) More complex data flow

Let's look at a more complex data flow. Go to your project again and open the data flow **Load\_Sales\_Analysis\_w\_cust\_value**. This data flow computes customer value and combines this information with customer demographics and movie genre data before loading into a new table **CUSTOMER\_SALES\_ANALYSIS\_FULL**.

To understand this better, different sections of the flow are highlighted in the screenshot below.

- Section 1: **Compute customer value**: This computes customer value by using a statistical tool called quantile_binning. This tool can be found under the **DATA PREPARATION** group. In our data flow, the tool is named as Find\_CustValue. It distributes all the customers into 5 equal buckets after ordering the customers based on their value. In this case, customer value is determined by the total movie sales amount by each customer (in the aggregator transform Agg\_sales\_per\_cust preceding Find\_CustValue). This is a statistical function and is a good example of Data Transforms leveraging database functions. There are many more advanced transformations available to be used in the data flow, including AI/ML and spatial transforms.

- Section 2: **Collect customer demographics**: Customer data is enhanced by looking up an age groups reference table based on age.

- Section 3: **Get movie genre name**: Movie sales data is enhanced by joining with the movie genre table to get genre name based on genre id.

    All three streams of the data flow are combined together and the data is loaded into the target.
    
    ![screenshot of complex dataflow ](images/image_dt_014_dataflow_complex.png)

    You will notice that the visual UI allows you to think about building the data flow step by step to prepare the data according to your requirements. This table will be used by the analysis lab later in the workshop.

## Task 5: (Optional) workflow and scheduler

The data flow created so far could be executed on its own to load the target table, but often a workflow is created so that all the executable steps can run as a single scheduled job with any needed dependencies between each step. 

Go to the project again and click on the **Nightly_run** workflow. 

![screenshot of workflow ](images/image_dt_014_workflow.png)

Let's review the different steps. You can see that both the data flows are executed in a sequential manner. The steps can be executed after the success or failure of previous step. A workflow step can be any executable object including SQL/PLSQL steps. In our demo repository the SQL steps have a dummy select value but it can be a complex PLSQL script.

We are just scratching the surface of possibilities in this overview workshop. If you are interested then we have Data Transforms specific workshop you can go through. 

![screenshot of workflow details](images/image_dt_014_workflow_details.png)

## Task 6: (Optional) Execute the dataflow

If you are interested in actually executing a data transforms job then follow these steps. For the remaining labs, demo data will be loaded afresh so this is an optional task.

1. Go to the Home page and click on the **Sales\_Datawarehouse** connection in the **Connections** menu. You need to upload the wallet from your database and provide user and password as shown below. Click on **Update** after the connection test succeeds.

    ![screenshot of dataflow DW connection](images/image_dt_015_dataflow_DW_Connection.png)

2. Go back to the data flow under the **SalesDW** project and click on execute by clicking on the green triangle in the actions section on the top.

    **NOTE**: If you had moved the layout or changed any properties, then you will need to save the data flow before you can execute it.

    ![screenshot of dataflow execution](images/image_dt_016_dataflow_execution.png)

3. The job is submitted in the background. Acknowledge the dialog.

    ![screenshot of dataflow execution OK](images/image_dt_017_dataflow_execution_OK.png)

    Click anywhere in the main panel and look at the status of the job. It should take 1-2 minutes to finish.

    ![screenshot of dataflow execution success](images/image_dt_018_dataflow_execution_success.png)

4. Data Transforms allows you to browse the data for source and target tables. Click on the target table in the flow and the eye icon in the property window to preview the data. Expand the property window for a larger view.

    ![screenshot of dataflow data preview](images/image_dt_019_dataflow_data_preview.png)

5. You can see the aggregated sales amount for each customer ID. We also have customer attributes like income level, marital status etc. from the customer table. Now this target table has all the data we need for analysis.

    ![screenshot of dataflow data preview details](images/image_dt_020_dataflow_data_preview_detail.png)

6. Note that there is a built-in scheduler as well for running any job (data flow or workflow) in a periodic basis. The jobs can be monitored by the jobs menu.

    ![screenshot of scheduler](images/image_dt_020_scheduler.png)

## Task 7: What's more?

This lab provided an introduction to Data Transforms. There are many other features available, including:

-   **Variety of data sources**: Databases, Object Storage, REST API and Fusion
    Applications

-   **Load Data**: Load multiple tables in a schema from another data
    source. Data Transforms can also integrate with Oracle Golden Gate Cloud Service for advanced
    replication. This complements the Data Load tool explored in the earlier
    lab.

-   **Workflow**: Combine several data flows to run sequentially or in parallel.

-   **Variables**: Parameterize data flow and control workflow steps.

-   **Schedule**: In-built scheduler for periodic execution.

-   **Export/Import**: Save snapshot of objects and move them from one environment to other (for example from development to production)

-   **Python API**: Create objects using scripting

Data Transforms is a comprehensive data integration tool, suitable for all projects and organizations. To explore more of its functionality, see the dedicated workshop in Oracle Livelabs: https://livelabs.oracle.com/pls/apex/f?p=133:180:10208447067911::::wid:832 

## RECAP

In this lab, we used the Data Transforms tool to aggregate sales data, combine it
with the customer attributes and clean up the data to load into a target table to be 
used for data analysis. 

You may now **proceed to the next lab**.

## Acknowledgements

- Created By/Date - Jayant Mahto, Product Manager, Autonomous AI Database, January 2023
- Contributors - Mike Matthews, Bud Endress, Ashish Jain,
- Last Updated By - Jayant Mahto, September 2025


Copyright (C)  Oracle Corporation.
