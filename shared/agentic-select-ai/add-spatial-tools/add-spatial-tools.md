# Enhance the the Return Agent with store location  

## Introduction

This lab focuses on refining the solution of the previous labs to achieve a better customer experience by providing an option to drive to the closest store to the customer.  

In this lab, you’ll enhance the table `customers` with a complete address, add a new `stores` table containing the addresses of a few stores, and experience the more complete answers from the Agent.

Estimated Time: 35 minutes

### Objectives

In this lab, you will:

* Replace the `customers` table with a more complete address
* Create a new `stores` table with the store addresses
* Create new `find_local_pickup` function to identify the closest stores to a customer
* Create a new tools and add it to the Task.
* Run an end-to-end test and review the generated answers.

### Prerequisites

- This lab requires completion of Lab 1 and Lab 2 in the **Contents** menu on the left.

> Note: If you are independently using OML Notebook on your instance to run the code, append `%script` at the beginning for the codeblocks.

## Task 1: Enhance Customer table with precise addresses, and add Store tables

We'll enhance the `customers` table with additional details on each customer's street address. The address is then geocoded into a spatial geometry, so the agent can later calculate drive times to nearby stores.

1. Run the paragraph that creates `customers` table. The `UPDATE` statement at the end geocodes each address with `SDO_GCDR.ELOC_GEOCODE_AS_GEOM` and stores the result in the `geometry` column.

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
       zip          VARCHAR2(10),
       address      VARCHAR2(100)
    );

    INSERT INTO customers (customer_id, name, email, phone, state, zip, address) VALUES
    (1, 'Alice Thompson', 'alice.thompson@example.com','555-1234', 'NY', '12210', '104 Chestnut St, Albany NY, 12210'),
    (2, 'Bob Martinez',   'bob.martinez@example.com',  '555-2345', 'CA', '95842', '4825 Willowbrook Dr, Sacramento CA 95842'),
    (3, 'Carol Chen',     'carol.chen@example.com',    '555-3456', 'TX', '73301', '1623 Alston Ave, Fort Worth TX, 73301'),
    (4, 'David Johnson',  'david.johnson@example.com', '555-4567', 'IL', '61605', '807 S Warren St, Peoria IL, 61605'),
    (5, 'Eva Green',      'eva.green@example.com',     '555-5678', 'FL', '32164', '10 Pittwick Ln, Palm Coast FL, 32164'); 

    alter table customers add (geometry sdo_geometry);

    -- Geocode customer addresses into spatial geometries for drive-time calculations.
    update customers set geometry = sdo_gcdr.eloc_geocode_as_geom(address) ;
    </copy>
    ```

2. View the contents of the `customers` table with full address. 

    ```
    <copy>
    select * from customers;
    </copy>
    ```

3. Run the paragraph that creates `stores` table. Each store has a name and a location, stored as longitude and latitude. The stores are spread across the same cities as the customers, so each customer has at least one store nearby.

    ```
    <copy>
  
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE stores';
    EXCEPTION WHEN OTHERS THEN NULL; END;
    /
    CREATE TABLE stores (
        store_id  NUMBER(10) PRIMARY KEY,
        store_name VARCHAR2(30),   
        longitude NUMBER,
        latitude  NUMBER
    );
    /

    INSERT INTO stores VALUES
    (1,'Albany Downtown Mall',-73.8326, 42.6220),
    (2,'North Greenbush Plaza',-73.6918, 42.7284),
    (3,'Capital District Center',-73.9288, 42.6537),
    (4,'Hudson Valley Outlet',-73.8168, 42.4734),
    (5,'Catskill Commons',-73.7920, 42.2529),
    (6,'Folsom Mall',-121.2715, 38.7397),
    (7,'Sacramento River Center',-121.5564, 38.7071),
    (8,'Gold Country Plaza',-121.0800, 38.8400),
    (9,  'Fort Worth Stockyards Center', -97.3489, 32.7873),
    (10, 'West 7th Fort Worth Plaza',     -97.3652, 32.7528),
    (11, 'Peoria Riverfront Center',      -89.5889, 40.6936),
    (12, 'Northwoods Mall Peoria',        -89.6107, 40.7584),
    (13, 'Palm Coast Town Center',        -81.2078, 29.5554),
    (14, 'Flagler Beach Marketplace',     -81.1311, 29.4743);
    </copy>
    ```

4. View the stores table content.

    ```
    <copy>
    select * from stores;
    </copy>
    ```

## Task 2: Create the Local Pickup Function

You will create a SQL function a function that finds the closest store for local pickup and test it.

1. Create a function that finds the closest store for local pickup. The function works in three steps:

    * It builds a drive-time polygon around the customer's address with `SDO_GCDR.ELOC_DRIVE_TIME_POLYGON`. The polygon covers the area reachable within 45 minutes by car.
    * It counts the stores that fall inside that polygon.
    * It ranks those stores by route drive time with `SDO_GCDR.ELOC_ROUTE_TIME`, and returns the closest store and its drive time.

     ```
    <copy>
    
    CREATE OR REPLACE FUNCTION find_local_pickup (
       p_customer_name IN VARCHAR2,
       p_order_number  IN VARCHAR2
      ) RETURN CLOB IS
       isochrone       SDO_GEOMETRY;
       out_store_name  stores.store_name%TYPE;
       out_drive_time  NUMBER;
       out_nstores     NUMBER;
      BEGIN
      -- Step 1: Build a drive-time polygon around the customer's address.
      -- This polygon represents the geographic area reachable within 45 minutes by car.
      SELECT SDO_GCDR.ELOC_DRIVE_TIME_POLYGON(c.address, 'US', 45, 'minute', 'auto')
      INTO isochrone
      FROM customers c
      JOIN customer_order_status o
        ON o.customer_id = c.customer_id
      WHERE c.name = p_customer_name
        AND o.order_number = p_order_number
      FETCH FIRST 1 ROW ONLY;

      -- Step 2a: Find all stores whose locations fall inside that drive-time polygon.
      -- This counts how many candidate pickup stores are within the reachable area.
      SELECT COUNT(*)
      INTO out_nstores
      FROM stores s
      WHERE SDO_ANYINTERACT(SDO_GEOMETRY(s.longitude, s.latitude), isochrone) = 'TRUE';

      -- Step 2b: Rank the stores inside the polygon by actual route drive time.
      -- The nearest store is selected by ordering first by calculated travel time,
      -- then by store name as a deterministic tie-breaker.
      SELECT store_name, drive_time
      INTO out_store_name, out_drive_time
      FROM (
        SELECT s.store_name,
               ROUND(
                 SDO_GCDR.ELOC_ROUTE_TIME(
                   'fastest',
                   'minute',
                   c.geometry.sdo_point.X,
                   c.geometry.sdo_point.Y,
                   s.longitude,
                   s.latitude,
                   'auto'
                 ),
                 0
               ) AS drive_time
        FROM stores s
        JOIN customers c
          ON c.name = p_customer_name
        WHERE SDO_ANYINTERACT(SDO_GEOMETRY(s.longitude, s.latitude), isochrone) = 'TRUE'
        ORDER BY drive_time, s.store_name
      )
      WHERE ROWNUM = 1;

      RETURN 'There are ' || out_nstores ||
             ' stores nearby. The closest is ' || out_store_name ||
             ' with a drive time of ' || out_drive_time || ' minutes';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN 'No stores within drive time';
      WHEN OTHERS THEN
        RETURN 'Error: ' || SQLERRM;
    END;
    /
    </copy>
    ```

2. Test the function for a specific customer and order.

    ```
    <copy>
    SELECT find_local_pickup('David Johnson', 3928);
    </copy>
    ```

   **Typical Result expected:**

    ```
    There are 2 stores nearby. The closest is Peoria Riverfront Center with a drive time of 6 minutes
    ```

## Task 3: Create Tools to Find a Local Pickup

You'll create a tool that a task will use, which finds a local pickup option. Each tool is identified by a unique name and includes attributes that define its purpose, instruction logic, and metadata. You'll verify the existing tools by querying a corresponding view.

1. Create Find\_Local\_Pickup\_Tool. This tool uses the `find_local_pickup` function. The `tool_inputs` attribute describes each function parameter, so the agent knows which values to pass.

    ```
    <copy>
    
    BEGIN
      DBMS_CLOUD_AI_AGENT.drop_tool(tool_name => 'Find_Local_Pickup_Tool', force => TRUE); END;
    /

    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name => 'Find_Local_Pickup_Tool',
        description => 'Tool for finding the best local pickup option for a customer based on shortest drive time.',
        attributes => '{"instruction": "Never ask for customer number. This tool looks for local pickup options for a customers order. ' ||
                                      'Always ask for customer name and order number before using this tool. ' ||
                                      'The tool returns the number of nearby locations, the store with the shortest drive time, and the drive time to that store.",
                        "function" : "find_local_pickup",
                        "tool_inputs": [{"name":"p_customer_name",
                                        "mandatory": true,
                                        "description" : "customer name, for example David Johnson"},
                                        {"name":"p_order_number",
                                        "mandatory": true,
                                        "description" : "order number, for example 3928"} ]}'
      );
    END;
    /
    </copy>
    ```

2. Verify the Find\_Local\_Pickup\_Tool by querying `USER_AI_AGENT_TOOLS` view.

    ```
    <copy>
    select * from USER_AI_AGENT_TOOLS
    order by created desc
    </copy>
    ```

## Task 4: Change the task to handle the product return with local pickup options

We use a task to specify the instructions for performing actions using tools. Here, we update the Handle\_Product\_Return\_Task and describe the interaction with the customer and how to respond in various cases.

This update will use the Update\_Order\_Status\_Tool, Find\_Local\_Pickup\_Tool, and the implicit HUMAN\_TOOL.

Customers rarely give information in a fixed order. The instruction tells the agent to collect the customer name, order number, and return reason in any order, and to never ask for something the customer already provided. For any replacement, the agent calls Find\_Local\_Pickup\_Tool and reports only the store and drive time that the tool returns.

Update Handle\_Product\_Return\_Task.

  ```
  <copy>
  
  BEGIN DBMS_CLOUD_AI_AGENT.drop_task(task_name => 'Handle_Product_Return_Task', force => TRUE); END;
  /

