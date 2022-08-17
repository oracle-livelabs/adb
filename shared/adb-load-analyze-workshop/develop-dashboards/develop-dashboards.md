# Develop Self-Service Analytics Cloud Dashboards

## Introduction

This lab will walk you through the steps to create data visualizations using Oracle Analytics Cloud (OAC). You will learn how to immediately gain insights and create beautiful data visualizations.

Estimated Time: 20 minutes

### Objectives
- Learn how to create a simple data visualization project with Oracle Analytics Cloud
- Learn how to access and gain insights from data in the Autonomous Database

### Prerequisites
- This lab requires creation of an Oracle Analytics Cloud instance, or the use of an OAC instance provided by your instructor.
- This lab requires completion of the Provision Autonomous Database lab in the Contents menu on the left.

## Task 1: Create a view by executing this script in SQL Worksheet

Create a `SALES_DASHBOARD` view that you will use to create your analytic dashboard. You can conveniently access the browser-based SQL Worksheet directly from your ADW or ATP console.

[](include:adb-goto-sql-worksheet.md)

3. In a SQL Worksheet, copy and execute the following script.  

    ```
    create or replace view sales_dashboard as
    select
      ce.last_name,
      ce.first_name,
      cs.short_name as customer_segment,
      c.day_id,
      g.name genre,
      m.title,
      m.budget,
      m.gross,
      m.year as released,
      m.cast,
      m.crew,
      m.awards,
      m.nominations,
      1 as views,
      actual_price as sales        
    from customer_extension ce, custsales c, genre g, movie m, customer_segment cs
    where ce.cust_id = c.cust_id
    and g.genre_id = c.genre_id
      and m.movie_id = c.movie_id
      and ce.segment_id = cs.segment_id;

    ```

   ![Paste the code and click Run Script.](./images/execute-script-in-sql-worksheet-to-create-view.png " ")

## Task 2: Create a connection to your Oracle Autonomous Database from Oracle Analytics Cloud

As ADW and ATP accept only secure connections to the database, you need to download a wallet file containing your credentials first. The wallet can be downloaded either from the instance's Details page, or from the ADW or ATP service console.

1. In your database's instance Details page, click **DB Connection**.

    ![Click DB Connection on your database instance page.](./images/dbconnection.png " ")

2. Use the Database Connection dialog to download client credentials.
    - Select a wallet type. For this lab, select **Instance Wallet**. This wallet type is for a single database only; this provides a database-specific wallet.
    - Click **Download Wallet**.

    ![Click Download Wallet.](./images/download-instance-wallet.png " ")

    > **Note:** Oracle recommends that you provide a database-specific wallet, using Instance Wallet, to end users and for application use whenever possible. Regional wallets should only be used for administrative purposes that require potential access to all Autonomous Databases within a region.

3. Specify a password of your choice for the wallet. You will need this password when connecting Oracle Analytics Desktop to the database in the next step. Click **Download** to download the wallet file to your client machine.

    > **Note:** If you are prevented from downloading your Connection Wallet, it may be due to your browser's pop-up window blocker. Please disable it or create an exception for Oracle Cloud domains.

    ![Enter password and confirm password.](./images/password-download-wallet.png " ")

    Click **Close** when the download is complete.
## Task 3: Create a Dataset

4. Start **Oracle Analytics Desktop**. When Oracle Analytics Desktop opens, click **Connect to Oracle Autonomous Data Warehouse**.

   ![Click Oracle Autonomous Data Warehouse in Oracle Analytics Desktop application.](./images/click-connect-to-oracle-autonomous-data-warehouse.png " ")

5. In the **Create Connection** dialog, enter the following information:


   | Connection Info       | Entry                                             |  
   | --------------------- | :--------------------------------------------- |
   | Connection Name:      | Type in '**SALES_HISTORY**'                             |
   | Client Credentials:   | Click '**Select...**' and select the wallet zip file that you downloaded in Task 3.3. A file with .sso extension will appear in the field.   |
   | Username:             | Insert username created in previous labs, likely **ADMIN**. Same username as SQL Worksheet and SQL Developer credentials. |                                            
   | Password              | Insert password created in previous labs. Same password as SQL Worksheet and SQL Developer credentials. |
   |Service Name:         | Scroll the drop-down field and select **adwfinance_high**, or the **high** service level of the database name you specified in Lab 1. |

6. After completing the fields, click **Save**.

   ![Click Save.](./images/create-connection-dialog.png " ")

    > **Note:** If the connection fails to save because you are behind a firewall or on a VPN, you may need to use an alias or shut down the VPN to connect to your ADW database.*

7. Click **Close** when the Save is complete.

8. Upon success of creating a new connection to the Autonomous Data Warehouse, click __Create__ in the upper right-hand corner, and click __Dataset__.  

    ![Click Create and select Data Set.](./images/click-create-data-set.png " ")

9. You will now choose the sales data you want to analyze and visualize in your first project. Select the connection you just created named __SALES_HISTORY__.

   ![Select SALES_HISTORY.](./images/choose_sales_history_connection.jpg " ")

10. In the Untitled Dataset page, expand the __ADMIN__ schema in the Data Warehouse. You will see the DV\_SH\_VIEW table that you defined.

    > **Note:** If you do not see schemas because you are behind a firewall or on a VPN, you may need to use an alias or shut down the VPN to connect to your ADW database.*

   ![Select Admin.](./images/select-admin-schema.png " ")

