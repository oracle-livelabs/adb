# Use Data Tools to load data

## Introduction

Load data on [Oracle Cloud Infrastructure Object Storage](https://www.oracle.com/cloud/storage/object-storage.html) into an Oracle Autonomous Database instance in preparation for exploration and analysis.

Estimated Time: 5 minutes

### Objectives

In this lab, you will:
* Learn how to set up an Oracle Object Storage cloud location
* Learn how to load data from object storage using Data Tools


### Prerequisites

- This lab requires completion of Lab 1, **Provision an ADB Instance**, in the Contents menu on the left.


## Task 1: Load data from files in Object Storage using Data Tools

Autonomous Database supports a variety of object stores, including Oracle Object Storage, Amazon S3, Azure Blob Storage, Google Cloud Storage and Wasabi Hot Cloud Storage ([see the documentation for more details](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/data-load.html#GUID-E810061A-42B3-485F-92B8-3B872D790D85)). In this step, we will load both csv and partitioned parquet files from Oracle Object Storage into tables in our Autonomous Database. 

1. Navigate to the Details page of the Autonomous Database you provisioned in the "Provision an ADB Instance" lab. In this example, the database name is "My Quick Start ADB." Click **Database Actions** to go to the suite of Autonomous Database tools.

    ![Details page of your Autonomous Database](images/service-details.png " ")


1. On the Database Actions home page, under **Data Tools**, click **DATA LOAD**.

    ![Click DATA LOAD](images/dataload.png)
 

2. Under **What do you want to do with your data?** select **LOAD DATA**, and under **Where is your data?** select **CLOUD STORAGE**, then click **Next**

    ![Select Load Data, then Cloud Storage](images/loadfromstorage.png)

3. This is your first time loading data. Click **Done** on the help tip to set up access to a bucket on Oracle Cloud Infrastructure Object Storage. 

    ![Click on Cloud Loactions](images/add-cloud-storage.png)

4. Specify details about the object storage bucket that contains the source data:

    - In the **Name** field, enter 'MovieStreamLanding'.

    > **Note:** Take care not to use spaces in the name.

    - Leave Cloud Store selected as **Oracle**.
    - Copy and paste the following URI into the URI + Bucket field:

    ```
    <copy>
    https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/moviestream_landing/o
    </copy>
    ```

    - Select **No Credential** as this is a public bucket.
    - Click on the **Test** button to test the connection. Then click **Create**.   

5. From the MOVIESTREAMLANDING location, drag the **sales_sample** folder over to the right hand pane. Note that a dialog box appears asking if we want to load all the files in this folder to a single target table. In this case, we have 24 parquet files partitioned by month that we want to load into a single table. Click **OK**.

    ![Select sales_dample](images/select-sales-sample.png)

6. Click on the pencil icon for the **sales_sample** task to view the settings for this load task.

    ![View settings for sales_sample load task](images/view-sales-sample.png)

7. The default action is to **Create Table** from the source. Update the name of the new table from **SALES_SAMPLE** to **CUSTSALES**. Notice the data loader derived the column names and data types from the parquet file contents. 

    ![Update table name to custsales](images/update-sales-sample-name.png)

    Click **Close** after updating the table name.

8. We will create tables and load two more sources. Next, drag the **genre** folder over to the right hand pane. Again, click **OK** to load all files into a single table.

9. Finally, drag the **customer** folder over to the right hand pane. Again, click **OK** to load all files into a single table.

10. Now click on the Play button to run the data load job.

    ![Run the data load job](images/rundataload.png)

    The job should take less than a minute to run.

9. Check that all the data load cards have green tick marks in them, indicating that the data load tasks have completed successfully.

    ![Check the job is completed](images/loadcompleted.png)

10. Review the results of the data load for genre. Click the **GENRE** tile and then select **Table** in the left hand side listing. You will see the list of movie genres that were loaded from its csv source. Then, click **Close** to dismiss the dialog.

    ![List movie genres](images/movie-genres.png)

This completes the Data Load lab. We now have a full set of structured tables loaded into Autonomous Database instance from both csv and parquet files from object storage. We will be working with these tables in the next lab.

Please *proceed to the next lab*.

## Acknowledgements

* **Author** - Mike Matthews, Autonomous Database Product Management
* **Contributors** -  Marty Gubar, Autonomous Database Product Management
* **Last Updated By/Date** - Marty Gubar, Autonomous Database Product Management, November 2021
