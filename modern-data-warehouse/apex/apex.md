# Create an insight application with APEX


## Introduction

Oracle APEX is a low-code development platform that enables you to build scalable, secure enterprise apps, with world-class features, that can be deployed anywhere. Using APEX, developers can quickly develop and deploy compelling apps that solve real problems and provide immediate value. You won't need to be an expert in a vast array of technologies to deliver sophisticated solutions. Focus on solving the problem and let APEX take care of the rest.

In this Lab we are going to use APEX to visualize the result from all the labs.

Estimated Lab Time: 15 minutes.

### Objectives

In this lab, you will:

* Create an APEX application
* Create simple charts 
* Modify a chart


### Prerequisites

This lab assumes you have done all the other labs.

## Task 1: Create workspace

1. Let's create a new workspace in **APEX** before we create an application. In your **Autonomous Database**, go to **Tools** and then **Oracle APEX**. Finally click on **Open APEX** button.

    ![Select SQL](./images/go-to-apex.png)

2. We need to log in with the admin user. We just need to introduce the password. 

    - **Password:** Password123##
        ```
            <copy>Password123##</copy>
        ```

    ![Select SQL](./images/sign-admin.png)

3. Click on **Create Workspace**.

    ![Select SQL](./images/create-workspace.png)

4. Click on **Existing Schema**.

    ![Select SQL](./images/existing-schema.png)

5. Define the **user**, **workspace** and password. Then click on **Create Workspace**.

    - **Database User:** CNVG. You have to search the database user as you have selected existing schema option previously.
        ```
            <copy>CNVG</copy>
        ```

    - **Workspace Name:** CNVG
        ```
            <copy>CNVG</copy>
        ```

    - **Workspace Username:** CNVG
        ```
            <copy>CNVG</copy>
        ```

    - **Password:** Password123##
        ```
            <copy>Password123##</copy>
        ```

    ![Select SQL](./images/define-workspace.png)

6. Click over **CNVG** to go to the new **workspace**.

    ![Select SQL](./images/new-workspace.png)

7. **Sign in** with the **CNVG** user:

    - **Workspace:** CNVG
        ```
            <copy>CNVG</copy>
        ```

    - **Workspace Username:** CNVG
        ```
            <copy>CNVG</copy>
        ```

    - **Password:** Password123##
        ```
            <copy>Password123##</copy>
        ```

    ![Select SQL](./images/sign-cnvg.png)

## Task 2: Create an application with charts

1. Let's **create our application**. Go to **App Builder** and click on **Create**.

    ![Select SQL](./images/create-app.png)

2. Select **New Application**.

    ![Select SQL](./images/new-app.png)

3. Let's define the **name** for our application. Let's call it **Data Insights**.
    
    - **Name:** Data Insights
        ```
            <copy>Data Insights</copy>
        ```

    ![Select SQL](./images/data-insights.png)

4. Let's add a page to our application. Click on **Add Page**.

    ![Select SQL](./images/add-page.png)

5. Click on **Dashboard**.

    ![Select SQL](./images/add-dashboard.png)

6. This dashboard will **populate 4 charts**. We just need to define what we want to plot. Let's define our **first chart**.

    - **Type:** Pie Chart
    - **Chart Name:** Sentiment Results
        ```
            <copy>Sentiment Results</copy>
        ```
    - **Table or View:** SENTIMENT_RESULTS
    - **Label Column:** EMOTION
    - **Value:** Count
    - **Value Column:** EMOTION

    ![Select SQL](./images/chart1.png)

7. Let's populate our **second chart**.

    ![Select SQL](./images/goto2.png)

    - **Type:** Bar Chart
    - **Chart Name:** Top Followers
        ```
            <copy>Top Followers</copy>
        ```
    - **Table or View:** MV_TWEETS
    - **Label Column:** NAME
    - **Value:** Column Value
    - **Value Column:** FOLLOWERS_COUNT

    ![Select SQL](./images/chart2.png)

8. Let's populate our **third chart**.

    ![Select SQL](./images/goto3.png)

    - **Type:** Bar Chart
    - **Chart Name:** Top Revenue
        ```
            <copy>Top Revenue</copy>
        ```
    - **Table or View:** Revenue
    - **Label Column:** ORDER_TYPE
    - **Value:** SUM
    - **Value Column:** REVENUE

    ![Select SQL](./images/chart3-new.png)

9. Let's populate our **fourth chart**.

    ![Select SQL](./images/goto4.png)

    - **Type:** Pie Chart
    - **Chart Name:** Location Popularity
        ```
            <copy>Location Popularity</copy>
        ```
    - **Table or View:** MV_TWEETS
    - **Label Column:** LOCATION
    - **Value:** COUNT
    - **Value Column:** LOCATION

    ![Select SQL](./images/chart4.png)

10. Click on **Add Page**.

    ![Select SQL](./images/chart4-2.png)

11. Select **Check All** and click on **Create Application**.

    ![Select SQL](./images/terminate-app.png)

12. Let's have first look into our application. Click on the **Run** button.

    ![Select SQL](./images/run-app.png)

13. Log in with the **CNVG** user. Then click on **Sign in**.

    - **Username:** CNVG
        ```
            <copy>CNVG</copy>
        ```

    - **Password:** Password123##
        ```
            <copy>Password123##</copy>
        ```

    ![Select SQL](./images/log-cnvg.png)

14. Click on **Dashboard**.

    ![Select SQL](./images/select-dashboard.png)

15. We can see our insight application with the **reports**.

    ![Select SQL](./images/final-dasbhoard.PNG)




_Congratulations! Well done!_

## Acknowledgements
* **Author** - Javier de la Torre, Principal Data Management Specialist
* **Contributors** - Priscila Iruela, Technology Product Strategy Director
* **Last Updated By/Date** - Javier de la Torre, Principal Data Management Specialist, November 2024


