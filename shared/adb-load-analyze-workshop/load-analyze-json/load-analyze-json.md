# Load and Analyze JSON Data

## Introduction

Load movie data that is stored in JSON format into an Autonomous Database collection. After loading the collection using the API, you will then analyze movie data using Oracle JSON functions.

Estimated Time: 10 minutes

Watch the video below for a quick walk-through of the lab.
[Load and Analyze JSON Data](videohub:1_9hugohpd)

### Objectives

In this lab, you will:
* Load JSON data from Oracle Object Storage using the `DBMS_CLOUD.COPY_COLLECTION` procedure
* Use SQL to analyze both simple and complex JSON attributes


### Prerequisites

- This lab requires completion of the lab **Provision an Autonomous Database**, in the Contents menu on the left.

## Task 1: Create and load JSON movie collection
[](include:adb-create-load-json-collection.md)

## Task 2: Analyze simple JSON fields to find Meryl Streep movies
[](include:adb-query-json-simple.md)

## Task 3: Analyze complex JSON arrays to find top actors
[](include:adb-query-json-arrays.md)

Please [*proceed to the next lab*](#next).

## Acknowledgements

* **Author** - Marty Gubar, Autonomous Database Product Management
* **Last Updated By/Date** - Marty Gubar, July 2022
