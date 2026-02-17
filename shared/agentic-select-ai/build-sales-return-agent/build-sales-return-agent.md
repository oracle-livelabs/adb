# Build a Sales Return Agent

## Introduction

In this lab, you’ll turn a common customer service workflow - returning a purchased item - into an agentic workflow using Oracle Autonomous AI Database Select AI. The agent will converse with you the customer, collect the reason for return, and run an update to the order record.

Estimated Time: X

### Objectives

In this lab, you will:

* Download and import the Sales Return Notebook into Oracle Machine Learning Notebooks.
* Review the sample customer data and create a PL/SQL function to update the order status.
* Create a tool that uses that function to update the return status in the database.
* Create a task that coordinates the return action.
* Create a customer agent that defines the persona/role of the customer return agent.
* Create an agent team and run it from the SQL command line, providing responses to the agent's questions.
* Use DBMS\_CLOUD\_AI\_AGENT.RUN\_TEAM function to run a multi-step interaction.

### Prerequisites

[comment]: # (This lab requires completion of the **Get Started** section in the **Contents** menu on the left.)
- Access to Oracle Machine Learning Notebooks interface.
- Typical grants to run DBMS\_CLOUD\_AI\_AGENT Package are (run as ADMIN once):

```
<copy>

GRANT EXECUTE ON DBMS_CLOUD_AI TO ADB_USER;
GRANT EXECUTE ON DBMS_CLOUD_AI_AGENT TO ADB_USER;
</copy>
```
Replace _`ADB_USER`_ with your user name.

## Task 1: Download and Import the Provided Notebook into OML

Oracle provides a ready-to-use OML notebook that walks through the complete setup of the **Sales Return Agent** that includes all required steps to define agents, tools, tasks, teams, and interactions for processing the product return from a customer using Select AI.
This notebook named **SelectAI4SQL - AI Agents - Sales Return Agent** contains all the steps for setting up the **Sales Return Agent**.

In this task, you will first download the **`SelectAI4SQL - AI Agents - Sales Return Agent.dsnb`** OML notebook to your local machine, and then import this notebook into OML. <!--You can import the provided notebook from a local disk or on GitHub-->.

1. Click the button below to download the notebook to your local folder:

    <a href="https://adwc4pm.objectstorage.us-ashburn-1.oci.customer-oci.com/p/1C_VWEcNHyMoV10mPLbRvJmxDOyCR0ogX4LijMCidf5MxL5xuhnnMvwuQ5tll4uR/n/adwc4pm/b/oaiw25-select-ai-agent-notebook/o/SelectAI4SQL%20-%20AI%20Agents%20-%20Sales%20Return%20Agent.dsnb" class="tryit-button">Download Notebook</a>
<!-- https://github.com/oracle-devrel/oracle-autonomous-database-samples/blob/main/select-ai-agent/notebooks/SelectAI4SQL%20-%20AI%20Agents%20-%20Sales%20Return%20Agent.dsnb-->
2. To access the URL for the Oracle Machine Learning sign in page, go to your Autonomous AI Database details page and click **Tool configuration**.

3. Go to the **Oracle Machine Learning user interface** section and click **Copy**. Paste the URL on the browser to sign into Oracle Machine Learning user interface.
  ![Access OML User Interface URL](../build-sales-return-agent/images/oml-notebook-url.png)

4. On your Oracle Machine Learning home page, click the top left navigation menu. Click **Notebooks**. Click **Import** and click **File**. The **Open** dialog box is displayed. Navigate to your local folder where you downloaded the OML notebook, and select the **`SelectAI4SQL - AI Agents - Sales Return Agent.dsnb`** notebook file. The file is displayed in the **File Name** field. Make sure that the **Custom Files (*.dsnb;\*.ipynb;\*.json;\*.zpln)** type is selected in the second drop-down field, and then click **Open**.

    ![The Open dialog box is displayed](../build-sales-return-agent/images/notebook-open-dialog.png " ")

    If the import is successful, a notification is displayed and the **`SelectAI4SQL - AI Agents - Sales Return Agent`** notebook is displayed in the list of available notebooks.

    ![The newly imported notebook is displayed.](../build-sales-return-agent/images/notebook-imported.png " ")

