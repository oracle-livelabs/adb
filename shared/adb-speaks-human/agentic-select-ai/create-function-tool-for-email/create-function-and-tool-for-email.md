# Create a Function and a Tool to Generate a Standard Email

## Introduction

This lab focuses on part two of the solution : Better Experience - confirmation email preview. In this lab, you’ll add a standard reusable email component so the agent can present a confirmation message after a return is recorded.

Estimated Time: 30 minutes.

### Objectives

In this lab, you will:

* Write and a PL/SQL function that composes a return-confirmation email.
* Register an email task with clear instructions.
* Create an agent that calls the email task to produce a ready-to-send email preview.
* Update the agent team to include the new task.
* Run an end-to-end interaction and capture the email preview.

### Prerequisites

- This lab requires completion of the first three labs in the **Contents** menu on the left.


## Task 1: Create a Function to Generate an Email

You'll create a function to return a confirmation email as a `CLOB` and test the output.

1. Create the build\_return\_email function.

```
  %script

CREATE OR REPLACE FUNCTION build_return_email (
    p_order_number      IN  VARCHAR2,
    p_item_name         IN  VARCHAR2,
    p_customer_name     IN  VARCHAR2,
    p_reason_for_return IN  VARCHAR2,
    p_email_type        IN  VARCHAR2   -- 'refund' or 'replacement'
) RETURN CLOB IS
    l_subject VARCHAR2(4000);
    l_body    CLOB;
    l_nl      CONSTANT VARCHAR2(2) := CHR(10);
    l_type    VARCHAR2(20) := LOWER(TRIM(p_email_type));
    l_json    CLOB;
BEGIN
    IF l_type NOT IN ('refund', 'replacement') THEN
        RAISE_APPLICATION_ERROR(-20001,
            'email_type must be ''refund'' or ''replacement''');
    END IF;

    l_subject := 'Your Return Request for Order ' || p_order_number ||
                 ' - ' || p_item_name;

    l_body := 'Dear ' || p_customer_name || ',' || l_nl || l_nl ||
              'Thank you for contacting us regarding your return request!' || l_nl || l_nl ||
              'This email confirms that we have received your request to return the following item from order number ' ||
              p_order_number || ':' || l_nl || l_nl ||
              'Item: ' || p_item_name || l_nl ||
              'Reason for Return: ' || p_reason_for_return || l_nl || l_nl;

    IF l_type = 'refund' THEN
        l_body := l_body ||
          'A full refund will be issued to the credit card on file. ' ||
          'Please allow 7-10 business days for the refund to reflect in your account.' || l_nl || l_nl;
    ELSE
        l_body := l_body ||
          'Your replacement for the ' || p_item_name || ' will be shipped within 3-5 business days. ' ||
          'You will receive a separate email with tracking information once your replacement has shipped.' || l_nl || l_nl;
    END IF;

    l_body := l_body ||
              'Please let me know if you have any questions or if there is anything else I can assist you with.' || l_nl || l_nl ||
              'Thank you, and have a great day!' || l_nl;

    -- Build JSON in PL/SQL to avoid RETURNING clause issues
    DECLARE
        jo JSON_OBJECT_T := JSON_OBJECT_T();
    BEGIN
        jo.put('subject', l_subject);
        jo.put('body',    l_body);
        l_json := TO_CLOB(jo.to_string);
    END;

    RETURN l_json;
END;
```
2. Test the build\_return\_email function and verify the output.

```
%script

DECLARE
    v_json CLOB;
BEGIN
    v_json := build_return_email(
        p_order_number      => '1234',
        p_item_name         => 'smartphone charging cord',
        p_customer_name     => 'Alice Thompson',
        p_reason_for_return => 'Item not compatible with my phone',
        p_email_type        => 'replacement'
    );

    DBMS_OUTPUT.PUT_LINE(v_json);
END;
```
**Result:**
```
{"subject":"Your Return Request for Order 1234 - smartphone charging cord","body":"Dear Alice Thompson,\n\nThank you for contacting us regarding your return request!\n\nThis email confirms that we have received your request to return the following item from order number 1234:\n\nItem: smartphone charging cord\nReason for Return: Item not compatible with my phone\n\nYour replacement for the smartphone charging cord will be shipped within 3-5 business days. You will receive a separate email with tracking information once your replacement has shipped.\n\nPlease let me know if you have any questions or if there is anything else I can assist you with.\n\nThank you, and have a great day!\n"}
```
## Task 2: Create an Email Tool

You’ll create an email tool with clear instructions on what the tool should do and update the database with the order status and an email confirmation.

Create a build\_email\_tool and include the build\_return\_email function.

```
%script

BEGIN DBMS_CLOUD_AI_AGENT.drop_tool('build_email_tool');
EXCEPTION WHEN OTHERS THEN NULL; END;
/
 BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name => 'build_email_tool',
        attributes => '{"instruction": "This tool constructs an email string using as input details from the customer interaction as to the product they want to return or get a refund.",
                        "function" : "build_return_email"}',
        description => 'Tool for updating customer order status in database table.'
    );
END;
```

## Task 3: Create an Email Task

You'll create an email task and add the build\_email\_tool to the task. The task gathers fields from the attributes, calls the tool, to return a clean email preview.

1. Create a Build\_Email\_Task.

```
%script

BEGIN DBMS_CLOUD_AI_AGENT.drop_task('Build_Email_Task');
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
  DBMS_CLOUD_AI_AGENT.create_task(
    task_name => 'Build_Email_Task',
    attributes => '{"instruction": "Use the customer information and product details to build an email using the tool.",
                    "tools": "build_email_tool"}'
  );
END;
```

## Task 4: Update the Agent Team

Add the new task into your agent team and ensure the team runs return update first and then generate an email.

Update the Return\_Agency\_Team.

```
%script

BEGIN DBMS_CLOUD_AI_AGENT.drop_team('Return_Agency_Team');
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN                                                                 
  DBMS_CLOUD_AI_AGENT.create_team(  
    team_name  => 'Return_Agency_Team',                                                            
    attributes => '{"agents": [{"name" : "Customer_Return_Agent", "task" : "Handle_Product_Return_Task"},
                               {"name" : "Customer_Return_Agent", "task" : "Build_Email_Task"}],
                    "process": "sequential"}');                                                                 
END;
```
## Task 5: Interact with the Refined Agent - Part 2
You can start interacting with the refined Select AI agent team by using a natural language prompt on the SQL command line. To do so, you must set the agent team for the current session.

1. Set the agent team in the current session.

```
%script

EXEC DBMS_CLOUD_AI_AGENT.set_team(team_name  => 'Return_Agency_Team'); 
```
2. Interact with Return Agency in a series of natural language prompts.

```
select ai agent I want to return a smartphone backup storage;
```

**Result:**
```
RESPONSE
What is the reason for your return? Is it because you no longer need it, it arrived too late, the box was broken, or it was defective?
```

```
select ai agent It arrived too late;
```
**Result:**
```
RESPONSE
Do you want a refund for the smartphone backup storage?
```

```
select ai agent Yes;
```
**Result:**
```
RESPONSE
Could you please provide your name and order number so I can process the refund?
```

```
select ai agent Carol Chen order number 7635;
```
**Result:**
  ```
  Is there anything else I can help you with today?
  ```

  ```
  select ai agent No, nothing else;
  ```


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
