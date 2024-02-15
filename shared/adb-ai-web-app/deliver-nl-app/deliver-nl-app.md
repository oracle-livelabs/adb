# Allow Users to Connect to Your LLM

## Introduction

You can use different large language models (LLM) with Autonomous Database. In this lab, you will enable the user **`MOVIESTREAM`** to use the LLM that you set up in the previous lab.

Estimated Time: 10 minutes.

### Objectives

In this lab, you will:
* As the `ADMIN` user, enable users to connect to the LLM REST endpoint
* Grant users privileges to use the **Select AI** APIs
* Test app

### Prerequisites
- This lab requires the completion of **Lab 1: Set up Your Workshop Environment** in the **Contents** menu on the left.

## Task 1: Create bucket to host application

1. Naviagte to **Buckets** using the hamburger menu (storage -> buckets)

2. Click **Create Bucket** 

3. Name the bucket, **movie_app** and click **create.** Leave all other fields as default. 

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
    wget enter zip file here 
    unzip movie-app
    cd movie-app
    npm i react-scripts
    npm run deploy 
    </copy>
    ```

## Task 3: Test app and compare code

The webpage is stored in object storage as a light weight deployment. The script from the previous command used a shell script in the deployment that uses a renaming convention to modify the index.html file to read the objects stored in the directory.

1. Navigate to bucket and click the ellipses. Click on object details. 

2. Grab the URL and paste into browser. 

![copy url for index.html](./images/react-url.png "")

3. The web page is made using the parallax effect, which moves object in the foreground at different speeds from the background. If you scroll down the page, subtle animations bring the page to life. Each of the components are organized in a directory to by component. 

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
* **Last Updated By/Date:** Nicholas Cusato, February 2024

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C)  Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
