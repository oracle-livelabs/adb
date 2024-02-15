# Allow Users to Connect to Your LLM

## Introduction

You can use different large language models (LLM) with Autonomous Database. In this lab, you will enable the user **`MOVIESTREAM`** to use the LLM that you set up in the previous lab.

Estimated Time: 20 minutes.

### Objectives

In this lab, you will:
* As the `ADMIN` user, enable users to connect to the LLM REST endpoint
* Grant users privileges to use the **Select AI** APIs
* Test the app

### Prerequisites
- This lab requires the completion of all the preceding labs.

## Task 1: Create bucket to host application

1. In your **Autonomous Database** browser tab, open the **Navigation** menu in the Oracle Cloud console and click **Storage**. Under **Object Storage & Archive Storage**, click **Buckets**. 

2. On the **Buckets** page, select the compartment where you want to create the bucket from the **Compartment** drop-down list in the **List Scope** section. Make sure you are in the region where you want to create your bucket. 

3. Click **Create Bucket**. 

4. In the **Create Bucket** panel, specify the following:
  - **Bucket Name:** Enter **movie_app**. 
  - **Default Storage Tier:** Accept the default **Standard** storage tier. Use this tier for storing frequently accessed data that requires fast and immediate access. For infrequent access, choose the **Archive** storage tier. 
  - **Encryption:** Accept the default **Encrypt using Oracle managed keys**. 

5. Click **Create** to create the bucket.

![Create bucket](./images/create-bucket.png "")

4. Click on the bucket you just made and change visibility to public. 

5. Save changes. 

![Change visibility to public](./images/public-visibility.png "")

## Task 2: Create App and deploy to Object Storage bucket

1. Open up Cloud Shell within the OCI Console. 

![Open Cloud Shell](./images/open-cloudshell.png "")

2. Run the following command:

    ```
    <copy>
    wget https://adwc4pm.objectstorage.us-chicago-1.oci.customer-oci.com/n/adwc4pm/b/wget-link/o/movie-app.zip
    unzip movie-app
    cd movie-app
    </copy>
    ```
3. Update the config file with the APIs used in the Lab **Allow Users to Connect to Your LLM and Data**. Run the following command to edit the file.

  ```<copy>vi ./src/config.ts</copy>```


![update APIs in config.tsx file](./images/update-config.png "")

4. Paste the endpoints into each of the corresponding fields. Press the **Esc** button and then **:wq!** to save and exit.

5.  Run the following commands to Deploy the app.

    ```
    <copy>
    npm i react-scripts
    chmod +x node_modules/.bin/react-scripts
    npm run deploy 
    </copy>
    ```

This script does all the deployment in a few simple commands. First, the src files are pulled from the repository and unzipped. The react-scripts are installed, while permissions are enabled for them. The **npm run deploy** script runs both the build and deploy_to_oci.sh script that implements OCI CLI to bulk upload the build directory to the bucket **movie-app**.

## Task 3: Test app and compare code

The Web page is stored in object storage as a light weight deployment. The script from the previous command used a shell script in the deployment that uses a renaming convention to modify the index.html file to read the objects stored in the directory.

1. Navigate back to the **movie_app** bucket and click the ellipsis for the **index.html** object. Click on **object details**. 

2. Grab the URL and paste into browser. 

![copy url for index.html](./images/react-url.png "")

3. The web page is made using the parallax effect, which moves object in the foreground at different speeds from the background. If you scroll down the page, subtle animations bring the page to life. Each of the components are organized in a directory in the zip file downloaded. Let's open the file in the **OCI Shell**.

4. View the file **App.tsx** by running the command in the shell.

  ```
  <copy>cat ./src/App.tsx</copy>
  ```

5. Click the **double arrow** in the shell to expand the window.

![Print the App.tsx file and expand the window](./images/expand-app.png "")

6. Scroll down to the bottom and notice the return statement that outlines the structure of the app. With the App open, compare the following to better understand the structure.
- First, Parallax is wraps the code so each of the components can move according to the desired effect. The **AdvancedBannerTop** component showcases the effect with the webpage title "MovieStreamAI" floating between the background of the stars and the foreground of the Las Vegas images.
- Secondly, the **{text}** is wrapped in a typewritter effect, which is declared in the script closer to the top.
- Next, the **SearchComponent** fetches the customerData and implements a state change, which displays the RecentlyWatched films cards (click to show the movie details) and Spinner for the ResponseComponent. 
- The **ResponseComponent** uses the {selectedCustID} to pass the variable to the API, which after loading will display a carousel of the recommended movies and details from the **/ai/moviePizzaRecommendation/:cust_id** endpoint. 
- The component **SearchTop** uses a similar Parallax effect as theAdvancedBannerTop component.
- Lastly, the **Map** component pulls the OpenMaps library and displays a map, pulling data from the PizzaShops endpoint.

![Highlighting the structure of the App.tsx file](./images/app-full.png "")

7. Press **F12** on your keyboard to open the **Browser Developer Tools interface** and select **Network** from the header. Refresh the webpage by pressing **ctrl + r** to load all of data that is being fetched when the App is running. 

![Browser Networking](./images/network-f12.png "")


8. Give the app a test drive by selecting a **Customer ID** from the dropdown list. Toggle the switch to **OCIAI_COHERE** and hit the **Search** button.

![Search Customer ID](./images/customer-id-dropdown.png "")

9. The data that is being fetched from the api can be seen in the Browser Developer Tool interface by selecting the endpoints. Click through each of them to see what data is being pulled from the API.
- pizza_shop/
- Customer ID entered in SearchBar (shown 3 times)

![Show API response in DevTools](./images/api-response.png "")

10.  Navigating back to the Cloud Shell, notice the **fetch** command in the **App.tsx** that is implemented above the return function described earlier. This pulls the endpoint set earlier in the config file. At the top, it is imported from this file using the following:

  ```import { CUSTOMER_API_URL, PIZZA_SHOP_API_URL } from './config';```

![Show fetch for both customer and pizza data](./images/fetch-customer-pizza.png "")

11. Similar fetch commands are implemented in the files **SearchComponent.tsx** and **ResponseComponent.tsx**. Use the following commands to investigate how the api is used in a similar method.

  ```<copy>cat ./SearchBar/SearchComponent.tsx</copy>```
  ```<copy>cat ./AI/ResponseComponent.tsx</copy>```

12. The Map component is updated with the information pulled from the customer fetch sequence to set the map coordinates to the coordinates pulled from the AutoREST of the Customer API. Investigate this in the App.tsx file for better understanding. This should give you a general understanding of how the APIs are used in the MovieStreamAI app.



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
    * Lauran K. Serhal, Consulting User Assistance Developer 
* **Last Updated By/Date:** Nicholas Cusato, February 2024

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C)  Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