3. Open the imported notebook. Click the notebook's name link. The notebook is displayed in the Notebook **Editor**. Read the paragraphs in this notebook.

     >**Note:** If a **User Action Required** message is displayed when you open the notebook, click **Allow Run**.

## Task 2: Review the Customer Table

You'll view the sample table for the scenario.

1. Run the paragraph that creates `customers` table. 
    ```
    <copy>
  
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE customers';
    EXCEPTION WHEN OTHERS THEN NULL; END;
    /
    CREATE TABLE customers (
        customer_id  NUMBER(10) PRIMARY KEY,
        name         VARCHAR2(100),
        email        VARCHAR2(100),
        phone        VARCHAR2(20),
        state        VARCHAR2(2),
        zip          VARCHAR2(10)
    );

    INSERT INTO customers (customer_id, name, email, phone, state, zip) VALUES
    (1, 'Alice Thompson', 'alice.thompson@example.com', '555-1234', 'NY', '10001'),
    (2, 'Bob Martinez', 'bob.martinez@example.com', '555-2345', 'CA', '94105'),
    (3, 'Carol Chen', 'carol.chen@example.com', '555-3456', 'TX', '73301'),
    (4, 'David Johnson', 'david.johnson@example.com', '555-4567', 'IL', '60601'),
    (5, 'Eva Green', 'eva.green@example.com', '555-5678', 'FL', '33101');
    </copy>
    ```

2. View the contents of the `customers` table. 

    ```
    <copy>
    select * from customers;
    </copy>
    ```

3. Run the paragraph that creates `customer_order_status` table.

    ```
    <copy>
  
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE customer_order_status';
    EXCEPTION WHEN OTHERS THEN NULL; END;
    /
    CREATE TABLE customer_order_status (
        customer_id     NUMBER(10),
        order_number    VARCHAR2(20),
        status          VARCHAR2(30),
        product_name    VARCHAR2(100)

    );

    INSERT INTO customer_order_status (customer_id, order_number, status, product_name) VALUES
    (2, '7734', 'delivered', 'smartphone charging cord'),
    (1, '4381', 'pending_delivery', 'smartphone protective case'),
    (2, '7820', 'delivered', 'smartphone charging cord'),
    (3, '1293', 'pending_return', 'smartphone stand (metal)'),
    (4, '9842', 'returned', 'smartphone backup storage'),
    (5, '5019', 'delivered', 'smartphone protective case'),
    (2, '6674', 'pending_delivery', 'smartphone charging cord'),
    (1, '3087', 'returned', 'smartphone stand (metal)'),
    (3, '7635', 'pending_return', 'smartphone backup storage'),
    (4, '3928', 'delivered', 'smartphone protective case'),
    (5, '8421', 'pending_delivery', 'smartphone charging cord'),
    (1, '2204', 'returned', 'smartphone stand (metal)'),
    (2, '7031', 'pending_delivery', 'smartphone backup storage'),
    (3, '1649', 'delivered', 'smartphone protective case'),
    (4, '9732', 'pending_return', 'smartphone charging cord'),
    (5, '4550', 'delivered', 'smartphone stand (metal)'),
    (1, '6468', 'pending_delivery', 'smartphone backup storage'),
    (2, '3910', 'returned', 'smartphone protective case'),
    (3, '2187', 'delivered', 'smartphone charging cord'),
    (4, '8023', 'pending_return', 'smartphone stand (metal)'),
    (5, '5176', 'delivered', 'smartphone backup storage');
    </copy>
    ```
2. View the order status table.

    ```
    <copy>
    select * from customer_order_status;
    </copy>
    ```

## Task 3: Create a Customer Order Update Status Function

You will create a SQL function to update a customer’s order status and return a message, run an PL/SQL block to set a customers order to _pending\_return_ and print the result, then verify the table.

