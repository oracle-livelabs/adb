# Use Natural Language Queries with ADB Select AI

## Introduction

Autonomous Database makes it simple to query your data using natural language. The person asking the question doesn't need to know where the data is stored, its structure or how to combine it with other data to get results. All of these tasks are handled by a large language model and Autonomous Database.

As you can see from the previous labs, Select AI makes it easy to build apps that take advantage of natural language queries. In this lab, you'll experiment with a demo app that was built using Oracle APEX. When you ran the scripts to set up your environment, the APEX demo application was also installed. The app is probably the easiest way to get answers about your business and general internet content. Simply ask a question! You can then explore the result, get an understanding of the generated SQL (and even update it if you like), and manage conversations.

Autonomous Database has a built in language (PLSQL) that is feature-rich, fast, optmized for SQL and secure.

Estimated Time: 15 minutes.

### Objectives

In this lab, you will:

* Create the business logic 
* Test the business logic 

### Prerequisites

- This lab requires completion of the first two labs in the **Contents** menu on the left.

## Task 1: Create the business logic 

1. In the SQL worksheet, run the following command to generate a simple procedure that process natural language requests.

    ```
    <copy>
    create or replace procedure ask_question ( 
        question in out varchar2,   -- INOUT : The natural language query
        sqlquery out clob,          -- OUTPUT: The generated SQL statement
        message out clob,           -- OUTPUT: A message: Success or the error
        resultset out SYS_REFCURSOR -- OUTPUT: A cursor that to the output. 
        )    

    is
    begin
        -- Generate the sql for the query
        sqlquery := dbms_cloud_ai.generate (
                    prompt => question,
                    profile_name => 'genai',
                    action => 'showsql'
                    );
                       
        -- Clean up the results. Get rid of new lines and multiple spaces
        sqlquery := replace(sqlquery, chr(10), ' ');
        sqlquery := regexp_replace(sqlquery, ' +', ' ');

        open resultset for sqlquery;

        message := 'success';

        exception
            -- this will pick up a bad sql statement (or a statement that could not be generated)
            when others then
                message := sqlquery;
                sqlquery := null;            
                open resultset for 'select ''unable to generate valid sql'' as item from dual';

    end ask_question;
    /
    </copy>
    ```

## Task 2: Test the business logic

1. In the SQL worksheet, run the following command to test the business logic procedure that we just created.

    ```
    <copy>
    declare
    l_question varchar2(200) := 'what are our total sales';
    l_sqlquery clob;
    l_message clob;
    l_resultset sys_refcursor;
    begin
    moviestream.ask_question(
        question => l_question,
        sqlquery => l_sqlquery,
        message => l_message,
        resultset => l_resultset
    );
    dbms_output.put_line(l_sqlquery);
    dbms_output.put_line(l_message);

    close l_resultset;
    end;
    /
    </copy>
    ```

## Task 3: Build a function and prompt 

1. Create a table to hold all of the business logic prompts. 

    ```
    <copy>
    create table genai_project (
    id number,
    name varchar2(4000),
    query clob,
    task varchar2(4000),
    task_rules varchar2(4000)
    );
    </copy>
    ```
