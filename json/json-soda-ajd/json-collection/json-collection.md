# Working with JSON collections using the SODA (Simple Oracle Document Access) API

## Introduction

Oracle is a relational database, meaning it typically stores data in rows and column of tables and JSON can be stored as a column value. For this lab though we first focus on the Document Store API SODA (Simple Oracle Document Access) which allows to store JSON data in a so-called collection. A JSON collection stores JSON documents alongside some metadata like the time of creation or update. Collections offer operations like inserts, deletes, index creation or queries.

In order to create a collection all you have to specify is the collection's name. Unlike a relational table you do not have to provide any schema information. So, lets create a collection for the products we want to sell in the store.

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

* Create Collection
* Insert First Document
* Find JSON documents in a collection
* Learn about JSON and Constraints
* Load more data through the Database API for MongoDB

### Prerequisites

* Have provisioned an Autonomous JSON Database instance and logged into the JSON

## Task 1: Create Collection

1. To create a collection, click **Create Collection**.

	![Create Collection](./images/create-collection.png)

2. Provide a name for your collection in the field **Collection Name - products** and click **Create**. MAKE SURE you check the **MongoDB Compatible** box. Note that the collection name is case-sensitive. You must enter products in all lower-case, don't use PRODUCTS or Products.

	![New collection: products](./images/new-products.png)

3. A notification pops up that displays `products` collections is created.

	![New collection notification](./images/popup.png)

4. Click the refresh button to verify `products` collection is created.

	![Refresh button](./images/refreshed.png)

## Task 2: Insert Documents

1. Double click **products** collection to show the **JSON-products** worksheet.

	![products worksheet](./images/double-clicked.png)

2. Click New JSON Document button.

	![new document button](./images/new-document.png)

3. A New JSON Document panel displays. Copy the following JSON object, paste it in the worksheet and click **Create**.

	```
	<copy>
	{
		"_id": 100,
		"type":"movie",
		"title": "Coming to America",
		"format": "DVD",
		"condition": "acceptable",
		"price": 5,
		"comment": "DVD in excellent condition, cover is blurred",
		"starring": ["Eddie Murphy", "Arsenio Hall", "James Earl Jones", "John Amos"],
		"year": 1988,
		"decade": "80s"
	}
	</copy>
	```

	![add new document](./images/paste1.png)

4. A notification pops up that says A New Document is created and the new document is shown in the bottom section of the JSON workshop.

	![new document confirmation popup](./images/popup2.png)

5. Let's repeat this with the following documents:

	Click New JSON Document button, copy the following JSON objects one by one, paste it in the worksheet and click **Create**.

    ```
	<copy>
	{
		"_id": 101,
		"title": "The Thing",
		"type": "movie",
		"format": "DVD",
		"condition": "like new",
		"price": 9.50,
		"comment": "still sealed",
		"starring": [
			"Kurt Russel",
			"Wilford Brimley",
			"Keith David"
		],
		"year": 1982,
		"decade": "80s"
	}
	</copy>
	```

	```
	<copy>
	{
		"_id": 102,
		"title": "Aliens",
		"type": "movie",
		" format ": "VHS",
		"condition": "unknown, cassette looks ok",
		"price": 2.50,
		"starring": [
			"Sigourney Weaver",
			"Michael Bien",
			"Carrie Henn"
		],
		"year": 1986,
		"decade": "80s"
	}
	</copy>
	```

	```
	<copy>
		{
		"_id": 103,
		"title": "The Thing",
		"type": "book",
		"condition": "okay",
		"price": 2.50,
		"author":"Alan Dean Forster",
		"year": 1982,
		"decade": "80s"
	}
	</copy>
	```

## Task 3: Find JSON documents in a collection

Documents can be selected based on filter conditions - we call them 'Queries By Example' or 'QBE' for short. A QBE is a JSON document itself and it contains the fields and filter conditions that a JSON document in the collection must satisfy in order to be selected. QBEs are used with SODA (only); you can use SQL functions as an alternative.

The simplest form of a QBE just contains a key-value pair. Any selected document in the collection must have the same key with the same value. More complex QBEs can contain multiple filter conditions or operators like 'negation' or 'and', etc.

The following are examples for QBEs. You can copy them into the corresponding window (see screenshot) and execute them. Obviously, in a real application those QBE-expressions would be issued directly from the programming language - the SODA drivers have APIs for common application programming languages: Python, etc.

Now let's issue some simple queries on the *products* collection we just created.

1. Copy and paste the following queries in the worksheet and click Run Query button to run a query.

2.  Lookup by one value:

	Here, it displays the document whose id value is 101.

	```
	<copy>
	{"_id":101}
	</copy>
	```
	![doc with id 101](./images/id101.png)
	![id 101 results](./images/id101-results.png)

3.	Find all DVDs:

	Running the query will displays two documents with format DVD.

	```
	<copy>
	{"format":"DVD"}
	</copy>
	```
	![DVD search results](./images/dvd-results.png)

