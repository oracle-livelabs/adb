# Feed data from cloud storage

## Introduction

This lab shows how you can use Data Studio to set up a live feed of data from cloud storage into the Autonomous Database. Feeding data into the database is a useful capability when you have large-scale, regularly added or updated data in cloud storage which is central to your data warehouse, and which will therefore benefit from the performance optimizations of being loaded into the database rather than simply linked from it.

There are two types of live feed:

1. Scheduled, where a feed job runs on a schedule and loads any new or changed data from cloud storage
2. Notification-based, where the addition or update of data in cloud storage triggers a notification to the database to run the feed job

In this lab, we will set up a notification-based live feed. In the lab, we will use Oracle Cloud Infrastructure Object Storage as the cloud object storage system, but the same approach can be used with any other cloud storage system that supports URL-based notifications, including Amazon Web Services S3, Azure Storage, and Google Cloud Platform Storage.

The diagram below shows how a notification-based feed works:

  ![Diagram of the data flow of a notification-based live feed](images/feed-diagram.png)

Estimated Time: 30 minutes

### Objectives

In this lab, you will:

- Set up a new bucket in your cloud storage system, and configure it to send events when objects are changed
- Use the Autonomous Database's built-in Data Studio application to set up a Data Feed job
- Configure notification rules in your cloud storage system to trigger the Data Feed job to check for and load data whenever data in the bucket is added

### Prerequisites

To complete this lab, you need to have completed Labs 1 and 2 in this workshop, so that you have:

- Created an Autonomous Data Warehouse instance
- Created a new QTEAM user

You do not need to have completed Labs 3, 4 or 5.

You will also need login information for Oracle Cloud Infrastructure so that you can set up a new cloud storage bucket and notification rules.

## Task 1: Create a new cloud storage bucket and configure it to send events

1. Log in to Oracle Cloud Infrastructure (OCI) at https://cloud.oracle.com 

>**Note:** See the **Get Started** lab at the beginning of this workshop for instructions to log in to OCI if you are using an Oracle Live Labs account. Otherwise, use your normal OCI credentials to log in to your tenancy.

2. Click the menu in the top left of your screen, and select **Storage**

  ![The Oracle Cloud Infrastructure menu, with the Storage option selected](images/nav-to-storage.png)

3. Under **Object Storage & Archive Storage**, click **Buckets**

  ![The Storage menu, with Buckets highlighted](images/buckets.png)

4. Under **Compartment**, select a suitable compartment for the new storage bucket. 

>**Note:** If you are using an Oracle Live Labs account, select the compartment created with your account. If you are working in your own tenancy, select any suitable compartment where you can create a new storage bucket. The compartment can be, but does not have to be, the same compartment where your Autonomous Database has been created. This example uses a compartment named 'sandbox'.

5. With a suitable compartment selected, click the **Create Bucket** button to set up a new bucket

  ![The Create Bucket option](images/create-bucket-button.png)

6. On the **Create Bucket** screen, set up a bucket with the name **feedlab** and be sure to tick the option to **Emit Object Events**. Keep the other options to the default values. Click on the **Create** button.

  ![The Create Bucket screen with the Emit Object Events option ticked](images/create-bucket.png)

7. We will need a URL so that Data Studio can read the contents of the bucket. Click the menu to the right of the bucket, and select **Create Pre-Authenticated Request**

  ![The bucket menu, with the Create Pre-Authenticated Request option selected](images/create-par.png)

8. Name the pre-authenticated request **feedlab-par** and tick the option to **Enable Object Listing**, leaving the other options to their default values.

  ![The Create Pre-Authenticated Request window, with the option to enable object listing ticked](images/create-par-options.png)

  Click the **Create Pre-Authenticated Request** button.

>**Note:** Pre-authenticated Requests have a default expiry date set a week after creation. For the purposes of this lab, this is fine. However, when you set up a real live feed, you may want to set this well into the future so that the feed continues to work for a while. Alternatively, you can set up the live feed with credentials to the bucket (or use a public bucket) rather than use a pre-authenticated request. If a pre-authenticted request does expire, you can simply create a new one and update the live feed URL in Data Studio.