1. Create a customer order update status function.

    ```
    <copy>
    
    CREATE OR REPLACE FUNCTION update_customer_order_status (
    p_customer_name IN VARCHAR2,
    p_order_number  IN VARCHAR2,
    p_status        IN VARCHAR2
    ) RETURN CLOB IS
    v_customer_id  customers.customer_id%TYPE;
    v_row_count    NUMBER;
    BEGIN
    -- Find customer_id from customer_name
    SELECT customer_id
    INTO v_customer_id
    FROM customers
    WHERE name = p_customer_name;
    
    UPDATE customer_order_status
    SET status = p_status
    WHERE customer_id = v_customer_id
      AND order_number = p_order_number;

    v_row_count := SQL%ROWCOUNT;

    IF v_row_count = 0 THEN
        RETURN 'No matching record found to update.';
    ELSE
        RETURN 'Update successful.';
    END IF;
    EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error: ' || SQLERRM;
    END;
    </copy>
    ```
2. Test this function by updating an order for a specific customer and return a message on completion.

    ```
    <copy>
    
    DECLARE
      v_result CLOB;
    BEGIN
      v_result := update_customer_order_status('David Johnson', '3928', 'pending_return');

      DBMS_OUTPUT.PUT_LINE(v_result);
    END;
    </copy>
    ```
3. Verify the change by viewing the customer order update status table for that customer. 

    ```
    <copy>
    select * from customer_order_status
    where ORDER_NUMBER = 3928
    </copy>
    ```

## Task 4: Create a Tool to Update Database

Tools are what allow agents to perform tasks in the "real" world. You'll create a tool that a task will use. Each tool is identified by a unique name and includes attributes that define its purpose, instruction logic, and metadata. You'll verify the tool by querying a corresponding view.

1. Create Update\_Order\_Status\_Tool.

    ```
    <copy>
    
    BEGIN DBMS_CLOUD_AI_AGENT.drop_tool('Update_Order_Status_Tool');
    EXCEPTION WHEN OTHERS THEN NULL; END;
    /
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name => 'Update_Order_Status_Tool',
            attributes => '{"instruction": "This tool updates the database to reflect return status change. Always confirm user name and order number with user before update status",
                            "function" : "update_customer_order_status"}',
            description => 'Tool for updating customer order status in database table.'
        );
    END;
    </copy>
    ```
2. Verify the Update\_Order\_Status\_Tool by querying `USER_AI_AGENT_TOOLS` view.

    ```
    <copy>
    select * from USER_AI_AGENT_TOOLS
    order by created desc
    </copy>
    ```

## Task 5: Create a Task to Handle the Product Return

We use a task to specify the instructions for performing actions using tools. You'll define a task that your Select AI agent will perform. Each task has a unique name and a set of attributes that specify  its behavior when planning and performing the task. In this scenario, you'll describe the interaction with the customer and how to respond in various cases.

Create Handle\_Product\_Return\_Task.

  ```
  <copy>
  
  BEGIN DBMS_CLOUD_AI_AGENT.drop_task('Handle_Product_Return_Task');
  EXCEPTION WHEN OTHERS THEN NULL; END;
  /
  BEGIN
    DBMS_CLOUD_AI_AGENT.create_task(
      task_name => 'Handle_Product_Return_Task',
      attributes => '{"instruction": "Process a product return request from a customer:{query}' || 
                      '1. Ask customer the reason for return (no longer needed, arrived too late, box broken, or defective)' || 
                      '2. If no longer needed:' ||
                      '   a. Inform customer to ship the product at their expense back to us.' ||
                      '   b. Update the order status to return_shipment_pending using Update_Order_Status_Tool.' ||
                      '3. If it arrived too late:' ||
                      '   a. Ask customer if they want a refund.' ||
                      '   b. If the customer wants a refund, then confirm refund processed and update the order status to refund_completed' || 
                      '4. If the product was defective or the box broken:' ||
                      '   a. Ask customer if they want a replacement or a refund' ||
                      '   b. If a replacement, inform customer replacement is on its way and they will receive a return shipping label for the defective product, then update the order status to replaced' ||
                      '   c. If a refund, inform customer to print out the return shipping label for the defective product, return the product, and update the order status to refund' ||
                      '5. After the completion of a return or refund, ask if you can help with anything else.' ||
                      '   End the task if user does not need help on anything else",
                      "tools": ["Update_Order_Status_Tool"]}'
    );
  END;
  </copy>
  ```

