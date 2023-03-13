# Import data entity definition


## Introduction

This lab guides you to import the data entity definitions from various connections. These will be used as source or target 
in data flow and data load processes.

Estimated Time: ?? minutes

### Objectives

In this workshop, you will learn:
-   How to create a connection
-	How to import your data entity definition

### Prerequisites

To complete this lab, you need to have completed the previous labs, so that you have:

- Created an Autonomous Data Warehouse instance
- Created a new QTEAM user with appropriate roles
- Loaded the demo data
- Loaded Age group data into AGE\_GROUP

### Demo data for this lab
>**NOTE:** Skip this section if you have demo data loaded and completed previous labs.

If you have not completed the previous labs then run the following script in SQL Worksheet to load all necessary objects.

*For copy/pasting, be sure to click the convenient __Copy__ button in the upper right corner of the following code snippet.*: 

```
<copy>
</copy>
```

Paste the SQL statements in the worksheet. Click on the **Run Script** icon.

>**Note:** Expect to receive "ORA-00942 table or view does not exist" errors during the DROP TABLE command for the first execution of the script, but you should not see any other errors.

![Alt text](images/image_sql_worksheet.png)

Now you are ready to go through the rest of the labs in this workshop.

## Task 1: Launch Data Transforms



## RECAP

In this lab, we used the Data Transforms tool to calculate customer value from sales data, and combine it
with the customer, age group and movie genre information to load into a target table to be 
used for data analysis. 

Note that we scratched only the surface. Other features are:

-   **Variety of data sources**: Databases, Object Store, REST API and Fusion
    Application

-   **Load Data:** Load multiple tables in a schema from another data
    source. It can also integrate with Oracle Golden Gate Cloud Service for advanced
    replication. This complements the Data Load tool explored in the earlier
    lab.

-   **Workflow:** Combine several data flows to run sequentially or in parallel.

-   **Schedule:** In-built scheduler for periodic execution.

You may now **proceed to the next lab**.

## Acknowledgements

- Created By/Date - Jayant Mahto, Product Manager, Autonomous Database, January 2023
- Contributors - Mike Matthews, Bud Endress, Ashish Jain, Marty Gubar, Rick Green
- Last Updated By - Jayant Mahto, January 2023


Copyright (C)  Oracle Corporation.
