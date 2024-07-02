# Extract multiple tables from from any source and load to your target without any transformations


## Introduction

This lab introduces you to the data load process from a source to target without any transformations. Data load job is defined for multiple tables in a schema and both full and incremental modes are supported.

Estimated Time: 25 minutes

### Objectives

In this workshop, you will learn how to:
- Extract data from multiple tables in a source and load them to corresponding tables in the target without any transformation.
- Use various extract and load options.

### Prerequisites

To complete this lab, you need to have completed the previous labs, so that you have:

- Created an Autonomous Data Warehouse instance
- Created users DT\_DEMO\_SOURCE and DT\_DEMO\_DW with appropriate roles
- Imported the demo data
- Started Data Transforms tool and performed the following:
    - Created SOURCE and DATAWAREHOUSE connections
    - Imported the entity definitions
    - Created a project called MY\_WORKSHOP


## Task 1: Create data load process

In this task we will create a data load job to extract MOVIESALES\_CA, MOVIE and TIME tables from source DB and load into our data warehouse target DB. MOVIE and TIME tables are small and will loaded in full by truncating the target. However, MOVIESALES\_CA data can be big since it contains transactional data. We will extract incremental data from this table and merge into the target.

1. Navigate to your project and click on **Create Data Load**.

    ![Screenshot of DT data load](images/image_dt_dataload.png)

    Enter data load name as DataLoad\_SOURCE\_TO\_DW.

    ![Screenshot of DT data load name](images/image_dt_dataload_name.png)

    Note that there is an option to use GoldenGate tool. This is an advanced option and allows real time data load using integration with GoldenGate. In this workshop we will be doing bulk data load scheduled at regular interval and it will be sufficient for many applications when real time data load is not needed. 

    Leave GoldenGate option unchecked and click **Next**.

    Enter the following information for your source and click **Next**.
    - Connect Type: Oracle
    - Connection: SOURCE\_DATA
    - Schema: DT\_DEMO\_SOURCE

    ![Screenshot of DT data load source](images/image_dt_dataload_source.png)

    Enter the following information for your target and click **Save**.
    - Connect Type: Oracle
    - Connection: DATAWAREHOUSE
    - Schema: DT\_DEMO\_DW

    Note that in our workshop we are using the same Autonomous database for source and target connections to keep the setup simple. However source and target connections can be heterogenous and different. For example, source can be SQL Server DB and target can be Autonomous database.

    ![Screenshot of DT data load target](images/image_dt_dataload_target.png)

2. Now we need to select tables and load options.

    Look at the screenshot below and set the appropriate options:

    Select tables MOVIE, MOVIESALES\_CA, TIME with options as below:

    - MOVIE: Target Action: Truncate
    - MOVIESALES\_CA: Target Action: Incremental Merge, Incremental Column: DAY\_ID, Merge Key: DAY\_ID, CUST\_ID, MOVIE\_ID
    - TIME:  Target Action: Truncate

    Note that whenever you want to incrementally load the data, you need to specify a date column in the source table which will be used to filter incremental rows and also you need to specify the keys which will be used to merge the records in the target. For full load option you can simply use non incremental target actions as in MOVIE and TIME tables. These tables are small and loading them in full every time is acceptable.

    ![Screenshot of DT data load def](images/image_dt_dataload_definition.png)

3. Click on the floppy icon on the top to save the data load job definition.

    ![Screenshot of DT data load save](images/image_dt_dataload_save.png)

4. Click on the green arrow to execute the data load job. 

    ![Screenshot of DT data load execute](images/image_dt_dataload_execute.png)

    You will see the run status on the bottom right part of your UI. It is going to take approximately 5 minutes to complete the job.

    ![Screenshot of DT data load execute status](images/image_dt_dataload_execute_status.png)

    The data load process is creating the corresponding tables in the target, scanning the source tables for incremental data (full for the first time) and performing the data movement process. It is also tracking the extracted rows for incremental load so that in the subsequent execution only the new or modified rows are loaded.

    Target tables are created with the same name as in source. There are advanced options to deal with potential issues with the tables names that may not be accepted in the target. You can optionally use name prefix or quotations to deal with such issues. In our lab we left them as default.

5. Look at the Data Load Status for job completion. If there is an error then you can click on the job definition and try to debug. For this lab you expect to see successful completion.

    ![Screenshot of DT data load done](images/image_dt_dataload_done.png)

## Task 2: View the loaded data

1. Navigate to the Home screen by clicking on top left link and click on **Data Entities**.

    ![Screenshot of DT home](images/image_data_transforms_home.png)

2. Filter for the connection DATAWAREHOUSE and you can see the tables MOVIE, MOVIESALES\_CA and TIME listed.

    ![Screenshot of DT data warehouse tables](images/image_datawarehouse_tables.png)

3. Select MOVIESALES\_CA table and from the right side menu, select the data preview to look at the data.

    ![Screenshot of DT movie sales data menu](images/image_moviesales_data_menu.png)

    Note that the number of rows in the this tables is the same as the number of rows observed in the source DB as observed in the previous lab.

    ![Screenshot of DT movie sales data in target](images/image_moviesales_data_target.png)

## RECAP

In this lab, we used the Data Transforms tool to extract multiple tables from a source DB and load them to the target in full and incremental modes. We executed this data load job as an ad-hoc process. In practice, these jobs are scheduled to run at regular frequency and subsequent runs extract and load only incremental rows wherever defined. Scheduler will be covered in the later labs in this workshop.

You may now **proceed to the next lab**.

## Acknowledgements

- Created By/Date - Jayant Mahto, Product Manager, Autonomous Database, January 2023
- Contributors - Mike Matthews
- Last Updated By - Jayant Mahto, June 2024

Copyright (C)  Oracle Corporation.
