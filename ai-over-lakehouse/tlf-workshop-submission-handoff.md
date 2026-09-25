# PeakGear Workshop — TLF Submission Handoff

## Purpose of this document

Use this file as the canonical metadata and positioning source when entering
the workshop into TLF or another Oracle workshop-registration system. The
learner content is in this same folder.

Do not infer capabilities or rewrite the lab from older PeakGear drafts. The
current decisions in this document override earlier versions.

## Canonical workshop identity

| Field | Copy-ready value |
|---|---|
| Workshop title | PeakGear: From Raw Data to Governed AI Answers with Codex |
| Short title | PeakGear AI Lakehouse with Codex |
| Subtitle | Connect live Oracle and Databricks data, add business meaning, and build governed Analytic Views |
| Workshop slug | peakgear-codex-semantic-lakehouse |
| Delivery type | Hands-on workshop |
| Experience level | Intermediate |
| Duration | 90 minutes |
| Hands-on time | 75 minutes |
| Troubleshooting and discussion buffer | 15 minutes |
| Content language | English |
| Industry scenario | Retail and consumer products |
| Primary product | Oracle AI Lakehouse |
| Primary interface | Oracle Data Studio |
| AI client | Codex Desktop through Oracle Data Studio MCP |

Workshop ID, event code, lab owner, capacity, cost, target region, and
availability dates are not yet assigned. Leave those fields as TBD rather
than inventing values.

## One-line value proposition

Turn live Oracle operational data and Databricks Iceberg data into one
governed business answer without copying the source data into a new staging
pipeline.

## Short description

Connect Databricks Unity/Iceberg and an existing Oracle operations database to
Oracle AI Lakehouse. Use Data Studio AI Enrichment and Codex through MCP to
turn a vague product-interest question into governed Analytic Views and an
explainable cross-source recommendation.

## Long description

PeakGear has product and digital-interaction data in Databricks Unity Catalog
and operational return events in an existing Oracle database. The systems are
connected, but their raw fields do not define what customer interest means,
which time period should be compared, or how digital behavior and returns
should be aggregated.

Participants first configure a bounded PEAKGEAR_USER environment and connect
both live sources to Oracle AI Lakehouse. They then connect Codex through the
Oracle Data Studio MCP server and ask a simple business question. Codex
correctly refuses to invent a ranking from raw objects. Participants use Data
Studio AI Enrichment to review and save the business meaning of the data, then
repeat the same question and receive a better, annotation-backed answer.

For the final cross-source question, Codex identifies that descriptions and
tags alone are not a governed multidimensional model. Through MCP, Codex
creates and validates Analytic Views with common time, product, category, and
aggregation semantics. The final answer ranks product categories using current
digital interest and returned units, with repeatable product-level drill-down
and explicit limitations.

The workshop demonstrates Oracle AI Lakehouse as the governed decision layer
across existing Oracle and Databricks data, with Data Studio as the primary
user experience and Codex as the AI client.

## Catalog abstract

Can an AI assistant answer a business question simply because it can connect
to several data systems? In this hands-on workshop, participants connect live
Databricks Iceberg data and an existing Oracle operations database to Oracle
AI Lakehouse. They observe the limits of raw-data reasoning, add reviewed
business context with Data Studio AI Enrichment, and use Codex through MCP to
create governed Analytic Views. The result is an explainable category
recommendation built on reusable time, hierarchy, and aggregation rules.

## Customer problem

The customer already has the necessary data, but it is distributed across
systems and described technically rather than in shared business terms:

* Databricks contains the product catalog and high-volume digital clickstream.
* An existing Oracle database contains operational return events.
* AI clients can reach data, but connectivity alone does not define measures,
  grain, time alignment, hierarchies, joins, or approved aggregations.
* One-off generated SQL can produce plausible but inconsistent answers.

The business question is:

> Which product categories should we prioritize, balancing current customer
> interest with returns?

