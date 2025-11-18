# Create a Function and a Tool to Generate a Standard Email

## Introduction

This lab focuses on generating a consistent email form letter. In this lab, you’ll add a standardized email function so the agent can present a consistent confirmation message after a return is recorded.

Estimated Time: 30 minutes.

### Objectives

In this lab, you will:

* Write and test a PL/SQL function that composes a return-confirmation email.
* Create a customer email tool that uses the function
* Create a task over this tool with clear instructions.
* Update the agent that calls the email task to produce a ready-to-send email preview.
* Update the agent team to include the new task.
* Run an end-to-end interaction and capture the email preview.

### Prerequisites

- This lab requires completion of all the previous labs in the **Contents** menu on the left.


## Task 1: Create a Function to Generate an Email

You'll create a function to return a confirmation email as a `CLOB` and test the output.

1. Create the `build_return_email` function.

    ```
    <copy>
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
    </copy>
    ```
2. Test the `build_return_email` function and verify the output.

    ```
    <copy>%script
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
        END;</copy>
    ```


    **Result:**

    ```

    {"subject":"Your Return Request for Order 1234 - smartphone charging cord","body":"Dear Alice Thompson,\n\nThank you for contacting us regarding your return request!\n\nThis email confirms that we have received your request to return the following item from order number 1234:\n\nItem: smartphone charging cord\nReason for Return: Item not compatible with my phone\n\nYour replacement for the smartphone charging cord will be shipped within 3-5 business days. You will receive a separate email with tracking information once your replacement has shipped.\n\nPlease let me know if you have any questions or if there is anything else I can assist you with.\n\nThank you, and have a great day!\n"}

    ```

>**NOTE**: The result is provided in JSON format and the result string includes `\n` for returns. Your application code can extract the subject and body and send using an email tool. Using the email tool is left as an unscripted exercise.

## Task 2: Create an Email Tool

You’ll create an email tool with clear instructions on what the tool should do.

Create a build\_email\_tool that specifies the build\_return\_email function.

```
<copy>
%script

BEGIN DBMS_CLOUD_AI_AGENT.drop_tool('build_email_tool');
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name => 'build_email_tool',
        attributes => '{"instruction": "This tool constructs an email string using as input details from the customer interaction as to the product they want to return or get a refund.",
                        "function" : "build_return_email",
                        "tool_inputs" : [{"name":"p_email_type",
                                        "description" : "Only supported value is ''refund'' and ''replacement'' "}]}',
        description => 'Tool for updating customer order status in database table.'
    );
END;</copy>
```

## Task 3: Create an Email Task

You'll create an email task and add the build\_email\_tool to the task. The task gathers fields from the attributes, calls the tool, and returns the email text to review.

Create a Build\_Email\_Task.

```
<copy>%script
BEGIN DBMS_CLOUD_AI_AGENT.drop_task('Handle_Product_Return_Task');
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
DBMS_CLOUD_AI_AGENT.create_task(
    task_name => 'Handle_Product_Return_Task',
    attributes => '{"instruction": "Process a product return request from a customer:{query} ' || 
                    '1. Ask customer the reason for return (no longer needed, arrived too late, box broken, or defective) ' || 
                    '2. If no longer needed:' ||
                    '   a. Inform customer to ship the product at their expense back to us.' ||
                    '   b. Update the order status to return_shipment_pending using Update_Order_Status_Tool.' ||
                    '3. If it arrived too late:' ||
                    '   a. Ask customer if they want a refund.' ||
                    '   b. If the customer wants a refund, then confirm refund processed and update the order status to refund_completed ' || 
                    '4. If the product was defective or the box broken:' ||
                    '   a. Ask customer if they want a replacement or a refund' ||
                    '   b. If a replacement, inform customer replacement is on its way and they will receive a return shipping label for the defective product, then update the order status to replaced' ||
                    '   c. If a refund, inform customer to print out the return shipping label for the defective product, return the product, and update the order status to refund. ' ||
                    '5. Use Build_Email_Tool to generate a confirmation email for the return/refund request. Display the email to customer and ask them to confirm if the information in email is correct' ||
                    '6. After the completion of a return or refund, ask if you can help with anything else. Say a friendly goodbye if user does not need help on anything else",
                    "tools": ["Update_Order_Status_Tool", "Build_Email_Tool"]}'
);
END;</copy>
```

