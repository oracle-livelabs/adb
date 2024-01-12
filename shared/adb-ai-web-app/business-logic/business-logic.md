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
