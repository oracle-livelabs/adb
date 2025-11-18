# Develop Self-Service Analytics Cloud Dashboards

## Introduction

> **Important:** _Oracle Analytics Cloud (OAC) is not available with Oracle Cloud Free Tier (Always Free), nor is it supported in Oracle LiveLabs Sandbox hosted environments (the Green button). If you run this workshop using an Always Free database or a LiveLabs Sandbox environment, you can review **Lab 1** and **Lab 5** **without provisioning and using OAC**, and later practice the two labs on **Oracle Autonomous AI Database** and **OAC** in your organization’s own tenancy._

This lab walks you through the steps to create data visualizations using Oracle Analytics Cloud (OAC). You will learn how to immediately gain insights and share powerful dashboards to analyze data in your Autonomous AI Database.

Estimated Time: 20 minutes

Watch the video below for a quick walk-through of the lab.
[Develop Self-Service Analytics Cloud Dashboards](videohub:1_6lsehv31)

### Objectives
- Learn how to create a simple data visualization project with Oracle Analytics Cloud
- Learn how to access and gain insights from data in the Autonomous AI Database

### Prerequisites
- This lab requires creation of an Oracle Analytics Cloud instance, or the use of an OAC instance provided by your instructor.
- This lab requires completion of the Provision Autonomous AI Database lab in the Contents menu on the left.

## Task 1: Create a View

Run a SQL script that will perform two tasks. First, primary keys are defined on tables to ensure uniqueness between rows. Then, foreign key constraints are added that ensure data integrity between tables. These constraints have the added benefit of improving performance.

Next, the script creates a `SALES_DASHBOARD` view that you will use to create your analytic dashboard. This simplifies the usability for analytics users; they can simply use the one view for all of their queries. You can conveniently access the browser-based SQL Worksheet directly from your Autonomous AI Database console.

[](include:adb-goto-sql-worksheet.md)

3. Copy and paste the following code into your SQL Worksheet. Click the Run Script icon in the Worksheet toolbar.

    ```
    <copy>
    -- Add constraints that ensure data integrity and improve performance
    alter table genre add constraint pk_genre_id primary key("GENRE_ID");
    alter table customer_extension add constraint pk_custextension_cust_id primary key("CUST_ID");
    alter table customer_contact add (
                constraint pk_custcontact_cust_id primary key("CUST_ID"),
                constraint fk_custcontact_cust_id foreign key("CUST_ID") references customer_extension("CUST_ID")
                );
    alter table customer_segment add constraint pk_custsegment_id primary key("SEGMENT_ID");
    alter table custsales add (
                constraint fk_custsales_cust_id foreign key("CUST_ID") references customer_contact("CUST_ID"),
                constraint fk_custsales_genre_id foreign key("GENRE_ID") references genre("GENRE_ID")
                );


    create or replace view sales_dashboard as
    select
    ce.last_name,
    ce.first_name,
    cs.short_name as customer_segment,
    ce.income_level,
    case
        when age > 75 then 'Silent Generation'
        when age between 57 and 75 then 'Boomer'
        when age between 41 and 56 then 'Gen X'
        when age between 25 and 40 then 'Millenials'
        when age between 9 and 24 then 'Gen Z'
        end as age_range,
    cc.country,
    cc.city,
    cc.loc_lat as latitutde,
    cc.loc_long as longitude,
    c.day_id,
    g.name genre,
    1 as views,
    actual_price as sales        
    from customer_extension ce, custsales c, genre g, customer_segment cs, customer_contact cc
    where ce.cust_id = c.cust_id
    and ce.cust_id = cc.cust_id
    and g.genre_id = c.genre_id
    and ce.segment_id = cs.segment_id;
    </copy>
    ```

    ![Run Script.](./images/run-script.png " ")
    
    ![Script output.](./images/script-output.png " ")
    
## Task 2: Download a Wallet to Connect Oracle Analytics Cloud to your Autonomous AI Database

You will need to download your wallet credentials file in order for Analytics Cloud to connect to Autonomous AI Database. The wallet will enable both the server and client to verify each other.

1. In the **Database Actions | Launchpad** banner, click the **Selector** menu, and then select **Download Client Credentials (Wallet)**.

    ![Download Client Credentials.](./images/sql-go-to-download-client-credentials.png " ")

2. Specify a password of your choice for the wallet such as `Training4OAC`. You will need this password when connecting Oracle Analytics Cloud to the database in the next step. Click **Download** to download the wallet file to your client machine.

    > **Note:** If you are prevented from downloading your Connection Wallet, it may be due to your browser's pop-up window blocker. Please disable it or create an exception for Oracle Cloud domains.

    ![Enter password and confirm password.](./images/password-download-wallet.png " ")

    In our example, the `wallet.zip` file was downloaded to the **Downloads** folder on our MS-Windows machine.

