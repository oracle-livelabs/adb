# Use the Select AI Demo Application

## Introduction

As you can see from the previous labs, **Select AI** makes it easy to build apps that take advantage of natural language queries. You learned how to use **Autonomous AI Database Select AI (Select AI)** with **Retrieval Augmented Generation (RAG)** to augment your natural language prompt by retrieving content from your specified vector store using semantic similarity search. This reduces hallucinations by using your specific and up-to-date and content and provides more relevant natural language responses to your prompts. In this lab, you'll experiment with asking a few questions using natural language. When you ran the scripts to set up your environment in Lab 1, The **Select AI APEX** demo application was also installed. The app is probably the easiest way to get answers about your business and general internet content. Simply ask a question! You can then explore the result, get an understanding of the generated SQL (and even update it if you like) and manage conversations.

>**Note:** Refer to lab 2 to review what you learned about creating profiles to specify what LLM provider and the vector index to use when answering your questions in the app.

Estimated Time: 10 minutes.

### Objectives

In this lab, you will:

* As the `moviestream` user, access the **Select AI demo** application using the URL that you saved in a text editor file in **Lab 1 > Task 3 > Step 8**. If you didn't save the URL, refer to **Lab 1 > Task 3** to find it using the **Outputs** link in the **Resources** section on the **Job details** page.
* Ask natural questions with the **Select AI demo** application.

### Prerequisites

- This lab requires the completion of all the preceding labs in the **Contents** menu on the left.

## Task 1: Access the Select AI Demo Application

1. Copy the **Select AI demo** application URL that you saved in a text editor earlier in Lab 1.

    ![Copy the URL value](./images/demo-credentials-file.png =85%x*)

    Paste the URL in a new tab in your Web browser, and then click **[ENTER]**. In the **ChatDB** page, enter the username (`moviestream`) and password that you saved in your text editor file, and then click **Sign In**.

    ![Enter ChatDB credentials](./images/ai-select-credentials.png =70%x*)

2. On the **ADB Chat** page, the **AI Settings** panel is displayed. Select a profile that you want to use from the **Choose subject areas** drop-down list. In this workshop, select the **`SUPPORT_SITE`** profile that was created in the **Lab 2** when you ran the script to create the profile. Close the **AI Settings** panel.

    ![Select AI profile](./images/select-profile-rag.png =85%x*)

    The **ADB Chat** application is displayed. You are now ready to ask questions at the **Ask a question** prompt!

    ![Select AI application displayed](./images/select-ai-application.png =85%x*)

## Task 2: Review the Oracle MovieStream Internal Support Website

Oracle MovieStream business has an internal website with support information that the users can use. We're going to make it easy to ask questions from that support site using vectors.

1. Navigate to the Moviestream Support web site. Copy the following URL and then paste it in a new Web browser window or tab.

  https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/building_blocks_utilities/o/support-site/index.html

  ![The oracle moviestream internal web site support web site](./images/support-site.png =85%x*)

2. Explore the different menu options as desired to get some ideas on prompts that you can ask the application. For example, you can click the **Playback Issues** or the **Subscription & Login Issues** menus.

## Task 3: Ask Natural Language and Database Questions Using the Application

You can use this application to ask the following types of questions:

- **Ask the Internet Using your LLM Provider:**
_Uncheck the **Ask Database** checkbox_ to ask general free form questions (internet-based) about anything such as _How do you make french toast?_. This question will go to the LLM Provider that you selected when you created the profile and returns the answer.

  ![Ask the internet](./images/ask-internet.png =70%x*)

- **Ask your Database :**
_Select the **Ask Database** checkbox_ to ask questions about your business data based on the user and tables in the database that you specified when you created the profile.

  ![Ask the database](./images/ask-database.png =70%x*)

  <!---
  --->

Let's experiment a bit with data from the `moviestream` support site.

1. Enter your question using a free form format in the **Ask a question** text box such as _My movie is frozen on the opening scene_. Select the **Ask your database** checkbox is checked since this is a general internet question and also one that uses the internal moviestream support site. Next, click the **Run** icon, or press **[ENTER]**.

    >**Note:** You can type your own natural language question. You don't have to use the exact question that we show in our examples.

    ![Prompt 1: frozen movie](./images/frozen-movie-prompt-1.png =70%x*)

    The suggested answers from the support site and the internet are displayed.

   ![Prompt 1 answer](./images/prompt-1-answer.png =70%x*)

   The result also shows where the answer is located on the moviestream support Web site.
   
    https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/building_blocks_utilities/o/support-site/playback-issues.html

2. Let's ask another question. Click **Clear** in the banner. In the **Ask a question** text box, enter something like, _George Clooney’s lips are moving but I can't hear him_. Select the **Ask Database** checkbox since this is a question about the moviestream internal data. Next, press **[ENTER]**.

    ![Can't hear audio](./images/no-audio.png =70%x*)

    The result from the moviestream support web site using the created vector index is displayed.

    ![No audio issue result](./images/no-audio-result.png =70%x*)

    The result also shows where the answer is located on the moviestream support Web site.
    
    https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/building_blocks_utilities/o/support-site/playback-issues.html

    ![Result on Web site](./images/result-web-site.png =70%x*)

3. Let's ask one more question. Click **Clear** in the banner. In the **Ask a question** text box, enter _My subscription is not recognized_. Select the **Ask Database** checkbox since this is a question about the moviestream data. Next, press **[ENTER]**.

    ![Subscription issue](./images/subscription-issue.png =70%x*)

    The result from the moviestream support web site using the created vector index is displayed.

    ![Subscription issue result](./images/subscription-issue-result.png =70%x*)


  >**Note:** _LLMs are remarkable at inferring intent from the human language and they are getting better all the time; however, they are not perfect! It is very important to verify the results._

You may now proceed to the next lab.

## Learn More
* [Select AI with Retrieval Augmented Generation (RAG)](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai-retrieval-augmented-generation.html#GUID-6B2A810B-AED5-4767-8A3B-15C853F567A2)
* [DBMS\_NETWORK\_ACL\_ADMIN PL/SQL Package](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_NETWORK_ACL_ADMIN.html#GUID-254AE700-B355-4EBC-84B2-8EE32011E692)
* [DBMS\_CLOUD\_AI Package](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/dbms-cloud-ai-package.html)
* [Using Oracle Autonomous AI Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)

## Acknowledgements
  * **Authors:** 
    * Lauran K. Serhal, Consulting User Assistance Developer
    * Marty Gubar, Product Management
* **Last Updated By/Date:** Lauran K. Serhal, November 2025

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (c) 2025 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
