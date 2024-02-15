# Allow Users to Connect to Your LLM

## Introduction

You can use different large language models (LLM) with Autonomous Database. In this lab, you will enable the user **`MOVIESTREAM`** to use the LLM that you set up in the previous lab. 

This lab will implement two different types of RESTful services. First, AutoREST can be published quickly and efficiently with only a couple clicks. Secondly, RESTful modules can be created to impelement PL/SQL blocks and SQL queries from an API and managed using the service manager. 

- AutoREST  

![REST API Introduction](./images/intro-restapi.png "")

- RESTful services management 

![REST API Introduction](./images/intro-restapi-two.png "")

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

1. Ensure you are logged in as MOVIESTREAM user. In the navigator, select **CUSTOMER.** 

2. Right click and select **REST** -> **Enable.**

![Enable REST](./images/enable-rest.png "")

## Task 2: Try the REST endpoint. 

1. Click **AutoREST** at the top of the page.

![Click AutoREST](./images/autorest-button.png "")

3. Click the **Open in new tab** for the table CUSTOMER to test the API. 

![Open in new tab](./images/open-new-tab.png "")

Notice that all of the records are displayed in json format without any filters. This api is unprotected and open to the public for consumption. In a production environment with senstive information, it is a best practice to require authentication to the AutoRest Enabled table, which can be accomplished by toggling the switch when editting the REST Enabled Object.

![Authorization toggle button](./images/authorization.png "")

In this example, let's leave it as default (open) for easy access.

## Task 3: (Optional) Access the API using OpenAPI (Swagger) tool. 

1. Navigate back to the REST object exporer by clicking **REST** in the breadcrumbs bar. 

![Rest button](./images/rest-button.png "")

2. Click the modules.

![Modules button](./images/modules.png "")
   
3. Click the ellipsis for the module **api** and select **OpenAPI View**.

![OpenAPI view](./images/open-api-view.png "")

4. Scroll down to the GET for **/ai/supportChatSummary/{chatID}** and click the **arrow** to expand the field.  

5. Paste the following into the ID field and click execute. The number 1 represents a view of a customer ID that was short-handed. Typing any customer ID would produce a similar result.

  ```
  <copy>
  1
  </copy>
  ```

![OpenAPI view for the support chat summary api](./images/support-chat-summary.png "")

Notice the response shows a summary of a chat with a customer. The Cohere model also, describes the sentiment related to it.

6. Additionally, the fields **/ai/thingsToDo/{customerID}** and **/ai/promotion/{customerID}** produces a similar effect. Give them a try before proceeding to the next task.

## Task 4: Create module for API.

Since there is already an existing module created by the Terraform script (named api), let's create a new one that will be utilized by the MovieStreamAI app.

1. Using the breadcrumb menu, select **Modules**.

![Modules breadcrumb button](./images/modules-breadcrumb.png "")

2. Click **Create Module.** 

![Modules create button](./images/create-modules.png "")

3. Name the Module, Base Path, and make sure all the fields match the image and click **Create.**

  ```
  Name:<copy>apiapp</copy>
  ```
  ```
  Base Path:<copy>/apiapp/</copy>
  ```

5. Click on the newly created module **apiapp**. From here, we will create multiple templates for the api to call. The endpoints will be designated by either data collection (named **/data/**) or ai generated responses (named **/ai/**). First, let's create the data collection api for the **recently watched movies**.

6. Click **Create Template.** 

![Template button](./images/create-template.png "")

7. Name the URI template and click **Create**. 

  ```
  URI Template:<copy>/data/image/:cust_id</copy>
  ```

8. Click **Create Handler**.

![Handler button](./images/create-handler.png "")

9.  Paste the following into **Source** and click **Create**.

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

10.  Click **Create Parameter**.
  
![Parameter button](./images/create-parameter.png "")

11.  Name the Parameter and the Bind Variable, change the source type from header to **URI,** and change parameter type from string to **INT.** Click **Create.**

  ```
  Parameter Name:<copy>:cust_id</copy>
  Bind Variable Name:<copy>cust_id</copy>
  ```

## Task 5: Test the module

1. Click **open in new tab** button and paste the following for cust_id

  ```
  cust_id:<copy>1000001</copy>
  ```

![Test module in new window](./images/test-in-new-window.png "")

1. Notice the API displays a JSON response containing an URL for images of the 3 most recently watched movies for only 1 customer, along with some additional details about the movie. Close the new tab when completed.

## Task 6: Create module template for natural language query API. 

1. Using the bread crumb menu, click **apiapp** to navigate back to the templates homepage. Let's create another template for the AI generated response (**/ai/**).

2. Click **Create Template**. 
  
![Template button](./images/create-template.png "")

3. Name the URI template and click **Create.** 

  ```
  URI Template:<copy>ai/moviePizzaRecommendation/:cust_id</copy>
  ```

![uri and create button](./images/uri-create.png "")

4. Click **Create Handler**.

![Handler button](./images/create-handler.png "")

5. Change the source type to **PL/SQL**, paste the following into **Source**, and click **Create**. Here we have designated 3 parameters: 
- **:summary** - defines the response for easy parsing.
- **:cust_id** - passes the variable from the uri into the pl/sql block.
- **:profile_name** - allows for comparison between the two models in the app by passing the variable from the header.

The function genai.get_response is a package created by the terraform script. This can be view optionally by navigating back to the sql worksheet and changing the object viewer to **packages**. Picture is included for reference.

![Genai Package in sql worksheet](./images/genai-package.png "")
  
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

6. Click **Create Parameter**.

![Parameter button](./images/create-parameter.png "")

7. Name the Parameter and the Bind Variable, change the source type from header to **URI**, and then click **Create**.

  ```
  Parameter Name:<copy>cust_id</copy>
  ```
  ```
  Bind Variable Name:<copy>cust_id</copy>
  ```

8. Click **Create Parameter** again.

9. Name the Parameter and the Bind Variable. Click **Create**.

  ```
  Parameter Name:<copy>profile_name</copy>
  ```
  ```
  Bind Variable Name:<copy>profile_name</copy>
  ```

10. Click **Create Parameter** one more time.

11. Name the Parameter and the Bind Variable, change the source type from header to **RESPONSE**. Click **Create**.

  ```
  Parameter Name:<copy>response</copy>
  ```
  ```
  Bind Variable Name:<copy>response</copy>
  ```

The completed **/ai/moviePizzaRecommendation/:cust_id** module is shown below:

![Complete module with all fields shown](./images/movie-pizza-recommendation.png "")


You may now proceed to the next lab.

## Learn More
* [DBMS\_NETWORK\_ACL\_ADMIN PL/SQL Package](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_NETWORK_ACL_ADMIN.html#GUID-254AE700-B355-4EBC-84B2-8EE32011E692)
* [DBMS\_CLOUD\_AI Package](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/dbms-cloud-ai-package.html)
* [Using Oracle Autonomous Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)
* [Overview of Generative AI Service](https://docs.oracle.com/en-us/iaas/Content/generative-ai/overview.htm)

## Acknowledgements
  * **Author:** Marty Gubar, Product Management Lauran K. Serhal, Consulting User Assistance Developer
  * **Contributors:** Stephen Stuart, Nicholas Cusato, Olivia Maxwell, Taylor Rees, Joanna Espinosa, Cloud Engineers 
* **Last Updated By/Date:** Nicholas Cusato, February 2024

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C)  Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
