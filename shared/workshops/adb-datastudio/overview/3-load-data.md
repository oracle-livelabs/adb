# Using Load Data to load additional data set


## Introduction

This lab introduces the Load Data application built into the Oracle Autonomous Database and shows how to load new data set.

Estimated Time: 5 minutes

Watch the video below for a quick walk through of the lab.
[](youtube:youtubeid)

## Objectives

In this workshop, you will learn:
-	How to load data from your local file

To complete this lab, you need to have completed the previous labs, so that you have:

- Created an Autonomous Data Warehouse instance
- Created a new QTEAM user with appropriate roles
- demo data loaded

## Task 1: Create local data file for age group

We need to analyze the movie sales data by age group as well. While browsing catalog,
we noticed that there is no age group information, and we need to load a
new table for age group.

For this we will go back to our database actions page by clicking on the
top left button and use Load Data tool.

![Screenshot of data load card](images/image8_load_card.png)

1.  We need to create a local data file for AGE_GROUP. Launch Excel on
    your desktop to create this dataset. Note that you can also use a
    text editor to create this data set since it is small.

![Screenshot of age group data in Excel](images/image9_data_excel.png)

Save this as AGE_GROUP Excel workbook.

If you don't have Excel then create a csv file with the data as below
and save it as AGE_GROUP.csv.

*For copy/pasting, be sure to click the convenient __Copy__ button in the upper right corner of the following data text*: 
    
```
"MIN_AGE","MAX_AGE","AGE_GROUP",

0,20,"00-20",

21,30,"21-30",

31,40,"31-40",

41,50,"41-50",

51,60,"51-60",

61,70,"61-70",

71,80,"71-80",

81,200,"Older than 81",
```

## Task 2: Load age group from local file

1.  Launch Data Load from Database Actions page by clicking on **DATA
    LOAD** card.

    **Note:** that you have various modes for loading data. You can either
    directly load data or leave it in place simply linking it. You can
    also create ongoing feed to load data to Autonomous Database.
    
    You can also load data from either your local file, database or from a
    cloud storage.
    
    In this lab we are loading data from the local file created in earlier
    task. Selected **LOCAL FILE** and press **Next**.

![Screenshot of load data options](images/image10_load_option.png)

2.  Drag your local file AGE_GROUP.xlsx to the load window.

![Screenshot of pick file for load](images/image11_load_file.png)

3.  Press on the green triangle button to start the load.

    After the load is complete, click on the Database Actions link on top
    of the page to go back to the main menu.
    
    Now we all the data sets that we need to complete our assignment.

![Screenshot of start loading file](images/image12_load_file_start.png)

This completes data load overview lab. Note that there are many more features in the data load tool, which are not covered here. These details will be covered in some other in-depth workshop.

You may now **proceed to the next lab**.