## Task 6: Create OCI Credentials
Before you create and use an AI profile, you must create your OCI credential. In this task you will gather the required parameters for OCI Gen AI credential and create a credential that will be used in the next task to create an AI profile.

Follow these steps to create your OCI credentials:
1. User OCID

   a. Go to the OCI Console.

   b. Open the profile menu (top right, click your profile icon) -> **User Settings**.

   c. Copy the OCID shown there.
   ![Copy your user OCID](./images/copy-your-ocid.png =70%x*)

2. Tenancy OCID

   a. From the same user menu -> go to **Tenancy**.
   ![Click Tenancy from profile menu](./images/click-tenancy.png =70%x*)

   b. Copy the **OCID** shown there.
   ![Copy the tenancy OCID](./images/copy-tenancy-ocid.png =70%x*)

3. Fingerprint

   This comes from the public key you upload when you create an API key.

   a. Navigate to **User Settings** -> **Tokens and Keys** -> click **Add API key**.

   ![Click User settings in your profile](./images/profile-user-settings.png =70%x*)
   ![Navigate to Tokens and Keys tab](./images/tokens-and-keys-tab.png)
   
   b. After creating and uploading a public key, OCI generates a fingerprint for it. Copy that value. 
   If you already have a public key on your system, skip the first step below:

   b1. If you are creating a new API key, select **Generate API key pair** and click **Download public key** and **Download private key** to download both public and private keys to your local system.
   ![Create your API key pair](./images/gen-api-key-pair.png)
  
   b2. Come back to the Add API key screen and select **Choose public key file** and upload the file from your system or drag and drop the file. Once your file is uploaded, the **Add** button is enabled. Click **Add**.
   ![Choose public key file](./images/upload-public-key.png)

   b3. OCI generates a fingerprint and a Configuration file preview is displayed. Copy the fingerprint value and click **Close**.

   You can also copy the fingerprint value after closing the Configuration file preview screen under the API Keys section in the console.


4. Private Key

   This is the private key file you generated locally (when you created the API key pair).

   Usually named `oci_api_key.pem`.

   Open it in a text editor and copy the entire contents, including:
     ```
     -----BEGIN PRIVATE KEY-----
     ...key content...
     -----END PRIVATE KEY-----
     ```
5. Create an OCI Gen AI credential.

    ```
    <copy>
    
    begin
      DBMS_CLOUD.drop_credential(credential_name => 'AI_CREDENTIAL');
      EXCEPTION WHEN OTHERS THEN NULL; END;
    end;
    /
    BEGIN
      DBMS_CLOUD.create_credential(
        credential_name => 'AI_CREDENTIAL',
        user_ocid       => '<ocid>',
        tenancy_ocid    => '<tenancy ocid>',
        private_key     => '<private key>',
        fingerprint     => '<fingerprint>'
      );
    END;
    </copy>
    ```
## Task 7: Create an AI Profile
You'll create an AI profile with LLM of your choice, to use in the next step to create an agent. In this task, you are using xAi's GROK model with OCI Gen AI credential.

```
<copy>

BEGIN
  BEGIN DBMS_CLOUD_AI.drop_profile(profile_name => 'OCI_GENAI_GROK'); 
  EXCEPTION WHEN OTHERS THEN NULL; END;

  DBMS_CLOUD_AI.create_profile(
      profile_name => 'OCI_GENAI_GROK',
      attributes   => '{
          "provider": "oci",
          "credential_name": "AI_CREDENTIAL",
          "model": "xai.grok-3",
          "embedding_model": "cohere.embed-english-v3.0"
      }',
      description  => 'Supports the Select AI Sales Return Agent scenario.'
  ); 
END;
</copy>
```

## Task 8: Define Customer Agent

You'll create an agent, which specifies the LLM to use through an AI profile and the role the agent plays.

Create the Customer\_Return\_Agent.

```
<copy>

BEGIN DBMS_CLOUD_AI_AGENT.drop_agent('Customer_Return_Agent');
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
  DBMS_CLOUD_AI_AGENT.create_agent(
    agent_name => 'Customer_Return_Agent',
    attributes => '{"profile_name": "OCI_GENAI_GROK",
                    "role": "You are an experienced customer return agent who deals with customers return requests."}');
END;
</copy>
```

