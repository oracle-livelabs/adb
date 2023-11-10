# Work with JSON collections

## Introduction

Oracle is a relational database, meaning it typically stores data in rows and columns of tables and JSON can be stored as a column value. For this lab though, we first focus on the Document Store API SODA (Simple Oracle Document Access) which allows us to store JSON data in a so-called collection. A JSON collection stores JSON documents alongside some metadata like the time of creation or update. Collections offer operations like inserts, deletes, index creation or queries.

To create a collection all you have to specify is the collection's name. Unlike a relational table, you do not have to provide any schema information. So, let's create a collection for the products we want to sell in the store.

Estimated Time: 15 minutes

Watch the video below for a quick walk-through of the lab.
[Work with JSON collections](videohub:1_7pnwwbm0)

### Objectives

In this lab, you will:

* Create Collection
* Insert First Document
* Find JSON documents in a collection
* Learn about JSON and Constraints
* Load more data through the Database API for MongoDB

### Prerequisites

* Have provisioned an Autonomous JSON Database instance and logged into the JSON
* Be working with a Mac OS/X (Intel Silicon) machine, a Linux x86 machine or a Windows PC

## Task 1: Create Collection

1. To create a collection, click **Create Collection**.

	![Create Collection](./images/create-collection.png)

2. Provide a name for your collection in the field **Collection Name - products** and click **Create**. MAKE SURE you check the **MongoDB Compatible** box. Note that the collection name is case-sensitive. it is highly recommended to use only lower cases, since this will be the collection name used later on. Do not used mixed capitalization, otherwise you will have to double-quote the table name for SQL access all the time (Oracle normalizes the collection names to upper case for the underlying table if you choose all lower or upper case names, but not for mixed capitalization). 

	![New collection: products](./images/new-products.png)

3. A notification pops up that displays **products** collections has been created.

	![New collection notification](./images/popup.png)

4. Click the refresh button to verify the *products** collection has been created.

	![Refresh button](./images/refreshed.png)

## Task 2: Insert Documents

1. Double click **products** collection to show the **JSON-products** worksheet.

	![products worksheet](./images/double-clicked.png)

2. Click the *New JSON Document* button.

	![new document button](./images/new-document.png)

3. A **New JSON Document** panel displays. Copy the following JSON object, paste it in the worksheet and click **Create**.

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

	Click the *New JSON Document* button, copy the following JSON objects one by one, paste it into the worksheet and click **Create**.

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

Documents can be selected based on filter conditions - we call them 'Queries By Example' or 'QBE' for short. A QBE is a JSON document itself and it contains the fields and filter conditions that a JSON document in the collection must satisfy, in order to be selected. QBEs are used with SODA (only); you can use SQL functions as an alternative.

The simplest form of a QBE just contains a key-value pair. Any selected document in the collection must have the same key with the same value. More complex QBEs can contain multiple filter conditions or operators like 'negation' or 'and', etc.

The following are examples of QBEs. You can copy them into the corresponding window (see screenshot) and execute them. Obviously, in a real application, those QBE-expressions would be issued directly from the programming language - the SODA drivers have APIs for common application programming languages: Python, etc.

Now let's issue some simple queries on the *products* collection we just created.

1. Copy and paste the following queries into the worksheet and click the *Run Query* button to run a query.

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

	Running the query will display two documents with format DVD.

	```
	<copy>
	{"format":"DVD"}
	</copy>
	```
	![DVD search results](./images/dvd-results.png)

