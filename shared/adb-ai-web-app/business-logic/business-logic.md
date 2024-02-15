# Use Natural Language Queries with ADB Select AI

## Introduction

Using the Natural Language (NL) Model makes it simple to query your data in Autonomous Database. The Large Language model and Autonomous Database are able to handle the task of storing and sturcturing data with ease, allowing the user to focus on the end use of the application. 

Business logic a key feature of integrating the NL model with the app. By setting these rules, the user is able to access specific use cases for queries.  In this app, the users will generate a table to store the business logic and perform a test operation on it. 

- Example use case for **DBMS_CLOUD_AI.GENERATE** 

![Business Logic Overview](./images/intro-businesslogic.png "")

> **Note:** The prompt is feeding in both the task and data using a profile previously created named "ociai" to generate a email using Generative AI and data from the database. 

Estimated Time: 15 minutes.

### Objectives

In this lab, you will:

* Create the business logic 
* Test the business logic 

### Prerequisites

- This lab requires completion of the first two labs in the **Contents** menu on the left.

## Task 1: Create the business logic 

1. Still logged in as MOVIESTREAM user, create a table by copying and pasting the following into SQL worksheet.

    ```
    <copy>
    CREATE TABLE "MOVIESTREAM"."GENAI_PROJECT" 
   (	
    "ID" NUMBER, 
    "NAME" VARCHAR2(4000 BYTE),
    "QUERY" CLOB,
    "TASK" VARCHAR2(4000 BYTE),
    "TASK_RULES" VARCHAR2(4000 BYTE)
   );
   </copy>
   ```

2. Let's take a look at the Business Logic that was defined by the setup script. It's captured in a table called GenAI_project. 

NOTE: Take screenshot and show how to look at table and preview existing projects then create new one by inserts 

Insert the following business rule into the new table by copying and pasting the following into SQL worksheet. 

    ```
    <copy>
    INSERT INTO "MOVIESTREAM"."GENAI_PROJECT" ("ID", "NAME", "QUERY", "TASK", "TASK_RULES")
        VALUES (1,	'Movie Pizza Recommendation',	'WITH promoted_movie_list AS (
        SELECT
            JSON_OBJECTAGG(title, image_url RETURNING CLOB) AS promoted_movie_list
        FROM
            movies
    )
    SELECT
        M.image_url,
        P.promoted_movie_list
    FROM
        MOVIESTREAM.STREAMS S
    JOIN
        promoted_movie_list P ON 1 = 1 -- Lateral join
    JOIN
        MOVIESTREAM.MOVIES M ON S.MOVIE_ID = M.MOVIE_ID
    WHERE
        S.CUST_ID = :cust_id
    ORDER BY
        S.DAY_ID DESC
    FETCH FIRST 1 ROWS ONLY',
        'Create a movie recommendation. Follow the task rules.',	'Recommend 3 movies from the promoted_movie_list that are most similar to movies in the recently_watched_movies list. Include a short synopsis of each movie. Convince the reader that they will love the recommended movies. Also include a recommend pizza that would pair well with each movie. include the image_url as well. Make it object oriented for easy parsing.')
    </copy>
    ```
    ![Insert GenAI Row](./images/insert-genai-row.png "")

3. Let's take a look at the function that drives the business logic.

## Task 2: Test the Business Logic 

1. In the SQL worksheet, run the following command to test the business logic function that we just created. We have created a view where customer_id's are short-handed. 

    ```
    <copy>
    SELECT get_genai_response(query_parameter => '1', project_id => '1')
    FROM dual
    </copy>
    ```  
    ![Test GenAI function](./images/test-genai-function.png "")
    
You may now proceed to the next lab.

## Learn More
* [DBMS\_NETWORK\_ACL\_ADMIN PL/SQL Package](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_NETWORK_ACL_ADMIN.html#GUID-254AE700-B355-4EBC-84B2-8EE32011E692)
* [DBMS\_CLOUD\_AI Package](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/dbms-cloud-ai-package.html)
* [Using Oracle Autonomous Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)
* [Overview of Generative AI Service](https://docs.oracle.com/en-us/iaas/Content/generative-ai/overview.htm)

## Acknowledgements

  * **Author:** Marty Gubar, Product Management 
  * **Contributors:** 
    * Stephen Stuart, Cloud Engineer 
    * Nicholas Cusato, Cloud Engineer 
    * Olivia Maxwell, Cloud Engineer 
    * Taylor Rees, Cloud Engineer 
    * Joanna Espinosa, Cloud Engineer 
* **Last Updated By/Date:** Stephen Stuart, February 2024

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C)  Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
