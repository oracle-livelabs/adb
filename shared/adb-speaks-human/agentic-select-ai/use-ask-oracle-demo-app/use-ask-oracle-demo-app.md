# Use the Ask Oracle Chatbot App

## Introduction

Before you create your own Select AI agents, this quick lab is your hands-on tour of the demo chatbot app that showcases the agentic chatbot running on Oracle Autonomous Database using Select AI Agent. While we’ll focus on interacting with an agent team, the chatbot also supports asking natural language questions of your LLM, your database data for SQL query generation, and LLM responses enhanced with your private document content using retrieval augmented generation (RAG). You’ll open the app, review at the settings, specify NL2SQL and RAG AI profiles, and pick an AI Agent. Then, try a few prompts — no heavy setup, just click and chat.


Estimated Time: 10 minutes.

### Objectives

In this lab, you will:
* Access the Ask Oracle chatbot app.
* Review the **Settings**.
* Choose an AI Agent to chat with.
* Run some sample prompts.

### Prerequisites
- This lab requires the completion of all the preceding labs in the **Contents** menu on the left.
- Autonomous Database is reachable from your browser environment.

## Task 1: Access the Application

1. Launch the demo app. Paste the URL in a new tab in your Web browser, and then click **[ENTER]**. In the **Ask Oracle** page, enter the username (`select_ai_user`) and password (`Welcome12345`), and then click **Sign In**.

  ![Enter Ask Oracle Chatbot credentials](./images/ask-oracle-login.png =70%x*)

2. The **Ask Oracle Chatbot using Select AI** chatbot application is displayed. On the top right-hand corner, click the user icon. 
    ![Enter Ask Oracle user icon](./images/ask-oracle-user-icon.png =70%x*)

3. Click **Settings** from the menu. 
    ![Select Settings](./images/settings.png =70%x*)

4. The **Settings** screen pops up with different tabs: **NL2SQL Profile**, **RAG Profile**, **AI Agents Teams**, **Account**, and **About**. Choose the following by clicking each tab and selecting the corresponding object:

  a. NL2SQL Profile – `OCI_GENAI[NL2SQL]`

      ![Select OCI_GENAI in NL2SQL Profile tab](./images/ask-oracle-nl2sql.png =70%x*)

  b. RAG Profile – `OCI_GENAI_RAG`
      ![Select OCI_GENAI_RAG in RAG Profile tab](./images/ask-oracle-rag.png =70%x*)

  c. AI Agent Teams – `RETURN_AGENCY_TEAM`
      ![Select RETURN_AGENCY_TEAM in AI Agent Teams tab](./images/ask-oracle-ai-agent-teams.png =70%x*)

For example, pick the agent team **`RETURN_AGENCY_TEAM`** and click the **X** in the upper right to close the **Settings** screen.

5. In the **Enter prompt** text area, click the **+** and select **Agents**. 
      ![Select Agents at the Enter prompt text area](./images/ask-oracle-enter-prompt-agents.png =70%x*)

    Notice that the bottom right indicates that agent team is `RETURN_AGENCY_TEAM`.

      ![Bottom right shows RETURN_AGENCY_TEAM](./images/ask-oracle-enter-prompt-agents-bottom-right.png =70%x*)

You are now ready to ask questions at the Ask question prompt!


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
Click the **+** and select **NL2SQL**. _Uncheck the  **Database** checkbox_ to provide free-form prompts to your LLM about anything such as:

  _What is Oracle Autonomous Database?_
  
  This prompt is sent to the LLM that you selected when you created the profile and returns the response.

  ![Ask the LLM](./images/ask-oracle-llm.png =70%x*)

- **Ask your Database :**
Click the **+** and select **NL2SQL**. _Select the **Database** checkbox_ to ask questions about your database data based on the user and tables in the database that you specified when you created the profile.

  ![Ask your database](./images/ask-oracle-database.png =70%x*)

- **Generate narrated result:**
_Check the **Database** and **Narrate** checkbox_ to ask questions about your database data based on the user and tables in the database specified in the AI profile.

    ![Select Database and Narrate checkboxes](./images/ask-oracle-narrate.png =70%x*)

1. Use the following script to refine your results in a conversation:

  _How many customers do I have in each country?_

2. Uncheck **Narrate**.

  _How many customers do I have in each country?_
  _Break that out by gender_

3. Click **Explain**. 

    ![Click Explain](./images/ask-oracle-explain.png =70%x*)

  When finished viewing, click the back arrow and continue with the following script:

  _Can you change that to have the country in one column and other columns such as male, female and total?_

  _Display this result in a bar chart_

  _Put the results in descending_

  _How many customers do I have in each country?_


- **Use RAG:**
Click **+** and select **RAG** to ask questions using retrieval augmented generation (RAG). Ask questions relative to the corresponding vector index content for Select AI to augment your prompt with relevant content for the LLM. Here, we have a vector index created using blogs from [Oracle Machine Learning Blogs](blogs.oracle.com/machinelearning), which covers both Oracle Machine Learning and Oracle Select AI.

1. First, we’ll just ask our LLM without RAG, so select the **Chat** checkbox.

  _What are the benefits of Select AI for retrieval augmented generation (RAG)?_

    ![Select Chat](./images/ask-oracle-rag-chat.png =70%x*)

2. Uncheck **Chat**

  _How do I create a vector index in Select AI?_

3. Let’s see the specific chunks provided to the LLM, so select the **Show chunk details** checkbox.

  _How do I create a vector index in Select AI?_

4. Uncheck **Show chunk details** checkbox.

  _What do I need to specify in my AI profile to enable RAG?_

**This concludes the workshop.**

<!---Next, let’s see how you build an AI Agent and use various Select AI Agent tools. You may now proceed to the next lab.--->

## Want to Learn More?

* [Select AI Agents](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai-agents1.html) 
* [Select AI Agents Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai-agents-package.html)
* [OML Notebooks](https://docs.oracle.com/en/database/oracle/machine-learning/oml-notebooks/index.html)
* [Using Oracle Autonomous Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)


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
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
