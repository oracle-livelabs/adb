# Create a New Application


## Introduction

Now that you know the basics about querying hierarchies and analytic views, it is time to put that knowledge to work.  You will now start building a dashboard application that selects from hierarchies and analytic view. This application will allow users to make interactive data selections. Queries will include time series and other calculations using analytic view expressions.

The application as shown in this lab will have a certain layout and appearance.  It is not important that your application look exactly like this sample application. As an APEX developer, you know that APEX makes it very easy to change the layout and appearance of an application.  What is important is that you learn how items and regions can use analytic views.

Estimated Time:  10 minutes.

### Objectives

In this lab, you will:

- Create new APEX application.
- Add a dashboard page to the application.

### Prerequisites:

- Complete the previous lab.

##  Task 1 - Login to APEX

If you are running APEX on a platform other than Autonomous AI Database, login into APEX as you normally would.  Use the database user (e.g., MOVIESTREAM) and APEX workspace (again, MOVIESTREAM) that was created early in this Live Lab.

If you are running this lab in your tenancy and do not have access to the Autonomous AI Database console,  ask the administrator of the database to provide you with the APEX URL.

If you are running APEX on Autonomous AI Database, and have access to the Autonomous AI Database Console follow the steps below.

1. If you have access to the Autonomous AI Database console, access it now..

![Autonomous AI Database Console](images/adb-console.png)

2. Scroll down until you see APEX instance.  Click on the **Instance name** link.

![APEX instance link](images/adb-console-apex-instance-link.png)

3. Launch APEX.  It would be a good idea to bookmark this link.

![Launch APEX](images/adb-console-launch-apex.png)

3. Sign into the MovieStream workspace as the MovieStream user.  (The password was Welcome#1234 the script used to create the user earlier in this Workshop.)

![APEX Workspace Login](images/apex-workspace-login.png)

You should now be at the APEX main page.

## Task 2 Create a New Application

In this task, you will create a new application.  Feel free to choose a different theme or menu type.

1. Choose **App Builder**.
1. Choose **Create** or **Create a New Application**.
1. Choose **New Application**
1. Choose **Add Page**.
1. Choose **Dashboard**.

![Choose Dashboard Page](images/add-page-dashboard.png)

6. Set up the dashboard as follows.
- Provide a **Page Name**, for example _Sales Dashboard_
- Chart 1: **Name: Sales, Type:  Line**
- Chart 2: **Name: Sales Change Prior Period, Type: Bar**
- Chart 3: **Name: Sales Percent Change Year Ago, Type: Bar**
- Chart 4: **Name: Sales Share of Genre, Type: Bar**
- Choose **Advanced** and **Set as home page**

![Add Dashboard Page](images/add-dashboard-page.png)

7. Press **Add Page**
7. Provide a **Name** for the application, for example _MovieStream_.
7. Choose an appearance. The example in this lab uses:
- **Redwood Light**
- **Top Menu**
10. Press **Save Changes**.
10. Press the **Create Application** button.
10. **Run Application** as the **MOVIESTREAM** user.

Congratulations, you are now the proud owner of four generic graphs!

![New Dashboard Page](images/new-dashboard-page.png)

You may now **proceed to the next lab** and start making the graphs come to life!

## Acknowledgements

- Created By/Date - William (Bud) Endress, Product Manager, Autonomous AI Database, June 2023
- Last Updated By - William (Bud) Endress, May 2024

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C)  Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)