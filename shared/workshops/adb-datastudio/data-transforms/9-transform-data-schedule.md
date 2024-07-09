# Scheduling the data pipeline process


## Introduction

This lab introduces you to the in-built scheduler that allows you to schedule your data pipeline process

Estimated Time: 10 minutes

### Objectives

In this workshop, you will learn:
-	How to schedule a process

### Prerequisites

To complete this lab, you need to have completed the previous labs, so that you have:

- Created an Autonomous Data Warehouse instance
- Created users DT\_DEMO\_SOURCE and DT\_DEMO\_DW with appropriate roles
- Imported the demo data
- Used Data Transforms tool, went through previous labs and created a workflow

## Task 1: Create a schedule

So far we were executing the processes directly from the editor window. Such on demand execution is useful for one off process or for debugging. However, in a data integration implementation you will have a need to execute the process on a periodic basis. This will be accomplished by creating a schedule for the process. 

1. Navigate to your project and click on **Schedules** from left side menu. Then click on **Create Schedule**. Configure it as follows.

    - Name: LOAD\_DATAWAREHOUSE
    - Resource: Workflow
    - Resource Name: Nightly\_Load
    - Frequency: Hourly
    - Time: 3 Minutes, 0 seconds
    - Status: Active

    Click on **Save** to create the schedule. This schedule will run in 3 minutes and then after every hour. 

    Note that you can schedule the job to any other frequency, daily or weekly at a certain time. For our exercise we did it hourly starting in 3 minutes so that we can check the progress quickly.

    ![Screenshot of create schedule](images/image_sc_01_create_sc.png)

2. Now the schedule is created and the workflow will be executed at the assigned time. Note that you can activate/de-activate any schedule by editing it. After testing your schedule, you should de-activate it so that it doesn't keep running in the background. Lets go to the jobs menu in three minutes and check. You should be able to see your job running.

    ![Screenshot of scheduled job](images/image_sc_01_jobs.png)

## RECAP

In this lab, we used the Data Transforms tool to create a schedule for a data pipeline process. One can have multiple schedule for different processes.

Now you have gone through the basic features of Data Transforms and should be ready to design and implement a data integration process based on your real world requirement.

This concludes Data Transforms workshop.

## Acknowledgements

- Created By/Date - Jayant Mahto, Product Manager, Autonomous Database, January 2023
- Contributors - Mike Matthews
- Last Updated By - Jayant Mahto, June 2024

Copyright (C)  Oracle Corporation.
