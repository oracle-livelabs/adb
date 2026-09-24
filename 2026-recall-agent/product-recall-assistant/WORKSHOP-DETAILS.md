# Workshop Details

Estimated Time: Not applicable

## Short Description

Build a Product Recall Assistant that investigates a realistic component-level recall with JSON, Spatial, SQL Property Graph, AI Vector Search, Select AI Agent, ORDS, Deep Data Security, and a React/Node command center in Oracle Autonomous AI Database 26ai.

## Long Description

A product quality incident can span component lots, sub-vendor locations, manufacturing batches, shipments, stores, customer purchases, and unstructured complaints. In this workshop, learners investigate batch `B-482` and turn those records into an evidence-grounded response.

The completed workshop uses relational, JSON, spatial, graph, vector, agent, security, and application features in one database. Learners connect the investigation to Select AI Agent and ORDS, apply role-aware retrieval, then deploy a React/Node command center. The final application agent receives one pre-authorized document containing product JSON, vector evidence, Spatial impact, and Graph relationship summaries. Every seed table contains at least 100 rows. The focal recall includes 120 affected stores, 2,400 shipped units, 600 exposed customers, 25 component batches, and 25 supplier or sub-vendor sites.

## Workshop Outline

1. Introduction and scenario, 10 minutes
2. Lab 1: Shape the Recall Evidence with JSON, 10 minutes
3. Lab 2: Map Recall Impact with Oracle Spatial, 10 minutes
4. Lab 3: Trace Recall Paths with SQL Property Graph, 10 minutes
5. Lab 4: Prioritize Complaint Evidence with AI Vector Search, 15 minutes
6. Lab 5: Build the Recall Assistant, 20 minutes
7. Lab 6: Publish the Recall API with ORDS, 10 minutes
8. Lab 7: Make the Recall Agent Role-Aware with Deep Data Security, 15 minutes
9. Lab 8: Deploy the Role-Aware React Recall Command Center, 25 minutes
10. Discussion and questions, 15 minutes

## Workshop Prerequisites

- New Oracle Autonomous AI Database 26ai instance
- `ADMIN` access for one-time identity and privilege bootstrap
- `RECALL_OWNER` access for schema setup and lab execution
- `RECALL_APP_USER` for the later ORDS and application runtime
- Database Actions access for `RECALL_OWNER`
- Spatial Studio access through the `SPATIAL_ADMIN` role and platform-managed `SPATIAL$PROXY_USER`
- Select AI Agent and ORDS availability for later labs
- Node.js 20 or later and npm for the React/Node capstone
- Object Storage access for the local `all-MiniLM-L12-v2.onnx` model and the later Select AI Agent provider
- A resource principal with a narrowly scoped OCI Generative AI IAM policy
- Basic SQL and REST knowledge

## Identity Plan

- `ADMIN` creates database users and roles but owns no application objects.
- `RECALL_OWNER` owns all workshop data, code, graph definitions, and security policies.
- `RECALL_APP_USER` calls only approved packages through `RECALL_API_ROLE`.
- Lab 7 adds local Deep Data Security end users and data roles for store, regional, and recall-lead access.
- Lab 8 deploys the React/Node command center; its login uses the local database end-user identity for this workshop.

## Current Implementation Status

- Introduction: updated for the eight-lab flow
- Lab 1: Native JSON inspection and `JSON_TRANSFORM` case opening
- Lab 2: Longitude/latitude promotion, V2 spatial indexing, and impact mapping
- Lab 3: Graph-focused component and exposure traversal
- Lab 4: Vector-focused complaint prioritization
- Lab 5: Select AI Agent recall and spatial tool boundary
- Lab 6: ORDS delivery boundary with store and component-site GeoJSON
- Lab 7: Deep Data Security role-aware retrieval
- Lab 8: React/Node capstone using live role-aware JSON, vector, Spatial, Graph, and agent calls
- Runtime note: static workshop QA is current; rerun live database tests after the expanded seed-data update

## Acknowledgements

- **Author:** Tim Cline, Product Management Architect
- Contributors: David Start, Director and Kevin Lazarz, Senior Manager
- **Last updated:** October 2026