## Oracle AI Lakehouse value demonstrated

* Connects live Oracle and Databricks/Iceberg sources without creating a
  separate learner-built staging pipeline.
* Uses Data Studio as the visual place to connect sources and review AI-assisted
  business metadata.
* Persists reviewed descriptions and tags as native database annotations.
* Uses Analytic Views to govern measures, hierarchies, grain, and drill-down.
* Gives Codex task-oriented MCP access without exposing source credentials or
  an administrator database account.
* Keeps the final answer reproducible and explicit about its limitations.
* Introduces Lake Cache directly after the Iceberg mount while keeping
  performance claims evidence-based.

## Target audience

### Primary audience

* Data engineers integrating Oracle and Databricks data.
* Database administrators and Autonomous Database practitioners.
* Analytics engineers and semantic-model designers.
* Data and AI architects evaluating governed agent access.
* AI application developers using MCP-based data tools.
* Oracle solution engineers and technical field teams.

### Secondary audience

* Technical product managers.
* Technical business analysts who understand basic database concepts.
* Retail analytics practitioners evaluating product-interest and returns use
  cases.

### Not the primary audience

This is not a no-code business-user workshop. Participants perform database
administration, credential, catalog-mount, SQL, and MCP setup steps.

## Recommended prior knowledge

Participants should be comfortable with:

* basic SQL concepts;
* database users and privileges;
* tables, views, and aggregations;
* the purpose of OAuth credentials; and
* basic use of a desktop AI assistant.

Prior experience with Oracle Analytic Views, Iceberg internals, Python, uv, or
manual MCP configuration is not required.

## Participant prerequisites

* A macOS laptop for the current starter-kit implementation.
* Codex Desktop installed and signed in.
* A modern browser.
* Internet access.
* Lab-only ADMIN and PEAKGEAR_USER credentials from the private handout.
* The Lab Data Studio URL produced in Lab 1.
* Azure read-only SAS and Databricks OAuth values from the private handout.

## Environment prerequisites

The workshop environment must provide:

* an assigned Oracle AI Lakehouse database;
* an existing Oracle operations database exposing CUSTOMER_RETURN_EVENTS;
* a Databricks Unity Catalog endpoint exposing ICEBERG.PRODUCTS and
  ICEBERG.DIGITAL_CLICKSTREAM_EVENTS;
* network access from the lab database to the Databricks OAuth endpoint;
* OCI Resource Principal and required IAM policy;
* a default NL2SQL AI profile that supports Data Studio AI Enrichment; and
* the project-scoped PeakGear LiveLab MCP starter kit.

The default AI profile is created before the workshop. Participants do not
create, edit, select, or validate an AI profile.

## What participants do

This is the current hands-on boundary:

1. Sign in as ADMIN and create or verify PEAKGEAR_USER, minimum grants, ORDS
   enablement, the Operations database link, the Data Studio URL, and the
   Databricks host ACL.
2. Sign out completely and sign back in as PEAKGEAR_USER.
3. Use Data Studio UI to create the Azure storage credential and Databricks
   OAuth credential.
4. Use Data Studio UI to mount the Databricks Unity/Iceberg catalog.
5. Add Lake Cache policies for both mounted Iceberg tables.
6. Create three user-owned raw views over products, digital intent, and
   returns.
7. Configure the project-scoped LiveLab MCP connection with the supplied
   starter script.
8. Ask a simple raw-data question and observe a controlled stop.
9. Use Data Studio AI Enrichment to review and save descriptions and tags.
10. Repeat the same question and observe the improved answer.
11. Ask a harder cross-source question and identify the governed-model gap.
12. Ask Codex through MCP to create and validate the required Analytic Views.
13. Ask the final question and review the governed category and product
    drill-down.

## What is preconfigured

