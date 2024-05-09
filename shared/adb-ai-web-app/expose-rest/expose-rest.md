# Publish AI projects as RESTful services

## Introduction
You created a GenAI project that recommends movies and creates a localized pizza offer. Now, expose that project as a RESTful service.

This lab will implement two different types of RESTful services. First, AutoREST lets you publish a RESTful service quickly and efficiently with only a couple clicks. Second, RESTful modules give you a bit more flexiblity. For example, you can define signatures for those REST endpoints using Swagger or other OpenAPI tools - and then import those definitions into Autonomous Database. After import, you use Autonomous Database's REST editor to implement the handlers for the endpoints.

- AutoREST  

  ![REST API Introduction](./images/intro-restapi.png "")

- RESTful services management 

  ![REST API Introduction](./images/intro-restapi-two.png "")

Estimated Time: 20 minutes.

### Objectives

In this lab, you will:
* Expose tables as REST endpoint
* Test the REST endpoints
* Access the API using OpenAPI tools
* Design and test RESTful module for your AI project
* Export your project to OpenAPI tools

### Prerequisites
- This lab requires the completion of all of the preceding labs.

## Task 1: Create customer and pizza shop REST endpoints using AutoREST
Start by providing access to customer data using AutoREST. This is the easiest way to enable RESTful access to data in Autonomous Database:

1. Ensure that you are logged in as the **MOVIESTREAM** user. In the Navigator pane, select the **CUSTOMER** table.

  ![Select customer](./images/select-customer.png "")

2. Right-click the **CUSTOMER** table, and then select **REST** > **Enable** from the context menu.

  ![Enable REST](./images/enable-rest.png "")

