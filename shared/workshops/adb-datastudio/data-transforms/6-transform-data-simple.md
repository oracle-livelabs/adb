# Transform and prepare data for analysis. Simple introduction.


## Introduction

This lab introduces you to creating data flows in Data Transforms to transform data and load it to a target.

Estimated Time: 35 minutes

### Objectives

In this workshop, you will learn how to:
- Create a data flow to transform data and load it to a target
- Execute and debug data flows

### Prerequisites

To complete this lab, you need to have completed the previous labs, so that you have:

- Created an Autonomous AI Lakehouse instance
- Created the users DT\_DEMO\_SOURCE and DT\_DEMO\_DW with appropriate roles
- Imported the demo data
- Started Data Transforms and performed the following:
    - Created SOURCE and DATAWAREHOUSE connections
    - Imported the entity definitions
    - Created a project called MY\_WORKSHOP

## Task 1: Create a simple data flow

In this task we will get familiar with the data flow UI and will be able to create a simple data flow to understand the concept. 

To begin with, we will use source and target tables in the same database schema. This way, the entire data transformation process takes place in the same database schema and there will be no external data movement. In a later part of this lab, we will create more complex data flows involving data movement between different databases, and transforming the data in the same flow.

1. Navigate to your project MY\_WORKSHOP and select **Data Flow** from the left side. After that click on the **Create Data Flow** button.

    - Name: Load\_customer\_value

    Click **Create**

    ![Screenshot of creating a data flow](images/image_dt_datatransforms01_create_df.png)

2. The first time you create a data flow in a project, it will ask you to add a schema from your connections that will be used to get source or target tables. Data Transforms keeps a list of connections used in a project and for subsequent data flow creation. It will automatically add these schemas on the left side of the UI. At any time more schemas can be added to the data flow as needed.

    In our use case, this is our first data flow and we will add the DT_DEMO_DW schema from our DATAWAREHOUSE connection. Click **OK**.

    ![Screenshot of adding a schema to a data flow](images/image_dt_datatransforms02_create_df_add_schema.png)

3. Now let's take a look at the different sections of the data flow UI. Refer to the numbered sections in the screenshot below.

    1- Data Entities: You will see all the entity definitions available to you, to be used as either sources or targets in the data flow. You can add more schemas and filter entities to quickly find what you are looking for. In the previous labs we imported entity definitions and these are what we are seeing on the left side. If you need to reimport the definitions, for example because more tables were added to the databases, or because their definitions changed, you can import the data entities at any time by right clicking on the schema name.

    2- Save, Execute, Validate, Code Simulation, Auto Layout, Zoom in and Zoom Out options.

    3- Data transformation tools organized in different sections.

    4- Main canvas to build the data flow by dragging entities and transformation tools and linking them in a flow.

    5- Object properties. You can click on any step in the flow to define its properties. You can expand and collapse the property section by clicking on the top right button.

    6- Execution status of the data flow.

    ![Screenshot of the areas of the data flow UI](images/image_dt_datatransforms03_create_df_areas.png)

4. Now we are ready to build our first data flow.

    The specification of our simple data flow is as follows:
    - Name: Load\_customer\_value
    - Source table (Columns used): MOVIESALES\_CA (CUST\_ID, TOTAL\_SALES)
    - Target table (Columns used): CUSTOMER\_VALUE (CUST\_ID, CUST\_VALUE)
    - Transformation specification: We want to categorize our customer data into five buckets of importance (Customer Value) to our fictitious movie business. Customers who have given us more business are in the highest bucket. The column CUST\_VALUE in the target table CUSTOMER\_VALUE contains values 1 to 5 depending on the value categorization. In order to categorize, we will first aggregate the sales data by customer and then use the Quantile Binning transform to create five buckets.

    We will create the entire flow step by step using a simple drag and drop interface.

5. Drag the MOVIESALES\_CA table and the **Aggregate** tool onto the canvas.

    The MOVIESALES\_CA table contains transactions of users watching individual movies. It has information on how much a user paid to watch a particular movie for each viewing.

6. Now click on MOVIESALES\_CA and use the little arrow on the right side to drag it to the Aggregate step to link both the steps.

    ![Screenshot of the first two steps of the data flow](images/image_dt_datatransforms05_firsttwo_link.png)

7. Click on the **Aggregate** step and expand the properties section. Look at the top right button in the following screenshot.

    ![Screenshot of the properties of the aggregate step](images/image_dt_datatransforms06_agg_prop.png)