4.	Find all non-movies:

	This query displays the documents that are not of type - movies, which means just the document with id 103.

	```
	<copy>
	{"type":{"$ne":"movie"}}
	</copy>
	```
	![results for "not movies" search](./images/not-movies.png)

5.	Find documents whose condition value contains "new", which means just document (with id) 101.

	```
	<copy>
	{"condition":{"$like":"%new%"}}
	</copy>
	```
	![condition is new results](./images/new.png)

6. Find bargains of all products costing 5 or less:

	This query displays the documents with ids 100, 102 and 103 as those documents have price less than 5.

	```
	<copy>
	{"price":{"$lte":5}}
	</copy>
	```
	![results for price less than 5](./images/less5.png)

7. Tighten previous query to choose only movie documents:

	This query displays the documents whose ids are 100, 102 as those documents have price less than 5 and not the type - book.

	```
	<copy>
	{"$and":[{"price":{"$lte":5}}, {"type":"movie"}]}
	</copy>
	```
	![price less than 5 and not type = book ](./images/less5-movie.png)

## Task 4: JSON and Constraints

JSON data is "schema flexible", you can add whatever data you like to a JSON document. But sometimes you will wish to impose some required structure on that data. That can be done through SQL by creating indexes and/or constraints on the JSON collection.

An index will aid fast access to an item (for example speeding up access via the "title" field), but can also be used to impose uniqueness (a unique index or primary key constraint), or to enforce particular datatypes (by triggering an error if the datatype is not what is expected).

More generally, constraints can be used to check the data being entered for various aspects.

1.  Let's add a check - or 'constraint' to check our data entry. We will do this using SQL Developer Web. Click the navigation menu on the top left and select **SQL** under Development.

	![SQL navigation](./images/nav.png)

8. Check constraint to make sure every product has a title of string data type and price >=0. 

	Add a constraint to make sure that every item has at least a title and the price. We want the price to be a non-negative number and title to be a string.

	Copy and paste the query below in the worksheet and click Run query button to run the SQL query to alter products table and add constraints.

	```
	<copy>
	alter table products add constraint required_fields 
		check (
				JSON_EXISTS(data, '$?(@.title.type() == "string" && @.price.number() > 0)')
			  );
	</copy>
	```
	![add constraint](./images/sql-query.png)

	JSON_Exists is a SQL/JSON function that checks that a SQL/JSON path expression selects at least one value in the JSON data. The selected value(s) are not extracted – only their existence is checked. Here, *$?(@.title.type() == "string" && @.price.number() > 0)* i a standard, SQL/JSON path expressions. You'll learn more about SQJ/JSON functions later in this lab.

9. Once the *products* table is altered, navigate back to JSON workshop. Click the navigation menu on the top left and select **JSON** under Development.

	![JSON navigation](./images/nav2-json.png)

10. Validate that the following documents cannot get inserted as fields are missing or of wrong type.

	Click New JSON Document icon, copy and paste the following query in the worksheet and click **Create**.

	Throws the error "Unable to add new JSON document" since the following document has missing fields while trying to insert.

	```
	<copy>
	{"_id":"200","title":"Top Gun"}
	</copy>
	```
	![create a not-allowed item](./images/tester.png)
	![constraint error message](./images/error2.png)

11. The following document now satisfies all the constraints: the "id" is a unique number, the title is a string, and the price is a positive number.

	```
	<copy>
	{
		"_id": 200,
		"title": "Top Gun",
		"category": "VHS",
		"condition": "like new",
		"price": 8,
		"starring": [
			"Tom Cruise",
			"Kelly McGillis",
			"Anthony Edwards",
			"Val Kilmer"
		],
		"year": 1986,
		"decade": "80s"
	}
	</copy>
	```

## Task 5: Using the Database API for MongoDB

In this task we will use the Oracle Database API for MongoDB. That allows standard MongoDB tools and drivers to connect to Autonomous Database as though it were a MongoDB database. We will use the mongoimport tool to bulk-load some data, then use mongosh to connect and do some interactive commands.

