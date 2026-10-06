# Workshop Details

Estimated Time: 60 minutes for hands-on work, plus a 15-minute recovery and
discussion buffer.

## Short Description

Connect Oracle Operations data and Databricks Unity/Iceberg data to Oracle AI
Lakehouse. Use Data Studio to add reviewed business context, then use Codex
through Oracle Data Studio MCP to create governed Analytic Views and answer a
cross-source business question.

## Long Description

PeakGear has product and digital interaction data in Databricks, operational
returns in an existing Oracle database, and business users who want a simple
answer: which product categories should be prioritized? Raw connectivity alone
does not define what customer interest means or how it should be compared with
returns. Participants first see Codex decline to make an unjustified
recommendation. They use Data Studio AI Enrichment to review and save business
metadata, then ask a harder question that requires governed time, product, and
aggregation semantics. Codex creates and validates the two Analytic Views that
make the final drill-down reproducible.

## Workshop Outline

| Lab | Focus | Minutes |
|---|---|---:|
| 2 | Connect to your LiveLabs database | 5 |
| 3 | Connect real Databricks and Operations sources | 15 |
| 4 | Connect Codex and ask the raw-data question | 8 |
| 5 | Add business meaning with Data Studio AI Enrichment | 12 |
| 6 | Identify the governed-model gap | 5 |
| 7 | Create Analytic Views with Codex and answer the question | 15 |
| Buffer | Troubleshooting and discussion | 15 |
| Total | | 75 |

Start at Lab 2. Lab 1 is intentionally removed: the reservation provisions the
database user, grants, ORDS access, Operations link, network ACL, and AI profile.

AI Enrichment is performed only in Lab 5 for all three raw views: digital
interactions, the product catalog, and operational returns. Lab 6 reuses the
saved annotations to identify the governed-model gap, without repeating
enrichment.

## Workshop Prerequisites

* An active LiveLabs reservation with a ready Autonomous AI Database environment.
* OCI Login Credentials, Tenancy Information, and Environment Details from
  the learner's own Reservation Information. The database password and OCI
  password are different; no participant ADMIN access is required.
* The shared [Event lab values](../assets/event-lab-values.md), included directly
  in the workshop with the event owner's approval. They contain the prepared
  Operations link name, Azure storage password, Databricks OAuth
  values, and source endpoints; no separate handout is needed for those values.
* An available Oracle Operations database that exposes
  `CUSTOMER_RETURN_EVENTS`.
* A Databricks Unity Catalog endpoint with `ICEBERG.PRODUCTS` and
  `ICEBERG.DIGITAL_CLICKSTREAM_EVENTS`.
* A default AI profile already configured for the assigned database. It must
  allow Data Studio AI Enrichment; participants do not create the profile.
* A Mac with Terminal, and Codex Desktop installed and signed in.

## Learning Outcomes

After completing this workshop, participants can:

* distinguish OCI sign-in from database sign-in and use a prepared participant session;
* connect and inspect raw Iceberg and Oracle Operations sources;
* distinguish raw technical data from reviewed business metadata;
* use Data Studio AI Enrichment to save descriptions and tags;
* use Codex through MCP to identify missing semantic requirements;
* create and validate governed Analytic Views through Codex; and
* explain why the same business question yields a better answer after
  governance is added.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