BEGIN
  DBMS_CLOUD_AI_AGENT.create_task(
    task_name => 'Handle_Product_Return_Task',
    attributes => '{"instruction": "Process a product return request from a customer: {query}. ' ||
                  '1. Ask customer the reason for return: no longer needed, arrived too late, box broken, or defective. Then ask for the customer name and order number if they are not already provided.' ||
                  '2. If no longer needed: ' ||
                  '2.1 Inform customer to ship the product at their expense back to us. ' ||
                  '2.2 if you have the customer name and order number, update the order status to return_shipment_pending using Update_Order_Status_Tool, otherwise ask for the customer name and order number. ' ||
                  '3. If it arrived too late: ' ||
                  '3.1 Ask customer if they want a refund or replacement. ' ||
                  '3.2 If the customer wants a refund, confirm the customer name and order number, then mention the refund is being processed and update the order status to refund_completed using Update_Order_Status_Tool. ' ||
                  '3.3 If the customer wants a replacement, confirm the customer name and order number, then update the order status to replaced using Update_Order_Status_Tool. ' ||
                  '3.4 Always check for local pickup options using Find_Local_Pickup_Tool with the same customer name and order number. ' ||
                  '3.5 Tell the customer their local pickup option. ' ||
                  '4. If the product was defective or the box was broken: ' ||
                  '4.1 Ask customer if they want a replacement or a refund. ' ||
                  '4.2 If the customer wants a replacement, confirm the customer name and order number, then update the order status to replaced using Update_Order_Status_Tool. ' ||
                  '4.3 Always check for local pickup options using Find_Local_Pickup_Tool with the same customer name and order number. ' ||
                  '4.4 Do not use any store name or drive time that was not returned by Find_Local_Pickup_Tool. ' ||
                  '4.5 When a replacement is requested, you must call Find_Local_Pickup_Tool with the customer name and order number from the conversation, and never invent store and drive time not listed in the tool. ' ||
                  '4.6 Use the exact pickup result returned by Find_Local_Pickup_Tool. ' ||
                  '4.7 Do not invent or substitute store names, brands, addresses, counts, or drive times. ' ||
                  '4.5 Tell the customer their local pickup option and inform them they will receive a return shipping label for the defective or damaged product. ' ||
                  '4.6 If the customer wants a refund, inform customer to print out the return shipping label, return the product, and update the order status to refund using Update_Order_Status_Tool. ' ||
                  '5. After the completion of a return, replacement, or refund, ask if you can help with anything else. ' ||
                  'Use human tool when you need confirmation from user. And only give a final answer and end the task if the user does not need help with anything else.",
                   "tools": ["Update_Order_Status_Tool", "Find_Local_Pickup_Tool"]}'
  );
