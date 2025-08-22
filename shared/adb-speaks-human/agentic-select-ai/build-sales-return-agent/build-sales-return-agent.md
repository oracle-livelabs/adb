# Build a Sales Return Agent

## Introduction

In this lab, you’ll turn a common support flow, returning a purchased item, into an agentic workflow inside Oracle Autonomous Database using Select AI. The agent will converse with a customer, collect the reason for return, and run an update to the order record. You’ll then group the agent into a small team so it can run end‑to‑end with one call.

Estimated Time: 30 minutes.

### Objectives

In this lab, you will:

* Create a sample customer data and create a function to update the order status.
* Register a tool that updates return status in the database.
* Create a task that coordinates the return action.
* Define a Customer Agent that collects details and calls the task.
* Assemble a Return Agency Team and run it using natural language prompt.
* Use DBMS\_CLOUD\_AI\_AGENT.RUN\_TEAM function to run a multi‑step interaction.

### Prerequisites

- This lab requires completion of the first two labs in the **Contents** menu on the left.
- Typical grants to run DBMS\_CLOUD\_AI\_AGENT Package are (run as ADMIN once):
```
GRANT EXECUTE ON DBMS_CLOUD_AI TO <user>;
GRANT EXECUTE ON DBMS_CLOUD_AI_AGENT TO <user>;
```

## Task 1: Create a Customer Table

You'll create a sample table for the scenario.

1. Create a customer table.

```
%script

BEGIN EXECUTE IMMEDIATE 'DROP TABLE customer';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
CREATE TABLE customer (
    customer_id  NUMBER(10) PRIMARY KEY,
    name         VARCHAR2(100),
    email        VARCHAR2(100),
    phone        VARCHAR2(20),
    state        VARCHAR2(2),
    zip          VARCHAR2(10)
);

INSERT INTO customer (customer_id, name, email, phone, state, zip) VALUES
(1, 'Alice Thompson', 'alice.thompson@example.com', '555-1234', 'NY', '10001'),
(2, 'Bob Martinez', 'bob.martinez@example.com', '555-2345', 'CA', '94105'),
(3, 'Carol Chen', 'carol.chen@example.com', '555-3456', 'TX', '73301'),
(4, 'David Johnson', 'david.johnson@example.com', '555-4567', 'IL', '60601'),
(5, 'Eva Green', 'eva.green@example.com', '555-5678', 'FL', '33101');
```
2. View the contents of the table.

```
select * from customer;
```
3. Create a customer order return status table and insert the sample data.

```
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
```
4. View the order status table you just created.

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

You'll create a tool that an agent can use during task processing. Each tool is identified by a unique name and includes attributes that define its purpose, implementation logic, and metadata. You'll verify the tool by querying a corresponding view.

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
2. Verify the Update\_Order\_Status\_Tool by querying USER\_AI\_AGENT\_TOOLS view.

```
select * from USER_AI_AGENT_TOOLS
order by created desc
```

## Task 4: Create a Task to Handle the Product Return

You'll define a task that a Select AI agent can include in its reasoning process. Each task has a unique name and a set of attributes that specify the agent’s behavior when planning and performing the task. In this scenario, you'll describe the interaction with the customer and how to respond in various cases.

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
                    "tools": ["HUMAN_TOOL","Update_Order_Status_Tool"]}'
  );
END;
```

## Task 5: Define Customer Agent

You'll create an agent to register a new AI agent in the Select AI Agent framework. This procedure enables you to configure the agent’s behavior and operational context for Select AI actions.

Create the Customer\_Return\_Agent.

```
%script

BEGIN DBMS_CLOUD_AI_AGENT.drop_agent('Customer_Return_Agent');
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
  DBMS_CLOUD_AI_AGENT.create_agent(
    agent_name => 'Customer_Return_Agent',
    attributes => '{"profile_name": "GOOGLE",
                    "role": "You are an experienced customer return agent who deals with customers return requests."}');
END;
```

## Task 6: Create the Agent Team

You'll define a team of AI agents that work together to accomplish tasks. You specify agents and their associated tasks, along with how the tasks should be processed. In this scenario it is a single agent.

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

## Task 7: Interact with the Return Agency Agent

You can start interacting with the Select AI agent team by using a natural language prompt on the SQL command line. To do so, you must set the agent team for the current session. Prefix your prompt with `Select AI agent`. In this scenario, the agent team interacts with you in a natural language, the team should confirm the fields, call the tool, and summarize the change.
Let's test it:

1. Set the agent team in the current session.

```
EXEC DBMS_CLOUD_AI_AGENT.set_team(team_name  => 'Return_Agency_Team');
```

2. Interact with the Return Agency in a series of natural language prompts.

```
select ai agent I''m Bob Martinez and my order number is 7820 and I''d like to return a smartphone stand;
```
**Result:**
```
RESPONSE
Thank you, Bob. And what is the reason for your return? Please choose from the following options: no longer needed, arrived too late, box broken, or defective.
```

```
select ai agent I no longer need it
```

**Result:**
```
RESPONSE
Thank you, Bob. Since you no longer need the smartphone stand, please ship the product back to us at your expense. Once we receive the returned item, we will process it. To confirm, your name is Bob Martinez and your order number is 7820?
```

```
select ai agent yes
```
**Result:**
```
RESPONSE
Is there anything else I can help you with today?
```

```
select ai agent No, I''m all set. Thanks
```
**Result:**
```
RESPONSE
Okay, Bob. If you have any other questions in the future, please don''t hesitate to contact us. Have a great day!
```

## Task 8: Use DBMS_CLOUD_AI_AGENT.RUN_TEAM

You'll use the DBMS\_CLOUD\_AI\_AGENT.RUN\_TEAM function to run the agent team and interact with the Return Agency team.

1. Call the DBMS\_CLOUD\_AI\_AGENT.RUN\_TEAM function.

```
%script

DECLARE
  v_response VARCHAR2(4000);
BEGIN
  v_response :=  DBMS_CLOUD_AI_AGENT.RUN_TEAM(
    team_name => 'Return_Agency_Team',
    user_prompt => 'I want to return a smartphone case',
    params => NULL
  );
  DBMS_OUTPUT.PUT_LINE(v_response);
END;
```
**Result:**
```
What is the reason for returning the smartphone case? (no longer needed, arrived too late, box broken, or defective)
```

2. Interact with the Return Agency team in a series of prompts provided within the function.

```
%script

DECLARE
  v_response VARCHAR2(4000);
BEGIN
  v_response :=  DBMS_CLOUD_AI_AGENT.RUN_TEAM(
    team_name => 'Return_Agency_Team',
    user_prompt => 'the item is defective',
    params => NULL
  );
  DBMS_OUTPUT.PUT_LINE(v_response);
END;
```
**Result:**
```
Would you like a replacement or a refund for the defective smartphone case?
```

```
%script

DECLARE
  v_response VARCHAR2(4000);
BEGIN
  v_response :=  DBMS_CLOUD_AI_AGENT.RUN_TEAM(
    team_name => 'Return_Agency_Team',
    user_prompt => 'I''d like a replacement',
    params => NULL
  );
  DBMS_OUTPUT.PUT_LINE(v_response);
END;
```
**Result:**
```
Great! A replacement is on its way, and you will receive a return shipping label for the defective product. Can you please provide your name and order number so I can update the order status?
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
