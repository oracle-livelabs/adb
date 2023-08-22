# Use Mongo API to interact transparently with Oracle Database

## Introduction

With our JSON Collection created in the Oracle Database, we can use Mongo APIs to interact with the collection as if we were interacting with a Mongo Database. In this lab, we will download Mongo tools and then use a Mongo connection string -- which was configured as a part of the Oracle REST Data Service (ORDS) configuration -- to connect to the Oracle Database using Mongo Shell. We will use the Mongo tools against the Oracle database transparently and natively.

Estimated Time: 15 minutes

Watch the video below for a quick walk through of the lab.
[Watch the video](videohub:1_wv7tziay)

### Objectives

In this lab, you will:

- Install Mongo Shell and Mongo Database Tools
- Load more data into the Oracle Database using MongoDB tools
- Use Mongo Shell to interact transparently with the Oracle Database

### Prerequisites

- Oracle Database 23c Free Developer Release
- ORDS started with MongoDB API enabled
- Password of database user hol23c is set and known


## Task 1: Download Mongo Shell and Mongo Database Tools

_If you closed your terminal window from the previous labs, you need to re-open a terminal window and restart ORDS. Please see Lab 1 for instructions_

This lab has you download software from the YUM repo at repo.mongodb.org. This software is free. If you agree to their terms of use please continue on with this portion of the lab.

1. Open your terminal window.


    Run the following commands to download and install Mongo Shell and Mongo Database Tools.

    ```
    $ <copy>echo "18.67.17.0 repo.mongodb.org" | sudo tee -a /etc/hosts</copy>
    $ <copy>sudo dnf install -y https://repo.mongodb.org/yum/redhat/8/mongodb-org/6.0/x86_64/RPMS/mongodb-mongosh-1.8.0.x86_64.rpm</copy>
    $ <copy>sudo dnf install -y https://repo.mongodb.org/yum/redhat/8/mongodb-org/6.0/x86_64/RPMS/mongodb-database-tools-100.7.0.x86_64.rpm</copy>
    ```
    Your screen will look similar to this after running the commands.
 	![End of mongo install](./images/mongo-install.png)

## Task 2: Basic interaction with Oracle Database using Mongo API

1. First, you must set the URI to the Mongo API running in ORDS on your machine. Copy and paste in the username, password, and host for your database and schema user. If you are using the green button, those values will be as follows: hol23c, Welcome123 (or the password you have chosen), and localhost.

    ```
    $ <copy>export URI='mongodb://<user>:<password>@<host>:27017/<user>?authMechanism=PLAIN&authSource=$external&tls=true&retryWrites=false&loadBalanced=true'</copy>
    ```

    ```
    Example: <copy>export URI='mongodb://hol23c:Welcome123@localhost:27017/hol23c?authMechanism=PLAIN&authSource=$external&tls=true&retryWrites=false&loadBalanced=true'</copy>
    ```

    If you aren't using the green button environment and you have different values for those fields, you may need to escape some characters. Please click [this link](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/mongo-using-oracle-database-api-mongodb.html#ADBSA-GUID-44088366-81BF-4090-A5CF-09E56BB2ACAB) to learn how to escape characters in the URL. 

2. Before we connect to the Mongo Shell, let's populate our database using the Mongo Tools. You will use a document from Object Storage to seed the data in your **movies** collection.

    ```
    $ <copy>curl -s https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/moviestream_gold/o/movie/movies.json | mongoimport --collection movies --drop --tlsInsecure --uri $URI
    </copy>
    ```
    ![Populate the database](images/populate-mongo-db.png " ")

    **Note**: Note that we need to use the option to allow tls communication with invalid Certificates. This is because the ORDS setup in this lab is a simple local install without CA certificate registration. The communication is nevertheless encrypted and safe.

3. Now with the URI set and the Mongo tools installed and the data inserted, we can connect to Mongo Shell. Run the command below to connect.

    ```
    $ <copy>mongosh  --tlsAllowInvalidCertificates $URI
    </copy>
    ```
    ![Connect to the Mongo Shell](images/mongo-shell.png " ")

4. Within the Mongo Shell, you can begin running commands to interact with the data in your database as if you were using a Mongo Database.
A MongoDB "database" is mapped to an Oracle schema when using Oracle Database with MongoDB API. A "collection" is mapped to a table.

    To show what collections exist in my database (schema hol23c) and to count the number of documents we imported in the **movie** collection, or look at a sample document in your collection, run the following commands.

    ```
    hol23c> <copy>show collections</copy>
    hol23c> <copy>db.movies.countDocuments()</copy>
    hol23c> <copy>db.movies.findOne()
    </copy>
    ```

    ![Query result for count](images/mongo-count.png " ")

5. You are using the Oracle Database transparently like a MongoDB. So for example, you can query for specific documents. Run this query to find the document with title "Zootopia."

    ```
    hol23c> <copy>db.movies.find( {"title": "Zootopia"} )
    </copy>
    ```
    ![Query result for Zootopia](images/mongo-zootopia.png " ")

5. Now query for all movies made after 2020.

    ```
    hol23c> <copy>db.movies.find ( { "year": {"$gt": 2020} } )
    </copy>
    ```
    ![Query result for after 2020](images/mongo-2020.png " ")

6. Your filter criteria can obviously become more complex, and you can leverage other functionality of MongoDB or mongosh, like projections, or counting the documents of a filtered search:

    ```
    hol23c> <copy>db.movies.find({"$and": [{"year": {"$gt": 2019}}, {"views": {"$lt": 500} }]},{"year":1, "title":1, "views":1, "budget":1, "awards":1, "_id":0})</copy>
    <copy>db.movies.find({"$and": [{"year": {"$gt": 2019}}, {"views": {"$lt": 500} }]},{"year":1, "title":1, "views":1, "budget":1, "awards":1, "_id":0}).count()
    </copy>
    ```
    ![Query result count for after 2019](images/mongo-2019-cnt.png " ")

Feel free to use your Mongo skills and play with the movies collection to experience the transparency of Oracle's MongoDB API for your Mongo applications. 

**Proceed to the next Lab where we will look a little bit under the hood.**
## Learn More

* [Oracle Database API for MongoDB](https://blogs.oracle.com/database/post/mongodb-api)

## Acknowledgements

* **Author** - William Masdon, Kaylien Phan, Hermann Baer
* **Contributors** -  David Start, Ranjan Priyadarshi
* **Last Updated By/Date** - Hermann Baer, May 2023