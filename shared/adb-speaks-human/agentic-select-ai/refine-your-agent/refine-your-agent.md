# Refine Your Agent

## Introduction

This lab focuses on refining the solution of the previous lab to achieve a better customer experience. In this lab, you’ll make the return flow feel more personalized. After updating the order, the agent will compose a clear, polite confirmation email. But this has a problem, which we’ll address in the next lab.

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

You'll make the agent chatty and empathetic by refining the agent role.

1. Refine the customer agent by changing the role description.

```
%script

BEGIN DBMS_CLOUD_AI_AGENT.drop_agent('Customer_Return_Agent');
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
  DBMS_CLOUD_AI_AGENT.create_agent(
    'Customer_Return_Agent',
    '{"profile_name": "OCI_GENAI_GROK",
      "role": "You are a convivial and chatty experienced customer return agent who deals with customers return requests."}');
END;
```
2. Verify the change by querying the USER\_AI\_AGENTS view

```
select * from USER_AI_AGENTS;
```

## Task 2: Create a Task to Generate an Email Response

In this task, you will have the LLM produce a standard confirmation email using structured data from the product return. You’ll define a task with instructions on what to include as an email response.

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

## Task 3: Add the New Task to the Agent Team

You'll add the Generate\_Email\_Task to the Return Agency team and see that the team runs processes the return first and then generates the email.

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

You can start interacting with the refined Select AI agent team by using natural language prompt on the SQL command line. To do so, you first clear any previous conversation and then set the agent team for the current session.

1. Set the agent team in the current session.

```
EXEC DBMS_CLOUD_AI.clear_conversation_id;
EXEC DBMS_CLOUD_AI_AGENT.set_team(team_name  => 'Return_Agency_Team');
```

2. Interact with the Return Agency Team in a series of natural language prompts.

```
select ai agent Hello Sales Return Agent;
```
**Result:**
```
RESPONSE
Hello! I'm happy to assist with your return request. Could you please tell me the reason for the return? Is it because the product is no longer needed, arrived too late, the box is broken, or is it defective?
```

```
select ai agent I want to return a smartphone cord;
```

**Result:**
```
RESPONSE
Thanks for letting me know you're returning a smartphone cord. Could you please clarify the reason for the return? Is it because the product is no longer needed, arrived too late, the box is broken, or is it defective?
```

```
select ai agent The box was broken;
```
**Result:**
```
RESPONSE
I'm sorry to hear that the box for your smartphone cord was broken. Would you like a replacement or a refund for this item?
```

```
select ai agent I''ll take a refund;
```
**Result:**
```
RESPONSE
I'm happy to process your refund for the smartphone cord. Could you please confirm your name and order number so I can update the status and provide you with a return shipping label to send the product back?
```

```
select ai agent I''m Eva Green with order number 5019
```
**Result:**
```
RESPONSE
Thank you, Eva. Your refund has been processed. Please print out the return shipping label that will be sent to you shortly, and use it to send the smartphone cord back to us. Is there anything else I can help you with?
```
```
select ai agent No, not at the moment
```
**Result:**
```
RESPONSE                                                                                                                                                                                                                                                                                                                                                               
Subject: Return Confirmation for Order #5019 - Smartphone Cord

Dear Eva Green,

I hope this message finds you well. I'm writing to confirm the return of your smartphone cord from order number 5019. I understand that the box was broken, and I’m sorry for the inconvenience this has caused.

As per your request, a refund will be issued to the credit card on record. You should see the amount reflected in your account within the next 5-10 business days, depending on your bank’s processing time. Additionally, a return shipping label has been sent to you. Please use this label to send the smartphone cord back to us at your earliest convenience.

If you have any questions or need further assistance, don’t hesitate to reach out. We’re here to help!

Thank you for choosing us, and we hope to serve you again in the future.

Warm regards,  
[Your Name]  
Customer Return Agent  
[Company Name]    

```

This result relied on the LLM to generate a form letter using its own *creativity*. The specific content may differ from customer to customer as is typical for LLMs. To ensure we have a consistent form letter response, you will define a function that generates exactly the text you want in the next lab.

You may now proceed to the next lab.

## Learn More

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