## Task 3: Create a Dataset in **Oracle Analytics Cloud**

1. Navigate to your **Instance Details** page of the **Oracle Analytics Cloud** (OAC) instance. Open the **Navigation** menu and click **Analytics & AI**. Under **Analytics**, click **Analytics Cloud**.

2. On the **Analytics Instances** page, click your instance name.

3. On the **Instance Details** page, scroll-down to the **Access Information** section, and then click the URL to open the OAC application.

    ![Click the URL to open the OAC application.](./images/click-the-url.png " ")

4. The initial OAC page appears in your browser. Click **Create** in the upper right corner of the banner.

    ![Click Create in Oracle Analytics Cloud initial screen.](./images/click-create.png " ")

5. In the **Create** pop-up window, click **Dataset**.

    ![Click Dataset in the Create pop-up window.](./images/oac-create-dataset.png =60%x*)

6. In the **Create Dataset** dialog box, click **Create Connection**.

    ![Click Create Connection in the Create Dataset dialog.](./images/oac-create-connection.png =65%x*)

7. In the **Create Connection** dialog box, click **Oracle Autonomous Data Warehouse**.

    ![Click Oracle Autonomous Data Warehouse in the Create Connection dialog.](./images/oac-connect-to-adb-pick-type.png =65%x*)

8. In the next **Create Connection** dialog box, enter the following information:

   | Connection Info       | Entry                                             |  
   | --------------------- | :--------------------------------------------- |
   | Connection Name:      | **MovieStream**                             |
   | Description:          | **MovieStream dashboard**                   |
   | Encryption Type:      | Select **Mutual TLS** from the drop-down list                   |
   | Client Credentials:   | Click **Select...**, and then select the `wallet` zip file that you previously downloaded. A file with `.sso` extension will appear in the text field.   |
   | Username:             | **`admin`**|                                            
   | Password:             | Insert the **`admin`** user password that you chose when you provisioned your ADB instance. |
   |Service Name:          | Clickx the drop-down field and select **myquickstart_low**, or the **low** service level of the database name you specified in the Provision an Autonomous AI Database lab. |
   | Authentication:      | Always use these credentials.     |

9. Click **Save**.

    ![Click Save.](./images/click-save-oac-connection.png " ")

10. In the **New Dataset** page, expand **Schemas > ADMIN** and drag and drop the **`SALES_DASHBOARD`** view that you previously created onto the palette to add it to the dataset.

    ![Drag and drop SALES_DASHBOARD view onto the palette.](./images/oac-drag-and-drop-sales-dashboard.png " ")

11. The data is profiled and the following thumbnails are created for each column.

    ![Wait for the Sales Dashboard to load.](./images/oac-sales-dashboard.png " ")

12. Note the 2 tabs at the bottom of the dashboard. The dashboard opens by default in the **Join Diagram** tab. Click the **`SALES_DASHBOARD`** to make updates to how the columns are displayed in the Analytics Cloud Workbook.

    ![Click the SALES_DASHBOARD tab to see the editable dashboard.](./images/oac-update-dataset.png " ")

13. On the right side of the dashboard, note the list of recommended columns to enrich the data.

    ![View the recommendations.](./images/recommendations.png " ")

14. We will keep it very simple and make two updates. First, scroll right to the **`DAY_ID`** column. Double click the card's **`DAY_ID`**.

    ![Rename the DAY_ID column](./images/oac-rename-day.png " ")

    Rename the column from **`DAY_ID`** to **`DAY`**.

    ![DAY_ID column renamed](./images/day-renamed.png " ")

15. Next, update the number format for **`SALES`**. Click the **`SALES`** column to select it, and then click the **#** property to update its format. Next, click the **Auto** link and change the **Number Format** from **Auto** to **Currency**.

    ![Use Properties to update the number format.](./images/oac-format-sales.png " ")

    The sales data is now formatted as currency.

    ![Sales number format is now currency.](./images/sales-currency.png " ")

16. When you are done setting up filters and other options, save the dataset. Click the **Save** icon in the upper right corner, and then select **Save As** from the drop-down list. In the **Save Dataset As** dialog box, enter a name and an optional description, and then click **OK**.

    ![Save the dataset.](./images/oac-save-dataset.png =65%x*)

    The dataset is saved.

    ![The dataset is saved.](./images/oac-saved.png " ")

## Task 4: Create a Workbook and Explore the Data in Your Dataset

Analytics Cloud provides a very intuitive experience for analyzing your data and creating interactive dashboards. Follow these steps to create a very simple, yet highly visual Workbook. And, feel free to explore MovieStream data in many more ways than what's listed here!

The final dashboard is depicted below:

![Final dashboard](images/final-workbook.png)