9. Copy the generated URL of the pre-authenticated request, and paste it into a note or other file, and save it. You will need this later in the lab.

  ![Screen showing the generated URL of the Pre-Authenticated Request, with the copy button highlighted](images/par-uri.png)


## Task 2: Use Data Studio to set up a live data feed

1. From the **Database Actions** launchpad, click the Data Studio's **Data Load** card.

  ![The Database Actions page, with the Data Load card selected](images/launch-data-load.png)

2. Click **Connections** to set up access to your new storage bucket.

  ![The Connections card](images/cloudlocations.png)

3. In the top left, click **Create** then select **New Cloud Store Location**

4. Set up a new cloud location named **MovieSalesData**. Select the **Public Bucket** option, and paste in the URL of the pre-authenticated request you created in Task 1.

  ![The Cloud Location screen, with the Public Bucket selected and the URL pasted in](images/add-feed-location.png)

  Click **Create** to save the location.

5. Click **Data Load** from the menu on the left, or from the breadcrumbs at the top of the screen.

6. Select **Feed Data** from the top list of cards. Note that the **Where is your data?** option automatically switches to **Cloud Store**. Click **Next**.

  ![The Data Load tool, with the Feed Data and Cloud Store options selected](images/feed-data.png)

7. Click the **Create Live Table Feed** button in the top right.

  ![The Create Live Table Feed button](images/create-live-feed.png)

8. Set up the Live Table Feed as shown below, with the **Live Table Feed Name** set to **FEED\_MOVIE\_DATA**, the **Target Table Name** set to **MOVIE\_SALES**, and the **Object Filter** set to **\*.csv**. Then tick the **Enable for Notifications** box, and untick the **Enable for Scheduling** box.

  ![The details of the live feed configuration](images/live-feed-details.png)

  Click the **Create** button to complete the initial setup of the live table feed. 

9. With the live table feed now set up, a URL is generated which we can use to link up to the OCI event generation mechanism. To see and copy the URL, click the menu of the newly created Live Table Feed, and select **Show Notification URL**. 

  ![The live table feed menu with the Show Notification URL option highlighted](images/show-not-url.png)

10. Copy the URL and paste it into a note or other file, and save it. Click OK to close the window.

## Task 3: Set up the event generation mechanism in OCI to trigger the live table feed

1. If you are not already logged in, log in to the OCI Console at https://cloud.oracle.com

2. Search for **notif** in the menu and click the result for **Notifications - Application Integration**.

  ![Search for 'notif' to find Notifications in the OCI Console](images/notif-search.png)

3. Select the same **Compartment** you selected when setting up the cloud storage bucket in Task 1. Then click **Create Topic**.

4. Name the topic **Movie\_sales\_events** as below, and click **Create**.

  ![The Create Topic window](images/create-topic.png)

5. Click the newly created topic, and then on the **Create Subscription** button.

6. Change the **Protocol** to **HTTPS (Custom URL)** and paste in the URL of the Live Table Feed you created in Task 2. Click the **Create** button.

  ![The Create Subscription window](images/create-sub.png)

The subscription is now created. It will show as **Pending** for a couple of minutes, then **Active** once it is live.

> **Note:** There is no need to wait for the subscription to become active before continuing the lab. It will become active while we do the next steps.

7. Next we need to set up event rules that will trigger notifications. In the search box in the top left, search for **events**, and click the **Rules - Events Service** link:

  ![The OCI Console search window, searching, for events, with Rules - Event Service highlighted](images/search-events.png)

8. Click the **Create Rule** button.

9. Set the **Display Name** to 'New\_moviesales\_object'. Then in the **Rule Conditions** section, under **Service Name**, select 'Object Storage', and under **Event Type** select **Object - Create**.

