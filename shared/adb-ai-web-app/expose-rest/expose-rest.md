# Allow Users to Connect to Your LLM

## Introduction

You can use different large language models (LLM) with Autonomous Database. In this lab, you will enable the user **`MOVIESTREAM`** to use the LLM that you set up in the previous lab.

Estimated Time: 10 minutes.

### Objectives

In this lab, you will:
* Expose tables as REST endpoint
* Test the REST endpoint
* Access the API using OpenAPI (Swagger) tool
* Create module for API 

### Prerequisites
- This lab requires the completion of **Lab 1: Set up Your Workshop Environment** in the **Contents** menu on the left.

## Task 1: Expose as a REST endpoint. 

1. In the navigator, select **CUSTOMER.** 

2. Right click and select **REST** -> **Enable.**

## Task 2: Try the REST endpoint. 

1. Go to the REST visual editor by clicking Hamburger -> **REST**

2. Click AutoREST.

3. Click the **Open in new tab** for the table CUSTOMER to test the API.  

## Task 3: (Optional) Access the API using OpenAPI (Swagger) tool. 

1. Click the elipsise for CUSTOMER and select OpenAPI View.

2. Click GET -> Try it out

3. Paste the following into the ID field and click execute. 

  ```
  <copy>
  1000001
  </copy>
  ```
4. Notice the response shows all the fields realting to that ID number. We can utitlize this within our app and more in our next lab. 

## Task 4: Create module for API.

1. Using the hamburger menu, click **REST.** 

2. Click **Modules.** 

3. Click **Create Module.** 

4. Name the Module, Base Path, and make sure all the fields match the image and click **Create.**

  ```
  Name:<copy>api</copy>
  Base Path:<copy>/api/</copy>
  ```

5. Click on the newly created module. 

6. Click **Create Template.** 

7. Name the URI template and click **Create.** 

  ```
  URI Template:<copy>image/:cust_id</copy>
  ```

8. Click **Create Handler.**

9. Paste the following into **Source** and click **Create.**

  ```
  <copy>
  SELECT M.image_url
  FROM MOVIESTREAM.STREAMS S
  JOIN MOVIESTREAM.MOVIES M ON S.MOVIE_ID = M.MOVIE_ID
  WHERE S.CUST_ID = :cust_id
  ORDER BY S.DAY_ID DESC
  FETCH FIRST 3 ROWS ONLY
  </copy>
  ```

10. Click **Create Parameter.** 

11. Name the Parameter and the Bind Variable, change the source type from header to **URI,** and change parameter type from string to **INT.** Click **Create.**

  ```
  Parameter Name:<copy>:cust_id</copy>
  Bind Variable Name:<copy>cust_id</copy>
  ```
## Task 5: Test the module

1. Click **open in new tab** button and paste the following for cust_id

  ```
  cust_id:<copy>1000001</copy>
  ```

2. Notice the row is retrieved for only 1 customer. 





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
