# Introduce a RAG Tool for Alternate Product Recommendation

## Introduction

In this lab you’ll enrich the return flow with RAG (Retrieval Augmented Generation). After recording a return, the agent can recommend alternative products based on your prompts from content indexed in Object Storage, and present a standard confirmation email. You’ll set up an AI Profile for RAG, provide Object Storage, build a vector index, and call a RAG tool into your agent team.

### Overview of Important Concepts
Let's review some of the important concepts that you should know.

### **Use AI profiles to access your LLM**

An AI profile captures the properties of your LLM provider plus the tables and views you want to enable for natural language queries. You can create multiple profiles (For example, for different providers), although only one is active for a given session or a particular call.

### **Create an AI Profile for RAG**

You can have multiple profiles where each one is pointing to different models or enabling different tables and views.

>**Note:** In this workshop, we are using OCI Generative AI.

To get started, you'll need to create a profile using the **`DBMS_CLOUD_AI.CREATE_PROFILE`** PL/SQL package that describes your _LLM provider_ and _the metadata such as schemas, tables, views, and so on that can be used for natural language queries_. You can have multiple profiles where each one is pointing to different models. For additional information, see the [CREATE_PROFILE procedure](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-package.html#GUID-D51B04DE-233B-48A2-BBFA-3AAB18D8C35C) documentation.

### **Ask Natural Language Questions**

You can ask questions using **`SELECT AI`**. **`AI`** is a special keyword in the `SELECT` statement that tells Autonomous Database that the subsequent text will be either an action or the natural language question.

Estimated Time: 20 minutes.

### Objectives

In this lab, you will:

* Create an AI Profile for RAG.
* Create credentials for Object Storage access.
* Build a vector index over your documents in Object Storage.
* Set the RAG profile for the session.
* Use natural-language prompts to get product suggestions (RAG in action).
* Create a RAG tool the agent can call for recommendations.
* Update the return task to include suggestions + email preview.
* Update the team and interact with the refined agent.

### Prerequisites

- This lab requires completion of the first two labs in the **Contents** menu on the left.
- Grants - run once as ADMIN:
```
GRANT EXECUTE ON DBMS_CLOUD_AI TO <user>;
GRANT EXECUTE ON DBMS_CLOUD_PIPELINE  TO <user>;
ALTER USER ADB_USER QUOTA 1T ON <tablespace_name>; 
```
- Create a credential for your AI provider.
```
EXEC 
DBMS_CLOUD.CREATE_CREDENTIAL(
credential_name   => 'OCI_CRED', 
username          =>  '<username>', 
password          =>  '<your_oci_password>');
```

## Task 1: Create a profile for RAG
Define an AI Profile that has your LLM and database objects and is ready to use RAG once a vector index exists.

1. Create an AI profile for RAG usage.
```
BEGIN  
  DBMS_CLOUD_AI.drop_profile(profile_name => 'SALES_AGENT_RAG_PROFILE');
 
  -- default LLM: meta.llama-3.1-70b-instruct
  -- default transformer: cohere.embed-english-v3.0

  DBMS_CLOUD_AI.create_profile(                                              
      profile_name => 'SALES_AGENT_RAG_PROFILE',                                                                 
      attributes   => '{"provider": "oci",   
                        "credential_name": "OCI_CRED",          
                        "vector_index_name": "SALES_AGENT_VECTOR_INDEX"}');  
END;
```

