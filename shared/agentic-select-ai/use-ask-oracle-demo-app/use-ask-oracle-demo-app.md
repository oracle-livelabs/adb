# Use the Ask Oracle Select AI Chatbot App

## Introduction

This lab provides a hands-on tour of the “Ask Oracle Select AI” demo chatbot app. Here, you’ll use the chatbot to run the agent team created and enhanced in the previous labs. While we’ll focus on interacting with an agent team, this APEX-based app allows you to interact with your data using natural language prompts for RAG and NL2SQL with AI profiles already defined. You’ll open the app, review the settings, specify NL2SQL   and RAG AI profiles, and pick an AI Agent. Then, try a few prompts - just click and chat.


Estimated Time: 20 minutes

### Objectives

In this lab, you will:
* Access the Ask Oracle Select AI chatbot app.
* Review the **Settings**.
* Choose an AI Agent to chat with.
* Run some sample prompts.

### Prerequisites
- This lab requires the completion of all the preceding labs in the **Contents** menu on the left.
- Autonomous AI Database is reachable from your browser environment.

> Note: If you are independently using OML Notebook on your instance to run the code, append `%script` at the beginning for the codeblocks.

## Task 1: Access the Application

1. We will launch the **Ask Oracle Select AI Application**. 
<if type="tenancy">
    The application and its URL were created during the installation of the Ask Oracle Select AI Chatbot Application in **Lab 1** -> **Task 4**.
    Paste the URL in a new tab in your Web browser, and then click **[ENTER]**. 
</if>
<if type="sandbox">
    The URL for the Ask Oracle Sekect AI Chatbot is available in your LiveLabs reservation information.  
    You can check the section Get Started with LiveLabs as a reminder on how to find your reservation information.

    ![Open Ask Oracle Select AI Chatbot link](./images/sandbox-open-ask-oracle.png =70%x*)
</if>

    In the **Ask Oracle** page, enter the username and password, and then click **Sign In**. 

    ![Enter Ask Oracle Chatbot credentials](./images/ask-oracle-login.png =70%x*)

2. Since it's the first time you sign in, the **Set Admin Users** window in the **Ask Oracle Select AI** application is displayed. You can click __SKIP__ and the current signed-in username will be stored as an **Admin Users**. Otherwise you can enter the desired username as ADMIN and click **Save Admin Users**.

<if type="sandbox">
    ![Enter comma separated usernames as Admin users](./images/ask-oracle-set-admin-users.png =70%x*)
</if>
<if type="tenancy">
    ![Enter comma separated usernames as Admin users](./images/ask-oracle-set-admin-users-adbuser.png =70%x*)
</if>

3. The **Ask Oracle Select AI Chatbot** application is displayed.
    
4. In the **Ask Question** prompt field, click the **+** menu and select **Agent Team**.  Notice that the bottom right indicates that agent team is `RETURN_AGENCY_TEAM`. You will see a section on the right of the conversation prompt that allows you to switch the Agent Team Profile. If you have configured other agent profiles using Select AI Agent framework, click the pull-down menu and select `RETURN_AGENCY_TEAM` profile. <if type="tenancy">  This profile was created in **Task 9 of Lab 2**. </if><if type="sandbox"> This profile was created in **Task 9 of Lab 1**. </if>

    ![Select OCI_GENAI profile](./images/ask-oracle-enter-prompt-agents.png =70%x*)

    You are now ready to ask questions at the prompt area!


## Task 2: Interact with the Sales Return Agent

For example, follow this script:
- “I want to return a smartphone case”
- “The item is defective”
- “I will need a replacement”
- “I'm Bob Martinez and my order number is 7820”
- “No thank you”


## Task 3 (optional): Create NL2SQL Profile
To create NL2SQL profile:
1. Add a paragraph in your OML Notebook by clicking the **+** symbol.
    ![Add a paragraph](./images/add-paragraph.png)

2. Create a NL2SQL Profile by pasting the following code.
    ```
    <copy>

    
    BEGIN
      DBMS_CLOUD_AI.CREATE_PROFILE(
          profile_name =>'OCI_GENAI',
          attributes   =>'{"provider": "oci",
          "credential_name": "AI_CREDENTIAL",
          "conversation": "true",
          "object_list": [{"owner": "SH", "name": "customers"},
                          {"owner": "SH", "name": "countries"},
                          {"owner": "SH", "name": "supplementary_demographics"},
                          {"owner": "SH", "name": "profits"},
                          {"owner": "SH", "name": "promotions"},
                          {"owner": "SH", "name": "products"}]
            }');
    END;
    /
    </copy>
    ```


## Task 4: (Optional) Ask Natural Language and Database Questions Using the Application

