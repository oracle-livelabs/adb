
# Apply Machine Learning to Customer Demographics

## Introduction

Autonomous Data Warehouse contains built-in machine learning algorithms. The aim of this lab is to provide a simple introduction into using machine learning models to solve common business problems. There are many other workshops in LiveLabs that will help you explore machine learning in more detail: [see here](https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/livelabs-workshop-cards?c=y&p100_focus_area=27&p100_product=131).

Estimated Lab Time: 10 minutes

### Objectives

- Learn how to use the  `DBMS_DATA_MINING.CREATE_MODEL2` procedure

- Learn how to interpret the results that are automatically generated


## Overview

Autonomous Data Warehouse contains built-in machine learning algorithms. There is a separate workshop that can guide you through creating machine learning models to solve common business problems. In this short lab, the objective is to use one of these built-in algorithms to help us understand the demographic factors that can explain why a customer triggers an "insufficient funds" event against their account. If we can find a way to identify the key demographic attributes associated with this type of event, we can target customers to help them better manage their account and therefore have a better experience on MovieStream.

To do this analysis, we are going to use a package called **`DBMS_DATA_MINING`**. This package helps in creating, evaluating, and querying Oracle Machine Learning for SQL models. This makes it really easy for everyone to benefit from the power of machine learning-driven analytics.


## Task 1: Preparing Our customer Data Set

1. The firsts step is to create a view which summarizes the main customer demographic attributes. This means removing the time attributes, transaction attributes and movie attributes from our movie sales data.  Copy and paste the following code into the SQL worksheet window:

    ```
    <copy>CREATE OR REPLACE VIEW vw_cust_funds AS
    SELECT DISTINCT
    customer_id,
    segment_name,
    credit_balance,
    education,
    full_time,
    gender,
    household_size,
    insuff_funds_incidents,
    job_type,
    late_mort_rent_pmts,
    marital_status,
    mortgage_amt,
    num_cars,
    num_mortgages,
    pet,
    rent_own,
    years_current_employer_band,
    years_customer,
    years_residence_band,
    commute_distance,
    commute_distance_band
    FROM movie_sales_fact;</copy>
    ```

2. You should get a message in the log window saying "View VW\_CUST\_FUNDS created". Check the number of rows returned by the above query/view, by running the following query, which should show that there are 4,845 unique customers:

    ```
    <copy>SELECT COUNT(*) FROM vw_cust_funds;</copy>
    ```

    You should see that there are 4,845 unique customer rows:

    ![Query result showing 4,845 unique customer rows](images/3038282315.png)

3. What does the data set in our table actually look like? Let's run another simple query:

    ```
    <copy>SELECT *
    FROM vw_cust_funds
    ORDER BY 1;</copy>
    ```

4. This will return something like the following output:

    ![Query result showing what the table data set looks like](images/analytics-lab-6-step-1-substep-4.png)

    **NOTE:** Unlike the movie sales data, we now have a single row per customer and you can see that in the column **insufficient\_funds\_incidents** there are single numeric values determining the status of this column.

5. Run the following query to show that the column contains only four values:

    ```
    <copy>SELECT
    DISTINCT insuff_funds_incidents
    FROM vw_cust_funds
    order by 1;</copy>
    ```

    ![Query result showing the column contains only four values](images/3038282313.png)

    Obviously we are interested in all the values in this column, not just the non-zero values. From a machine learning perspective, it is important for this type of analysis to have situations where an event did occur, as well as situations where an event does not occur - we need data to cover both sides of the story. Now that we know we have the right data set in place, we can proceed to building our model.

## Task 2: Building The Model

### Overview

In this case, we will use the **CREATE\_MODEL2** procedure to help us understand which demographic attributes can explain the likelihood of a customer incurring an insufficient funds event. The CREATE\_MODEL2 procedure uses an Attribute importance that computes a Minimum Description Length algorithm to determine the relative importance of attributes in predicting the column to be explained.

To run this analysis we need to provide the following information:

- `DBMS_DATA_MINING.SETTING_LIST`: defines model settings or hyperparameters for your model
- `v_setlst`: variable to store the setting list
- `ALGO_NAME`:  specifies the algorithm name. In this case, it is `ALGO_AI_MDL` indicating Minimum Description Legth.

Then, the `CREATE_MODEL2` procedure takes the following parameters:

- `MODEL_NAME`:  A unique model name that you will give to the model. The name of the model is in the form [schema\_name.]model\_name. If you do not specify a schema, then your own schema is used. Here, the model name is `AI_EXPLAIN_OUTPUT`. 

- `MINING_FUNCTION`:  Specifies the machine learning function. Since it is a feature selection problem in this case, select `ATTRIBUTE_IMPORTANCE`.  

