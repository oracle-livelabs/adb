# Build a Sales Return Agent

## Introduction

In this lab, you’ll turn a common customer service workflow - returning a purchased item - into an agentic workflow using Oracle Autonomous Database Select AI. The agent will converse with you the customer, collect the reason for return, and run an update to the order record.

Estimated Time: 30 minutes.

### Objectives

In this lab, you will:

* Review the sample customer data and create a PL/SQL function to update the order status.
* Create a tool that uses that function to update the return status in the database.
* Create a task that coordinates the return action.
* Create a customer agent that defines the persona/role of the customer return agent.
* Create an agent team and run it from the SQL command line, providing responses the agent’s questions.
* Use DBMS\_CLOUD\_AI\_AGENT.RUN\_TEAM function to run a multi step interaction.

### Prerequisites

- This lab requires completion of the first two labs in the **Contents** menu on the left.
- Typical grants to run DBMS\_CLOUD\_AI\_AGENT Package are (run as ADMIN once):
```
GRANT EXECUTE ON DBMS_CLOUD_AI TO <user>;
GRANT EXECUTE ON DBMS_CLOUD_AI_AGENT TO <user>;
```

## Task 1: Review a Customer Table

You'll view the sample table for the scenario.

1. View the contents of the customer table.

```
select * from customer;
```

2. View the order status table.

```
select * from customer_order_status;
```

## Task 2: Create a Customer Order Update Status Function

You will create a SQL function to update a customer’s order status and return a message, run an PL/SQL block to set a customers order to _pending\_return_ and print the result, then verify the table.

1. Create a customer order update status function.

```
%script

CREATE OR REPLACE FUNCTION update_customer_order_status (
    p_customer_name IN VARCHAR2,
    p_order_number  IN VARCHAR2,
    p_status        IN VARCHAR2
) RETURN VARCHAR2 IS
    v_customer_id  customer.customer_id%TYPE;
    v_row_count    NUMBER;
BEGIN
    -- Find customer_id from customer_name
    SELECT customer_id
    INTO v_customer_id
    FROM customer
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
```
2. Update the order for a specific customer and return a message on completion.

```
%script

DECLARE
  v_result CLOB;
BEGIN
  v_result := update_customer_order_status('David Johnson', '3928', 'pending_return');

  DBMS_OUTPUT.PUT_LINE(v_result);
END;
```
3. Verify the change by viewing the customer order update status table for that particular customer. 

```
select * from customer_order_status
where customer_id = 4
```

## Task 3: Create a Tool to Update Database

You'll create a tool that a task will use. Each tool is identified by a unique name and includes attributes that define its purpose, implementation logic, and metadata. You'll verify the tool by querying a corresponding view.

1. Create Update\_Order\_Status\_Tool.

```
%script

BEGIN DBMS_CLOUD_AI_AGENT.drop_tool('Update_Order_Status_Tool');
EXCEPTION WHEN OTHERS THEN NULL; END;
/
 BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name => 'Update_Order_Status_Tool',
        attributes => '{"instruction": "This tool updates the database to reflect return status change. It take the customer name and order number as input",
                        "function" : "update_customer_order_status"}',
        description => 'Tool for updating customer order status in database table.'
    );
END;
```
2. Verify the Update\_Order\_Status\_Tool by querying `USER_AI_AGENT_TOOLS` view.

```
select * from USER_AI_AGENT_TOOLS
order by created desc
```

## Task 4: Create a Task to Handle the Product Return

You'll define a task that a Select AI agent will perform. Each task has a unique name and a set of attributes that specify  its behavior when planning and performing the task. In this scenario, you'll describe the interaction with the customer and how to respond in various cases.

Create Handle\_Product\_Return\_Task.

```
%script

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
                    '   a. Ask customer for their name and order number and update order status return_shipment_pending.' ||
                     '3. If it arrived too late:' ||
                    '   a. Ask customer if they want a refund.' ||
                    '   b. If the customer wants a refund, then confirm refund processed and update the database for customer name and order number with status refund_completed' ||
                    '4. If the product was defective or the box broken:' ||
                    '   a. Ask customer if they want a replacement or a refund' ||
                    '   b. If a replacement, inform customer replacement is on its way and they will receive a return shipping label for the defective product, then update the database for customer name and order number with status replaced' ||
                    '   c. If a refund, inform customer to print out the return shipping label for the defective product, return the product, and update the database for customer name and order number with status refund' ||
                    '5. After the completion of a return or refund, ask if you can help with anything else.' ||
                    '   End the task if user does not need help on anything else",
                    "tools": ["Update_Order_Status_Tool"]}'
  );
END;
```
## Task 5: Create an AI Profile
You'll create an AI profile that you'll use in the next step to create an agent.

```
%script

BEGIN
  BEGIN DBMS_CLOUD_AI.drop_profile(profile_name => 'OCI_GENAI_GROK'); 
  EXCEPTION WHEN OTHERS THEN NULL; END;

  DBMS_CLOUD_AI.create_profile(
      profile_name => 'OCI_GENAI_GROK',
      attributes   => '{
          "provider": "oci",
          "credential_name": "OCI_CRED",
          "model": "xai.grok-3",
          "embedding_model": "cohere.embed-english-v3.0"
      }',
      description  => 'Supports the Select AI Sales Return Agent scenario.'
  ); 
END;
```

