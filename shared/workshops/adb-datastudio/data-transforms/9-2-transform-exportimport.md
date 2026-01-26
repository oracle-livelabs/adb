# Export/Import Data transforms objects


## Introduction

This lab will guide you to the process of exporting and importing data transforms objects from one environment to the other. This feature is primarily used to move from development to QA or to production environment. This can also be used to export a specific version of objects for saving snapshot or versioning purposes. Note that versioning will be external to Data Transforms environment.

Estimated Time: 15 minutes

### Objectives

In this workshop, you will learn how to:
-   Export a set of objects
-	Import objects to a new environment

### Prerequisites

To complete this lab, you need to have completed the previous labs, so that you have:

- Created an Autonomous AI Lakehouse instance
- Created the users DT\_DEMO\_SOURCE and DT\_DEMO\_DW with appropriate roles
- Created a project with some objects (Data Load, Data Flow, Workflow etc.)
- Access to an object store bucket with public access. If you don't have access to your own object store then also you should go through the instructions to learn about this feature.
- User token is available for the OCI user owning the public bucket
- Access to another Autonomous AI Database with an user accessing Data Transforms tool. This will be a target env where we will import the objects. If you don't have access to a new Autonomous AI Database then we will simply delete the objects and import into the same Autonomous AI Database to learn about this feature.

## Task 1: Create an object store connection

1.  We will create a connection to an Object Store for export and import of objects. Click on **Connections** on the left side.

    ![screenshot of the connection menu](../overview/images/image17_transform_conn.png)

2.  There maybe other connections already defined. We will create a new one. Click on **Create Connection**.

    ![screenshot of creating connection](../overview/images/image_dt_003_create_connection.png)

3.  Click on **Oracle Object Storage** icon in the Database section. Then click **Next**.

    ![screenshot of creating connection Object Store](../overview/images/image_dt_003_1_create_connection_ObjectStore.png)

4. Configure connection details as follows:

    **Connection Name**: DT\_demo\_rep\_bucket

    **Object Storage URL**: Your object store bucket url. 

    Enter the URL in the Object Storage URL textbox. You can enter the URL in either of the following formats:
    URL with fully qualified domain name.
    For example:

    ```
    <copy>
    https://`<namespace>`.swiftobjectstorage.`<your-region>`.oci.customer-oci.com/v1/`<your-namespace>/<your-bucket>`
    </copy>
    ```

    ```
    <copy>
    https://`<namespace>`.objectstorage.`<your-region>`.oci.customer-oci.com/n/`<your-namespace>`/b/`<your-bucket>`/o
    </copy>
    ```
    
    If you want to use the URL provided by the OCI Console, specify the URL only till the name of the bucket.
    For example:

    Your bucket URL:
    ```
    <copy>
    https://`<namespace>`.swiftobjectstorage.`<your-region>`.oci.customer-oci.com/v1/`<your-namespace>/<your-bucket>`
    </copy>
    ```

    Use this by removing name of the bucket.
    ```
    <copy>
    https://`<namespace>`.objectstorage.`<your-region>`.oci.customer-oci.com/n/`<your-namespace>`/b/`<your-bucket>`/o
    </copy>
    ```
    
    **User Name**: Owner of the bucket. Enter your Oracle Cloud Infrastructure username. For tenancies that support identity domains, specify the domain name along with the username. For example, `<identity-domain-name>/<username>`.

    **Token**: Authentication token

    Click on **Create**

    ![screenshot of connection configuration](../overview/images/image_dt_004_create_connection_config.png)



## Task 2: Export your objects


## Task 3: Import your objects

5. From Home page click on **Import**.

    ![screenshot of import](images/image_dt_005_create_import.png)

6. Configure import task as follows:

    Object Store Location: DT\_demo\_rep\_bucket

    Import File Name: Export\_Load\_Sales\_Analysis\_20250819203943\_DTR.zip

    Click on **Import**

    ![screenshot of import configuration](images/image_dt_006_create_import_config.png)

    Click **OK** on the next dialog.

    ![screenshot of import configuration OK](images/image_dt_007_create_import_config_OK.png)

7. An import job is submitted. Click **OK** to acknowledge. It will take 1-2 minute for the import to finish. 

    Get a coffee or stretch. We are now ready to learn how Data Transforms helps in transforming the data to any desired shape.

    ![screenshot of import configuration OK Job](images/image_dt_008_create_import_config_OK_job.png)

## RECAP

In this lab, we learned you to export your objects and import them to a target environment.

You may now **proceed to the next lab**.

## Acknowledgements

- Created By/Date - Jayant Mahto, Product Manager, Autonomous AI Database, January 2023
- Contributors - Mike Matthews
- Last Updated By - Jayant Mahto, Aug 2025

Copyright (C)  Oracle Corporation.
