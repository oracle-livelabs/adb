# Work with RDF Graphs in Graph Studio

## Introduction
Graph Studio in Oracle Autonomous Database enables users to model, create, query, and analyze graph data. It includes notebooks, developer APIs for executing graph queries using PGQL, 60+ built-in graph algorithms, and offers dozens of visualizations including native graph visualization.
In addition to property graph, Graph Studio now extends support for semantic technologies, including storage, inference, and query capabilities for data and ontologies based on Resource Description Framework (RDF) and Web Ontology Language (OWL).
You can now use Graph Studio for the following supported RDF features:
- Create an RDF graph
- Execute SPARQL queries on the RDF graph in a notebook paragraph
- Analyze and visualize RDF graphs

RDF is a W3C-standard data model for representing linked data. RDF uses Uniform Resource Identifiers (URIs) as globally-unique identifiers for resources and URIs to name the relationship between two resources. In addition to URIs, RDF uses literals to represent scalar values such as numbers, strings, and timestamps.
RDF models linked data as a directed, labeled graph, where each edge is usually called a triple. The source vertex of the edge is called the subject of the triple. The label or name of the edge is called the predicate of the triple, and the destination vertex of the edge is called the object of the triple.
RDF graphs are particularly well suited for knowledge graphs and data integration applications because URIs provide globally unique identifiers and the simple, schemaless triple structure makes it very easy to combine data from several different RDF graphs into a single graph. In addition, RDFS and OWL provide standard ways to define re-usable vocabularies (sets of semantically meaningful edge labels and resource types) for more interoperable and machine-processible graph data.
See [here](https://www.w3.org/TR/rdf11-primer/) for more information about the W3C RDF 1.1 standards.

SPARQL Protocol and RDF Query Language (SPARQL) is one of the technologies standardized by the W3C for querying Resource Description Framework (RDF) data. You can read more about the W3C SPARQL 1.1 standard [here](https://www.w3.org/TR/sparql11-overview/).

SPARQL uses a **SELECT some elements WHERE some conditions** structure to specify a query. The conditions in the WHERE clause of a SPARQL query are built using triple patterns, which are essentially an RDF triple where elements of the triple can be replaced with query variables (denoted with a ? prefix). A query variable in a triple pattern acts as a wild card. Consider the triple pattern **?movie ms:genre ms:genre\_Comedy**. When this triple pattern is evaluated against an RDF graph, it will return all **subjects** of triples with predicate **ms:genre** and **object ms:genre\_Comedy**. The SPARQL SELECT clause specifies a list of query variables to project from the query. In SPARQL syntax, URIs are enclosed within angle brackets (for example, <http://www.example.com/moviestream/actor>) and literals are enclosed within double quotes (e.g., "Kevin Bacon"). Literals can be followed by ^^ and a datatype URI (e.g., "100"^^<http://www.w3.org/2001/XMLSchema#integer>) or followed by @ and a language tag (e.g., "Jalapeño"@es). Most XML schema data types are supported in SPARQL, and plain literals without a datatype URI are considered to have datatype <http://www.w3.org/2001/XMLSchema#string>.

This video featured below is a demo example using a similar dataset that will be utilized in this lab. This video emphasizes the structure of the ontology of the movie structure using RDF. The demo features RDF Graph using a staging table in combination with SQL Developer, which is distinctly different from this Autonomous Database version of the lab. However, the SPARQL language used to query and visualize the data is very similar for context.

  [](youtube:e_EQjInas50)

In this lab, a semantic graph will be built using SPARQL, which is a standardized methodology for integrating different data sources. This procedure will teach you how to analyze the data using graph-based queries and visualization.  

Estimated Time: 35 minutes

### Objectives
- Prepare the Environment
- Get Started with RDF Graphs
- Creating and validating an RDF graph user in Graph Studio
- Querying and Visualizing the RDF Graph

### Prerequisites
  This lab assumes you have:
  * An Oracle Cloud Account - Please view this workshop's LiveLabs landing page to see which environments are supported
  
  - Download the MOVIESTREAM file (moviestream\_rdf.nt) using this [link](https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/moviestream_rdf.nt)

This concludes this lab. You may now *proceed to the next lab.*

## Acknowledgements
- **Author** -  Nicholas Cusato, Ethan Shmargad, Matthew McDaniel Solution Engineers, Ramu Murakami Gutierrez Product Manager
- **Technical Contributor** - Melliyal Annamalai Distinguished Product Manager, Joao Paiva Consulting Member of Technical Staff, Lavanya Jayapalan Principal User Assistance Developer
- **Last Updated By/Date** -  Marion Smith, Technical Program Manager, April 2022