4.	Find all non-movies:

	This query displays the documents that are not of type - movies, which means just the document with id 103. It is using MongoDB compatible QBE (Query By Example) syntax. The "$ne" is the **N**ot **E**qual operator.

	As you can guess, there are more such operators, such as "$eq" (equal), "$lt" (less than), "$gt" (greater than), and so forth. For a more comprehensive list, see [the documentation](https://docs.oracle.com/en/database/oracle/simple-oracle-document-access/adsdi/overview-soda-filter-specifications-qbes.html#GUID-A19B0A93-0B17-4D0C-8362-4A7015C74842).

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

7. Tighten the previous query to choose only movie documents:

	This query displays the documents whose ids are 100, 102 as those documents have price less than 5 and not the type - book. This filter uses a more complex construct. If you are interested in how these constructs are built, see [the documentation](https://docs.oracle.com/en/database/oracle/simple-oracle-document-access/adsdi/overview-soda-filter-specifications-qbes.html#GUID-36420BAE-3BE0-43EA-9C4B-5F793BCCB3F5).

	```
	<copy>
	{"$and":[{"price":{"$lte":5}}, {"type":"movie"}]}
	</copy>
	```
	![price less than 5 and not type = book ](./images/less5-movie.png)

## Task 4: JSON and Constraints

JSON data is "schema flexible", you can add whatever data you like to a JSON document. But sometimes you will wish to impose some required structure on that data. That can be done through SQL by creating indexes and/or constraints on the JSON collection.

An index will aid fast access to an item (for example speeding up access via the "title" field), but can also be used to impose uniqueness (a unique index or primary key constraint) or to enforce particular datatypes (by triggering an error if the datatype is not what is expected).

More generally, constraints can be used to check the data being entered for various aspects.

1.  Let's add a check - or 'constraint' to check our data entry. We will do this using SQL Developer Web. Click the navigation menu on the top left and select **SQL** under Development.

	![SQL navigation](./images/nav.png)

8. Check constraint to make sure every product has a title of string data type and price >=0. 

	Add a constraint to make sure that every item has at least a title and the price. We want the price to be a non-negative number and title to be a string.

	Copy and paste the query below in the worksheet and click the *Run query* button to run the SQL query to alter the **products** table and add constraints.

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

10. Validate that the following documents cannot get inserted, since fields are missing or are of wrong type.

	Click the *New JSON Document* icon, copy and paste the following query in the worksheet and click *Create*.

	This throws the error "Unable to add new JSON document" since the following document has missing fields while trying to insert.

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

## Task 5: Install MongoDB tools on your local machine

In this task, we will use the Oracle Database API for MongoDB. That allows standard MongoDB tools and drivers to connect to Autonomous Database as though it were a MongoDB database. We will use the mongoimport tool to bulk-load some data, then use mongosh to connect and do some interactive commands.

1.  (Mac machines only) Determine the type of hardware

	If you know already whether your Mac uses Intel or Apple Silicon you can skip this step. Otherwise:

    Click on the Apple menu in the top left-hand corner of your screen and go to "About this Mac". 

    !["about this mac" menu item](./images/about-this-mac.png " ")

    That will open a "details" panel. Intel Mac will show a line with *Processor:* and the name of an Intel processor. Apple Silicon Macs will show a line saying *Chip"* and a line such as "Apple M1 Pro".  If you have an Apple Silicon machine, you will configure a terminal window with Rosetta to continue.

    ![processor details](./images/about-mac-details.png " ")

2.	Open a command prompt or terminal window

	On a Mac with Intel Processor:

	Open the Launchpad icon in the Dock (or press Command-space) and start typing "terminal" in the search box. Press enter to start terminal.

    ![open terminal in launchpad](./images/terminal.png " ")

	On a Windows PC:

    Press "Run" (Windows-R) and type "cmd.exe". Press enter or click "OK".

    ![open command prompt](./images/cmd-exe.png " ")

	On a Mac with Apple Silicon (Open terminal using Rosetta):

	Open the "Utilities" folder in Finder (Macintosh HD > Applications > Utilities). Right click on "Terminal" and choose "Duplicate". 
	
	![duplicate "terminal" in Utilities folder](./images/duplicate-terminal.png " ")

	Rename the duplicate to "Rosetta Terminal". Now right-click on it and choose "Get Info".

	!["get info" on terminal](./images/terminal-get-info.png " ")

	In the info panel, check the box labelled "Open using Rosetta". Close the panel and double-click on the Rosetta Terminal to launch.

	!["info panel with Rosetta check box](./images/rosetta-checkbox.png " ")

	On a Linux machine, we'll assume you know how to open a terminal as this will vary with the distribution.

3.  Create and enter a suitable directory. We'll create a directory 'mongosh' under the default home directory, but you can choose to create it elsewhere. For **Mac. Windows or Linux**, enter the following commands:

    ```
    <copy>
    mkdir mongotools
    cd mongotools
    </copy>
    ```

4.	Copy **ONE** of the following set of commands, depending on your machine type:

	For **Mac** with **Intel Processor** *or* **Apple Silicon**:

    ```
    <copy>
    curl https://downloads.mongodb.com/compass/mongosh-1.5.0-darwin-x64.zip -o mongosh.zip
	curl https://fastdl.mongodb.org/tools/db/mongodb-database-tools-macos-x86_64-100.5.4.zip -o mongotools.zip
	tar xvf mongosh.zip
	tar xvf mongotools.zip
    export PATH=`pwd`/mongosh-1.5.0-darwin-x64/bin/:`pwd`/mongodb-database-tools-macos-x86_64-100.5.4/bin/:$PATH
	</copy>
    ```

	For **Windows**:

    ```
    <copy>
    curl https://downloads.mongodb.com/compass/mongosh-1.5.0-win32-x64.zip -o mongosh.zip
	curl https://fastdl.mongodb.org/tools/db/mongodb-database-tools-windows-x86_64-100.5.4.zip -o mongotools.zip
	tar xvf mongosh.zip
	tar xvf mongotools.zip
    set path=%cd%\mongosh-1.5.0-win32-x64\bin\;%cd%\mongodb-database-tools-windows-x86_64-100.5.4\bin;%path%
    </copy>
    ```

	For **Linux x86**:

	Go to [https://www.mongodb.com/try/download/database-tools](https://www.mongodb.com/try/download/database-tools) and copy the correct URmongoL for your distribution. That will be used for the SECOND URL in the code snippet below. The example URL works for Oracle Linux 7.0 and above. You will need to use a different PATH command as well if you a different distribution.
	
	```
	<copy>
	curl https://downloads.mongodb.com/compass/mongosh-1.5.1-linux-x64.tgz -o mongosh.tgz
	curl https://fastdl.mongodb.org/tools/db/mongodb-database-tools-rhel70-x86_64-100.5.4.tgz -o mongotools.tgz
	tar xvf mongosh.tgz
	tar xvf mongotools.tgz
	export PATH="`pwd`/mongodb-database-tools-rhel70-x86_64-100.5.2/bin/:`pwd`/mongosh-1.5.1-linux-x64/bin/:$PATH"
	</copy>
	```

	Note that if you close and reopen the terminal/command shell window before running mongoimport, you will need to run the PATH setting command again.

	![install mongo tools](./images/mongo-install.png " ")

## Task 6: Using the Database API for MongoDB

1.	Edit the URI for the MongoDB API to include the correct username and password.

	Earlier (in Lab 1) you saved the URI for the Database API for MongoDB.

	* Change the [user:password@] to admin:YourPassword@ at the start of the URI. Substitute the password you chose earlier for the YourPassword.
	* Change the [user] string in the middle to admin

   	For example, let's say your password is "Password123", and your original connection string is mongodb://[user:password@]MACHINE-JSONDB.oraclecloudapps.com:27017/[user]?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true

	You would change it to 

	```
	mongodb://admin:Password123@MACHINE-JSONDB.oraclecloudapps.com:27017/admin?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true
	```

	Make sure you've changed both strings, and have not left any square brackets in there.

	**IMPORTANT NOTE:** if your password contains any special characters in the set / : ? # [ ] @, you will need to escape them as follows:s

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

	Copy the following into the terminal or command window, making sure that you replace <yourURI> with the edited URI from the previous step. Make sure you keep the *single* or *double* quote characters (**Mac/Linux** or **Windows**) either side of the URI.

    For **Mac** or **Linux**:

	```
	<copy>
	export URI='<yourURI>'
	</copy>
	```

	As an example, this command could look as follows:
	```
	export URI='mongodb://admin:Password123@MACHINE-JSONDB.oraclecloudapps.com:27017/admin?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true'
	```
	Don't forget the single quotes for the string. If you are using a different shell on for example a Linux machine, you have to set the environment variable according to your shell.

	For **Windows**:
	```
	<copy>
	set URI="<yourURI>"
	</copy>
	```
	Don't forget the double quotes on your windows machine.

	![set URI variable](./images/set-uri.png " ")

	If you close the terminal or command window and open it again before running the following commands, you will need to re-run this step.

3. 	Bulk load the data using mongoimport

	mongoimport is a standard MongoDB tool which takes a file full of JSON documents and loads it to a MongoDB compatible database. Here we will use the tool to load a file currently situated on Object Storage into Autonomous Database. We could download the file to our machine, then upload it to the database using mongoimport, but we might as well do pipe it directly into mongoimport using standard output.

	The following command using 'curl -s' to fetch the file from object storage and send it to stdout. mongoimport then reads the data from stdin, connects to the database specified by $URI, and inserts the data into the collection 'products'.

	Copy this into your terminal or command window, being sure to press "Enter" afterwards.

	For **Mac** or **Linux**:

	```
	<copy>
	curl -s https://objectstorage.us-ashburn-1.oraclecloud.com/n/idaqt8axawdx/b/products/o/products.ndjson | \
    	mongoimport --collection products --uri $URI
	</copy>
	```

	For **Windows**:
	
	```
	<copy>
	curl -s https://objectstorage.us-ashburn-1.oraclecloud.com/n/idaqt8axawdx/b/products/o/products.ndjson -o products.json
    mongoimport products.json --collection products --uri %URI%
	</copy>
	```

	![mongo import command](./images/mongo-import.png " ")
	
4.	Optional (but recommended) step: Run Mongo Shell

	Then run mongosh providing the URI to connect to your Autononous Database:


	For **Mac** or **Linux**:

	```
	<copy>
	mongosh $URI
	</copy>
	```

	For **Windows**:

	```
	<copy>
	mongosh %URI%
	</copy>
	```

	That will bring you to the Mongo Shell prompt.

	![mongo shell prompt](./images/mongosh.png " ")

	From here you can run MongoDB commands against the data in your Autonomous Database. Here are a few suggested commands.

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

	Find the product with _id = 100

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

	When done in Mongo Shell, you can type "quit" to exit Mongo Shell.

You may now proceed to the next lab.

## Learn More

* [Oracle Database API for MongoDB](https://blogs.oracle.com/database/post/mongodb-api)

## Acknowledgements

- **Author** - Beda Hammerschmidt, Architect
- **Contributors** - Roger Ford, Principal Product Manager; Anoosha Pilli, Product Manager, Oracle Database
- **Last Updated By/Date** - Anoosha Pilli, Brianna Ambler, June 2021