## Task 9: Create the Agent Team

You'll define an agent team that uses the agent and tasks specified above. You specify agent-task pairs for defining a sequential workflow. If you have multiple agents or multiple tasks, these are specified within the JSON list. The same Agent can be specified multiple times with their associated tasks. In this scenario it is a single agent and task pair.

Create the Return\_Agency\_Team.

```
<copy>

BEGIN DBMS_CLOUD_AI_AGENT.drop_team('Return_Agency_Team');
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN                                                                 
  DBMS_CLOUD_AI_AGENT.create_team(  
    team_name  => 'Return_Agency_Team',                                                            
    attributes => '{"agents": [{"name" : "Customer_Return_Agent", 
                                "task" : "Handle_Product_Return_Task"}],
                    "process": "sequential"}');                                                                 
END;

</copy>
```

## Task 10: Interact with the Return Agency Agent

You can start interacting with the Select AI agent team by using natural language prompt on the SQL command line. To do so, you must set the agent team for the current stateful session. Then, prefix your prompt with `select ai agent`. You'll interact with the agent team using natural language. Behind the scenes, the ReAct agent pattern is used by Select AI Agent to get needed information from you, the customer, engage the LLM, call the needed tools, and respond.
Let's test it:

1. Set the agent team in the current session.

    ```
    <copy>
    
    BEGIN DBMS_CLOUD_AI_AGENT.clear_team();
    EXCEPTION WHEN OTHERS THEN NULL; END;
    / 
    EXEC DBMS_CLOUD_AI_AGENT.set_team(team_name  => 'Return_Agency_Team');
    </copy>
    ```

2. Interact with the Return Agency in a series of natural language prompts.

    ```
    <copy>
    select ai agent I want to return a smartphone case;
    </copy>
    ```
**Result:**
    ```
    RESPONSE
    Could you please tell me the reason for returning the smartphone case? Is it no longer needed, arrived too late, box broken, or defective?
    ```

    ```
    <copy>
    select ai agent the item is defective
    </copy>
    ```
**Result:**
    ```
    RESPONSE
    I'm sorry to hear that the smartphone case is defective. Would you like a replacement or a refund?
    ```

    ```
    <copy>
    select ai agent I will need a replacement
    </copy>
    ```
**Result:**
    ```
    RESPONSE
    Could you please confirm your name and order number so I can update the status and process the replacement?
    ```

    ```
    <copy>
    select ai agent I''m Bob Martinez and my order number is 7820
    </copy>
    ```
**Result:**
    ```
    RESPONSE
    Thank you, Bob. The replacement smartphone case is on its way, and you will receive a return shipping label for the defective product. Is there anything else I can help you with?
    ```

To continue, you may try these prompts in the given sequence:

a. _select ai agent Yes, I''d like to return a smartphone stand;_

b. _select ai agent I no longer need it_

c. _select ai agent I''m Bob Martinez with order number is 7820_

d. _select ai agent No, I''m all set. Thanks_


## Task 11: Use `DBMS_CLOUD_AI_AGENT.RUN_TEAM`

The RUN_TEAM procedure enables you to use your agent team from PL/SQL - as opposed to the SQL command line. This procedure is mainly to enable you to build your own agentic applications where you may need greater control over individual conversations. First, you'll create Select AI conversation and then use the `DBMS_CLOUD_AI_AGENT.RUN_TEAM` function to run the agent team and interact with the Return Agency team. Creating a conversation helps the agent team to keep track of the customer conversation context and history.

1. Create Select AI conversation.

    ```
    <copy>
    
    CREATE OR REPLACE PACKAGE my_globals IS
      l_team_cov_id varchar2(4000);
    END my_globals;
    /
    -- Create conversation
    DECLARE
      l_team_cov_id varchar2(4000);
    BEGIN
      l_team_cov_id := DBMS_CLOUD_AI.create_conversation();
      my_globals.l_team_cov_id := l_team_cov_id;
      DBMS_OUTPUT.PUT_LINE('Created conversation with ID: ' || my_globals.l_team_cov_id);
    END;
    </copy>
    ```
