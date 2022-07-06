# Use graph analytics to recommend movies

## Introduction

#### Video Preview

[](youtube:6ik6ahjmYQQ)

Use Oracle Graph analytics to create customer communities based on movie viewing behavior. Once you've created communities - make recommendations based on what your community members have watched.

In this lab you will use graph analytics to identify movies to recommend to customers who are at risk of leaving.

Estimated Time: 10 minutes

### About graph
When you model your data as a graph, you can run graph algorithms on your data to analyze your data based on the connections and relationships in your data. You can also use graph queries to find patterns in your data, such as cycles, paths between vertices, anomalous patterns, and others. Graph algorithms are invoked using a Java or Python API, and graph queries are run using PGQL (Property Graph Query Language, see [pgql-lang.org](https://pgql-lang.org)).

In this lab you will use a graph created from the tables MOVIE, CUSTOMER\_PROMOTIONS, and CUSTSALES\_PROMOTIONS. MOVIE and CUSTOMER\_PROMOTIONS are vertex tables (every row in these tables becomes a vertex). CUSTSALES\_PROMOTIONS connects the two tables, and is the edge table. Every time a customer in CUSTOMER\_PROMOTIONS rents a movie in the table MOVIE, that is an edge in the graph. This graph has been created for you for use in this lab.  

You have the choice of over 60 pre-built algorithms when analyzing a graph. In this lab you will use the **Personalized SALSA** algorithm, which is a good choice for product recommendations. Customer vertices map to *hubs* and movies map to *authorities*. Higher hub scores indicate a closer relationship between customers. Higher authority scores indicate that the vertex (or movie) is plays a more important role in establishing that closeness.

### Objectives

In this lab, you will use the Graph Studio feature of Autonomous Database to:
* Use a notebook
* Run a few PGQL graph queries
* Use python to run Personalized SALSA from the algorithm library
* Query and save the recommendations

### Prerequisites

- This lab requires completion of Lab 1 and Lab 2.

## Task 1: Log into Graph Studio

Graph Studio is a feature of Autonomous Database. It is available as an option under the **Tools** tab. You need a graph-enabled user to log into Graph Studio. When you created the MOVIESTREAM user in Lab 2 you had graph-enabled that user.

1. In your Autonomous Database Details page, click the **Tools** tab and then **Graph Studio**.

    Click **Tools**.

    ![Click Tools](images/toolstab.png " ")    

    Scroll down and click **Graph Studio**.

    ![Scroll down and click Graph Studio](images/graphstudiofixed.png " ")

2. Log in to Graph Studio. Use the credentials for the database user MOVIESTREAM.

    ![Use the credentials for database user MOVIESTREAM](images/task1step2.png " ")

## Task 2: Load a graph into memory

The MOVIE_RECOMMENDATIONS graph has been created for you from the tables CUSTOMER\_PROMOTIONS, CUSTSALES\_PROMOTIONS, and MOVIE (as explained earlier).  You will now load this graph from the database into the in-memory graph server.  

1. Click on the graphs icon.  You will see that the MOVIE_RECOMMENDATIONS graph is available.

    ![Click on the graphs icon](images/task2step1.png " ")

    ![See the list of graphs](images/task2step2.png " ")

2. Click on the 3 dots on the right and select **Load Graph Into Memory**.

    ![Expand the 3 dots on the right](images/task2step3.png " ")

3. Select **Yes**.  Next see that the load into memory is in progress.  About two minutes later the load job has completed.

    ![Select Yes](images/task2step4.png " ")

    ![See the load into memory In Progress](images/task2step5.png " ")

    ![See the load job completed](images/task2step6.png " ")

 Click on the Graphs icon again to see that the graph is now in memory.  

    ![See the graph loaded into memory](images/task2step7.png " ")

## Task 3: Use a notebook to run graph queries and graph analytics

 You can import a notebook that has the graph queries and analytics. Each paragraph in the notebook has an explanation.  You can review the explanation, and then run the query or analytics algorithm.   

  [Click here to download the notebook](files/movie_recommendations_psalsa.dsnb) and save it to a folder on your local computer.  This notebook includes graph queries and analytics for the MOVIE_RECOMMENDATIONS graph.

 1. Import a notebook by clicking on the notebook icon on the left, and then clicking on the **import notebook** icon on the far right.

     ![Click the notebook icon and import the notebook](images/task3step1.png " ")

 Click on the + sign and navigate to the folder where you just downloaded the notebook.  Select the notebook and click on **Import**.

     ![Select the notebook to import and click on Import](images/task3step2.png " ")

 2. Review the description before each paragraph.   Review the graph queries and analytics.   You can then run the query by clicking on the triangle on the top right if you would like to do so.  Below is an example of running a query in a paragraph.  

     ![Click Execute](images/task3step4.png " ")

 You can click on the **Settings** icon to change the visualization parameters.

     ![Click Execute](images/task3step6.png " ")

     ![Click Execute](images/task3step7.png " ")

## Learn more

* [LiveLabs](https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=758&clear=180&session=900372122498)
* [Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-database/graph-studio.html)
* [Get Started](https://www.oracle.com/autonomous-database/graph/get-started/)
* [Webpage](https://www.oracle.com/database/graph/)

## Acknowledgements
* **Author** - Melli Annamalai, Product Manager, Oracle Spatial and Graph
* **Contributors** -  Jayant Sharma
* **Last Updated By/Date** - Rick Green, Database User Assistance, November 2021