8. In the **Attributes** section, click on all the attributes except CUST\_ID and TOTAL\_SALES. 

    ![Screenshot of the attributes section of the aggregate step's properties](images/image_dt_datatransforms07_agg_prop_att.png)

9. Click on the trash icon on the top right to delete the unwanted attributes. Now you have only two attributes that we care about.

10. Click on **Column Mapping** and fill in the attribute's expression as follows. You can drag the columns from the tree view to the expression and edit as needed. There is also full expression editor but we don't need it for such simple task.

    - CUST\_ID: MOVIESALES\_CA.CUST\_ID
    - CUST\_VALUE: SUM(MOVIESALES\_CA.TOTAL\_SALES)

    ![Screenshot of the column mappings for the aggregate step](images/image_dt_datatransforms09_agg_colmap.png)

    This completes our aggregate step. Note that Data Transforms automatically figures out the column used to group the transactions (CUST\_ID in our case).

11. Now collapse the aggregate property area and drag the **Quantile Binning** tool from the **DATA PREPARATION** section. Link the **Aggregate** and **Quantile Binning** steps.

    ![Screenshot of the quantile binning step](images/image_dt_datatransforms10_qb.png)

12. Click on **Quantile Binning** and expand its properties section. You can see that there is help text available explaining how to use the transform. 

    ![Screenshot of the properties of the quantile binning step](images/image_dt_datatransforms11_qb_prop.png)

13. Click on the **Column Mapping** on the left side and enter the following in the expression.

    - number of buckets: 5
    - \[partition\]: leave blank
    - order: Aggregate.TOTAL\_SALES (you can also drag it from the tree view on the left side)

    It means the incoming data will be divided into 5 buckets based on aggregate sales by customer.

    ![Screenshot of the column mappings for the quantile binning step](images/image_dt_datatransforms12_qb_map.png)

14. Collapse the properties section and drag the CUSTOMER_VALUE table from the left side entities section. Link it to the previous flow as follows. This is our target table.

    We are now done! You can see how simply we created a flow to populate a new table that defines the value of each customer. 

    ![Screenshot of the target table for the data flow](images/image_dt_datatransforms13_target.png)

15. However, we are not quite finished. We need to specify how we are going to populate the target. Let's review the target properties. Click on the CUSTOMER\_VALUE table and expand its properties section. Click on **Column Mapping** and you will see that the expression for CUST\_VALUE is empty. Expand the tree view on the left for QuantileBinning and drag **Return** into the expression for CUST\_VALUE.

    Note that for any step (including the final target step), attributes from the previous steps are available in the tree view for populating column mappings. You also have auto mapping functionality to map by name or by position. You can type in mapping texts in the expression, or use the expression editor, for more complex expressions.

    ![Screenshot of target column mappings](images/image_dt_datatransforms14_target_map.png)

16. Now click on the **Options** and review the loading options. On the top right you have loading modes of append or incremental. For our flow we are simply truncating the target and appending data for every execution.

    Make sure **Truncate target table** option is set to **True**

    ![Screenshot of the options for creation of the target table](images/image_dt_datatransforms15_target_option.png)

    Incremental mode is similar, but in this mode you would additionally need to specify the column or columns to be used as the primary key for merging data. Click on the **Attributes** section. Since this is a simple append load, no keys are defined.

    ![Screenshot of the attributes of the target table](images/image_dt_datatransforms16_attr.png)

    Now collapse the properties section.

17. Save the data flow by clicking the Save icon at the top. You will get a successful save message. In a complex data flow it is advisable to keep saving once in a while so that you don't lose any work. Unfinished data flows can also be saved.

    ![Screenshot of the save button](images/image_dt_datatransforms17_save.png)

18. Click the check mark at the top to validate the data flow. Since there are no errors, we get a success message. If you do not get a success message then you can go back and correct your data flow.

    ![Screenshot of the validate button](images/image_dt_datatransforms18_validate.png)

19. Now click the green arrow to execute the data flow. Click on **Start** for the dialog box and then **OK** for the notification dialog to start the job. Note that we are executing the data flow 'on demand'. Data Transforms also has a built-in scheduler that we will cover later.

    Notice the execution status on the bottom right side of the UI. The job should complete successfully. If there is any error then we will need to look at the job log and debug the data flow. For now, all is good.

    ![Screenshot of the status of data flow execution](images/image_dt_datatransforms19_exec_status.png)

20. Click the target table in the data flow and expand the properties section for a preview of the data. Click on the "Preview" icon to see/preview the data loaded in the table. You can see that each customer is now assigned a value attribute between 1 and 5 in our table.

    ![Screenshot showing a preview of the customer value table](images/image_dt_datatransforms20_exec_preview.png)

## Task 2: Advanced user: Code simulation and debugging

In this task we will examine more closely the data flow defined in the previous task, and look at the generated code.

1. Click the code simulation button at the top.

    ![Screenshot of the code simulation button](images/image_dt_datatransforms21_simul.png)

2. Look at the generated code. Data Transforms is an **Extract-Load-Transform (ELT)** data integration tool, so it pushes the entire execution of its data flows to the target database, leveraging database resources. It also uses set-based execution for high performance as opposed to row by row execution of the data flow.

    ![Screenshot of the generated data flow sql](images/image_dt_datatransforms22_simul_dtl.png)

3. Now close the simulation window and let's explore how to debug the job execution. You can click the execution job link in the status section to jump to jobs details.

    ![Screenshot of the link to jobs in the status section](images/image_dt_datatransforms23_job_link.png)

4. This provides details of the executed job. You can expand the execution steps and get more details on the following:

    - Start/End overall time
    - Start/End time of each step
    - Rows processed in each step
    - Success/failure messages
    - Code executed in each step in source or target connection

    ![Screenshot of job details](images/image_dt_datatransforms24_job_detail.png)

5. Close the jobs and go back to the Data Transforms home screen. You can access job details from the jobs menu as well. Click **Jobs** on the left side. You can filter the jobs you are interested in by partial name, status and the start date.

    ![Screenshot of the job menu](images/image_dt_datatransforms25_job_menu.png)

## RECAP

In this lab, we used Data Transforms to calculate customer value from sales data, and loaded the results into a target table. This was just a simple example but it introduced you to the basic concepts of creating a data flow.

In the next lab we will create a slightly more complex data flow.

You may now **proceed to the next lab**.

## Acknowledgements

- Created By/Date - Jayant Mahto, Product Manager, Autonomous AI Database, January 2023
- Contributors - Mike Matthews
- Last Updated By - Jayant Mahto, June 2024

Copyright (C)  Oracle Corporation.
