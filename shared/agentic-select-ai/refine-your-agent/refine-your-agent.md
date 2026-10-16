# Refine Your Agent

## Introduction

This lab focuses on refining the solution of the previous lab to achieve a better customer experience. In this lab, you’ll make the return flow feel more personalized. After updating the order, the agent will compose a clear, polite confirmation email. But this has a problem, which we’ll address in Lab 4.

Estimated Time: 25 minutes

### Objectives

In this lab, you will:

* Refine the Customer Agent persona and response style.
* Create a Generate Email task that produces a standard return-confirmation email.
* Add the new task to the Return Agency Team.
* Run an end-to-end test and review the generated email text.

### Prerequisites

- This lab requires completion of Lab 1 in the **Contents** menu on the left.

> Note: If you are independently using OML Notebook on your instance to run the code, append `%script` at the beginning for the codeblocks.

## Task 1: Refine the Role of the Customer Agent

You'll make the agent chatty and empathetic by refining the agent role.

1. Refine the customer agent by changing the role description.

    ```
    <copy>

     

    BEGIN DBMS_CLOUD_AI_AGENT.drop_agent(agent_name => 'Customer_Return_Agent', force => TRUE); END;
    /
    BEGIN
      DBMS_CLOUD_AI_AGENT.create_agent(
        'Customer_Return_Agent',
        '{"profile_name": "OCI_GENAI_AGENT",
          "role": "You are a convivial and chatty experienced customer return agent who deals with customers return requests."}');
    END;
        </copy>
      ```
2. Verify the change by querying the USER\_AI\_AGENTS view

    ```
    <copy>
    select * from USER_AI_AGENTS;
    </copy>
    ```

## Task 2: Create a Task to Generate an Email Response

In this task, you will have the LLM produce a standard confirmation email using structured data from the product return. You’ll define a task with instructions on what to include as an email response.

Create a `Generate_Email_Task`.

```
<copy>

 

BEGIN DBMS_CLOUD_AI_AGENT.drop_task(task_name => 'Generate_Email_Task', force => TRUE); END;
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
</copy>
```

## Task 3: Add the New Task to the Agent Team

You'll add the Generate\_Email\_Task to the Return Agency team and see that the team processes the return first and then generates the email.

Update the customer agent to include both the tasks.

```
<copy>
 

BEGIN DBMS_CLOUD_AI_AGENT.clear_team();
EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN DBMS_CLOUD_AI_AGENT.drop_team(team_name => 'Return_Agency_Team', force => TRUE); END;
/

BEGIN                                                                 
  DBMS_CLOUD_AI_AGENT.create_team(  
    team_name  => 'Return_Agency_Team',                                                
    attributes => '{"agents": [{"name" : "Customer_Return_Agent", "task" : "Handle_Product_Return_Task"},
                               {"name" : "Customer_Return_Agent", "task" : "Generate_Email_Task"}],
                    "process": "sequential", "long_term_memory_length": 3}');                                                                 
END;
</copy>
```

## Task 4: Interact with the Refined Agent - Part 1

You can start interacting with the refined Select AI agent team by using natural language prompt on the SQL paragraph. To do so, set the agent team for the current session.

1. Set the agent team in the current session.

    ```
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.set_team(team_name  => 'Return_Agency_Team');
    </copy>
    ```

2. Interact with the Return Agency Team in a series of natural language prompts.

    **Prompt:**

    ```
    <copy>
    select ai agent Hello Sales Return Agent;
    </copy>
    ```

    **Typical result expected:**

    ```
    RESPONSE
    Hello there! Welcome to our returns team—I'm your friendly customer return agent, ready to help make this process as smooth as possible. How can I assist you with your return today? 😊
    ```

    **Prompt:**

    ```
    <copy>
    select ai agent I want to return a smartphone cord;
    </copy>
    ```

    **Typical result expected:**

    ```
    RESPONSE
    Please provide your full name, order number, the exact item (smartphone cord details if any), and reason for return so I can prepare the return email.
    ```

    **Prompt:**

    ```
    <copy>
    select ai agent The box was broken;
    </copy>
    ```

    **Typical result expected:**

    ```
    RESPONSE
    Thanks for the reason (box was broken). To complete the return email, please also share your full name and order number.
    ```

    **Prompt:**

    ```
    <copy>
    select ai agent I''ll take a refund; 
    </copy>
    ```

    > Note: SQL requires escaping single quotes with '' (double single quotes).

    **Typical result expected:**

    ```
    RESPONSE
    Got it—refund for the smartphone cord due to broken box. Please provide your full name and order number to finalize the email.
    ```

    **Prompt:**

    ```
    <copy>
    select ai agent I''m Eva Green with order number 5019
    </copy>

    ```

    **Typical result expected:**

    ```
    RESPONSE
    Subject: Return Confirmation for Order $5019

    Dear Eva Green,

    Thank you for reaching out regarding your return request. We're sorry to hear about the issue with your order.

    This email confirms that we have processed your return for the smartphone cord from order number 5019. The reason for the return is that the box was broken.

    As requested, a refund will be issued to the credit card on record. Please allow 5-7 business days for the refund to appear on your statement.

    If you have any further questions, feel free to reply to this email. We're here to help!
  
    Best regards,  
    Your Customer Return Agent    
    ```

This result relied on the LLM to generate a form letter using its own *creativity*. The specific content may differ from customer to customer as is typical for LLMs. To ensure we have a consistent form letter response, you will define a function that generates exactly the text you want in Lab 4 "Define a function to populate a standard form email".

You may now proceed to the next lab.

## Learn More

* [OML Notebooks](https://docs.oracle.com/en/database/oracle/machine-learning/oml-notebooks/index.html)
* [Using Oracle Autonomous AI Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)
* [How to help AI models generate better natural language queries](https://blogs.oracle.com/datawarehousing/post/how-to-help-ai-models-generate-better-natural-language-queries-in-autonomous-database)

## Acknowledgements

* **Author:** Sarika Surampudi, Principal User Assistance Developer
* **Contributors:** Marcos Arancibia, Lead Principal Product Manager; Sherry LaMonica, Lead Principal Product Manager; Laura Zhao, Member of Technical Staff
* **Last Updated By/Date:** Marcos Arancibia, October 2026


Copyright (c) 2026 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
