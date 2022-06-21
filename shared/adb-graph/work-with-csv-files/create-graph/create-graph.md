# Graph Studio: Create a graph using PGQL CREATE PROPERTY GRAPH statement

## Introduction

In this lab you will create a graph from the `bank_accounts` and `bank_txns` tables using Graph Studio and the CREATE PROPERTY GRAPH statement.

<!-- COMMENTED THE FOLLOWING OUT FOR DATABSE WORLD:
The following video shows the steps you will execute in this lab.

[](youtube:5g9i9HA_cn0) Graph Studio: Create a graph. -->

Estimated Time: 15 minutes. 

Watch the video below for a quick walk through of the lab.

[](youtube:tNPY4xmVFMk)

### Objectives

Learn how to
- use Graph Studio and PGQL DDL (that is, CREATE PROPERTY GRAPH statement) to model and create a graph from existing tables or views.

### Prerequisites

- The following lab requires an Autonomous Database - Shared Infrastructure account. 
- And that the Graph-enabled user (`GRAPHUSER`) exists. That is, a database user with the correct roles and privileges exists.

## Task 1: Connect to your Autonomous Database using Graph Studio

1. If you have the Graph Studio URL then proceed to step 4. 

    Log in to the Oracle Cloud Console, choose the Autonomous Database instance, then Click the **Tools** tab on the details page menu on the left. 

   ![Oracle Cloud Console](./images/adw-console-tools-tab.png)


2. Click the **Open Graph Studio** card to open in a new page or tab in your browser.   
   
   If your tenancy administrator provided you the Graph Studio URL to connect directly then use that instead.


3. Enter your Autonomous Database account credentials (for example, `GRAPHUSER`) into the login screen:
 
    ![ALT text is not available for this image](./images/graphstudio-login-graphuser.png " ")

4. Then click the **Sign In** button. You should see the studio home page.   

    ![ALT text is not available for this image](./images/gs-graphuser-home-page.png " ") 

    Graph Studio consists of a set of pages accessed from the menu on the left. 

    The Home icon ![ALT text is not available for this image](images/home.svg "") takes you to the Home page.  
    The Models icon ![ALT text is not available for this image](images/code-fork.svg "") takes you to the Models page where you start modeling your existing tables and views as a graph and then create, or instantiate, a graph.  
    The Graph page ![ALT text is not available for this image](images/radar-chart.svg "") lists existing graphs for use in notebooks.  
    The Notebook page ![ALT text is not available for this image](images/notebook.svg "") lists existing notebooks and lets you create a new one.  
    The Jobs page ![ALT text is not available for this image](images/server.svg "") lists the status of background jobs and lets you view the associated log if any.  


## Task 2: Create a graph of accounts and transactions from the corresponding tables

1. Click the **Models** icon to navigate to the start of the modeling workflow.  
   Then click **Create**.  
   ![ALT text is not available for this image](images/modeler-create-button.png " ")  

   >**Note: If you clicked on `Start Modeling` button instead then you'll see the screen shown in the next step.**

2. Then select the `BANK_ACCOUNTS` and `BANK_TXNS` tables.   
    ![ALT text is not available for this image](./images/select-tables.png " ")

3. Move them to the right, that is, click the first icon on the shuttle control.   

   ![ALT text is not available for this image](./images/selected-tables.png " ")

4.  Click **Next** to get a suggested model. We will edit and update this model to add an edge and a vertex label.  

    The suggested model has the `BANK_ACCOUNTS` as a vertex table since there are foreign key constraints specified on `BANK_TXNS` that reference it.   

    And `BANK_TXNS` is a suggested edge table.

  ![ALT text is not available for this image](./images/create-graph-suggested-model.png " ")    
  

5.  Now let's change the default Vertex and Edge labels.  

    Click the `BANK_ACCOUNTS` vertex table. Change the Vertex Label to **ACCOUNTS**. Then click outside the input box on confirm label and save the update.  

    ![ALT text is not available for this image](images/edit-accounts-vertex-label.png " ")  

    Click the `BANK_TXNS` edge table and rename the Edge Label from `BANK_TXNS` to **TRANSFERS**.  
    Then click outside the input box on confirm label and save the update.  

    ![ALT text is not available for this image](images/edit-edge-label.png " ")  

    This is **important** because we will use these edge labels in the next lab of this workshop when querying the graph.  

6.  Since these are directed edges, a best practice is verifying that the direction is correct.  
    In this instance we want to **confirm** that the direction is from `from_acct_id` to `to_acct_id`.  

    Note the `Source Vertex` and `Destination Vertex` information on the left.  
 
    ![ALT text is not available for this image](images/wrong-edge-direction.png " ")  

    **Notice** that the direction is wrong. The Source Key is `to_acct_id` instead of what we want, which is `from_acct_id`.  

    Click the swap edge icon on the right to swap the source and destination vertices and hence reverse the edge direction.  

   Note that the `Source Vertex` is now the correct one, i.e. the `FROM_ACCT_ID`.

   ![ALT text is not available for this image](images/reverse-edge-result.png " ") 


   

7. Click the **Source** tab to verify that the edge direction, and hence the generated CREATE PROPERTY GRAPH statement, is correct.


   ![ALT text is not available for this image](images/generated-cpg-statement.png " ")  
  
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

8. Click **Next** and then click **Create Graph** to move on to the next step in the flow.   

   Enter `bank_graph` as the graph name.  
   That graph name is used throughout the next lab.  
   Do not enter a different name because then the queries and code snippets in the next lab will fail.  
   
   Enter a model name (for example, `bank_graph_model`), and other optional information and then click Create.
   ![ALT text is not available for this image](./images/create-graph-dialog.png " ")

9. Graph Studio modeler will now save the metadata and start a job to create the graph.  
   The Jobs page shows the status of this job. 

   ![ALT text is not available for this image](./images/23-jobs-create-graph.png " ")  

   You can then interactively query and visualize the graph in a notebook after it's loaded into memory.


Please **proceed to the next lab** to do so.

## Acknowledgements
* **Author** - Jayant Sharma, Product Management
* **Contributors** -  Jayant Sharma, Product Management
* **Last Updated By/Date** - Jayant Sharma, Product Management, March 2022  