11. Drag and drop or double click the __DV\_SH\_VIEW__ table to add it to the dataset.

   ![Select DV\_SH\_VIEW.](./images/select-dv-sh-view-from-admin.png " ")

12. Right-click the blue DV\_SH\_VIEW button and select **Edit Definition** from the menu.

   ![Right click blue button and select Edit Definition.](./images/right-click-button-and-select-edit-definition.png " ")

13. First click the __Add All__ button in the left column. You may click __Get Preview Data__ at the bottom to see some example records. Click the __OK__ button to add the dataset.

   ![Click Add All on the left and then click OK on the right.](./images/add-all-data-to-data-set.png " ")

14. Click the **Save Dataset** icon in the upper right corner of the toolbar to save the dataset. In the **Save Dataset As** pop-up dialog, name the dataset **SALES\_HISTORY**. Click **OK**.

    > **Note:** It is important to use the new name of __SALES_HISTORY__, as the rest of the lab steps will reference that name.

   ![Click the Save Dataset icon in upper right corner.](./images/click-save-dataset-icon.png " ")

15. Once the __SALES_HISTORY__ dataset has successfully been created, click the **Go back** arrow on the top left.

   ![Click on the data icon on the upper left.](./images/data-set-results-click-go-back-arrow.png " ")

16. You are returned to the OAD home page; this may take a number of seconds. In the Datasets area at the bottom of your screen, click your new __SALES_HISTORY__ dataset to open it up as a **Project**.

   ![Click SALES\_HISTORY dataset to open as project.](./images/click-sales-history-data-set-to-open-as-project.png " ")

17. By default, the project opens in the **Visualize** tab. Click the **Data** tab to enable overriding the settings of some columns.

   ![Change from the Visualize tab to the Data tab.](./images/change-from-visualize-tab-to-data-tab.png " ")

18. In the middle of the palette, right-click the SALES_HISTORY dataset and select **Open** from the pop-up menu.

   ![Right-click the dataset and select Open.](./images/right-click-dataset-and-open.png " ")

19. This opens a new window filled with data for each column. Notice how easy it is to browse the data elements to see what is available for you to further explore. In the upper left corner, hover your mouse over the icons to see that by default you are in the **Preparation Script** tab. Click the **Data** tab.

    ![By default you are in the Preparation Script tab.](./images/preparation-script-tab.png " ")

    ![Change from the Preparation Script tab to the Data tab.](./images/change-from-preparation-script-tab-to-data-tab.png " ")

20. You are going to override the data types for two columns recognized as measures (i.e. numeric), and correct them to be treated as attributes -- __CALENDAR\_YEAR__ and __CUST\_YEAR\_OF\_BIRTH__. Click the __CALENDAR\_YEAR__ column name in the upper left navigation panel. Details of this column appear in the lower left panel. Change the __‘Treat As’__ field to an __‘Attribute’__. Repeat for the column, __CUST\_YEAR\_OF\_BIRTH__.

   ![Change the data elements appropriately on the left column.](./images/change-treat-as-from-measure-to-attribute.png " ")

21. Click the **Save Dataset** button in the upper right corner. Select **Save** from the pop-up menu. After you receive a message that the dataset was successfully saved, close this dataset window. The untitled project window should still be open.

   ![Click the Save Dataset button and select Save.](./images/click-save-dataset-button.png " ")

## Task 4: Create a workbook and explore the data in your dataset

No matter what your role is in the organization, access to data timely can provide greater insights to improve the performance of your business. Whether you’re creating a data warehouse or a data mart for yourself or others, Autonomous Data Warehouse is making it far simpler than ever before. Easy, fast, and elastic. This small project demonstrates this. This is how business users would interact with the Autonomous Data Warehouse.

1. We will now create a very simple visualization project to finish this part of the lab. Multi-select (ctrl+click) the 5 Data Elements within __SALES\_HISTORY__, including __PROD\_NAME__, __AMOUNT\_SOLD__, __CALENDAR\_YEAR__, __PROD\_CATEGORY__, and __QUANTITY\_SOLD__.  

2. Drag the five selected data elements to the middle of the screen.
   ![Drag the elements to the middle of the screen.](./images/drag-five-columns-to-middle.png " ")

3. Based upon this data, Oracle Analytics Desktop will choose a default visualization. In this example, Oracle Analytics Desktop chose **Scatter** as the Auto Visualization. You can choose among several dozen other diagram types from the Auto Visualization drop-down menu.

   ![Select Scatter on the left column and click Save.](./images/first-visualization-scatter-chart.png " ")

4. You may save this project if you need. Click the **Save** button in the upper right corner. Select **Save** from the drop-down menu. In the **Save Project** dialog, provide a project name and click **Save**. You will receive a message that the project was saved.

    ![Click the Save button and select Save.](./images/click-save-project-button.png " ")

    ![Name the project and click Save.](./images/name-the-project-and-save.png " ")

 At this point, with very few steps, you now have something that can further bring your data to life and you can begin to make some data-driven decisions. As you share this with others, more people will want to gain access to and benefit from the data. To enable this, the Oracle Autonomous Database in ADW or ATP is easy to use, fast, elastic, and will be able to quickly scale to meet your growing data and user base.

## Want to learn more?

See the [documentation](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/user/create-reports-analytics.html#GUID-30A575A6-2CAD-4A8A-971E-2F751C8E6F90) on working with analytics and visualization of data in your Oracle Autonomous Database.

## **Acknowledgements**

- **Author** - Richard Green, Principal Developer, Database User Assistance
- **Last Updated By/Date** - Richard Green, August 2022
