# Use the Ask Oracle Chatbot App

## Introduction

Before you create your own Select AI agents, this quick lab is your hands-on tour of the demo chatbot app that showcases the agentic chatbot running on Oracle Autonomous Database using Select AI Agent. While we’ll focus on interacting with an agent team, the chatbot also supports asking natural language questions of your database data and received LLM responses enhanced with your private document content using retrieval augmented generation (RAG). You’ll open the app, review at the settings, pick an AI Agent, and try a few prompts—no heavy setup, just click and chat.


Estimated Time: 10 minutes.

### Objectives

In this lab, you will:
* Access the Ask Oracle Chatbot App.
* Review the **Settings**.
* Choose an AI Agent to chat with.
* Run some sample prompts.

### Prerequisites
- This lab requires the completion of all the preceding labs in the **Contents** menu on the left.
- Autonomous Database is reachable from your browser environment.

## Task 1: Access the Application

1. Launch the demo app. 

    [Ask Oracle Chatbot](https://g0a51db2590de87-selectaiagentdb.adb-stable.us-ashburn-1.oraclecloudapps.com/ords/r/appstore/askoracle102/home)

    Paste the URL in a new tab in your Web browser, and then click **[ENTER]**. In the **Ask Oracle** page, enter the username (`select_ai_user`) and password (`Welcome12345`), and then click **Sign In**.

    ![Enter Ask Oracle Chatbot credentials](./images/ask-oracle-login.png =70%x*)

2. The **Ask Oracle Chatbot using Select AI** chatbot application is displayed. On the top right hand corner, click the profile icon. 
    ![Enter Ask Oracle Chatbot credentials](./images/ask-oracle-chatbot-screen.png =70%x*)

3. Click **Settings** from the menu. 
    ![Select Settings](./images/settings.png =70%x*)

4. Choose your AI Agent by clicking on the **AI Agents**. Pick the agent team **Sales Return Agent Team** and click the **x** in the upper right to close the settings dialog. Notice that the bottom right indicates that the selected profile is **[Sales Return Agent Team]**.

    ![Select AI application displayed](./images/ai-agents.png =70%x*)

    The Ask Oracle Chatbot using Select AI application is re-displayed. You are now ready to ask questions at the **Ask question** prompt!


## Task 2: Interact with the Sales Return Agent

For example, follow this script:
- “I want to return a smartphone case”
- “The item is defective”
- “I will need a replacement”
- “I'm Bob Martinez and my order number is 7820”
- “No thank you”

## Task 3: (Optional) Ask Natural Language and Database Questions Using the Application

You can use this application to interact with the LLM and your database in a variety of ways:

- **Ask the LLM Directly:**
_Uncheck the **Ask Database** checkbox_ and **Generate narrated result** _checkbox_ to ask general free form questions to your LLM about anything such as _What is Oracle Autonomous Database?_. This question will go to the LLM that you selected when you created the profile and returns the response.

  ![Ask the internet](./images/ask-internet.png =70%x*)

- **Ask your Database :**
_Select the **Ask your Database** checkbox_ to ask questions about your database data based on the user and tables in the database that you specified when you created the profile.

  ![Ask the database](./images/ask-database.png =70%x*)

  - **Generate narrated result:**
  _Select the **Generate narrated result** checkbox_ to ask questions using retrieval augmented generation (RAG). Choose an AI profile that specifies a vector index. Ask questions relative to the corresponding vector index content for Select AI to augment your prompt with relevant content for the LLM. 


  <!---
  Where do you specify what LLM provider and database schema/tables to use when answering your questions? When you create the profile using **`DBMS_CLOUD_AI.CREATE_PROFILE`** PL/SQL procedure, you specify the LLM provider, the credential, the schema, and the tables to use to answer your natural language questions on general data or your business data that is stored in your database.

  ![Create profile diagram](./images/create-profile-diagram.png " ")
--->

Let's experiment with  these. Let's find out about **Oracle Autonomous Database**. Enter your prompt using natural language in the prompt text box, and make sure that the **Ask your database** checkbox is not checked. Next, click the **Run Prompt** icon, or press [ENTER].

**Note:** You can type your own natural language question. You don't have to use the exact question that we show in our examples.

![How to make french toast question](./images/french-toast-example.png =70%x*)

A description of Oracle Autonomous Database is returned.

<!---

2. Let's find out the top 10 streamed movies in the moviestream company. Click the **Clear** icon in the banner to clear the last question and answer. Enter your question using a free form format in the **Ask a Question** text box, and select the **Ask Database** checkbox since this is a question about the moviestream data. Next, press **[ENTER]**.

    ![Top 10 streamed movies](./images/top-10-movies.png =70%x*)

    The top 10 streamed movies are displayed in descending order.

    ![Top 10 streamed movies result](./images/top-10-movies-result.png =70%x*)
    
  --->

You may now proceed to the next lab.

## Learn More
* [DBMS\_NETWORK\_ACL\_ADMIN PL/SQL Package](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/DBMS_NETWORK_ACL_ADMIN.html#GUID-254AE700-B355-4EBC-84B2-8EE32011E692)
* [DBMS\_CLOUD\_AI Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-package.html#GUID-000CBBD4-202B-4E9B-9FC2-B9F2FF20F246)
* [Using Oracle Autonomous Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)

## Acknowledgements
  * **Authors:** 
    * Sarika Surampudi, Principal User Assistance Developer
    * Mark Hornick, Product Management
<!--* **Last Updated By/Date:** Sarika Surampudi, August 2025
-->


Copyright (c) 2025 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