## Task 6: Define Customer Agent

You'll create an agent, which specifies the LLM to use through an AI profile and the role the agent plays.

Create the Customer\_Return\_Agent.

```
%script

BEGIN DBMS_CLOUD_AI_AGENT.drop_agent('Customer_Return_Agent');
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
  DBMS_CLOUD_AI_AGENT.create_agent(
    agent_name => 'Customer_Return_Agent',
    attributes => '{"profile_name": "OCI_GENAI_GROK",
                    "role": "You are an experienced customer return agent who deals with customers return requests."}');
END;
```

## Task 7: Create the Agent Team

You'll define an agent team that uses the agent and tasks specified above. You specify agent-task pairs for defining a sequential workflow. If you have multiple agents or multiple tasks, these are specified within the JSON list. The same Agent can be specified multiple times with their associated tasks. In this scenario it is a single agent and task pair.

Create the Return\_Agency\_Team.

```
%script

BEGIN DBMS_CLOUD_AI_AGENT.drop_team('Return_Agency_Team');
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
  DBMS_CLOUD_AI_AGENT.create_team(
    team_name  => 'Return_Agency_Team',
    attributes => '{"agents": [{"name" : "Customer_Return_Agent", "task" : "Handle_Product_Return_Task"}],
                    "process": "sequential"}');
END;
```

## Task 8: Interact with the Return Agency Agent

You can start interacting with the Select AI agent team by using natural language prompt on the SQL command line. To do so, you must set the agent team for the current session. Then, prefix your prompt with `Select AI agent`. In this scenario, the agent team interacts with you in natural language. Behind the scenes, the ReAct agent pattern is used to get needed information from you, the customer, engage the LLM, call the needed tools, and respond.
Let's test it:

1. Set the agent team in the current session.

```
EXEC DBMS_CLOUD_AI_AGENT.set_team(team_name  => 'Return_Agency_Team');
```

2. Interact with the Return Agency in a series of natural language prompts.

```
select ai agent agent I want to return a smartphone case;
```
**Result:**
```
RESPONSE
Could you please tell me the reason for returning the smartphone case? Is it no longer needed, arrived too late, box broken, or defective?
```

```
select ai agent the item is defective;
```

**Result:**
```
RESPONSE
I'm sorry to hear that the smartphone case is defective. Would you like a replacement or a refund?
```

```
select ai agent I will need a replacement
```
**Result:**
```
RESPONSE
Can you please confirm your name and order number so I can update the status and process the replacement?
```

```
select ai agent I''m Bob Martinez and my order number is 7820
```
**Result:**
```
RESPONSE
Thank you, Bob. The replacement for your smartphone case is on its way, and you will receive a return shipping label for the defective product. Is there anything else I can help you with?
.
.
.
```

## Task 9: Use `DBMS_CLOUD_AI_AGENT.RUN_TEAM`

First you'll create Select AI conversation and then use the `DBMS_CLOUD_AI_AGENT.RUN_TEAM` function to run the agent team and interact with the Return Agency team. The agent team also keeps a track of the customer conversation history.

1. Create Select AI conversation.

```
%script

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
```
2. Call the `DBMS_CLOUD_AI_AGENT.RUN_TEAM` function. Interact with the Return Agency team in a series of prompts provided within the function. This function holds your conversation ID so that Select AI does not loose the context and prompt histories.
```
%script

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
```
**Result:**
```
Could you please tell me the reason for returning the smartphone case? Is it no longer needed, arrived too late, box broken, or defective?
```

```
%script

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
```
**Result:**
```
I'm sorry to hear that the smartphone case is defective. Would you like a replacement or a refund?
```

```
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
```
**Result:**
```
Can you please confirm your name and order number so I can update the status and process the replacement?
```

```
%script

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
```
**Result:**
```
Thank you, Bob. The replacement for your smartphone case is on its way, and you will receive a return shipping label for the defective product. Is there anything else I can help you with?
```

```
%script

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
```
**Result:**
```
Thank you, Bob. I'm glad we could assist with the replacement of your smartphone case. If you have any other concerns in the future, feel free to reach out. Have a great day!
```

You may now proceed to the next lab.

## Learn More

* [OML Notebooks](https://docs.oracle.com/en/database/oracle/machine-learning/oml-notebooks/index.html)
* [Using Oracle Autonomous Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)
* [How to help AI models generate better natural language queries](https://blogs.oracle.com/datawarehousing/post/how-to-help-ai-models-generate-better-natural-language-queries-in-autonomous-database)

## Acknowledgements

* **Author:** Sarika Surampudi, Principal ting User Assistance Developer
* **Contributor:** Mark Hornick, Product Manager
<!--* **Last Updated By/Date:** Sarika Surampudi, August 2025
-->


Copyright (c) 2025 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
