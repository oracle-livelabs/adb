# Integrate GenAI models with Autonomous Database

## Introduction

LLMs can produce incredibly creative responses to prompts, generate SQL from natural language, and so much more. In order to be most effective, you want to leverage LLMs with your organization's private data. The first step is to integrate your models with Autonomous Database.

You can use different LLMs with Autonomous Database. This lets you pick the best model for your use case. Select AI profiles encapsulate the connections to each model; you specify which profile to use when generating results. In this lab, you will enable the user **`MOVIESTREAM`** to connect to models from Oracle OCI GenAI, Azure OpenAI and Google Gemini.

Estimated Time: 10 minutes.

### Objectives

In this lab, you will:
* Connect Autonomous Database to an AI provider
* Test the AI profile

### Prerequisites
- This lab requires the completion of the previous labs that deployed your Autonomous Database.

## Task 1: Log into the SQL Worksheet
>**Note:** the **MOVIESTREAM** user and its tables were created as part of the setup. You can find the Moviestream password by navigating to **Developer Services** from the Navigation menu. Next, click **Resource Manager** > **Stacks** > Select the stack we created, **Deploy-ChatDB-Autonomous-Database...** > Select the job we created, **ormjob2024117214431** > Select **Outputs** under **Resources**.

![Moviestream password](./images/moviestream-output-pswd.png "")

1. If you are not logged in to Oracle Cloud Console, log in and select **[](var:db_workload_type)** from the Navigation menu.

    ![Oracle Home page left navigation menu.](./images/database-adw.png " ")

2. Make sure you are in the correct compartment where you ADB instance was provisioned and then click your **TrainingAIWorkshop** instance.

    ![Autonomous Databases homepage.](./images/adb-home-page.png " ")

3. On your **TrainingAIWorkshop** Autonomous Database details page, click the **Database Actions** drop-down list, and then select **View all database actions**.

    ![Click Database Actions button.](./images/view-db-actions.png " ")

    Logging in from the OCI service console requires you to be the **`ADMIN`** user. Log in as the **`ADMIN`** user if you are not automatically logged in.
    
    * **Username:** **`ADMIN`**
    * **Password:** *your-password* (e.g. **`WlsAtpDb1234#`**)

4. The **Database Actions** page is displayed. Click the **Development** tab if not already selected, and then click the **SQL** tab.

    ![Click SQL.](./images/adb-dbactions-click-sql.png " ")

5. The first time you open SQL Worksheet, a series of pop-up informational boxes may appear, providing you a tour that introduces the main features. If not, click the **Tour** icon (binoculars) in the upper right corner. Click **Next** to take a tour through the informational boxes; otherwise, close the boxes. Close the boxes.

    ![SQL Worksheet.](./images/adb-sql-worksheet.png " ")

6. We'll run the SQL analytics as the **`MOVIESTREAM`** user. Sign out of the **`ADMIN`** user. Click the the drop-down list next to the **`ADMIN`** user in the banner, and then click **Sign Out**.
    
    ![Log out.](./images/sign-out-admin.png " ")

7. Log in to the SQL Worksheet using the following credentials, and then click **Sign in** to display the **Database Actions Launchpad**.

    * **Username:** **`MOVIESTREAM`**
    * **Password:** **`your-password`** (e.g. **`watchS0meMovies#`**)

    ![Sign in.](./images/sign-in-moviestream.png " ")

8. The **Database Actions Launchpad** page is displayed. Click the **Development** tab if not already selected, and then click the **SQL** tab.

    ![Click SQL.](./images/adb-dbactions-click-sql.png " ")

    The SQL Worksheet is displayed.

    ![SQL Worksheet.](./images/moviestream-sql-worksheet.png " ")

## Task 2: Connect Autonomous Database to an AI Provider, Create an AI Profile, and a Vector Index

### Background
There are 4 things to do in order to connect Autonomous Database to an AI provider:
1. Grant the **`MOVIESTREAM`** user network access to the AI provider endpoint (already done for you)
2. Create a credential containing the secret used to sign requests to the AI provider
3. Create a Select AI profile (see below for more details)
4. Create a Vector index (see below for more details)