You use the Ask Oracle Select AI chatbot application to interact with both a large language model (LLM) and your Autonomous AI Database through a single conversational interface.
The application supports two modes of interaction:

- **Ask the LLM Directly:**
Click the **+** and select **NL2SQL**. _Uncheck the  **Database** checkbox_ ask general free form questions (internet-based) about anything such as:

  _Give me a recipe for french toast._
  
  This prompt is sent to the LLM that you selected when you created the profile and returns the response.
  ![Ask the LLM](./images/ask-oracle-uncheck-database.png =70%x*)

- **Ask your Database :**
Click the **+** and select **NL2SQL**. _Select the **Database** checkbox_ to ask questions about your database data based on the user and tables in the database that you specified when you created the profile.
  
  ![Ask your database](./images/ask-oracle-check-database.png =70%x*)


Let's experiment a bit with both general data from the _internet_ and also from the schema tables in the database.

1. Let's find out how to make french toast. Enter your question using a free form format in the **Ask Question** text box, and make sure that the **Database** checkbox is _not checked_ since this is a general internet question that will be handled by your LLM provider. Next, click the **Run** icon, or press **[ENTER]**.
   
    > You can type your own natural language question. You don't have to use the exact question that we show in our examples.
  
    ![Ask the LLM](./images/ask-oracle-french-toast-recipe.png =70%x*)

    A French toast recipe is displayed.

    ![LLM's response](./images/ask-oracle-french-toast-recipe-display.png =70%x*)

2. Let's find out _How many customers do I have in each country?_ Enter your question using a free form format in the **Ask Question** text box, and select the **Database** checkbox since this is a question about the tables present in the OCI_GENAI profile. Next, press **[ENTER]**. 
    The number of customers along with the countries are displayed.
    ![Select Database and ask database tables related question](./images/ask-oracle-database.png =70%x*)
  
3. Check the **Database** and **Narrate** checkbox to ask questions about your database data based on the user and tables in the database specified in the AI profile such as:

    _How many customers are females?_

    ![Select Database and Narrate checkboxes](./images/ask-oracle-narrate.png =80%x*)

4. Now run Step 1 again and click **Explain** to view and explain the SQL query behind this natural language question.
    ![Click Explain to view the explanation of the generated SQL](./images/ask-oracle-explain.png =80%x*)
5. When you finish reviewing, click the Back icon (left arrow) to return to the conversation on Home page.
    ![Click Explain to view the generated SQL](./images/ask-oracle-explain-sql.png =80%x*)
6. Now, click **Explore**.
    ![Select Explore](./images/ask-oracle-explore.png =80%x*)
    The **Explore** page is displayed.
    ![Select Explore](./images/ask-oracle-explore-display.png =80%x*)
7. Click the **Actions** drop-down list to perform several tasks on the generated data such as sorting, downloading, formatting, charting and much more. 
    ![Select Actions and explore various options](./images/ask-oracle-explore-actions.png =80%x*)
8. When you finish exploring, click the **Back** icon (left arrow) to return to the conversation on Home page. Now, click **Show SQL**.
    ![Select Show SQL](./images/ask-oracle-showsql.png =80%x*)
9. You can now see the SQL code generated by Select AI.
    ![View generated SQL](./images/ask-oracle-showsql-display.png =80%x*)
10. Finally, there is also a button to **Show Charts** that enables you to play interactively with the data.
    ![Select Show Charts](./images/ask-oracle-show-charts.png =80%x*)
   
    The chart is displayed:
    ![Displays a bar chart of the data](./images/ask-oracle-show-charts-display.png =70%x*)

    > LLMs are remarkable at inferring intent from the human language and they are getting better all the time; however, they are not perfect! It is very important to verify the results.

You may now proceed to the next lab.


## Want to Learn More?

* [Ask Oracle Select AI Application available in Github](https://github.com/oracle-devrel/oracle-autonomous-database-samples/tree/main/apex/Ask-Oracle-Select-AI-Chatbot)
* [Select AI Agent Framework](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai-agent1.html) 
* [Select AI Agent Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)
* [OML Notebooks](https://docs.oracle.com/en/database/oracle/machine-learning/oml-notebooks/index.html)
* [Using Oracle Autonomous AI Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)


## Acknowledgements

* **Author:** Sarika Surampudi, Principal User Assistance Developer; Marcos Arancibia, Lead Princiopal Product Mgr
* **Contributors:** Marcos Arancibia, Lead Princiopal Product Mgr; Mark Hornick, Senior Dir. of AI and ML Product Mgt.; Laura Zhao, Member of Technical Staff; Sherry LaMonica, Lead Principal Product Manager
* **Last Updated By/Date:** Marcos Arancibia, October 2026

Copyright (c) 2026 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