1.  Start Cloud Shell

	Go back to the main Cloud menu page (you may need to close the Database Actions tab).

	On the top row, click the "Command Prompt" button.

	![start cloud shell](./images/start-shell.png " ")

	That will bring up the Cloud Shell (it may take a minute or so to start). You can maximize the cloud shell window using the "double arrow" button at the top right.

	![maximize cloud shell](./images/shell-maximize.png " ")

	We're now going to download and install the MongoDB shell tool. We will download this from MongoDB's own website using 'wget' and install it directly in Cloud Shell.

	Copy these commands into the cloud shell (make sure you press "Enter" after the final command as the paste doesn't include it).

	```
	<copy>
	wget https://fastdl.mongodb.org/tools/db/mongodb-database-tools-rhel70-x86_64-100.5.2.tgz
	tar -xvf mongodb-database-tools-rhel70-x86_64-100.5.2.tgz
	export PATH="`pwd`/mongodb-database-tools-rhel70-x86_64-100.5.2/bin/:$PATH"
	</copy>
	```

	Note that if you close and reopen the Cloud Shell before running mongoimport, you will need to run that last PATH setting command again.

	![install mongo tools](./images/install-mongosh.png " ")


1.	Edit the URI for the MongoDB API to include the correct username and password.

	Earlier (in Lab 1) you saved the URI for the Database API for MongoDB.

	* Change the [user:password@] to admin:YourPassword@ at the start of the URI. Substitute the password you chose earlier for the YourPassword.
	* Change the [user] string in the middle to admin

   	For example, let's say your password is "Password123", and your original connection string is mongodb://[user:password@]MACHINE-JSONDB.oraclecloudapps.com:27017/[user]?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true

	You would change it to 

	```
	<copy>
	mongodb://admin:Password123@MACHINE-JSONDB.oraclecloudapps.com:27017/admin?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true
    </copy>
	```

	Make sure you've changed both strings, and have not left any square brackets in there.

	**IMPORTANT NOTE:** if your password contains any special characters in the set / : ? # [ ] @, you will need to escape them as follows:

	| Character | Escape Sequence |
	| :---:     | :---: |
	| /	 | %25 |
	| :	 | %3A |
	| #	 | %23 |
	| [	 | %5B |
	| ]  | %5D |
	| @	 | %40 |

	So if your password was **P@ssword#123** you would encode it as **P%40ssword%23123**.

2.  Store the MongoDB URI in an environment variable

	Copy the following into Cloud Shell, making sure that you replace <yourURI> with the edited URI from the previous step. Make sure you keep the single quote characters either side of the URI.

	```
	<copy>
	export URI='<yourURI>'
	</copy>
	```

	![set URI variable](./images/set-uri.png " ")

	If you close Cloud Shell and open it again before running the following commands, you will need to re-run this step.

3. 	Bulk load the data using mongoimport

	mongoimport is a standard MongoDB tool which takes a file full of JSON documents and loads it to a MongoDB compatible database. Here we will use the tool to load a file currently situated on Object Storage into Autonomous Database. We could download the file to Cloud Shell, then upload it to the database using mongoimport, but we might as well do pipe it directly into mongoimport using standard output.

	The following command using 'curl -s' to fetch the file from object storage and send it to stdout. mongoimport then reads the data from stdin, connects to the database specified by $URI, and inserts the data into the collection 'products'.

	Copy this into Cloud Shell, being sure to press "Enter" afterwards.

	```
	<copy>
	curl -s https://objectstorage.us-ashburn-1.oraclecloud.com/n/idaqt8axawdx/b/products/o/products.ndjson | \
    	mongoimport --collection products --uri $URI
	</copy>
	```

	![mongo import command](./images/mongo-import.png " ")
	
4.	Optional step: Download and run Mongo Shell

	Copy these commands into Cloud Shell, being sure to press "Enter" after the last:

	```
	<copy>
	wget https://downloads.mongodb.com/compass/mongosh-1.3.1-linux-x64.tgz
	tar -xvf mongosh-1.3.1-linux-x64.tgz
	export PATH="`pwd`/mongosh-1.3.1-linux-x64/bin/:$PATH"
	</copy>
	```

	(as before you will need to run that PATH expression again if you leave Cloud Shell)

	![install mongo shell](./images/install-mongosh-2.png " ")

	Then run mongosh providing the URI to connect to your Autononous Database:

	```
	<copy>
	mongosh $URI
	</copy>
	```

	That will bring you to the Mongo Shell prompt.

	![mongo shell prompt](./images/mongosh.png " ")

	From here you can run MongoDB commands against the data in your Autonomous Database. Here's a few suggested commands.

	Show collections in the database:

	```
	<copy>
	show collections
	</copy>
	```

	Count the documents in the __products__ collection

	```
	<copy>
	db.products.countDocuments()
	</copy>
	```

	Find product with _id = 100

	```
	<copy>
	db.products.find( { "_id": 100} )
	</copy>
	```

	Find products priced over 100:

	```
	<copy>
	db.products.find( {"price": {"$gt": 11} } )
	</copy>
	```

	When done in Mongo Shell, you can type "quit" to exit to Cloud Shell.

You may now proceed to the next lab.

## Learn More

* [Creating B-Tree Indexes for JSON_VALUE](https://docs.oracle.com/en/database/oracle/oracle-database/21/adjsn/indexes-for-json-data.html#GUID-FEE83855-780A-424B-9916-B899BFF2077B)

## Acknowledgements

- **Author** - Beda Hammerschmidt, Architect
- **Contributors** - Anoosha Pilli, Product Manager, Oracle Database
- **Last Updated By/Date** - Anoosha Pilli, Brianna Ambler, June 2021