* The Oracle AI Lakehouse database exists.
* The Oracle operations database exists and contains the lab data.
* The Databricks Unity Catalog and Iceberg tables exist.
* OCI IAM and Resource Principal infrastructure are available.
* The default Data Studio AI profile exists.
* The source datasets are populated.

Preconfigured does not mean hidden instructor setup: Lab 1 ADMIN actions are
performed by the participant.

## Learning objectives

After completing the workshop, participants can:

1. Explain why source connectivity is not the same as shared business
   semantics.
2. Connect Databricks Unity/Iceberg and an existing Oracle database to Oracle
   AI Lakehouse.
3. Use Data Studio AI Enrichment to review and persist business metadata.
4. Distinguish annotations from governed measures, hierarchies, and
   aggregations.
5. Connect Codex to Data Studio through a bounded MCP configuration.
6. Use a controlled AI stop to identify missing business definitions.
7. Create and validate Analytic Views through Codex and MCP.
8. Produce an explainable cross-source answer with a reusable drill-down.
9. Explain the difference between a Lake Cache policy, populated cache files,
   and verified query acceleration.

## Workshop outline

| Lab | Title | Duration |
|---:|---|---:|
| 1 | Prepare the PeakGear lab as ADMIN | 15 minutes |
| 2 | Sign in as PEAKGEAR_USER | 5 minutes |
| 3 | Connect real Oracle and Databricks sources | 15 minutes |
| 4 | Connect Codex and ask the raw-data question | 8 minutes |
| 5 | Add business meaning with Data Studio AI Enrichment | 12 minutes |
| 6 | Identify the governed-model gap | 5 minutes |
| 7 | Create Analytic Views with Codex and answer the question | 15 minutes |
| Buffer | Troubleshooting and discussion | 15 minutes |
| Total |  | 90 minutes |

## Business questions used in the workshop

### Question 1 — before and after enrichment

> Which products are customers interested in right now?

The exact same question is asked twice:

* Before enrichment, Codex stops because interest, grain, time, and display
  semantics are undefined.
* After enrichment, Codex returns the latest-completed-month product ranking
  using the reviewed digital-event definition.

### Question 2 — before and after Analytic Views

> Which product categories should we prioritize, balancing current customer
> interest with returns?

* Before Analytic Views, Codex identifies the missing common time window,
  category hierarchy, additive measures, and governed drill-down.
* After Analytic Views, Codex returns the category recommendation with product
  evidence and explicit return context.

## Products, features, and technologies

* Oracle AI Lakehouse
* Oracle Data Studio
* Oracle Database Links
* Oracle Analytic Views
* Oracle database annotations
* Oracle Data Studio MCP Server
* OCI Resource Principal
* Databricks Unity Catalog
* Apache Iceberg
* Azure Blob Storage
* Lake Cache
* Codex Desktop

## Suggested categories

Use the closest available TLF categories:

* Database
* Data Lakehouse
* Data Integration
* Analytics
* Generative AI
* AI Agents and MCP
* Multicloud
* Retail

## Suggested keywords and tags

Oracle AI Lakehouse, Data Studio, Databricks, Unity Catalog, Apache Iceberg,
Lake Cache, database link, Analytic Views, semantic layer, annotations, Codex,
MCP, governed AI, retail analytics, product popularity, digital intent,
returns analysis, cross-source analytics.

## Success criteria

The workshop is successful when:

* PEAKGEAR_USER can read both mounted Iceberg tables and the Operations table;
* Codex confirms the bounded PEAKGEAR_USER MCP session;
* the first raw question produces a controlled stop;
* AI Enrichment metadata is saved and visible in Data Studio;
* the repeated simple question produces the defined latest-month ranking;
* the harder question identifies the need for a governed model;
* LAB_DIGITAL_POPULARITY_AV and LAB_RETURNS_AV are valid and queryable; and
* the final answer uses the common period, digital-event count, and returned
  units without inventing revenue, sales, or return rate.

## Deliberate non-goals

