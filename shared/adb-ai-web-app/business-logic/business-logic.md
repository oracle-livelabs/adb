# Use Natural Language Queries with ADB Select AI

## Introduction

Using the Natural Language Model makes it simple to query your data in Autonomous Database. The Large Language model and Autonomous Database are able to handle the task of storing and sturcturing data with ease, allowing the user to focus on the end use of the application. In this app, users can will be able to converse with the AI to generate trivia about their favorite movies. 

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

2. Insert the following business rule into the new table by copying and pasting the following into SQL worksheet. 

    ```
    <copy>
    INSERT INTO "MOVIESTREAM"."GENAI_PROJECT" ("ID", "NAME", "QUERY", "TASK", "TASK_RULES")
    VALUES (
    3,
    'Movie Recommendation',
    'with promoted_movie_list as
    (select json_arrayagg(json_object(title, image_url)) as promoted_movie_list
     from movies
     where studio like ''%Amblin%''
    ),
    customer_latest_movies as (
        select 
            s.cust_id,            
            m.title,
            max(s.day_id) as day_id
        from streams s, movies m
        where m.movie_id = s.movie_id
          and s.cust_id = :cust_id
        group by s.cust_id, m.title
        order by day_id desc
        fetch first 3 rows only
    ),
    customer_details as (
        select 
            m.cust_id,
            c.first_name,
            c.last_name,
            c.age,
            c.gender,
            c.pet,
            max(day_id),            
            json_arrayagg(m.title) as recently_watched_movies
        from customer_extension c, customer_latest_movies m
        where 
            c.cust_id = m.cust_id
        group by  
            m.cust_id,
            first_name,
            last_name,
            age,
            gender,
            pet
    )
    select cust_id, first_name, last_name, age, gender, pet, recently_watched_movies, promoted_movie_list 
    from customer_details, promoted_movie_list',
    'Create a movie recommendation in the persona of the top genre of films watched. Follow the task rules.',
    'Recommend 3 movies from the promoted_movie_list that are most similar to movies in the recently_watched_movies list. Include a short synopsis of each movie. Convince the reader that they will love the recommended movies. Recommend a type of pizza that would pair well with each movie.',
    );
    </copy>
    ```

3. In the SQL worksheet, run the following command to generate a simple function that process natural language requests.

    ```
    <copy>
    create or replace function MOVIESTREAM.get_genai_response(
        query_parameter varchar2 default '1192572', 
        project_id number default 1,
        profile_name varchar2 default 'genai'
        ) return clob is
        
        l_prompt clob;
        l_response clob;

    begin

        -- Get the prompt from the project + the query parameter
        l_prompt := get_genai_prompt(
                query_parameter => query_parameter,
                project_id => project_id
        );

        -- Pass the prompt to the model and return the response
        l_response := dbms_cloud_ai.GENERATE(
            prompt => l_prompt,
            profile_name => profile_name,
            action => 'chat'
        );

        return l_response;

        exception
            when others then
                return 'Error generating response.' || chr(10) || sqlerrm;
    end;
    </copy>
    ```
## Task 2: Test the Business Logic 

1. In the SQL worksheet, run the following command to test the business logic function that we just created.

    ```
    <copy>
    SELECT get_genai_response() FROM dual;
    </copy>
    ```  
    
You may now proceed to the next lab.

## Learn More
* [DBMS\_NETWORK\_ACL\_ADMIN PL/SQL Package](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_NETWORK_ACL_ADMIN.html#GUID-254AE700-B355-4EBC-84B2-8EE32011E692)
* [DBMS\_CLOUD\_AI Package](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/dbms-cloud-ai-package.html)
* [Using Oracle Autonomous Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)
* [Overview of Generative AI Service](https://docs.oracle.com/en-us/iaas/Content/generative-ai/overview.htm)

## Acknowledgements
  * **Author:** Marty Gubar, Product Management Lauran K. Serhal, Consulting User Assistance Developer
  * **Contributors:** Stephen Stuart, Nicholas Cusato, Olivia Maxwell, Taylor Rees, Joanna Espinosa, Cloud Engineers 
* **Last Updated By/Date:** Stephen Stuart, January 2024

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C)  Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
