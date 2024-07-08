# Basic setup for Data Transforms workshop


## Introduction

This lab will guide you to launch Data Transforms and to do basic setup before we start creating data pipeline jobs.

Estimated Time: 15 minutes

### Objectives

In this workshop, you will learn how to:
-   Create a connection
-	Import your data entity definition
-   Create a project

### Prerequisites

To complete this lab, you need to have completed the previous labs, so that you have:

- Created an Autonomous Data Warehouse instance
- Downloaded the database wallet
- Created users DT\_DEMO\_SOURCE and DT\_DEMO\_DW with appropriate roles

## Task 1: Launch Data Transforms

1. Connect to DT\_DEMO\_DW user and navigate to the **Database Actions** page. Click on **Data Transforms** tool under **Data Studio** section.

    ![Screenshot of DT](images/image_data_transforms.png)

2. Enter user name and password for DT\_DEMO\_DW in the login screen and click **Connect**. 

    ![Screenshot of DT Login](images/image_data_transforms_login.png)

    It will launch Transforms service. The service startup time is approximately two minutes. The service is active when you are using the Transforms tool or it is executing a scheduled job. After a fixed idle time the service goes to sleep and starts up again when you want to use it or a background scheduled job executes. You can control the maximum idle time in the Transforms tool configuration for your Autonomous database from OCI console.

    ![Screenshot of DT startup](images/image_data_transforms_startup.png)

    This will take you to the home screen of Data Transforms.

    *Note*: Transforms service goes to sleep when not in use. After it goes to sleep, you can wake it up by refreshing the browser and logging back again. The default maximum idle time is 10 minutes. For the workshop you don't need to change the maximum idle time but if needed, it can be configured from in the Autonomous database tools configuration from OCI console.

    ![Screenshot of DT home](images/image_data_transforms_home.png)


## Task 2: Create connections

1. From the home screen, click on connections from the left side menu. This shows all the connections to your data sources. By default some connection may already have been created but we will create our own connections for this workshop.

    ![Screenshot of DT connections](images/image_data_transforms_connections.png)

2. Click on Create connection. You will see all the supported data sources under Database and Applications section. Data Transforms supports out of the box connections to more than 100 data sources. Many of these connections can also be used as a target. You can refer to the Transforms documentation for the full list and details on how to connect.

    ![Screenshot of DT create connection](images/image_data_transforms_create_conn.png)

3. For this workshop we will use the connection to Oracle database. Click on Oracle database icon in the list and click **Next**.

    ![Screenshot of DT create connection source](images/image_data_transforms_create_conn_source.png)

4. Upload the wallet for your Autonomous database and provide connection authentication information as follows:

    - Connection Name: SOURCE_DATA
    - Use Credential File: Toggle ON (drag and drop the DB wallet file)
    - Service: Select High service from the drop down list
    - Username: DT\_DEMO\_SOURCE
    - Password: your password

    Test the connection and click **Create**.

    ![Screenshot of DT create connection source config](images/image_data_transforms_create_conn_source_config.png)

5. Create another connection similar to above for your data warehouse user DT\_DEMO\_DW

    - Connection Name: DATAWAREHOUSE
    - Use Credential File: Toggle ON (drag and drop the DB wallet file)
    - Service: Select High service from the drop down list
    - Username: DT\_DEMO\_DW
    - Password:

    ![Screenshot of DT create connection data warehouse config](images/image_data_transforms_create_conn_datawarehouse_config.png)

    Test the connection and make sure both the connections test successfully.

## Task 3: Import data entity definition

Now we have all the connectivity we need for the workshop. In order to create data pipeline, Transforms stores a local copy of entity definition. You can initially import the entity definition from your connections and later keep it in sync periodically. 

Note that once imported, the entity definitions in Transforms are isolated from the DDL changes in the respective sources. This provides some flexibility in the design on data pipeline processes. Transforms user is in control of assessing the DDL change in the source definition and evaluating its impact on the existing processes (and making appropriate updates) before syncing the entity definitions. You can also create a new entity in Transforms and use data flow to create the table in the source connection or simply create inline SQL as a view stored in Transforms. Inline SQL will be described in the customizations lab.

1. Navigate to the **Data Entities** menu

    ![Screenshot of DT entity](images/image_dt_entity.png)

2. Click on **Import Data Entities** and provide the following information

    - Connection: SOURCE\_DATA
    - Schema: DT\_DEMO\_SOURCE

    Click **Start**. It will launch a background process which should take around two minutes to complete. 

    Note that you can also provide a mask or decide between tables/views for selectively importing the definitions.

    ![Screenshot of DT entity source](images/image_dt_entity_SOURCE.png)

    Click **OK** on the job notification dialog.

    ![Screenshot of DT entity source job](images/image_dt_entity_SOURCE_job.png)

3. Navigate to the Jobs menu to monitor the entity import job. Refresh the list by clicking on the refresh icon on the right side as needed.

    ![Screenshot of DT entity](images/image_dt_job.png)

4. After successful job completion, go back to **Data Entities** menu and you should be able to see the following table entries:

    - GENRE
    - MOVIE
    - MOVIESALES\_CA
    - TIME

    You can use the left side filter to get the list based on a connection or partial name filter. Note that you may see some more tables in the list depending on the table list in the source DB. Some may have been created by DB processes.

    ![Screenshot of DT entity view](images/image_dt_entity_view.png)

    You can safely delete these tables by using the right side menu. Deleting these tables does not impact your source DB. You are only deleting it from the Transforms' local definition. We will delete any table with "$" in the name (if exist). If you accidentally delete any other table then you can import the definitions again.

    ![Screenshot of DT entity delete](images/image_dt_entity_delete.png)

5. You can also use the Actions menu (three dots at the end) to look at the entity definition and preview the data from the right side menu. Select MOVIESALES\_CA and click on the **Preview** from the Actions menu.

    This the data preview for MOVIESALES\_CA.

    ![Screenshot of DT entity data](images/image_dt_entity_data.png)

6. Go through the similar process to import the entity definitions from your data warehouse connection.

    - Connection: DATAWAREHOUSE
    - Schema: DT\_DEMO\_DW

    After the successful import you should see the following tables in the list for DATAWAREHOUSE connection:
    - AGE\_GROUP
    - CUSTOMER\_CA
    - CUSTOMER\_SALES\_ANALYSIS
    - CUSTOMER\_VALUE


## Task 4: Create project

Project help you to keep related data pipeline processes together.

1. Create a new project. We will use this for our workshop.

    Click on Project menu.

    ![Screenshot of DT project create](images/image_dt_project_create.png)

    Click on **Create Project**. Type in MY\_WORKSHOP and click **Create**.

    Note that you can directly create a data flow from this menu as well by clicking on **Create Data Flow** button. For this workshop we will setup a project first and then start creating data pipeline objects.

    ![Screenshot of DT project create](images/image_dt_project_create_new.png)

## RECAP

In this lab, we launched Data Transforms service and completed the basic setup of creating connections, importing entity definitions and created a project.

You may now **proceed to the next lab**.

## Acknowledgements

- Created By/Date - Jayant Mahto, Product Manager, Autonomous Database, January 2023
- Contributors - Mike Matthews
- Last Updated By - Jayant Mahto, June 2024

Copyright (C)  Oracle Corporation.
