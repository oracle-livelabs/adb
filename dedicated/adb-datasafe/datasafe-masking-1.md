# Discover and Mask Sensitive Data using Default Masking Formats
## Introduction
Using Data Safe, view sensitive data in your ATP-D database and discover sensitive data by using Data Discovery. Also, mask sensitive data by using the default masking formats in Data Masking and validate.

Estimated Time: 30 minutes

### Objectives
In this lab, you learn how to do the following:
- View sensitive data in your ATP-D database
- Discover sensitive data by using Data Discovery
- Mask sensitive data by using the default masking formats in Data Masking
- Validate the masked data in your ATP-D database

## Task 1: Check for sensitive data using SQL Developer

Connect to ATP-D DB using SQL Developer Web.

Refer to Task 5 from the earlier lab in this workshop, **Assess Users with Oracle Data Safe**.

- In the SQL Developer worksheet, run the following query to select the `EMPLOYEES` table:

    ```
    <copy>SELECT * FROM HCM1.EMPLOYEES</copy>
    ```

- Review the query results. Data such as `employee_id`, `first_name`, `last_name`, `email`, `phone_number`, `hire_date`, `job_id`, `salary`, and `manager_id` are considered sensitive data and should be masked if shared for non-production use, such as development and analytics.
- Keep this tab open so that you can return to it later in part 4 when you view the masked data.

## Task 2: Discover sensitive data using Data Safe Discovery tool

Sign in to the Oracle Data Safe Console in your region.

Refer to the earlier lab in this workshop, **Register a Target Database**.

Discover sensitive data by using Data Discovery.

- Access the **Data Discovery** wizard by clicking the **Data Discovery** tab.

    ![This image shows the result of performing the above step.](./images/img25.png " ")

- The **Select Target for Sensitive Data Discovery** page is displayed.
- Select your target database, and then click **Continue**.
- The Select **Sensitive Data Model** page is displayed.
- Leave **Create** selected, enter **SDM2** for the name, enable **Show and save sample data**, select your resource group, and then click **Continue**.

    ![This image shows the result of performing the above step.](./images/img62.png " ")

- The **Select Schemas for Sensitive Data Discovery** page is displayed.
- Scroll down and select the `HCM1` schema, and then click **Continue**.

    ![This image shows the result of performing the above step.](./images/img63.png " ")

- The **Select Sensitive Types for Sensitive Data Discovery** page is displayed.
- **Expand all** of the categories by moving the slider to the right, and then scroll down the page and review the sensitive types.
- Notice that you can select individual sensitive types, sensitive categories, and all sensitive types.

    ![This image shows the result of performing the above step.](./images/img64.png " ")

- At the top of the page, select the **Select All** check box, and then click **Continue** to start the data discovery job.
- When the job is completed, ensure that the **Detail** column states `Data discovery job finished successfully`, and then click **Continue**.

    ![This image shows the result of performing the above step.](./images/img65.png " ")

- The **Sensitive Data Discovery Result** page is displayed.
- Examine the sensitive data model created by the Data Discovery wizard.
- To view all of the sensitive columns, move the **Expand All** slider to the right. Oracle Data Safe automatically saves your sensitive data model to the Oracle Data Safe Library.

    ![This image shows the result of performing the above step.](./images/img66.png " ")

- From the drop-down list, select **Schema View** to sort the sensitive columns by table.

    ![This image shows the result of performing the above step.](./images/img67.png " ")

