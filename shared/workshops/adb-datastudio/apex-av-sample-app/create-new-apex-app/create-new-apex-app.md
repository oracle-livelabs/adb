# Create a New Application

## Introduction

Now that you’ve learned how to query hierarchies and analytic views, it's time to build an APEX dashboard. This app will let users interactively explore data using time series and other calculations powered by analytic view expressions.

The sample layout shown in this lab is just a reference. APEX makes it easy to customize appearance and layout. What matters is understanding how APEX items and regions work with analytic views.

**Estimated Time:** 10 minutes

### Objectives

- Create a new APEX application  
- Add a dashboard page

### Prerequisites

- Complete the previous lab.

## Task 1 - Login to APEX

**If you're using APEX outside of Autonomous Database**, log in with the workspace and user you created (e.g., `MOVIESTREAM`).

**If you're using Autonomous Database and have console access**, follow these steps:

1. Open the Autonomous Database Console.

   ![Autonomous Database Console](images/adb-console.png)

2. Scroll to the **APEX instance** section. Click the **Instance name** link.

   ![APEX instance link](images/adb-console-apex-instance-link.png)

3. Click **Launch APEX** (bookmark this page for easy access).

   ![Launch APEX](images/adb-console-launch-apex.png)

4. Log in to the **MovieStream** workspace as the **MovieStream** user.  
   *(Default password: `Welcome#1234`)*

   ![APEX Workspace Login](images/apex-workspace-login.png)

You should now be on the APEX home screen.

## Task 2 - Create a New Application

Follow these steps to create your app and add a dashboard page:

1. Click **App Builder**  
2. Click **Create** or **Create a New Application**  
3. Choose **New Application**  
4. Click **Add Page**  
5. Select **Dashboard**

   ![Choose Dashboard Page](images/add-page-dashboard.png)

6. Set up the dashboard:

- **Page Name:** `Sales Dashboard`  
- **Charts:**
  - Chart 1: `Sales` – Line  
  - Chart 2: `Sales Change Prior Period` – Bar  
  - Chart 3: `Sales Percent Change Year Ago` – Bar  
  - Chart 4: `Sales Share of Genre` – Bar  
- Go to **Advanced**, check **Set as home page**

   ![Add Dashboard Page](images/add-dashboard-page.png)

7. Click **Add Page**  
8. Name the app (e.g., `MovieStream`)  
9. Choose appearance (example used in this lab):

- Theme: `Redwood Light`  
- Navigation: `Top Menu`

10. Click **Save Changes**  
11. Click **Create Application**  
12. Click **Run Application** and log in as the **MOVIESTREAM** user

Congratulations! You now have four placeholder graphs.

![New Dashboard Page](images/new-dashboard-page.png)

You may now **proceed to the next lab** and bring your dashboard to life!

## Acknowledgements

- **Created By** - William (Bud) Endress, Product Manager, Autonomous Database, June 2023  
- **Last Updated By** - William (Bud) Endress, June 2025

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (C) Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation License, Version 1.3 or any later version published by the Free Software Foundation;  with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.  A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