## Task 4: Update the Agent Team

Add the new task into your agent team, which now includes the email generation tool as part of the `Handle_Product_Return_Task`.

Update the Return\_Agency\_Team.

```
<copy>%script

BEGIN DBMS_CLOUD_AI_AGENT.drop_team('Return_Agency_Team');
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN                                                                 
  DBMS_CLOUD_AI_AGENT.create_team(  
    team_name  => 'Return_Agency_Team',                                                            
    attributes => '{"agents": [{"name" : "Customer_Return_Agent", "task" : "Handle_Product_Return_Task"}],
                    "process": "sequential"}');                                                                 
END;</copy>
```

## Task 5: Interact with the Refined Agent - Part 2
You can start interacting with the refined Select AI agent team by using natural language prompt on the SQL command line. To do so, you must set the agent team for the current session.

1. Set the agent team in the current session.

    ```
    <copy>%script

    EXEC DBMS_CLOUD_AI.clear_conversation_id;

    EXEC DBMS_CLOUD_AI_AGENT.set_team(team_name  => 'Return_Agency_Team');</copy>
    
    ```
2. Interact with Return Agency in a series of natural language prompts.

    ```
    <copy>select ai agent I want to return a smartphone backup storage</copy>
    ```

    **Result:**

    ```
    RESPONSE
    Could you please tell me the reason for returning the smartphone backup storage? Is it no longer needed, did it arrive too late, is the box broken, or is the product defective?
    ```

    ```
    <copy>select ai agent It arrived too late</copy>
    ```
**Result:**
    ```
    RESPONSE
    I'm sorry to hear that the smartphone backup storage arrived too late. Would you like a refund for this item?
    ```

    ```
    <copy>select ai agent Yes;</copy>
    ```
**Result:**
    ```
    RESPONSE
    Could you please provide me with your full name and the order number for the smartphone backup storage so I can process the refund?
    ```

    ```
    <copy>select ai agent Carol Chen order number 7635;</copy>
    ```
**Result:**
    ```
    RESPONSE                                                                                                                               
    Here is the confirmation email for your refund request:

    Subject: Your Return Request for Order 7635 - smartphone backup storage
    Body:
    Dear Carol Chen,

    Thank you for contacting us regarding your return request!

    This email confirms that we have received your request to return the following item from order number 7635:

    Item: smartphone backup storage
    Reason for Return: arrived too late

    A full refund will be issued to the credit card on file. Please allow 7-10 business days for the refund to reflect in your account.

    Please let me know if you have any questions or if there is anything else I can assist you with.

    Thank you, and have a great day!

    Is all the information in this email correct? If not, please let me know what needs to be updated.

    ```

    ```
    <copy>select ai agent yes it is correct</copy>
    ```
**Result:**
    ```
    RESPONSE
    I'm glad everything looks good with the email confirmation. Is there anything else I can help you with today?
    ```

    ```
    <copy>select ai agent No, thank you, nothing else;</copy>
    ```
**Result:**
    ```
    RESPONSE
    I'm happy to have assisted you with the return process, Carol. If you think of anything else in the future, don't hesitate to reach out. Have a wonderful day! Goodbye!
    ```

You may now proceed to the next lab.

## Learn More

* [Select AI Agents](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai-agents1.html)
* [Select AI Agent Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)
* [OML Notebooks](https://docs.oracle.com/en/database/oracle/machine-learning/oml-notebooks/index.html)
* [Using Oracle Autonomous Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)
* [How to help AI models generate better natural language queries](https://blogs.oracle.com/datawarehousing/post/how-to-help-ai-models-generate-better-natural-language-queries-in-autonomous-database)

## Acknowledgements

* **Author:** Sarika Surampudi, Principal User Assistance Developer
* **Contributor:** Mark Hornick, Product Manager; Laura Zhao, Member of Technical Staff
<!--* **Last Updated By/Date:** Sarika Surampudi, August 2025
-->


Copyright (c) 2025 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
