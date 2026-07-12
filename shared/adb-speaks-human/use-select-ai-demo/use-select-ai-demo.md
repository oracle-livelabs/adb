# Use the Select AI Demo Application

## Introduction

As you can see from the previous labs, **Select AI** makes it easy to build apps that take advantage of natural language queries. In this lab, you'll experiment with a few. When you ran the scripts to set up your environment, The Select AI APEX demo application was also installed. The app is probably the easiest way to get answers about your business and general internet content. Simply ask a question! You can then explore the result, get an understanding of the generated SQL (and even update it if you like) and manage conversations.

>**Note:** Refer to lab 3 to review what you learned about creating profiles to specify what LLM provider and database schema/tables to use when answering your questions in the app.

Estimated Time: 10 minutes.

Watch the video below for a detailed walk-through of using the Oracle APEX-based ChatDB demo application and the Select AI feature.

[](youtube:htVeX8loT6c)

### Objectives

In this lab, you will:
* As the `moviestream` user, access the **Select AI demo** application using the URL that you saved in a text editor file in **Lab 1 > Task 3 > Step 8**. If you didn't save the URL, refer to **Lab 1 > Task 3** to find it using the **Outputs** link in the **Resources** section on the **Job details** page.
* Ask natural questions with the **Select AI demo** application.

### Prerequisites
- This lab requires the completion of all the preceding labs in the **Contents** menu on the left.

## Task 1: Access the Select AI Demo Application

1. Copy the URL for the **Select AI demo** application that you saved in a text editor in Lab 1.

    ![Copy the URL value](./images/demo-credentials-file.png =65%x*)

    Paste the URL in a new tab in your Web browser, and then click **[ENTER]**. 
    
2. On the **Ask Oracle Select AI** page, enter the username (`moviestream`) and password that you saved in your text editor file, and then click **Sign In**.

    ![Enter ChatDB credentials](./images/ai-select-credentials.png =70%x*)

3. The **Set Admin Users** window in the **Ask Oracle Select AI** application is displayed.  Type the username **MOVIESTREAM** in the `Admin usernames` , then click on the **Save Admin Users** button.  You should see a red `OK` shown on the bottom.  After you confirm this, hit the `ESCAPE` key on your keyboard to dismiss the menu.

    ![Set Admin Users is displayed](./images/select-ai-app-set-admin-users.png =70%x*)

4. In the main menu, you will see a section on the right of the conversation prompt that allows you to **switch the NL2SQL Profile**.  Click the pull-down menu and select **`GENAI`** profile. This profile was created in the **Create credential and AI profile** paragraph in the notebook that you imported in **Lab 3**.

    ![Select AI application Profile](./images/select-ai-app-profile.png =70%x*)

## Task 2: Ask Natural Language and Database Questions Using the Application

1. You can use this application to ask the following types of questions:

- **Ask the Internet Using your LLM Provider:**
_Uncheck the **Ask Database** checkbox_ to ask general free form questions (internet-based) about anything such as _Give me a recipe for french toast_. This question will go to the LLM Provider that you selected when you created the profile and returns the answer.

  ![Ask the internet](./images/ask-internet.png =70%x*)

- **Ask your Database :**
_Select the **Ask Database** checkbox_ to ask questions about your business data based on the user and tables in the database that you specified when you created the profile.

  ![Ask the database](./images/ask-database.png =70%x*)

Let's experiment a bit with both general data from the `internet` and also from the `moviestream` tables in the database.

Let's find out how to make french toast. Enter your question using a free form format in the **Ask a Question** text box, and make sure that the **Ask Database** checkbox is not checked since this is a general internet question that will be handled by your LLM provider. Next, click the **Run** icon, or press **[ENTER]**.

>**Note:** You can type your own natural language question. You don't have to use the exact question that we show in our examples.

![How to make french toast question](./images/french-toast-question.png =70%x*)

A French toast recipe is displayed.

![How to make french toast answer](./images/french-toast-answer.png =70%x*)

2. Let's find out the top 10 streamed movies in the moviestream company. Click the **Clear** icon in the banner to clear the last question and answer. Enter your question using a free form format in the **Ask a Question** text box, and select the **Ask Database** checkbox since this is a question about the moviestream data. Next, press **[ENTER]**.

    ![Top 10 streamed movies](./images/top-10-movies.png =70%x*)

    The top 10 streamed movies are displayed in descending order.

    ![Top 10 streamed movies result](./images/top-10-movies-result.png =70%x*)

2. Click the **Explain** button to view and explain the SQL query behind this natural language question.

  ![View and explain query](./images/explain-query-1.png =70%x*)

  When you finish, click the **Back** icon (left arrow) to return to the Home page. Click the **Explore** button.

  ![Click Explore](./images/click-explore.png =70%x*)
  
  The **Explore** page is displayed.

  ![The Explore page](./images/explore-page.png =70%x*)

4. Click the **Actions** drop-down list to perform several tasks on the generated data such as sorting, downloading, formatting, charting and much more. For details on using the actions tasks, see the embedded video in the Introduction section of this lab. Click the **Close SQL** icon (left arrow) to return to the Home page.

  ![Actions drop-down list](./images/actions.png =70%x*)

5. When you finish, click the **Back** icon (left arrow) to return to the Home page. Now click the **Show SQL** button.

  ![Actions drop-down list](./images/show-sql-button.png =70%x*)

6. You can now see the SQL code generated by Select AI.

  ![Actions drop-down list](./images/show-sql-response.png =70%x*)

7. Finally, there is also a button to **Show Charts** that allows you to play interactively with the data.

  ![Actions drop-down list](./images/show-charts.png =70%x*)

  >**Note:** _LLMs are remarkable at inferring intent from the human language and they are getting better all the time; however, they are not perfect! It is very important to verify the results._

You may now proceed to the next lab.

## Learn More
* [DBMS\_NETWORK\_ACL\_ADMIN PL/SQL Package](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_NETWORK_ACL_ADMIN.html#GUID-254AE700-B355-4EBC-84B2-8EE32011E692)
* [DBMS\_CLOUD\_AI Package](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/dbms-cloud-ai-package.html)
* [Using Oracle Autonomous Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)

## Acknowledgements
  * **Authors:** 
    * Marcos Arancibia, Lead Principal Product Manager
    * Marty Gubar, Product Management (Retired)
* **Contributors:** 
    * Lauran K. Serhal, Consulting User Assistance Developer
* **Last Updated By/Date:** Marcos Arancibia, July 2026

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (c) 2026 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