2. (Need to fix code) Insert the following into our new table to allow the user to see the top 3 recommended movies based on recently watched movies. 

    ```
    <copy>
    create or replace function get_custom_email(customer_id number) return clob is
    l_prompt clob;
    l_response clob;

    begin

    l_prompt := q'[{
    "task": "Create a promotional email with a catchy subject line and convincing email text. Follow the task rules.",
    "task_rules": "Recommend 3 movies from the promoted_movie_list that are most similar to movies in the recently_watched_movies list.\n             Include a short synopsis of each movie. \n             Convince the reader that they will love the recommended movies",
    "cust_id": 1192572,
    "first_name": "Stuart",
    "last_name": "Lester",
    "age": 72,
    "gender": "Male",
    "pet": "Cat",
    "recently_watched_movies": [
        "Apocalypse Now",
        "Captain Marvel",
        "Frozen"
    ],
    "promoted_movie_list": [
        {
            "title": "Casper",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/7/7f/Casper_poster.jpg"
        },
        {
            "title": "Hook",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/0/0e/Hook_poster_transparent.png"
        },
        {
            "title": "Schindler's List",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/3/38/Schindler%27s_List_movie.jpg"
        },
        {
            "title": "The Flintstones",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/d/dc/Flintstones_ver2.jpg"
        },
        {
            "title": "Back to the Future",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/d/d2/Back_to_the_Future.jpg"
        },
        {
            "title": "Gremlins",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/3/3d/Gremlins1.jpg"
        },
        {
            "title": "Jurassic Park",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/e/e7/Jurassic_Park_poster.jpg"
        },
        {
            "title": "The Color Purple",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/b/be/The_Color_Purple_poster.jpg"
        },
        {
            "title": "Back to the Future Part II",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/c/c2/Back_to_the_Future_Part_II.jpg"
        },
        {
            "title": "Jurassic Park III",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/6/6d/Jurassic_Park_III_poster.jpg"
        },
        {
            "title": "Twister",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/a/a5/Twistermovieposter.jpg"
        },
        {
            "title": "Who Framed Roger Rabbit",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/3/32/Movie_poster_who_framed_roger_rabbit.jpg"
        },
        {
            "title": "Back to the Future Part III",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/4/4e/Back_to_the_Future_Part_III.jpg"
        },
        {
            "title": "E.T. the Extra-Terrestrial",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/6/66/E_t_the_extra_terrestrial_ver3.jpg"
        },
        {
            "title": "Saving Private Ryan",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/a/ac/Saving_Private_Ryan_poster.jpg"
        },
        {
            "title": "War of the Worlds",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/8/83/War_of_the_Worlds_2005_poster.jpg"
        },
        {
            "title": "Jurassic World",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/6/6e/Jurassic_World_poster.jpg"
        },
        {
            "title": "Men in Black",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/f/fb/Men_in_Black_Poster.jpg"
        },
        {
            "title": "Cape Fear",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/1/1b/Cape_fear_91.jpg"
        },
        {
            "title": "Jurassic World: Fallen Kingdom",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/c/c6/Jurassic_World_Fallen_Kingdom.png"
        },
        {
            "title": "Men in Black 3",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/8/8a/Men_In_Black_3.jpg"
        },
        {
            "title": "The Goonies",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/c/c6/The_Goonies.jpg"
        },
        {
            "title": "Men in Black II",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/3/3d/Men_in_Black_II_Poster.jpg"
        },
        {
            "title": "Minority Report",
            "image_url": "https://upload.wikimedia.org/wikipedia/en/4/44/Minority_Report_Poster.jpg"
        }
    ]
    }]';

    l_response := dbms_cloud_ai.GENERATE(
        prompt => l_prompt,
        profile_name => 'AZURE_AI',
        action => 'chat'
    );

    return l_response;
    end;
    </copy>
    ```

3. 

    ```
    <copy>
    create or replace function get_genai_response(query_parameter varchar2 default '1192572', project_id number default 1) return clob is
    l_prompt clob;
    l_response clob;
    l_query clob;
    l_complete_query clob;

    begin

    select query
    into l_query
    from genai_project
    where id = project_id;

    l_complete_query := 
        'select json_object(g.task, g.task_rules, genai_dataset.*) as prompt
        from genai_project g, 
        (' || l_query || ' 
        ) genai_dataset';

    execute immediate l_complete_query INTO l_prompt USING query_parameter;

    l_response := dbms_cloud_ai.GENERATE(
        prompt => l_prompt,
        profile_name => 'AZURE_AI',
        action => 'chat'
    );

    return l_response;

    exception
        when others then
            return 'Error generating response.' || chr(10) || sqlerrm;
    end;
    </copy>
    ```

You may now proceed to the next lab.

## Learn More

* [Using Oracle Autonomous Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)

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
