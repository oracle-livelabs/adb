# Use Open API tools with your RESTful services

## Introduction
OpenAPI is a specification for building and documenting APIs. It allows developers to describe the structure of their APIs in a standardized format using JSON or YAML, making it easier to understand and work with APIs. OpenAPI specifications can be used to generate interactive documentation, client libraries, and server stubs, streamlining the API development process. There are many tools that you can use with OpenAPI, including Swagger, Postman, and more. 

It's easy to use OpenAPI with Autonomous Database RESTful development. Autonomous Database supports the OpenAPI 3.0 specification, allowing you to both import and export your API modules. This gives you flexibility in your API development:
1. Create your API modules in Autonomous Database, export their definitions, and then document them using your API tools.
2. Design your RESTful services in your OpenAPI tool and then import those definitions into Autonomous Database. Complete the API implementation in Autonomous Database's API design tool.

This lab will show you how to view and test your APIs using OpenAPI. We'll need to capture the endpoint URLs in order to update our web app in the next lab.

Estimated Time: 15 minutes.

### Objectives

In this lab, you will:

* Review and test our REST endpoints
* Export the API definitions for use by OpenAPI tools

### Prerequisites

- This lab requires completion of the previous labs in the **Contents** menu on the left.

## Task 1: Review the customer API created using AutoREST
Let's review our **customer** endpoint. We'll test it and then save the URL.

1.  Make sure that you are still logged in to the Database Actions as the **MOVIESTREAM** user. Click the hamburger menu and then select **REST**.

    ![go to REST](./images/go-to-rest.png)

2. Select the AutoREST tab:
    ![go to AutoREST](./images/go-to-autorest.png)


3. You'll notice our **CUSTOMER** RESTful endpoint. You can view the endpoint in an OpenAPI view. Click the 3 dots on the **CUSTOMER** tile and select **OpenAPI View**:
    ![go to CUSTOMER OpenAPI view](images/openapi-customer-apis.png)

4. This view will look familiar if you use OpenAPI tools; they present the APIs in a very similar way. As you can see, AutoREST exposed numerous APIs for customer. For example, you can add, delete and view customer records. 

    Let's get all customers whose last name includes "Water". Use the **GET** API and apply a JSON query by example parameter:
    - Click **GET** and then click the **Try it out** button.
    - Copy and paste the following code into the parameter field:

        ```
        <copy>
        {"last_name":{"$instr":"Water"}}
        </copy>
        ```
    The form should look as follows:

        ![completed form](images/openapi-customer-qbe-form.png)

5. Click **Execute**

6. Scroll down to the **Response body** section to see the results. You'll find numerous customers whose name contains `Water`:
    ![Names with Water](images/openapi-water-results.png)

## Task 2: Review the movie recommendation API using the OpenAPI view

Let's review the **apiapp** module using the OpenAPI view.

1. Go to the **Modules** tab. You'll see 2 modules.

    - the **api** module that was created by the setup script
    - the **apiapp** module that you created in the previous lab

        ![module list](images/module-list.png =60%x*)

2. Click the 3 dots on the **apiapp** tile and select **OpenAPI view** from the context menu.

    ![go to openapi view for apiapp module](images/goto-apiapp-module.png =60%x*)

3. Test the **ai/moviePizzaRecommendation/{cust_id}**:
    - Click **GET** for API **ai/moviePizzaRecommendation/{cust_id}**
    - Click **Try it out**
    - **cust_id**: `1000001`
    - **profile_name**: `OCIAI_COHERE`.
    
    The completed form should look as follows.

    ![The completed form](images/openapi-movie-recommendation-form.png)
    
4. Click **Execute**.

5. Scroll down to the **Response Body** section to view the recommendations.

    ![The response.](images/response.png =60%x*)

## Task 3: Export your API definitions to an OpenAPI tool
It's easy to export your API signatures to an OpenAPI tool.

1. Go to the **apiapp** module tile and click the 3 dots. Select **Export Module > OpenAPI**
    ![Export to OpenAPI](./images/openapi-export-module.png)
2. You are presented with the OpenAPI 3.0 export file. OpenAPI tools will provide a way to either copy and paste these definitions or import the file:
    ![Resulting document](./images/export-results.png)
3. The example below shows our API used in the OpenAPI plug-in for VSCode. Using the tool, you can document the API, test it and more. 
    ![In an OpenAPI too](./images/openapi-tool-example.png)
    This is just one example. Import these definitions into any number of tools that support OpenAPI - including Swagger, Postman and more.

## Summary    
Autonomous Database makes it easy to develop and test your APIs and integrate them with your favorite OpenAPI tools

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
    * Lauran K. Serhal, Consulting User Assistance Developer
    * Olivia Maxwell, Cloud Engineer
    * Taylor Rees, Cloud Engineer
    * Joanna Espinosa, Cloud Engineer
* **Last Updated By/Date:** Lauran K. Serhal, April 2024

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (c) 2024 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