3. In the **REST Enable Object** panel, click **Enable**.

  ![Click Enable](./images/click-enable.png "")

  That's it! Your table is now available via REST.

  >**Note:** The API can be secured by selecting **Require Authentication**. We will keep things simple and not require authentication, which is clearly not a best practice. To learn more about securing REST endpoints, go to [Configuring Secure Access to RESTful Services.](https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/18.4/aelig/developing-REST-applications.html#GUID-5B39A5A6-C55D-452D-AE53-F49431A4DE97).

4. You can test the REST endpoint from a command prompt (we'll test it using other tools later). Right-click **CUSTOMER** and then select **REST** > **cURL command...** from the context menu.
  
  ![test the api](images/click-rest-quick-test.png)

5. In the **cURL for the table CUSTOMER** panel, select the **GET Single** tab, and then enter **1320371** in the cust_id field. Click the **Copy to clipboard** icon. Next, click **Close**.

  ![curl for custid](images/curl-for-custid.png)

6. Open a command prompt on your computer. Paste the curl command and press **[Enter]**. Assuming no firewalls are blocking your access to the service, you will see information about our customer **Betsy Chan**.
  
  ![curl result](images/click-rest-quick-test-result.png)

7. Repeat steps 1-3 for the **PIZZA_SHOP** table.

  ![Enable AUTOrest for pizza_shop](./images/pizza-shop.png "")

## Task 2: Create customer-movie REST endpoint using a module
AutoREST is fast and easy. Your APIs are immediately available to use; however, you may want more control over how your APIs are organized and structured. You can design your APIs using Autonomous Database's REST design tool. Start by creating an API module. See the [Getting Started with RESTful Services](https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/23.4/orddg/developing-REST-applications.html#GUID-25DBE336-30F6-4265-A422-A27413A1C187) documentation for additional information.

1. Ensure that you are still logged in as **MOVIESTREAM** user. Click the **Selector** (hamburger) in the banner, and then click **REST**.
  ![Go to REST](images/goto-rest.png)

2. View the list of modules. In the REST tool, click the **Modules** tab.
  ![Go to modules](images/goto-modules.png =60%x*)

  A module named **api** was created by the Terraform script.
  
  ![The API module.](images/api-modules.png)

3. Let's create a new module that the **MovieStreamAI** app will use. Click **Create Module**.

4. Specify the following for the new module. Make sure all the fields match the image below. Next, click **Create**.

    * **Name:** `apiapp`
    * **Base Path:** `/apiapp/`
    * **Protected By Privilege:** `Not Protected`
  
      ![Completed module form](images/module-completed-form.png)
 
5. The newly created **apiapp** module is displayed. From here, we will create multiple templates that will provide RESTful services. The endpoints will be designated by either data collection (named **data/**) or AI generated responses (named **ai/**).

6. First, let's create the data collection api for the **recently watched movies**. Click **Create Template**. The **Create Template** panel is displayed.

  ![Template button](./images/create-template-one.png "")

7. In the **URI Template** field, enter **`data/image/:cust_id`** as the name for the template. Next, then click **Create**.

    >**Note:** Use the exact name, **`data/image/:cust_id`**. Our React app is expecting that name.

    ![Template button](./images/create-template-two.png =75%x*)

8. Click **Create Handler** to implement the API.

  ![Handler button](./images/create-handler.png "")

9. Copy and paste the following code into **Source** field, and then click **Create**.

    ```
    <copy>
    SELECT 
        M.image_url,
        M.year,
        M.main_subject,
        M.awards,
        M.summary,
        M.gross,
        M.runtime
    FROM 
        MOVIESTREAM.STREAMS S
    JOIN 
        MOVIESTREAM.MOVIES M ON S.MOVIE_ID = M.MOVIE_ID
    WHERE 
        S.CUST_ID = :cust_id
    ORDER BY 
        S.DAY_ID DESC
    FETCH FIRST 3 ROWS ONLY
    </copy>
    ```

  ![Handler with code](./images/image-handler.png "")

10. Add a parameter for the handler. Click **Create Parameter**.
  
  ![Parameter button](./images/create-parameter.png =60%x*)

11. Specify the following in the **Create Parameter** panel.

    * **Parameter Name:** `:cust_id`
    * **Bind Variable Name:** `cust_id`
    * **Source Type:** `URI`
    * **Parameter Type:** `INT`

    The completed panel should look as follows:

    ![The parameter details.](./images/parameter-details.png =70%x*)

12. Click **Create**. The new parameter is displayed.

      ![The parameter is created.](./images/parameter-created.png "")

## Task 3: Test the new customer-movie API

1. Test the handler. Click the **Open in new tab** icon.

  ![Open in new tab](./images/open-new-tab-two.png "")
 
2. In the **Bind Variables** dialog box, enter **`1000001`** for the **cust_id**, and then click **OK**.

  ![Cust_id input](./images/cust_id.png =75%x*)

3. Notice the API displays a JSON response containing an URL for images of the 3 most recently watched movies for only 1 customer, along with some additional details about the movie. Close the new tab when completed.

  ![JSON response.](./images/json-response.png "")

## Task 4: Create REST API for movie recommendations with a pizza offer
This last task will create our final RESTful service. This uses GenAI to recommend movies and a local pizza offer.

1. Click **apiapp** in the breadcrumbs. Let's create another template for the AI generated response (**/ai/**).

2. Click **Create Template**. The **Create Template** panel is displayed.

    ![Create template](./images/create-template-one.png "")

3. In the **URI Template** field, enter **`ai/moviePizzaRecommendation/:cust_id`** as the name for the template. Next, click **Create**.

    >**Note:** Use the exact name, **`ai/moviePizzaRecommendation/:cust_id`**. Our React app is expecting that name.

    ![uri and create button](./images/uri-create.png "")

4. Click **Create Handler**.

    ![Handler button](./images/create-handler-2.png =75%x*)

5. In the **Create Handler** panel, select **PL/SQL** from the **Source Type** drop-down list. Paste the following into **Source** field, and then click **Create**.
    
    ```
    <copy>
    begin
        :summary := genai.get_response ( 
            query_parameter => :cust_id,
            project_id => 4,
            profile_name => :profile_name);
    end;
    </copy>
    ```

    ![Movie handler with code and updated source type](./images/movie-handler.png "")

    The code has 3 parameters that you will define in the next steps:
    - **:summary** - defines the response for easy parsing.
    - **:cust_id** - passes the variable from the uri into the pl/sql block.
    - **:profile_name** - allows for comparison between the two models in the app by passing the variable from the header.

6. Click **Create Parameter**.

    ![Parameter button](./images/create-parameter.png "")

7. Specify the following for the new parameter, and then click **Create**.

    - **Parameter Name:** `cust_id`
    - **Bind Variable Name:** `cust_id`
    - **Source Type:** `URI`

    ![Create cust_id parameter.](./images/cust-id-parameter.png "")

8. Repeat steps 6 and 7 for the following new parameters:

    - **Parameter Name:** `profile_name`
    - **Bind Variable Name:** `profile_name`
    - **Source Type:** `HEADER`

    ![Create profile_name parameter.](./images/profile-name-parameter.png "")

9.  Repeat steps 6 and 7 for the following new parameters:

    - **Parameter Name:** `summary`
    - **Bind Variable Name:** `summary`
    - **Source Type:** `RESPONSE`
    - **Parameter Type:** `STRING`
    - **Access Method:** `Output`

The completed **ai/moviePizzaRecommendation/:cust_id** module is shown below:

![Complete module with all fields shown](./images/movie-pizza-recommendation.png "")

That's it. You'll test this and other APIs in our next lab using the OpenAPI integration.


## Summary
Your APIs are now available! You can test the APIs using the built-in OpenAPI tool or publish the APIs to your favorite OpenAPI tools.

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
* **Last Updated By/Date:** Nicholas Cusato, February 2024

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (c) 2024 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
