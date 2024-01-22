# Allow Users to Connect to Your LLM

## Introduction

You can use different large language models (LLM) with Autonomous Database. In this lab, you will enable the user **`MOVIESTREAM`** to use the LLM that you set up in the previous lab.

Estimated Time: 10 minutes.

### Objectives

In this lab, you will:
* 

### Prerequisites
- This lab requires the completion of **Lab 1: Set up Your Workshop Environment** in the **Contents** menu on the left.

## Task 1: Expose as a REST endpoint. 

1. In the navigator, select **Procedures.** 

2. Right click and select **REST** -> **Enable.**

## Task 2: Try the rest endpoint. 

1. Go to the REST visual editor by clicking Hamburger -> **REST**

2. Click AutoREST.

3. Go to ASK_QUESTION -> OpenAPI View.

4. Click POST -> Try it out

5. Replace "string" with a question and click Execute.

    ```
    <copy>
    json
    {
    "question": "what are our top 10 movies based on total views"
    }
    </copy>
    ```

## Task 3: (Optional) Design the API using OpenAPI (Swagger) tool. 

1. Right click the REST enabled table. Click on REST. Click on cURL command and copy the code into your clipboard. 

2. Navigate to Swagger. 

    ```
    <copy>
    https://editor.swagger.io/
    </copy>
    ```



2. Paste the following into the editor. 




You may now proceed to the next lab.

## Learn More
* [DBMS\_NETWORK\_ACL\_ADMIN PL/SQL Package](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_NETWORK_ACL_ADMIN.html#GUID-254AE700-B355-4EBC-84B2-8EE32011E692)
* [DBMS\_CLOUD\_AI Package](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/dbms-cloud-ai-package.html)
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
