# Introduction

You are in a meeting where your team is asked to create an application on a set of data...no problem! You have done this multiple times before...should be simple. At the end of the meeting, after reviewing the requirements, UX and timelines, you are given the data. 

**Its 4400 records in JSON format.**

What do you do?

## About JSON

JSON is a human-readable, self-describing format to represent data in a hierarchical format. This is best illustrated by an example:

Example 1:
```
{
	"id": 100,
	"title": "Coming to America",
	"category": "DVD",
	"condition": "acceptable",
	"price": 5,
	"comment": "DVD in excellent condition, cover is blurred",
	"starring": ["Eddie Murphy", "Arsenio Hall", "James Earl Jones", "John Amos"],
	"year": 1988,
	"decade": "80s"
}
```

Example 1 shows one JSON string (also called document) with information about a movie. The main building blocks are key-value pairs. The key is always a string - syntactically identified by being enclosed in double quotes. A key is on the left side of a colon. On the right side of the colon is the corresponding value. Key-Value pairs are encapsulating in a JSON Object - identified by the curly brackets {…}. The order or key-value pairs in an object is not significant. 
A value (right side of colon) can also be a string ("DVD"), a number (5), a Boolean, null or an Object or Array. What is an array? Think of it as a list of values. In this example the key "starring" points to a JSON array of 4 string value. In a JSON array the order matters. 
JSON arrays and objects can be recursively nested so that the structure resembles a hierarchy or tree.

JSON has no fixed schema, no upfront definition of key names or data types is required to work with JSON. This makes JSON very attractive to developers who can easily add make r application changes without having to maintain a matching relational schema (no more ALTER TABLE ADD COLUMN). For example, we could easily add a new key-value pair for 'language' or 'ratings'.  Another benefit of JSON is that it avoids normalization: look at the JSON array for "starring". How would that be modeled relationally? We would likely have used a separate table for it so that every 'movie' retrieval would require a join on multiple tables and every insertion of a new 'movie' object would require inserts into multiple tables. JSON is therefore also called 'denormalized' as it stores values together instead of normalizing them into separate tables/relations.


## About JSON and the Oracle Database

Did you know that the Oracle Database fully supports schema-less application development using the JSON data model? In addition, in the same database, that developers can use SQL over the same data for analytics or reporting?

This workshop will provide a walkthrough on how the Oracle Database can not only store, index and have transactional consistency (ACID) with JSON documents, but how you can leverage all the power of the database for advanced security, application development and a whole suite of Simple Oracle Document Access (SODA) APIs. 

### Objectives

-   Load JSON into the Oracle Database
-   Work with JSON in the Oracle Database with relational tables
-   Work with JSON in the Oracle Database as JSON documents
-   Provide developer endpoints for relation or schemaless application development

### Required Artifacts

-   The following lab requires an <a href="https://www.oracle.com/cloud/free/" target="\_blank">Oracle Cloud account</a>. You may use your own cloud account, a cloud account that you obtained through a trial, or a training account whose details were given to you by an Oracle instructor.

### Prerequisites
This lab assumes you have completed the following labs:
* Lab: [Login to Oracle Cloud]()
* Lab: [Provision an Autonomous Database]() or have access to a 19c or greater Oracle Database


# Choose your Own JSON Adventure: Relational or Document Store

In this lab you will work with JSON in the Oracle Database with the intent of exposing the data for application development.

### Task 1: Connect to your Database using SQL Developer Web

### Task 2: Create a user for working with JSON in the Oracle Database

### Task 3: Load JSON into the database and work with relational tables

### Task 4: Load JSON into the database and work with JSON documents and collections

### Task 5: Expose the JSON data for application development via a REST endpoint

### Task 6: Extra Credit: Deploy a sample application and consume the REST endpoint

## Conclusion
 In this lab, you had an opportunity to work with JSON in the Oracle Database

## Acknowledgements

- **Authors** - Jeff Smith, Beda Hammerschmidt and Brian Spendolini
- **Last Updated By/Date** - April 2021
- **Workshop Expiry Date** - April 2022
