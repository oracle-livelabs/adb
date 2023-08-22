<!--
    {
        "name":"Create Graph",
        "description":"Login to Graph Studio and create a moviestream graph for when running the tenancy the lab in your own tenancy."
    }
-->

# Create Graph

## Introduction

In this lab you will create a graph from the `MOVIE, CUSTOMER\_PROMOTIONS`, and `CUSTSALES\_PROMOTIONS` tables using Graph Studio and the CREATE PROPERTY GRAPH statement.

Estimated Time: 15 minutes.

### Objectives

Learn how to
- use Graph Studio and PGQL DDL (that is, CREATE PROPERTY GRAPH statement) to model and create a graph from existing tables or views.

### Prerequisites

- The following lab requires an Autonomous Database - Shared Infrastructure account.
- And that the Graph-enabled user exists. That is, a database user with the correct roles and privileges exists.

## Task 1: Access the Autonomous Database 

1. Click the **Navigation Menu** in the upper left, navigate to **Oracle Database**, and select **Autonomous Database**.

    ![Navigating to Autonomous Database.](images/navigation-menu.png " ") 

2. Select your **compartment**, and click on the **Display Name** for the **Autonomous Database**. 

    ![Selecting Autonomous Database in the Navigation Menu.](images/select-autonomous-database.png " ") 

## Task 2: Log into Graph Studio

Graph Studio is a feature of Autonomous Database. It is available as an option on the Database Actions Launchpad. You need a graph-enabled user to log into Graph Studio. In this workshop, the graph user has already been created for you.

1. In your **Autonomous Database Details page** page, click the **Database Actions**.

    ![Click the Database Actions button.](images/click-database-actions.png " ")    

2. On the Database Actions panel, click **Graph Studio**.

    ![Click Open Graph Studio.](images/graphstudiofixed.png " ")

3. Log in to Graph Studio. Use the credentials for the graph user.

The graph user credentials are: 

**Username:** 


     <copy>MOVIESTREAM</copy>


**password:**


     <copy>watchS0meMovies#</copy>


![Use the credentials for database user MOVIESTREAM.](images/graph-login.png " ")

## Task 3: Create Graph

1. Click the **Graph** icon to navigate to create your graph.  
    Then click **Create**.  
    ![Shows where the create button modeler is.](images/graph-create-button.png " ")  

2. Then select the `CUSTOMER_PROMOTIONS`, `CUSTSALES_PROMOTIONS` and `MOVIE` tables.

    Click to expand list of available items and then select the tables

    ![Shows how to select tables](./images/selected-tables.png " ")

3. Move them to the right, that is, click the first icon on the shuttle control.   

    ![Shows the selected tables.](./images/select-tables.png " ")

4.  Click **Next** to get a suggested model.  

    The suggested model has the `MOVIE` and `CUSTOMER_PROMOTIONS`, as a vertex table since there are foreign key constraints specified on `CUSTSALES_PROMOTIONS` that reference it.   

    And `CUSTSALES_PROMOTIONS` is a suggested edge table.

    ![Shows the vertex and edge table.](./images/create-graph-suggested-model.png " ")    


5.  Now let's change the default Edge label.   

    Click the `CUSTSALES_PROMOTIONS` edge table and rename the Edge Label from `CUSTSALES_PROMOTIONS` to **WATCHED**.  
    Then click outside the input box on confirm label and save the update.  

    ![Changed the label name of the edge to Transfers.](images/edit-edge-label.png " ")  

    This is **important** because we will use these edge labels in the next lab of this workshop when querying the graph.  

6. Click the **Source** tab to verify that the edge direction, and hence the generated CREATE PROPERTY GRAPH statement, is correct.

    ![Verifies that the direction of the edge is correct in the source.](images/generated-cpg-statement.png " ")  

<!---
  **An alternate approach:** In the earlier Step 5 you could have just updated the CREATE PROPERTY GRAPH statement and saved the updates. That is, you could have just replaced the existing statement with the following one which specifies that the SOURCE KEY is  `from_acct_id`  and the DESTINATION KEY is `to_acct_id`.  

    ```
    -- This is not required if you used swap edge in UI to fix the edge direction.
    -- This is only to illustrate an alternate approach.
    <copy>
    CREATE PROPERTY GRAPH bank_graph
        VERTEX TABLES (
            BANK_ACCOUNTS as ACCOUNTS
            KEY (ACCT_ID)
            LABEL ACCOUNTS
            PROPERTIES (ACCT_ID, NAME)
        )
        EDGE TABLES (
            BANK_TXNS
            KEY (FROM_ACCT_ID, TO_ACCT_ID, AMOUNT)
            SOURCE KEY (FROM_ACCT_ID) REFERENCES ACCOUNTS
            DESTINATION KEY (TO_ACCT_ID) REFERENCES ACCOUNTS
            LABEL TRANSFERS
            PROPERTIES (AMOUNT, DESCRIPTION)
        )
    </copy>
    ```

   ![ALT text is not available for this image](images/correct-ddl-save.png " " )  

   **Important:** Click the **Save** (floppy disk icon) to commit the changes.
--->

7. Click **Next** and then click **Create Graph** to move on to the next step in the flow.   

    Enter **`MOVIE_RECOMMENDATIONS`** as the graph name.  
    That graph name is used throughout the next lab.  
    Do not enter a different name because then the queries and code snippets in the next lab will fail.  

    Enter a model name (for example, `movie_recommendations_model`), and other optional information and then click Create.
  
    ![Shows the create graph window where you assign the graph a name.](./images/create-graph-dialog.png " ")

8. Graph Studio modeler will now save the metadata and start a job to create the graph.  
    The Jobs page shows the status of this job.

    ![Shows the job tab with the job status as successful](./images/jobs-create-graph.png " ")  

    You can then interactively query and visualize the graph in a notebook after it's loaded into memory.

   <!---
   ## Task 2: Load a graph into memory

   The MOVIE_RECOMMENDATIONS graph has been created for you from the tables CUSTOMER\_PROMOTIONS, CUSTSALES\_PROMOTIONS, and MOVIE (as explained earlier).  You will now load this graph from the database into the in-memory graph server.  

   1. Click the **Graphs** icon.

       ![Click the Graphs icon](images/task2step1.png " ")

       You will see that the MOVIE_RECOMMENDATIONS graph is available.

       ![See the list of graphs](images/task2step2.png " ")

   2. Click the **3 dots** on the right and click **Load Graph Into Memory**.

       ![Expand the 3 dots on the right](images/task2step3.png " ")

   3. Accept the defaults and click **Yes**.  

       ![Click Yes](images/task2step4.png " ")

       Next see that the load into memory is in progress:  

       ![See the load into memory In Progress](images/task2step5.png " ")

       About two minutes later the load job should complete successfully.

       ![See the load job completed](images/task2step6.png " ")

       **Note:** If the load into memory fails, retry Steps 2 and 3.

    Click the Graphs icon again to see that the graph is now in memory.  

       ![See the graph loaded into memory](images/task2step7.png " ")
--->

## Acknowledgements
* **Author** - Melli Annamalai, Product Manager, Oracle Spatial and Graph
* **Contributors** -  Jayant Sharma
* **Last Updated By/Date** - Ramu Murakami Gutierrez, Product Manager, Oracle Spatial and Graph, February 2023