END;
/
  </copy>
  ```

## Task 5: Update the Agent Team

You'll define an agent team that uses the agent and tasks specified above. You specify agent-task pairs for defining a sequential workflow. If you have multiple agents or multiple tasks, these are specified within the JSON list. The same Agent can be specified multiple times with their associated tasks. In this scenario it is a single agent and task pair.

The `long_term_memory_length` attribute sets how many summaries of earlier task runs the team includes as context when a new run starts. The default is 30. Here, you set it to 3. This keeps details from earlier, unrelated returns, such as another customer's name, out of a new conversation.

Create the Return\_Agency\_Team.

```
<copy>

BEGIN DBMS_CLOUD_AI_AGENT.drop_team(team_name => 'Return_Agency_Team', force => TRUE); END;
/
BEGIN                                                                 
  DBMS_CLOUD_AI_AGENT.create_team(  
    team_name  => 'Return_Agency_Team',                                                            
    attributes => '{"agents": [{"name" : "Customer_Return_Agent", 
                                "task" : "Handle_Product_Return_Task"}],
                    "process": "sequential",
                    "long_term_memory_length": 3}');                                                                 
END;

</copy>
```

## Task 6: Interact with the Return Agency Agent

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

    **Typical Result expected:**

    ```
    RESPONSE
    Thank you for your return request. Could you please tell me the reason: no longer needed, arrived too late, box broken, or defective? Also, what's your full name and order number?

    ```

    ```
    <copy>
    select ai agent the item is defective
    </copy>
    ```

    **Typical Result expected:**

    ```
    RESPONSE
    Thank you for letting me know the smartphone case is defective. Would you like a replacement or a refund? Also, please provide your name and order number so I can assist further.
    ```

    ```
    <copy>
    select ai agent I will need a replacement
    </copy>
    ```

    **Typical Result expected:**

    ```
    RESPONSE
    Thank you for confirming you'd like a replacement for the defective smartphone case. To proceed, could you please provide your name and order number? Once I have those, I can update the status and check local pickup options for you.
    ```

    ```
    <copy>
    select ai agent I''m Bob Martinez and my order number is 7820
    </copy>
    ```

    **Typical Result expected:**

    ```
    RESPONSE
    Thank you, Bob Martinez. Your order 7820 has been updated for a replacement due to the defective item. The closest store for pickup is Folsom Mall, a 9-minute drive. Can I help with anything else?
    ```

    Because the customer asked for a replacement, the agent called Find\_Local\_Pickup\_Tool and reported the closest store and its drive time.

    >**Note:** LLM responses vary from run to run, and model to model. Your wording may differ from the results shown here.

To continue, you may try these prompts in the given sequence. The agent treats the smartphone stand as a new return, so it asks for the name, order number, and reason again. Because the reason is _no longer needed_, the agent does not offer a refund or replacement:

  a. _select ai agent Yes, I''d like to return a smartphone stand;_

  b. _select ai agent I no longer need it_

  c. _select ai agent I''m Bob Martinez with order number is 7820_

  d. _select ai agent No, I''m all set. Thanks_

You may now proceed to the next lab.

## Learn More

* [Blog: Geocoding API in Oracle Autonomous Database Serverless](https://blogs.oracle.com/database/new-in-database-geocoder-for-autonomous-database-shared)
* [Spatial Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/spatl/sdo_gcdr-package-geocoding.html)
* [OML Notebooks](https://docs.oracle.com/en/database/oracle/machine-learning/oml-notebooks/index.html)
* [DBMS\_CLOUD\_AI\_AGENT Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)
* [Using Oracle Autonomous AI Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)
* [Example of creating an OCI Gen AI Select AI Profile](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai-examples.html#GUID-BD10A668-42A6-4B44-BC77-FE5E5592DE27)
* [How to help AI models generate better natural language queries](https://blogs.oracle.com/datawarehousing/post/how-to-help-ai-models-generate-better-natural-language-queries-in-autonomous-database)

## Acknowledgements

* **Author:** Ramu Murakami Gutierrez, Senior Product Manager
* **Contributor:** Marcos Arancibia, Lead Principal Product Manager; David Lapp, Product Management Architect
* **Last Updated By/Date:** Marcos Arancibia, October 2026

Copyright (c) 2026 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
