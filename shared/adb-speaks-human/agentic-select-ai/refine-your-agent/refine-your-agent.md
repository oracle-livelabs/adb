# Refine Your Agent

## Introduction

This lab focuses on part two of the solution : Better Experience. In this lab, you’ll make the return flow feel personalized. After updating the order, the agent will compose a clear, polite confirmation email that could be sent to the customer.

Estimated Time: 15 minutes.

### Objectives

In this lab, you will:

* Refine the Customer Agent persona and response style.
* Create a Generate Email task that produces a standard return-confirmation email.
* Add the new task to the Return Agency Team.
* Run an end-to-end test and review the generated email text.

### Prerequisites

- This lab requires completion of the first three labs in the **Contents** menu on the left.


## Task 1: Refine the Role of the Customer Agent

You'll make the agent concise, chatty, empathetic, and consistent by defining a clear role.

1. Refine the customer agent by redefining the role.

```
%script

BEGIN DBMS_CLOUD_AI_AGENT.drop_agent('Customer_Return_Agent');
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
  DBMS_CLOUD_AI_AGENT.create_agent(
    'Customer_Return_Agent',
    '{"profile_name": "GOOGLE",
      "role": "You are a convivial and chatty experienced customer return agent who deals with customers return requests."}');
END;
```
2. Verify the change by querying the USER\_AI\_AGENTS view

```
select * from USER_AI_AGENTS;
```

## Task 2: Create a Task to Generate an Email Response

You will produce a standard confirmation email using structured data from the return. You’ll define a task with instructions on what to include as an email response.

Create a Generate\_Email\_Task.

```
%script

BEGIN DBMS_CLOUD_AI_AGENT.drop_task('Generate_Email_Task');
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
  DBMS_CLOUD_AI_AGENT.create_task(
    task_name => 'Generate_Email_Task',
    attributes => '{"instruction": "Use the customer information and product details to generate an email in a professional format. The email should:' || 
                    '1. Include a greeting to the customer by name' || 
                    '2. Specify the item being returned, the order number, and the reason for the return' ||
                    '3. If it is a refund, state the refund will be issued to the credit card on record.' ||
                    '4. If it is a replacement, state that the replacement will be shipped in 3-5 business days."}'
  );
END;
```

## Task 3: Add New Task to the Agent Team

You'll add the Generate\_Email\_Task to the Return Agency team and ensure the team runs the return update first and then generates the email.

Update the customer agent to include both the tasks.

```
%script

BEGIN DBMS_CLOUD_AI_AGENT.drop_team('Return_Agency_Team');
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
  DBMS_CLOUD_AI_AGENT.create_team(
    team_name  => 'Return_Agency_Team',
    attributes => '{"agents": [{"name" : "Customer_Return_Agent", "task" : "Handle_Product_Return_Task"},
                               {"name" : "Customer_Return_Agent", "task" : "Generate_Email_Task"}],
                    "process": "sequential"}');
END;
```

## Task 4: Interact with the Refined Agent - Part 1

You can start interacting with the refined Select AI agent team by using a natural language prompt on the SQL command line. To do so, you must set the agent team for the current session.

1. Set the agent team in the current session.

```
EXEC DBMS_CLOUD_AI_AGENT.set_team(team_name  => 'Return_Agency_Team');
```

2. Interact with the Return Agency in a series of natural language prompts.

```
select ai agent I want to return a smartphone cord;
```
**Result:**
```
RESPONSE
What is the reason for returning the smartphone cord? Is it no longer needed, arrived too late, the box was broken, or is the product defective?
```

```
select ai agent The box was broken;
```

**Result:**
```
RESPONSE
Since the box was broken, would you prefer a replacement or a refund for the smartphone cord?
```

```
select ai agent I''ll take a refund; 
```
**Result:**
```
RESPONSE
Could you please provide your name and order number?
```

```
select ai agent Eva Green with order number 5019;
```
**Result:**
```
RESPONSE                                               
Is there anything else I can assist you with today?
```

```
select ai agent No, I''m all set
```


You may now proceed to the next lab.

## Learn More

* [OML Notebooks](https://docs.oracle.com/en/database/oracle/machine-learning/oml-notebooks/index.html)
* [Using Oracle Autonomous Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)
* [How to help AI models generate better natural language queries](https://blogs.oracle.com/datawarehousing/post/how-to-help-ai-models-generate-better-natural-language-queries-in-autonomous-database)

## Acknowledgements

* **Author:** Sarika Surampudi, Principal User Assistance Developer
* **Contributor:** Mark Hornick, Product Manager
<!--* **Last Updated By/Date:** Sarika Surampudi, August 2025
-->


Copyright (c) 2025 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