- `DATA_QUERY`: A query that provides training data for building the model. Here, the query is `select * from vw_cust_funds`. This is the name of the input table - our customer demographic view.

- `SET_LIST`: Specifies `SETTING_LIST`.

- `TARGET_COLUMN_NAME`:  For a supervised model, the target column in the build data. In this case, it is the column for insufficient funds events. 

These settings are described in [`DBMS_DATA_MINING.CREATE_MODEL2 Procedure`](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/DBMS_DATA_MINING.html#GUID-560517E9-646A-4C20-8814-63FDA763BFD9).


**NOTE:**  The input table contains the column `CUSTOMER_ID` to make the data easier to validate once we get a final result. However, under normal circumstances this column would not be included as an input to the machine learning model, since every row is unique. Fortunately, the machine learning features in Autonomous Data Warehouse are smart enough to automatically ignore these types of columns and focus on the other more "interesting" columns.

1. Now that we understand the required inputs, let's run the model:

    ```
    <copy>DECLARE
  v_setlst DBMS_DATA_MINING.SETTING_LIST;
BEGIN
  v_setlst('ALGO_NAME') := 'ALGO_AI_MDL';
 
  DBMS_DATA_MINING.CREATE_MODEL2
(MODEL_NAME        => 'AI_EXPLAIN_OUTPUT',
   MINING_FUNCTION    => 'ATTRIBUTE_IMPORTANCE',
   DATA_QUERY         => 'select * from vw_cust_funds',
   SET_LIST           => v_setlst,
   TARGET_COLUMN_NAME => 'insuff_funds_incidents');
END;</copy>
    ```

2. The package will return a "PL/SQL procedure successfully completed" message to the log window once it has finished processing - which should take around 20 seconds.

    ![Query results showing procedure completed successfully](images/3038282312.png)

## Task 3: Reviewing The Output

1. To view the results from our model, we simply need to query the model detail view `DM$VA`:

    ```
    <copy>SELECT ATTRIBUTE_NAME, ATTRIBUTE_IMPORTANCE_VALUE, ATTRIBUTE_RANK FROM
DM$VAAI_OUTPUT;</copy>
    ```
Learn more about [model detail views](https://docs.oracle.com/en/database/oracle/machine-learning/oml4sql/23/dmprg/model-detail-views.html#GUID-58E2B8C6-0329-43B2-9CDE-7F3B34E6B304).

2. This should return the following results:

    ![Query results from the model](images/output_of_attribute_importance.png)

What do the above columns mean?

### ATTRIBUTE\_IMPORTANCE\_VALUE

This column contains a value that indicates how useful the column is for determining the value of the target column (insufficient funds). Higher values indicate greater atrribute importance value. Value can range from 0 to 1.

An individual column's attribute importance value is independent of other columns in the input table. The values are based on how strong each individual column correlates with the target column. The value is affected by the number of records in the input table, and the relations of the values of the column to the values of the target column.

An attribute importance value of 0 implies there is no useful correlation between the column's values and the target column's values. An attribute importance value of 1 implies perfect correlation; such columns should be eliminated from consideration for prediction. In practice, an attribute importance equal to 1 is rarely returned.

### ATTRIBUTE\_RANK

Simply shows the ranking of attribute importance value. Rows with equal values for attribute\_importance\_value have the same rank. Rank values are not skipped in the event of ties.

## Task 4: Interpreting The Results

What do the results tell us? The above results tell us that to understand why an insufficient funds event occurs, we need to examine the occurrence of late mortgage payments by a customer, their segment name and the mortgage amount. Note that the analysis doesn't focus on specific attribute values. The analysis shows that we could predict the likelihood of an insufficient funds event based on the top three attributes identified by the CREATE\_MODEL2 procedure.

Conversely, we can say that demographic attributes such as job\_type, marital\_status and education have no impact on whether a customer is likely to incur an insufficient funds event.

## Recap

This lab has introduced you to the built-in capabilities of machine learning within Autonomous Data Warehouse. There are additional workshops in this series that will take you deeper into these unique capabilities. 

Within this lab we have examined:

- How to use the `DBMS_DATA_MINING.CREATE_MODEL2` procedure and how to interpret the results that are automatically generated.
- How this feature helps us understand the demographic factors that can explain why a customer might trigger an "insufficient funds" event.

Now that we identified these key demographic attributes, we can do more analysis using SQL to go deeper. This type of analysis can allow us to identify and guide customers in better ways to manage their account and, therefore, have a better experience on our MovieStream platform.

## **Acknowledgements**

- **Author** - Keith Laker, ADB Product Management
- **Adapted for Cloud by** - Richard Green, Principal Developer, Database User Assistance
- **Last Updated By/Date** - Sarika Surampudi, April 2023
