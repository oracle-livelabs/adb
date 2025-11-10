# Introduction

## About this Workshop

### Workshop Scenario

In this workshop, we'll implement a very simple employee database.

We'll create an Autonomous AI JSON Database, and connect to it using the standard "MongoDB Shell" tool. We'll use that to create an employee collection, and populate it with some employee records.

We'll then explore the same data using "Database Actions" in Oracle's Cloud Infrastructure.

You can complete this entire workshop using your web browser and a command or shell window. As part of the lab we will install MongoDB Shell, a command-line tool for accessing MongoDB and MongoDB-compatible databases.

If you have MongoDB tools such as MongoDB Shell or MongoDB Atlas already installed on your own machine, you could run the MongoDB commands from there instead. However, the workshop will assume at all times that you are following the provided instructions.

This workshop consists of multiple 'labs' - each describing one aspect or feature. This lab has been designed for 19c AJD database but should also work on 21c AJD database and these concepts are also applicable to on-premise versions.

Watch this quick video to know why JSON in Oracle Autonomous AI Database is awesome.

**Estimated Time: 1 hour**

[Youtube video about JSON in Oracle Database](youtube:yiGFO139ftg)

<if type="odbw">If you would like to watch us do the workshop, click [here](https://youtu.be/uvlhnG-bjnY).</if>

### About JSON

Before we get started let's take a brief look at JSON (you may skip this step if you're already familiar with it)

#### What is JSON?

JSON is a human-readable, self-describing format to represent data in a hierarchical format. This is best illustrated by an example - a JSON object with information about a person:

```
<copy>
{
	"id":100,
	"firstName":"John",
	"lastName":"Smith",
	"age":25,
	"address":{
		"street":"21 2nd Street“,"city":"New York",
		"state":"NY","postalCode":"10021",	 
		"isBusiness":false	
	},	
	"phoneNumbers":[		
		{"type":"home","number":"212 555-1234"},	
		{"type":"mobile","number":"646 555-4567"}
	],
	"bankruptcies":null,
	"lastUpdated":"2019-05-13T13:03:35+0000"
}
</copy>
```

Objects consist of key-value pairs: the key "id" has the value 100. Keys are always strings (identified by double quotes). Scalar values can be numeric (like 100), strings ("John"), Boolean (true, false) or null. The ordering of key-value pairs in an object is not relevant but keys have to be unique per object. Keys can also point to a non-scalar value, namely another object (like address) or array (phoneNumbers). A JSON array is an ordered list of values. You can think of objects and arrays both being containers with values; in an object, the key identifies the value whereas in an array it is the position that identifies the value.

No problem, if this does not make much sense yet, you'll get more comfortable with JSON very soon - it is really easy!

One thing to keep in mind is that JSON needs no upfront definition of keys or data types. You can easily modify the shape (schema) of your data.

#### Why is JSON so popular for application development?

Schema-flexibility is a big reason why JSON makes a lot of sense for application development. Especially in the initial phase, an application is quite dynamic, new fields are needed, interfaces get changed, etc. Maintaining a relational schema is hard if application changes often need a change in the underlying tables and existing data needs to be modified to fit into the new schema. JSON makes this much easier as new documents may look different than the old ones (for example have additional fields).

JSON also avoids normalization of a business object into multiple tables. Look at the example above with a customer having multiple phone numbers. How would we store the phone numbers relationally? In separate columns (thus limiting the total amount of phone numbers per person) or in a separate table so that we need to join multiple tables if we want to retrieve on business object? In reality most business objects get normalized into many more than two tables so an application developer has to deal with the complexities of inserting into many tables when adding a new object and joining the tables back on queries - the SQL to do that can get quite complex. JSON on the other hand allows one to map an entire business object into one JSON document. Every insert or query now only affects one value in the database - no joins are needed.

Now you know what JSON is and also why so many people love it. Enough theory for now - time to code!

### Objectives

In this workshop, you will explore:
*	How to provision an Oracle Autonomous AI (JSON) Database,
*	How to install MongoDB Shell on your own system
*   How to connect to the Oracle Autonomous AI Database from MongoDB Shell and create a collection
*   How to access the MongoDB collection from JSON Workshop and SQL

### Prerequisites

* An Oracle Cloud Account

You may now proceed to the next lab.

## Learn More

* [Overview of JSON](https://docs.oracle.com/en/database/oracle/oracle-database/21/adjsn/json-data.html#GUID-B2D82ED4-B007-4019-8B53-9D0CDA81C4FA)

## Acknowledgements

* **Author** - Roger Ford, Principal Product Manager
* **Last Updated By/Date** - Abby Mulry, November 2025