- Scroll down the page to view the sensitive columns. You can view sample data (if it's available for a sensitive column), column counts, and estimated data counts. In particular, take a look at the sensitive columns that Data Discovery found in the `EMPLOYEES` table. Columns that do not have a check mark are called referential relationships. They are included because they have a relationship to another sensitive column and that relationship is defined in the database's data dictionary.
- Also view the sample data provided to get an idea of what the sensitive data looks like.
- Scroll to the bottom of the page, and then click **Report** to view the Data Discovery report. The chart compares sensitive categories. You can view totals of sensitive values, sensitive types, sensitive tables, and sensitive columns. The table displays individual sensitive column names, sample data for the sensitive columns, column counts based on sensitive categories, and estimated data counts.

    ![This image shows the result of performing the above step.](./images/img68.png " ")

1. Click the chart's **Expand All** button.
2. Position your mouse over **Identification Info** to view statistics.
3. With your mouse still over **Identification Info**, click the **Expand** button to drill down.
4. Notice that the **Identification Info** category is divided into two smaller categories (**Personal IDs and Public IDs**).
5. To drill-up, position your mouse over an expanded sensitive category, and then click the **Collapse** button.
6. Click the **Close** button (**X**) to close the expanded chart. Continue to work in the wizard.

## Task 3: Mask sensitive data using Data Safe Masking

- Click **Continue to mask the data**.

    ![This image shows the result of performing the above step.](./images/img69.png " ")

- On the **Select Target for Data Masking** page, your target database is selected. Click **Continue**. The **Masking Policy** page is displayed.

    ![This image shows the result of performing the above step.](./images/img70.png " ")

- In the field below **Masking Policy**, enter **Mask1_HCM1** for the masking policy name.
- Move the **Expand All** slider to the right to view all of the sensitive columns.

    ![This image shows the result of performing the above step.](./images/img71.png " ")

- Scroll down the page to view the default masking format selected for each sensitive column.
- For the `HCM1.LOCATIONS.STREET_ADDRESS` column, click the drop down to view other masking formats.

    ![This image shows the result of performing the above step.](./images/img72.png " ")   

- Next to the arrow, click the **Edit Format** button (pencil icon). The **Edit Format** dialog box is displayed.
- View the description, examples, and default configuration for the masking format. This is where you can modify a masking format.
- Click **Cancel**.
- At the bottom of the page, click **Confirm Policy**, and then wait a moment while Data Masking creates the masking policy. The **Schedule the Masking Job** page is displayed.

    ![This image shows the result of performing the above step.](./images/img73.png " ")   

- Leave **Right Now** selected, and then click **Review**. The **Review and Submit** page is displayed.
- Review the information, and then click **Submit** to start the data masking job.

    ![This image shows the result of performing the above step.](./images/img74.png " ")   

- Wait for the data masking job to finish. It takes a couple of minutes. You can follow the status of the job on the **Masking Jobs** page.

    ![This image shows the result of performing the above step.](./images/img75.png " ")

- When the job is finished, click **Report**.   

    ![This image shows the result of performing the above step.](./images/img76.png " ")

- Examine the **Data Masking** report. At the top of the report, you can view the number of values, sensitive types, tables, and columns that were masked. The table shows you column counts for the sensitive categories and types. For each sensitive column, you can view the masking format used and the number of rows masked.

   ![This image shows the result of performing the above step.](./images/img77.png " ")   

- Click **Generate Report**.
- In the **Generate Report** dialog box, leave **PDF** selected, enter **<username> Mask1_HCM1** for the description, ensure your resource group is selected, and then click **Generate Report**.

    ![This image shows the result of performing the above step.](./images/img78.png " ")   

- Wait for the report to generate. When it's generated, click **Download Report**.

    ![This image shows the result of performing the above step.](./images/img79.png " ")

- Access the browser's downloads and open the report in Adobe Acrobat. Review the report, and then close it.

    ![This image shows the result of performing the above step.](./images/img80.png " ")   

## Task 4: Verify masked data through SQL Developer

1. Return to SQL Developer Web. You should still have your query results from Part 2 in this lab.
2. Take a moment to review the data.
3. On the toolbar, click the **Run Statement** button (green circle with a white arrow) to execute the query.
4. If a dialog box is displayed stating that your session has expired, click **OK**, sign in again, and then click the **Run Statement** button.
5. Review the masked data. You can resize the panel to view more data, and you can scroll down and to the right.

You may now **proceed to the next lab**.

## Acknowledgements

*Great Work! You successfully completed the Data Safe Masking Lab 1*

- **Author** - Jayshree Chatterjee
- **Last Updated By/Date** - Kris Bhanushali, Autonomous Database Product Management, March 2022


## See an issue or have feedback?  
Please submit feedback [here](https://apexapps.oracle.com/pls/apex/f?p=133:1:::::P1_FEEDBACK:1).   Select 'Autonomous DB on Dedicated Exadata' as workshop name, include Lab name and issue / feedback details. Thank you!