2. Create credentials to access Object Storage.
```
%script

begin
  dbms_cloud.drop_credential(credential_name => 'OCI_SALES_CRED');
  EXCEPTION WHEN OTHERS THEN NULL; END;
end;
/
BEGIN
  DBMS_CLOUD.create_credential(
    credential_name => 'OCI_SALES_CRED',
    user_ocid       => 'ocid1.user.oc1..aaaaaa...',
    tenancy_ocid    => 'ocid1.tenancy.oc1..aaaaaaaa...',
    private_key     => '<your_oci_private_key>',
    fingerprint     => '<your_fingerprint>'
  );
END;
```
3. Build a vector index over product docs stored in Object Storage. The index is used by RAG.
```
%script
BEGIN
  DBMS_CLOUD_AI.DROP_VECTOR_INDEX(
   index_name  => 'SALES_AGENT_VECTOR_INDEX',
   include_data => TRUE);
  EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
  DBMS_CLOUD_AI.CREATE_VECTOR_INDEX(
    index_name  => 'SALES_AGENT_VECTOR_INDEX',
    attributes  => '{"vector_db_provider": "oracle",
                     "location": "https://adwc4pm.objectstorage.us-ashburn-1.oci.customer-oci.com/p/b9UsLs4CwZi9iorADMTK9c-ziXkhmME6m7kcdJ9ypjqFTzzZmHSLqNve0t_Vi1du/n/adwc4pm/b/oaiw25-sales-agent-rag-documents/o/",
                     "object_storage_credential_name": "OCI_SALES_CRED",
                     "profile_name": "SALES_AGENT_RAG_PROFILE", 
                     "vector_distance_metric": "cosine",
                     "chunk_overlap":50,
                     "chunk_size":450}',
      description => 'Vector index for sales return agent scenario');
END;
```
4. Set the AI profile in the current session.
```
<copy>
%script
EXEC DBMS_CLOUD_AI.SET_PROFILE(profile_name => 'SALES_AGENT_RAG_PROFILE');
</copy>
```
5. Use natural language prompts to check RAG. Ask for alternate product recommendations.
```
select ai narrate what are alternatives for the smartphone case
```
**Result:**
```
RESPONSE
Alternatives for smartphone cases include TitanGuard Pro, ClearEdge Ultra, and ArmorFlex Shield. TitanGuard Pro is a military-grade case with reinforced corners and dust-proof port covers, designed for rugged outdoor use. ClearEdge Ultra is a crystal-clear slim case made with hybrid polymer to resist scratches and yellowing, showcasing the phone's design while offering light protection. ArmorFlex Shield is built with a shock-absorbing TPU frame and scratch-resistant polycarbonate back, designed for maximum impact protection without adding unnecessary bulk.

Sources:
  - Smartphone-R-US_Catalog.pdf (https://adwc4pm.objectstorage.us-ashburn-1.oci.customer-oci.com/p/b9UsLs4CwZi9iorADMTK9c-ziXkhmME6m7kcdJ9ypjqFTzzZmHSLqNve0t_Vi1du/n/adwc4pm/b/oaiw25-sales-agent-rag-documents/o/Smartphone-R-US_Catalog.pdf)
  - ABC_Smartphone_Supply_Catalog.pdf (https://adwc4pm.objectstorage.us-ashburn-1.oci.customer-oci.com/p/b9UsLs4CwZi9iorADMTK9c-ziXkhmME6m7kcdJ9ypjqFTzzZmHSLqNve0t_Vi1du/n/adwc4pm/b/oaiw25-sales-agent-rag-documents/o/ABC_Smartphone_Supply_Catalog.pdf)
```

## Task 2: Create a RAG Tool
Define a RAG tool that the AI agent team can call to provide alternate product recommendations based on your prompt.

Create the sales\_rag\_tool.
```
%script

BEGIN DBMS_CLOUD_AI_AGENT.drop_tool('sales_rag_tool');
EXCEPTION WHEN OTHERS THEN NULL; END;
/
 BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name => 'sales_rag_tool',
        attributes => q'[{"tool_type": "RAG",
                      "tool_params": {"profile_name": "SALES_AGENT_RAG_PROFILE"}}]',
        description => 'Tool for doing RAG for product recommendations using supplier documents.'
    );
END;
```

## Task 3: Update the Task to Handle the Product Return
You'll update the Handle\_Product\_Return\_Task with the new RAG tool and define clear instructions. The task first updates the the return status and then fetches the alternate product recommendations using RAG.

Update the Handle\_Product\_Return\_Task.
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
                    '   a. Ask customer if they want a replacement or a refund or if they would like to consider alternative recommendations' ||
                    '   b. If a replacement, inform customer replacement is on its way and they will receive a return shipping label for the defective product, then update the database for customer name and order number with status replaced' ||
                    '   c. If a refund, inform customer to print out the return shipping label for the defective product, return the product, and update the database for customer name and order number with status refund' ||
                    '   d. if consider alternative recommendations, use the RAG tool to present 2 alternatives to the customer and let them decide if they want this product or the original one' || 
                    '5. After the completion of a return or refund, ask if you can help with anything else.' ||
                    '   End the task if user does not need help on anything else",
                    "tools": ["HUMAN_TOOL","Update_Order_Status_Tool","sales_rag_tool"]}'
  );
END;
```

## Task 4: Update the Agent Team
You'll update the agent team with the updated Product Return task and generate a standard email. Ensure the team runs return update first and then generate an email.

Update the Return\_Agent\Team.
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
## Task 5: Interact with your Updated RAG Agent
Start interacting with the updated RAG agent with natural language prompts. 
1. Set the AI profile for RAG in the session.
```
%script

EXEC DBMS_CLOUD_AI_AGENT.set_team(team_name  => 'Return_Agency_Team');
```

2. Interact with the new RAG agent.
```
<copy>
%script
select ai agent I want to return a smartphone case just received
select ai agent Can you suggest alternative products
</copy>
```

## Learn More

* [Select AI with RAG](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai-retrieval-augmented-generation.html#GUID-6B2A810B-AED5-4767-8A3B-15C853F567A2)
* [Select AI with OCI Generative AI Example](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai-examples.html#GUID-BD10A668-42A6-4B44-BC77-FE5E5592DE27)
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