>**Note:** All of these steps have already been done for accessing OCI GenAI when you deployed your Autonomous Database. You can review the deployment steps below. You will need to execute these steps when connecting to non-Oracle AI providers.

A Select AI profile encapsulates connection information for an AI provider. This includes: 

1. A security credential (e.g. the resource principal for OCI GenAI or a credential that captures a secret for a 3rd party AI provider)
2. The name of the provider
3. The name of the LLM (optional)
4. A list of target tables that will be used for natural language queries (required when using NL2SQL)

You can create as many profiles as you need, which is useful when comparing the quality or performance of the results of different models.

For a complete list of the Select AI profile attributes, see the [DBMS\_CLOUD\_AI\_Package] (https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-package.html#GUID-D51B04DE-233B-48A2-BBFA-3AAB18D8C35C) in the Using Oracle Autonomous Database Serverless documentation. 

### **Connect to one of the following AI providers using each provider's default model**:

>**Note:** In this workshop, we are using the OCI GenAI as the LLM in our examples.

<details>
    <summary>**OCI Generative AI** (default)</summary>

1. Copy and paste the following code into your SQL Worksheet, and then click the **Run Script** icon in the toolbar.

    ```sql
    <copy>

    -- Use resource principal
    -- This policy allows access: allow any-user to manage
    -- generative-ai-family in the tenancy as ADMIN

    -- The following is already done for you in this workshop.
    -- exec dbms_cloud_admin.enable_resource_principal(username  => 'MOVIESTREAM');

    -- As MOVIESTREAM
    -- Here is the web site:
    -- https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/building_blocks_utilities/o/support-site/index.html

    /* REVIEW */
    -- Look at the files on object store
    -- Review the file list that comprise the support web site
    SELECT object_name, bytes 
    FROM dbms_cloud.list_objects(
        credential_name => 'OCI$RESOURCE_PRINCIPAL',
        location_uri => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/building_blocks_utilities/o/support-site/'
    );

    /* RESET */
    -- delete profiles / vector indexes in case they exist
    BEGIN  
    -- AI profile
    dbms_cloud_ai.drop_profile(
            profile_name => 'SUPPORT_SITE',
            force => true
    );           
    -- Vector index
    dbms_cloud_ai.drop_vector_index (
        index_name => 'SUPPORT',
        force => true
    );                                                                 

    END;
    /

    /* CREATE */
    -- create the profile and index
    BEGIN  
    -- create the ai profile. It will use the support vector to answer questions
    dbms_cloud_ai.create_profile (
        profile_name => 'SUPPORT_SITE',
        attributes => 
            '{
            "provider": "oci",        
            "credential_name": "OCI$RESOURCE_PRINCIPAL",              
            "vector_index_name": "SUPPORT"
            }'      
    );  

    -- Create a vector index that points to the object storage location
    -- that contains the website files. This will create a pipeline
    -- that loads the index and keeps it up to date

    dbms_cloud_ai.create_vector_index(
        index_name  => 'SUPPORT',
        attributes  => '{"vector_db_provider": "oracle",
                        "object_storage_credential_name": "OCI$RESOURCE_PRINCIPAL",
                        "location": "https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/building_blocks_utilities/o/support-site/",
                        "profile_name": "SUPPORT_SITE",
                        "vector_table_name":"support_site_vector",
                        "vector_distance_metric": "cosine"
                    }'
        );                                       
    END;                                                                           
    /  

    /* PIPELINE */
    -- A pipeline was created and you can see it here. The pipeline runs
    -- periodically to update the vectors.
    -- Check out the status table to see progress/details
    SELECT pipeline_id, pipeline_name, status, last_execution, status_table
    FROM user_cloud_pipelines;

    SELECT * 
    FROM user_cloud_pipeline_attributes;

    SELECT * 
    FROM user_cloud_pipeline_history;

    /* VECTOR TABLE */
    -- Review the generated table that has the chunks and vector embedding
    SELECT * FROM support_site_vector;

    /* QUERY */
    SELECT
    dbms_cloud_ai.generate (
        profile_name => 'SUPPORT_SITE',
        action => 'narrate',
        prompt => 'George Clooney lips are moving but I can not hear him'
    ) as support_question;  
    </copy>
    ```
    ![The output is displayed in the Script Output tab.](./images/genai-output-rag.png " ")

    ![The output is displayed in the Script Output tab.](./images/genai-output-rag-query.png " ")
    </details>


<details>
    <summary>**OpenAI**</summary>
You will need a [paid OpenAI account](https://platform.openai.com/docs/overview) and [an API key](https://platform.openai.com/docs/quickstart) in order to use OpenAI GPT models. 

1. Grant the **`MOVIESTREAM`** user network access to the OpenAI endpoint.    

    ```sql
    <copy>
    BEGIN
    DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
        host => 'api.openai.com',
        ace  => xs$ace_type(privilege_list => xs$name_list('http'),
                            principal_name => 'MOVIESTREAM',
                            principal_type => xs_acl.ptype_db)
    );
    END;
    /    
    </copy>
    ```

2. Create a credential.
    ```sql
    <copy>
    BEGIN                                                                          
        dbms_cloud.create_credential (                                                 
            credential_name => 'openai_credential',                                            
            username => 'openai',                                                 
            password => 'your-api-key-goes-here'
        );                             
    END;                                                                           
    /  
    </copy>
    ```

3. Create a Select AI profile.

    ```sql
    <copy>
    BEGIN
        -- Drop the profile in case it already exists
        dbms_cloud_ai.drop_profile(
            profile_name => 'genai',
            force => true
        );        
        
        -- Create an AI profile that uses the default GPT model
        dbms_cloud_ai.create_profile(
            profile_name => 'genai',
            attributes =>       
                '{"provider": "openai",
                "credential_name": "openai_credential",
                "comments":"true",            
                "object_list": [
                    {"owner": "MOVIESTREAM", "name": "GENRE"},
                    {"owner": "MOVIESTREAM", "name": "CUSTOMER"},
                    {"owner": "MOVIESTREAM", "name": "PIZZA_SHOP"},
                    {"owner": "MOVIESTREAM", "name": "STREAMS"},            
                    {"owner": "MOVIESTREAM", "name": "MOVIES"},
                    {"owner": "MOVIESTREAM", "name": "ACTORS"}
                ]
                }'
            );          
    END;
    /    
    </copy> 
    ```
</details>


<details>
    <summary>**Azure OpenAI**</summary>
You will need an Azure subscription and an [Azure OpenAI resource](https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/create-resource?pivots=web-portal) in order to use the GPT models. After creating the Azure OpenAI resource, navigate to the resource page and select **Resource Management -> Keys and Endpoint**. Copy its **Endpoint** (the server name only - not including "https://" or "/") and a **KEY**. For example, consider a resource named **openaigpt40** (your name will be different):
![Azure OpenAI resource](images/azure-resource-info.png)

You will also need the Azure OpenAI deployment name. In that same portal page, navigate to **Resource Management -> Model Deployments** and click **Manage Deployments**. Copy the **Deployment name** for your GPT model.

1. Grant the **`MOVIESTREAM`** user network access to the Azure OpenAI resource endpoint.    
    ```sql
    <copy>
    BEGIN
    DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
        host => 'your-azure-openai-resource-endpoint',
        ace  => xs$ace_type(privilege_list => xs$name_list('http'),
                            principal_name => 'MOVIESTREAM',
                            principal_type => xs_acl.ptype_db)
    );
    END;
    /    
    </copy>
    ```

2. Create a credential.
    ```sql
    <copy>
    BEGIN                                                                          
    dbms_cloud.create_credential (                                                 
        credential_name => 'azure_openai_credential',                                            
        username => 'azure',                                                 
        password => 'your-api-key-goes-here'
    );                             
    END;                                                                           
    /  
    </copy>
    ```

3. Create a Select AI profile.
    ```sql
    <copy>
    begin    
        -- Drop the profile in case it already exists
        dbms_cloud_ai.drop_profile(
            profile_name => 'genai',
            force => true
        );    

        -- Create an AI profile that uses the default Gemini model
        dbms_cloud_ai.create_profile(
            profile_name => 'genai',
            attributes =>       
                '{"provider": "azure",
                "azure_resource_name": "your-azure-resource-name",                    
                "azure_deployment_name": "your-azure-deployment-name",
                "credential_name": "azure_openai_credential",                
                "comments":"true",            
                "object_list": [
                    {"owner": "MOVIESTREAM", "name": "GENRE"},
                    {"owner": "MOVIESTREAM", "name": "CUSTOMER"},
                    {"owner": "MOVIESTREAM", "name": "PIZZA_SHOP"},
                    {"owner": "MOVIESTREAM", "name": "STREAMS"},            
                    {"owner": "MOVIESTREAM", "name": "MOVIES"},
                    {"owner": "MOVIESTREAM", "name": "ACTORS"}
                ]
                }'
            );          
    end;
    /    
    </copy> 
    ```
</details>

<details>
    <summary>**Google Gemini**</summary>
You will need a [Google AI Studio account](https://ai.google.dev) and [an API key](https://aistudio.google.com/app/apikey) in order to use Google Gemini. 

1. Grant the **`MOVIESTREAM`** network access to the Google Gemini endpoint. 
    ```sql
    <copy>
    BEGIN
    DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
        host => 'generativelanguage.googleapis.com',
        ace  => xs$ace_type(privilege_list => xs$name_list('http'),
                            principal_name => 'MOVIESTREAM',
                            principal_type => xs_acl.ptype_db)
    );
    END;
    /    
    </copy>
    ```

2. Create a credential.
    ```sql
    <copy>
    BEGIN                                                                          
    dbms_cloud.create_credential (                                                 
        credential_name => 'gemini_credential',                                            
        username => 'google',                                                 
        password => 'your-api-key-goes-here'
    );                             
    END;                                                                           
    /  
    </copy>
    ```

3. Create a Select AI profile.
    ```sql
    <copy>
    begin    
        -- Drop the profile in case it already exists
        dbms_cloud_ai.drop_profile(
            profile_name => 'genai',
            force => true
        );    

        -- Create an AI profile that uses the default Gemini model
        dbms_cloud_ai.create_profile(
            profile_name => 'genai',
            attributes =>       
                '{"provider": "google",
                "credential_name": "gemini_credential",
                "comments":"true",            
                "object_list": [
                    {"owner": "MOVIESTREAM", "name": "GENRE"},
                    {"owner": "MOVIESTREAM", "name": "CUSTOMER"},
                    {"owner": "MOVIESTREAM", "name": "PIZZA_SHOP"},
                    {"owner": "MOVIESTREAM", "name": "STREAMS"},            
                    {"owner": "MOVIESTREAM", "name": "MOVIES"},
                    {"owner": "MOVIESTREAM", "name": "ACTORS"}
                ]
                }'
            );          
    end;
    /    
    </copy> 
    ```
</details>

## Task 3: Test the AI Profile

We will use the Select AI PL/SQL API to generate a response from the AI model. This example is using the **chat** action. It is not using any private data coming from your database.

1. Test the LLM and learn about Autonomous Database as the **`MOVIESTREAM`** user. Copy and paste the following code into your SQL Worksheet, and then click the **Run Script** icon. Your answer may differ!

    ```
    <copy>
    SELECT DBMS_CLOUD_AI.GENERATE(
        prompt       => 'what is oracle autonomous database',
        profile_name => 'GENAI',
        action       => 'chat')
    FROM dual;
    </copy>
    ```
    ![Test the LLM](./images/cohere-output.png "")

## Summary
You learned how to integrate Autonomous Database with your AI provider. And, you asked the model your first question using the "chat"action. Next, let's see how to use our private data with LLMs.

You may now proceed to the next lab.

## Learn More
* [DBMS\_NETWORK\_ACL\_ADMIN PL/SQL Package](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_NETWORK_ACL_ADMIN.html#GUID-254AE700-B355-4EBC-84B2-8EE32011E692)
* [DBMS\_CLOUD\_AI Package](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/dbms-cloud-ai-package.html)
* [Using Oracle Autonomous Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)
* [Overview of Generative AI Service](https://docs.oracle.com/en-us/iaas/Content/generative-ai/overview.htm)

## Acknowledgements

  * **Authors:**
    * Marty Gubar, Product Management
    * Lauran K. Serhal, Consulting User Assistance Developer
  * **Last Updated By/Date:** Lauran K. Serhal, February 2025

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (c) 2025  Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)