# Introduce a RAG Tool for Alternative Product Recommendation

## Introduction

In this lab you’ll enrich the return flow with RAG (Retrieval Augmented Generation). We’ll use a couple of documents that provide product summary information: descriptions, pros, and cons, that can be used to offer alternative product recommendations. After recording a return, the agent can recommend alternative products based on your prompts from content indexed in Object Storage and present a standard confirmation email. You’ll set up an AI Profile for RAG, use content Object Storage, create a vector index, and insert a RAG-related task into your agent team.

### Overview of Important Concepts
Let's review some of the important concepts that you should know.

### **Use AI profiles to access your LLM**

An AI profile captures the properties of your AI provider and the AI model(s) you want to us, as well as other attributes depending on whether you are using it for SQL query generation or retrieval augmented generation (RAG). You can create multiple profiles for different purposes (NL2SQL, RAG, and the content you want them to access), although only one is active for a given session or a particular call.

### **Create an AI Profile for RAG and a Vector Index**
[comment]: # (MH: The LiveLab will need to tell the user how to create the credential as well. For the HOL, we'll have a predefined credential, but the general LiveLab will require users to create this. This will require a section on credential creation with OCI GenAI since it's far from easy. When we first use the OCI_CRED, much earlier in the workshop, this should be added. With a reference to that section here (rather than repeat it.)

Here, you will create an AI profile for RAG. 

>**Note:** In this workshop, we are using OCI Generative AI. Before creating an AI profile, create credentials to access AI provider. See **Lab 1** of this workshop.

To get started, you'll need to create a profile using the **`DBMS_CLOUD_AI.CREATE_PROFILE`** PL/SQL package that describes your _AI provider_ and use the _default_ LLM transformer. We’ll then create a vector index using content from object storage. For additional information, see the [CREATE\_PROFILE procedure](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-package.html#GUID-D51B04DE-233B-48A2-BBFA-3AAB18D8C35C) documentation.

### **Ask Natural Language Questions**

You can ask questions using **`SELECT AI`** where **`AI`** is a special keyword in the `SELECT` statement that tells Autonomous Database to use Select AI on your natural language question. Select AI provides multiple ‘_actions_’ for interacting with the LLM. The one we will use is ‘_narrate_’ that, when paired with an AI profile configured with a vector index, will support RAG.

### **Update your Task to Use the RAG Tool**

With this AI profile, define a RAG tool and update the task to use RAG to suggest alternative products. 

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

- This lab requires completion of the previous labs in the **Contents** menu on the left.

## Task 1: Create a profile for RAG
Define an AI Profile that has your LLM and database objects and is ready to use RAG once a vector index exists.

1. Create an AI profile for RAG usage.
```
    <copy>
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
      </copy>
```

2. Create credentials to access Object Storage.

```
<copy>
%script

begin
DBMS_CLOUD.drop_credential(credential_name => 'OCI_SALES_CRED');
EXCEPTION WHEN OTHERS THEN NULL; END;
end;
/
BEGIN
DBMS_CLOUD.create_credential(
  credential_name => 'OCI_SALES_CRED',
  user_ocid       => '<ocid>',
  tenancy_ocid    => '<tenancy ocid>',
  private_key     => '<private key>',
  fingerprint     => '<fingerprint>'
);
END;
</copy>
```
3. Build a vector index over product docs stored in Object Storage. The index is used by RAG.
```
<copy>
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
  </copy>
```
4. Set the AI profile in the current session.
  ```
  <copy>
  %script
  EXEC DBMS_CLOUD_AI.SET_PROFILE(profile_name => 'SALES_AGENT_RAG_PROFILE');
  </copy>
  ```
5. Use natural language prompts to run a test using our LLM and specific content. Ask for alternate product recommendations.
  ```
  <copy>
  select ai narrate what are alternatives for the smartphone case
    </copy>
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
<copy>
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
	</copy>
```

## Task 3: Update the Task to Handle the Product Return
You'll update the Handle\_Product\_Return\_Task with the new RAG tool and define clear instructions. The task first updates the return status and then fetches the alternate product recommendations using RAG.

Update the `Handle_Product_Return_Task`.
  
>   **Note**: This version does not include email generation, only the product recommendation.
```
<copy>
%script

BEGIN DBMS_CLOUD_AI_AGENT.drop_task('Handle_Product_Return_Task');
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
  DBMS_CLOUD_AI_AGENT.create_task(
    task_name => 'Handle_Product_Return_Task',
    attributes => '{"instruction": "Process a product return request from a customer: {query} ' ||
                    'Steps to be followed: ' ||
                    '1. Ask customer the reason for return (no longer needed, arrived too late, box broken, or defective)' || 
                    '2. If no longer needed:' ||
                    '   a. Inform customer to ship the product at their expense back to us.' ||
                    '   b. Update the order status to return_shipment_pending using Update_Order_Status_Tool.' ||
                     '3. If it arrived too late:' ||
                    '   a. Ask customer if they want a refund.' ||
                    '   b. If the customer wants a refund, then confirm refund processed and update the order status to refund_completed' || 
                    '4. If the product was defective or the box broken:' ||
                    '   a. Ask customer if they want a replacement or a refund or if they would like to consider alternative recommendations' ||
                    '   b. If a replacement, inform customer replacement is on its way and they will receive a return shipping label for the defective product, then update the order status to replaced' ||
                    '   c. If a refund, inform customer to print out the return shipping label for the defective product, return the product, and update the order status to refund' ||
                    '   d. If consider alternative recommendations, use the RAG tool to present 2 alternatives to the customer and let them decide if they want this product or the original one' || 
                    '5. After the completion of a return or refund, ask if you can help with anything else.' ||
                    '   End the task and generatea a final answer only if user does not need help on anything else",
                    "tools": ["Update_Order_Status_Tool","sales_rag_tool"]}'
  );
END;
	</copy>
```

## Task 4: Update the Agent Team
You'll update the agent team with the revised Product Return task.

Update the `Return_Agent_Team`.
```
<copy>
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
	</copy>
```
## Task 5: Interact with your Updated RAG Agent
Start interacting with the updated RAG agent with natural language prompts.
1. Set the AI profile for RAG in the session.
```
<copy>
%script

EXEC DBMS_CLOUD_AI.clear_conversation_id;

EXEC DBMS_CLOUD_AI_AGENT.set_team(team_name  => 'Return_Agency_Team');
	</copy>
```

2. Interact with the new RAG agent.
```
<copy>
select ai agent I want to return a smartphone case just received
</copy>
```
**RESULT**
```
RESPONSE
Can you please tell me the reason for returning the smartphone case? Is it no longer needed, did it arrive too late, is the box broken, or is the product defective?
```

You may continue with the following prompts as per the below sequence:

_select ai agent Hi, unforunately, it is defective_

_select ai agent Sure, what are some alternatives you could recommend_

_select ai agent A refund please_

_select ai agent Carol Chen order number 7635_

_select ai agent no, thank you_

You may now proceed to the next lab.

## Learn More

* [Select AI with RAG](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai-retrieval-augmented-generation.html#GUID-6B2A810B-AED5-4767-8A3B-15C853F567A2)
* [Select AI with OCI Generative AI Example](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai-examples.html#GUID-BD10A668-42A6-4B44-BC77-FE5E5592DE27)
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