* The workshop does not calculate sales, revenue, margin, or return rate.
* Digital interest means digital-event count, not orders or unique customers.
* Returned units are quality context, not a rate, because shipped-unit volume
  is not present.
* The lab does not copy source data into participant-built staging tables.
* The lab does not teach manual TOML editing, Python setup, or direct MCP
  server administration.
* The lab does not grant DBA or broad ANY privileges to PEAKGEAR_USER.
* The lab does not claim Lake Cache speedup without plan and runtime evidence.

## Security and publication notes

* Real passwords, SAS tokens, OAuth client secrets, client IDs, tenant URLs,
  and private endpoints must remain outside the public repository.
* The public SQL and screenshots use placeholders or masked values.
* Source credentials are never given to Codex.
* Codex connects as PEAKGEAR_USER, not ADMIN.
* The public Operations database link is created by ADMIN and consumed by the
  participant through bounded user-owned views.
* Review database names, regions, compartments, and tenant labels before
  external publication.

## Current content status

Completed:

* Seven-module LiveLabs folder structure and sandbox manifest.
* ADMIN setup script with public placeholders.
* Project-scoped Codex MCP starter kit.
* Data Studio credential, Unity mount, catalog, default-profile, and AI
  Enrichment screenshots.
* Codex screenshots for raw stop, improved simple answer, and final governed
  answer.

Still required before publication:

* Lake Cache inspection screenshot.
* Data Studio Catalog screenshot after the reviewed annotations are saved.
* Codex screenshot explaining the governed-model gap.
* Codex screenshot creating and validating both Analytic Views.
* Final end-to-end dry run in the target event environment.
* Verification that the target Data Studio MCP release can perform the
  Analytic View build path used by the workshop.
* Final Lake Cache behavior and query-plan evidence.

## Known evidence boundaries

* Data Studio descriptions and tags are annotations. They improve context but
  do not themselves enforce joins, measures, hierarchies, or aggregation.
* Analytic Views provide the governed multidimensional contract used in the
  final stage.
* A visible AI profile or AI Profile ready badge is not sufficient runtime
  proof; AI Enrichment and the actual Codex MCP path must work in the dry run.
* A populated Lake Cache is not proof that a query used the cache or ran
  faster.
* Codex-generated Analytic View creation remains a publication gate until it
  succeeds with the target MCP release.

## Source files

| Purpose | Relative path |
|---|---|
| Workshop entry | readme.md |
| Existing workshop metadata | workshop-details.md |
| Release checklist | author-review.md |
| Screenshot mapping | traceability.md |
| Sandbox manifest | workshops/sandbox/manifest.json |
| ADMIN setup | scripts/00-admin-setup.sql |
| Codex starter kit | starter-kit/ |
| Learner modules | admin-setup/, connect-peakgear/, connect-sources/, connect-codex/, ai-enrichment/, governed-question/, analytic-views/ |

## Instructions for the next Codex agent

When using this document to populate TLF:

1. Preserve the canonical title, short description, long description, audience,
   duration, prerequisites, learning objectives, and outline unless the user
   explicitly requests a rewrite.
2. Map these definitions to the actual TLF field names; do not invent missing
   event IDs, dates, owners, capacities, costs, or regions.
3. If a field has a character limit, produce a shorter variant while
   preserving the customer problem, the two live sources, Data Studio,
   governed Analytic Views, and Codex through MCP.
4. Do not add AI Profile creation to the participant flow. The default profile
   is preconfigured.
5. Keep Lab 1 ADMIN setup as participant hands-on work.
6. Do not replace Codex-created Analytic Views with learner copy-and-paste DDL
   unless the user explicitly chooses the fallback path.
7. Do not describe annotations as constraints or guaranteed joins.
8. Do not claim sales, revenue, margin, return rate, or Lake Cache performance
   that the lab does not prove.
9. Keep real credentials and tenant-specific values out of public output.
10. Use the files listed above as the source of truth for final links and
    current readiness.