2. Call the `DBMS_CLOUD_AI_AGENT.RUN_TEAM` function. Interact with the Return Agency team in a series of prompts provided within the function. This function holds your conversation ID so that Select AI does not lose the context and prompt history.
    ```
    <copy>
    
    DECLARE
      v_response VARCHAR2(4000);
    BEGIN
      v_response :=  DBMS_CLOUD_AI_AGENT.RUN_TEAM(
        team_name   => 'Return_Agency_Team',
        user_prompt => 'I want to return a smartphone case',
        params      => '{"conversation_id": "' || my_globals.l_team_cov_id || '"}'
      );
      DBMS_OUTPUT.PUT_LINE(v_response);
    END;
    </copy>
    ```
**Result:**
    ```
    Could you please tell me the reason for returning the smartphone case? Is it no longer needed, arrived too late, box broken, or defective?
    ```

    ```
    <copy>
    
    DECLARE
      v_response VARCHAR2(4000);
    BEGIN
      v_response :=  DBMS_CLOUD_AI_AGENT.RUN_TEAM(
        team_name   => 'Return_Agency_Team',
        user_prompt => 'the item is defective',
        params      => '{"conversation_id": "' || my_globals.l_team_cov_id || '"}'
      );
      DBMS_OUTPUT.PUT_LINE(v_response);
    END;
    </copy>
    ```
**Result:**
    ```
    I'm sorry to hear that the smartphone case is defective. Would you like a replacement or a refund?
    ```

    ```
    <copy>
    %script

    DECLARE
      v_response VARCHAR2(4000);
    BEGIN
      v_response :=  DBMS_CLOUD_AI_AGENT.RUN_TEAM(
        team_name   => 'Return_Agency_Team',
        user_prompt => 'I''d like a replacement',
        params      => '{"conversation_id": "' || my_globals.l_team_cov_id || '"}'
      );
      DBMS_OUTPUT.PUT_LINE(v_response);
    END;
    </copy>
    ```
**Result:**
    ```
    Thank you for your response. The replacement smartphone case is on its way, and you will receive a return shipping label for the defective product. Could you please confirm your name and order number so I can update the order status?
    ```

    ```
    <copy>
    
    DECLARE
      v_response VARCHAR2(4000);
    BEGIN
      v_response :=  DBMS_CLOUD_AI_AGENT.RUN_TEAM(
        team_name    => 'Return_Agency_Team',
        user_prompt => 'I''m Bob Martinez and my order number is 7820',
        params      => '{"conversation_id": "' || my_globals.l_team_cov_id || '"}'
      );
      DBMS_OUTPUT.PUT_LINE(v_response);
    END;
    </copy>
    ```
**Result:**
    ```
    Is there anything else I can help you with?
    ```

    ```
    <copy>
    
    DECLARE
      v_response VARCHAR2(4000);
    BEGIN
      v_response :=  DBMS_CLOUD_AI_AGENT.RUN_TEAM(
        team_name => 'Return_Agency_Team',
        user_prompt => 'No, thank you',
        params => '{"conversation_id": "' || my_globals.l_team_cov_id || '"}'
      );
      DBMS_OUTPUT.PUT_LINE(v_response);
    END;
    </copy>
    ```
**Result:**
    ```
    Thank you, Bob. I'm glad we could assist with the replacement of your smartphone case. If you have any other concerns in the future, feel free to reach out. Have a great day!
    ```

You may now proceed to the next lab.

## Learn More

* [OML Notebooks](https://docs.oracle.com/en/database/oracle/machine-learning/oml-notebooks/index.html)
* [Using Oracle Autonomous AI Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)
* [Example of creating an OCI Gen AI Select AI Profile](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai-examples.html#GUID-BD10A668-42A6-4B44-BC77-FE5E5592DE27)
* [How to help AI models generate better natural language queries](https://blogs.oracle.com/datawarehousing/post/how-to-help-ai-models-generate-better-natural-language-queries-in-autonomous-database)

## Acknowledgements

* **Author:** Sarika Surampudi, Principal User Assistance Developer
* **Contributor:** Mark Hornick, Product Manager; Laura Zhao, Member of Technical Staff
<!--* **Last Updated By/Date:** Sarika Surampudi, August 2025
-->


Copyright (c) 2026 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