The tree map on the left describes the MovieStream customers broken out by income level. The size of the boxes is indicative of the number of customers within that income level. Clicking on one of the income levels will filter the chart on the right to summarize the number of movie views for that income level. The chart shows the breakdown of views by customer segment across movie genres.

Let's build the dashboard!

1. When you saved the dataset, a **Create Workbook** button appeared in the upper right corner. Click **Create Workbook**.

    ![Click the Create Workbook button.](./images/click-create-workbook.png " ")  

2. The **New Workbook** page is displayed. This is where you can drag and drop measures and attributes onto the canvas.

    ![The New Workbook page appears.](./images/oac-begin-dashboard.png " ")  

    Close the pane on the right where it is showing the insights.

    ![Close the right pane.](./images/close-right-pane.png " ")  

    ![Right pane closed.](./images/right-pane-closed.png " ")  

3. Drag and drop **VIEWS** onto the canvas. **VIEWS** represents the number of times a movie was viewed.

    ![Drag and drop VIEWS onto the palette.](./images/oac-drag-views.png " ")  

    The Workbook attempts to create the best presentation using **Auto Visualization**. The total number of views is displayed as a tile.

4. Drag and drop **`CUSTOMER_SEGMENT`** onto canvas, and then drop it on the **Category (Chart)** tile.

    ![Drag and customers_segment onto the canvas.](./images/oac-drag-customers-segment.png " ")

    The workbook displays the number of views as a bar chart. Select **Bar** chart from the **Tile**drop-down menu.

    ![Bar chart of views by customers_segment.](./images/views-by-customers-segment.png " ")

    ![Bar chart displayed.](./images/bar-chart-displayed.png " ")

5. Let's now break out each customer segment's views by genre. Drag **`GENRE`** to the **Color** field in the grammar panel.

    ![Drag genere to color.](./images/oac-genere-color.png " ")

6. Update the visualization type to **Stacked Bar**. Click the **Tile**drop-down list, and select **Stacked Bar**.

    ![Finish creating your workbook.](./images/oac-stacked-bar-genre-segment.png " ")

7. Great! Let's now add the tree map. Create a new visualization. Drag **VIEWS** to the left of the stacked bar chart. Drop the measure when you see a **blue vertical bar** running the length of the stacked bar chart.

    ![Add second view to the worksheet.](images/oac-add-second-view.png)

    Again, the number of views is displayed as a tile.

    ![The view is re-displayed.](images/oac-worksheet-add-second-view.png)

8. Drag and drop **INCOME_LEVEL** to the view. 

    ![Drag and drop income_level](images/drag-drop-income-level.png)

9. Change its visualization to **Treemap**. Click the **Tile** drop-down menu and select **Treemap**.

    ![Pick Tree Map from the menu](images/oac-worksheet-pick-treemap.png)

    The new visualization should look like as follows.

    ![Tree Map in green](images/oac-worksheet-treemap-green.png)

9. Make the Tree Map a bit more colorful. Drag and Drop INCOME_LEVEL to the **Color** field.
    ![Colorful Tree Map](images/oac-worksheet-treemap-colorful.png)

10. Finally, use the income level tree map to filter the genre views by customer segment stacked bar. Right click on the tree map, and then select **Use as Filter**.

    ![Use tree map to filter other visualizations by income level](images/oac-worksheet-filter-setup.png)

11. Analyze views by income level, customer segment and genre. Click an income level tile, the chart displays the customer segment and genre by the selected income level.

    ![Analyze views by income level, customer segment and genre](images/oac-worksheet-final.png)

12. Now that you've seen how to create dashboards, create more pages and visualizations!

13. When you are done building your workbook, click **Save** in the upper right corner. Select **Save As**. 

    ![Save the workbook.](./images/oac-save.png " ")

14. In the **Save Workbook** dialog box, enter a name, an optional description, and then click **Save**.

    ![Click Save.](./images/save.png " ")

    Your final workbook should look similar to the following:

    ![Final workbook.](./images/final-workbook.png " ")


At this point, with very few steps, you now have something that can further bring your data to life and you can begin to make some data-driven decisions. As you share this with others, more people will want to gain access to and benefit from the data. To enable this, the Oracle Autonomous AI Database is easy to use, fast, elastic, and will be able to quickly scale to meet your growing data and user base.

You may now **proceed to the next lab**.

## Want to learn more?

* [Create Dashboards and Reports to Analyze and Visualize Your Data](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/user/create-reports-analytics.html#GUID-30A575A6-2CAD-4A8A-971E-2F751C8E6F90)

## **Acknowledgements**

- **Authors:**
    * Lauran K. Serhal, Consulting User Assistance Developer
    * Marty Gubar (Retired), ADB Product Management

- **Last Updated By/Date:** Lauran K. Serhal, October 2025

Data about movies in this workshop were sourced from Wikipedia.

Copyright (C) 2025 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)