10. In the **Actions** section, under **Action Type** select **Notifications**. The Notifications Compartment should be set to the same compartment you have been using throughout the lab. Select the **Topic** as **Movie\_sales\_events**. The final screen should look as below. Click the **Create Rule** button to confirm the rule addition.

  ![Creation of a rule to notify the OCI topic when an object is created](images/create-rule.png)

  This has now created a rule that will send a notification message to the OCI Topic when an object is created in the bucket, for example when a new file arrives. As the Live Table Feed we set up earlier is subscribed to that topic, it will run when this message is sent, check for any files named *.csv, and load them into the MOVIE\_SALES table.

  If required, we can set up another rule for object update. This should be specified in exactly the same way, but with **Object - Update** selected as the Event Type, and with a display name such as **Updated\_moviesales\_object**.

  This completes the configuration steps needed to trigger the live table feed job to update the Autonomous Database when an object is added or updated in our cloud storage bucket. All we need to do now is test it!

## Task 4: Test the live feed

To trigger the live table feed, we simply need to upload a new csv file into the **feedlab** bucket that we created at the very beginning of the lab. 

1. To do this, first download the following example file to your local machine:

  https://objectstorage.us-ashburn-1.oraclecloud.com/p/YtpqXpUpPx1pPXFQa4Githwxx4bxp12q2yZJsCyzN0Y9-kpYr5nAOvLvwZfLHxXF/n/c4u04/b/moviestream_landing/o/custsales/custsales-2020-10.csv

>**Important:** Your computer may not support downloading files to your local disk. If you are in this situation, you may be able to use another structured csv file with a header row, as this is just an example. 

2. Then navigate back to **Object Storage - Buckets** in the OCI Console as you did in the first few steps in the lab:

  ![The Storage menu, with Buckets highlighted](images/buckets.png)

3. Select your compartment, if not selected already, and click the **feedlab** bucket

  ![The 'feedlab' object storage bucket](images/feedlab-bucket.png)

4. Under **Objects**, click the **Upload** button.

5. Find the **custsales-2020-10.csv** file you just downloaded to your local machine, and click the **Upload** button to upload it.

6. Now go back to the Database Actions launchpad, click the **Data Load** card, select **Feed Data** and **Next** to view the details of your live feed.

7. Click the menu of the live feed, and select **Live Table Feed Run Details** to view information about the live feed.

  ![The live table feed menu with the Live Table Feed Run Details object selected](images/feed-run-details.png)

8. You should now see a preview of the data that has been loaded from the uploaded csv file. Switch to the **Job Report** view from the list on the left. 

  ![The Job Report option for the live feed](images/feed-load-jobs.png)

  Here we can see that a job has just run to load the MOVIE\_SALES table with the 1,019,901 rows that were present in the uploaded csv file.

9. Now click the **Logs** view on the left to see a summary of this job run.

  ![The Logs option for the live feed](images/feed-logs.png)

  This view summarizes all runs of the live feed to show the files that have been loaded, and if there were any errors or rejected rows. In this case, there were none, so we know the data has been loaded completely.

10. To see detailed information about all actions related to the Data Feed, change the selection under **Live Table Run Log Details** from **Loaded Files** to **Log**

  ![Detailed logs for the live feed](images/feed-logs-detail.png)

  This view shows details of all the actions taken for this live feed, including when the OCI subscription was confirmed, when the new file was detected in the bucket, and when the ingest job was triggered. This is also a very useful view to use if something has gone wrong in any of the steps!
  
  This completes the setup of the live table feed. As new csv files with the same structure as the file just uploaded arrive in the cloud object storage bucket, they will automatically be loaded into the MOVIE\_SALES table in the Autonomous Database, to facilitate fast data analysis. 

## RECAP

In this lab, you used Data Studio to set up a notification-based feed of data into the Autonomous Database from cloud storage. This is a very useful option where you have large volumes of data arriving into cloud object storage as files but which you need to participate in performance-critical analysis in the database.

You may now **proceed to the next lab**.

## Acknowledgements

- Created By/Date - Mike Matthews Product Management, Autonomous Database, January 2023
- Contributors - Jayant Mahto, Rick Green
- Last Updated By - Mike Matthews, January 2023
