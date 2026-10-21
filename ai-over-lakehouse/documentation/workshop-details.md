# Workshop Details

### Objectives

Describe the audience, learning objectives, prerequisites, and hands-on workshop plan.

Estimated Time: 60 minutes for hands-on work, plus a 15-minute recovery and
discussion buffer.

## Short Description

Use Oracle Autonomous AI Lakehouse as an AI-powered query hub for enterprise
data across Databricks and Oracle. Add business context with Data Studio, then
use Codex through MCP to answer a cross-source business question reliably.

## Long Description

PeakGear is a fictional sporting goods retailer with product and digital interaction data in Databricks, operational
returns in an existing Oracle database, and business users who want a simple
answer: which product categories should be prioritized? Raw connectivity alone
does not define what customer interest means or how it should be compared with
returns. Participants first see Codex decline to make an unjustified
recommendation. They use Data Studio AI Enrichment to review and save business
metadata on local snapshots of those sources, then ask a harder question that requires governed time, product, and
aggregation semantics. Codex creates or reuses and validates one Analytic View
with two additive measures through explicit MCP SQL DDL, making the final
drill-down reproducible.

## Workshop Outline

| Lab | Focus | Minutes |
|---|---|---:|
| 1 | Sign in as PEAKGEAR_USER | 5 |
| 2 | Connect real Databricks and Operations sources | 15 |
| 3 | Connect Codex and ask the raw-data question | 8 |
| 4 | Add business meaning with Data Studio AI Enrichment | 12 |
| 5 | Identify the model gap, create an Analytic View with Codex, and answer the question | 20 |
| Buffer | Troubleshooting and discussion | 15 |
| Total | | 75 |

Start with participant sign-in. ADMIN setup is not a learner task: the reservation provisions the
database user, grants, ORDS access, Operations link, network ACL, and AI profile.

AI Enrichment is performed only in Lab 4 for all three raw tables: digital
interactions, the product catalog, and operational returns. Lab 5 reuses the
saved annotations to identify the governed-model gap, without repeating
enrichment, then creates or reuses and validates one Analytic View and answers the
final question in the same lab.

## Workshop Prerequisites

* An active LiveLabs reservation with a ready Autonomous AI Database environment.
* OCI Login Credentials, Tenancy Information, and Environment Details from
  the learner's own Reservation Information. The database password and OCI
  password are different; no participant ADMIN access is required.
* **Azure Storage Password**, **Databricks Client ID**, and **Databricks Client
  Secret** available privately in **View Login Info → Environment Details**.
  The public [Connection field reference](../assets/event-lab-values.md)
  contains only endpoints, aliases, and the field mapping. If private fields
  are missing or empty, ask the instructor before starting Lab 2.
* An available Oracle Operations database that exposes
  `CUSTOMER_RETURN_EVENTS`.
* A Databricks Unity Catalog endpoint with `ICEBERG.PRODUCTS` and
  `ICEBERG.DIGITAL_CLICKSTREAM_EVENTS`.
* A default AI profile already configured for the assigned database. It must
  allow Data Studio AI Enrichment; participants do not create the profile.
* A macOS laptop with Terminal or a Windows laptop with Windows PowerShell
  5.1 or later. Lab 3 includes separate setup instructions for both platforms.
* Codex installed, signed in, and able to create a local task. Event organizers
  must arrange a supported desktop client and account access before the event;
  a LiveLabs reservation does not supply a Codex account. Confirm that managed
  laptops permit the user-scoped package installation and project-scoped MCP.
  See the [official desktop setup](https://learn.chatgpt.com/docs/app) and
  [Windows guidance](https://learn.chatgpt.com/docs/windows/windows-sandbox).
* No prior experience with Analytic Views, Iceberg, Python, or manual MCP
  configuration is required. The Starter Kit installs its own package runner
  and Python runtime; learners do not install these tools manually.

## Learning Outcomes

After completing this workshop, participants can:

* distinguish OCI sign-in from database sign-in and use a prepared participant session;
* connect and inspect raw Iceberg and Oracle Operations sources;
* create local snapshot tables so later analysis avoids repeated remote scans;
* distinguish raw technical data from reviewed business metadata;
* use Data Studio AI Enrichment to save descriptions and tags;
* use Codex through MCP to identify missing semantic requirements;
* create or reuse and validate a governed Analytic View through Codex and MCP SQL; and
* explain why the same business question yields a better answer after
  governance is added.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
