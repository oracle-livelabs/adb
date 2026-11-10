# Source and asset traceability

Estimated Time: Reference only; not a timed learner task.

### Objectives

Trace workshop content and screenshots to retained sources and record outstanding capture checks.

## Content sources

| Source | Use and boundary |
|---|---|
| PeakGear lab source files | Technical sequence, object names, SQL, MCP checkpoints, and runtime gates. |
| Owner-confirmed working Unity mount SQL, supplied October 5, 2026 | Original source for the public catalog endpoint and mount/read calls. The current learner flow reuses provisioned credentials. Protected values and the host ACL belong to provider provisioning; the learner mount stays under PEAKGEAR_USER. |
| Owner-confirmed default provisioning, November 4, 2026 | Source credentials are prepared before the learner starts; Lab 2 selects existing names. Fresh-reservation validation remains a provider release check. |
| Valentina Feruere, Re: Review HOL Issue LH Summit, November 9, 2026; corrections ZIP and original screenshots | Execution-result wording in Lab 1; current Data > Database navigation, Test-before-Add, worksheet controls, and Data Explorer in Lab 2. These supplied UI examples are not a new end-to-end execution. |
| Owner-supplied LiveLabs Reservation Information screenshots, October 6, 2026 | OCI versus database credential fields and prepared environment details. Illustrative values only; the database password is redacted. |
| Owner-supplied Data Studio screenshots, October 8, 2026 | Lab 4 local-table Catalog, AI Enrichment entry and review, and saved annotations. Unmodified UI examples; Task 2 defines the reviewed contract, not the example's AI suggestions. |
| Participant-authorized Data Studio and Codex sessions | UI screenshots captured during the working dry run. |
| Official Oracle documentation | Public Learn More links and supported product behavior. |

Public endpoints and credential aliases remain in the field reference.
Source credentials are now created during private provisioning; learners
select their saved names. Only the participant database login values come
from LiveLabs View Login Info.
The OAuth credential screenshot was withdrawn because it displayed a concrete
client ID. The current mount screenshot shows an unconfigured form; the field
table supplies the public endpoint and credential aliases. No source-data export, ADMIN login, or OCI API private key
is added to the package.

## Captured screenshots

| Source upload | Published file | Lab | Visible state |
|---|---|---:|---|
| 1.1 | connect-sources/images/azure-credential-start.png | 2, historical | Credential creation; retained for provenance, no longer embedded in the learner flow |
| 1.2 | connect-sources/images/create-azure-storage-credential.png | 2, historical | Azure credential creation; retained for provenance, no longer embedded in the learner flow |
| Screenshot 2026-11-09 182001.png | connect-sources/images/add-iceberg-catalog.png | 2 | Data > Database > Add > Iceberg Catalog; original screenshot supplied by Valentina |
| Screenshot 2026-11-09 182013.png | connect-sources/images/mount-iceberg-catalog.png | 2 | Unconfigured form with example name ICEBERG_CATALOG and default type Oracle; caption explicitly requires the workshop's DBX_UNITY_PEAKGEAR and Unity |
| Screenshot 2026-11-09 174808.png | connect-sources/images/test-iceberg-catalog.png | 2 | Catalog metadata access passed; Object Storage data access was not tested |
| Screenshot 2026-11-09 174839.png | connect-sources/images/connected-iceberg-tables.png | 2 | Example ICEBERG_CATALOG mount and ICEBERG > Tables with count 2; caption requires the workshop mount name and expanding Tables |
| Screenshot 2026-11-05 122922.png | connect-sources/images/run-sql-statement.png | 2 | Separate Run SQL gutter buttons beside individual statements |
| Screenshot 2026-11-09 175132.png | connect-sources/images/rename-worksheet.png | 2 | Worksheets > three-dot menu > Rename; Save disk icon in toolbar |
| Screenshot 2026-11-05 123530.png | connect-sources/images/local-snapshot-tables.png | 2 | SQL Worksheet > Data Explorer > Database > PEAKGEAR_USER > Tables shows all three local raw tables |
| Reservation Information | connect-peakgear/images/livelabs-reservation-information.png | 1 | OCI Login Credentials with UI-masked password, Launch OCI, tenancy, region, and compartment; example reservation only |
| Environment Details | connect-peakgear/images/livelabs-environment-details.png | 1 | Password-redacted illustration of assigned database user, name, profile, and Operations link |
| Screenshot 2026-10-08 at 4.18.31 PM | ai-enrichment/images/local-table-catalog.png | 4 | Catalog > PEAKGEAR_USER > Tables lists all three local raw tables |
| Screenshot 2026-10-08 at 4.18.47 PM | ai-enrichment/images/local-table-ai-enrichment-entry.png | 4 | Digital Intent table Overview with empty annotations and the AI Enrichment entry point |
| Screenshot 2026-10-08 at 4.19.21 PM | ai-enrichment/images/local-table-ai-enrichment-review.png | 4 | Editable table and column fields, Show code, and Save; visible suggestions are not the final contract |
| Screenshot 2026-10-08 at 4.19.35 PM | ai-enrichment/images/local-table-annotations-saved.png | 4 | Catalog Overview after Save; illustrates annotation locations, not complete contract validation |
| 11 | analytic-views/images/final-governed-answer.png | 5 | Governed category recommendation and drill-down |

## Still needed

| File | Lab | Required visible state |
|---|---:|---|
| connect-codex/images/raw-question.png | 3 | Controlled stop naming the current local table; replace historical view screenshot |
| ai-enrichment/images/same-question-after-enrichment.png | 4 | Ranking from reviewed local-table annotations; replace historical view screenshot |
| analytic-views/images/governed-model-gap.png | 5 | Codex names time, hierarchy, and aggregation requirements without recommending |
| analytic-views/images/codex-builds-av.png | 5 | Codex creates or reuses and validates one AV with both SUM measures through explicit MCP SQL |

## Publication checks

* The earlier view-based screenshots are retained as historical dry-run
  evidence but are no longer embedded in the affected learner pages. Lab 4
  now embeds the four owner-supplied local-table screenshots. The raw-question
  and enriched-answer captures still need table-based replacements. Reservation screenshots are
  explicitly examples. The Environment Details image was edited with Image
  Generation solely to mask the database password and is labelled a redacted
  illustration, not an unmodified execution capture.
* One image explains one action and preserves a useful header or breadcrumb.
* Public source endpoints may be shown; concrete client IDs, client secrets,
  SAS tokens, and passwords must not appear in text, SQL, images, or ZIPs.
  Review unrelated database names, compartments, tenant labels, and browser
  identity before publishing externally.
* Each Markdown image has descriptive alt text.
* Lab 4 screenshots are unmodified and contain no visible passwords or tokens.
  They show the older Catalog navigation; the learner text maps this to the
  current Data > Database path until new AI Enrichment captures are available.
  Their database labels are examples. The review and saved screenshots do not
  prove fresh AI generation, an ALTER TABLE target check, or completion of the
  exact Task 2 contract; learner captions preserve these evidence boundaries.
* The old default-ai-profile.png remains a historical asset, not the current
  learner reference: profile names must come from the reservation.
* The November 9 Lab 2 screenshots are unmodified originals from the email.
  They show no passwords, client IDs, or tokens. Default form values and the
  example mounted-catalog name are explicitly distinguished from lab settings.

## Reservation illustration edit provenance

Tool mode: built-in Image Generation, precise-object-edit, opaque background.
The original Environment Details upload is not distributed. The published
file is `connect-peakgear/images/livelabs-environment-details.png`. Its masking
and field labels were visually reviewed after generation.

Prompt: Change only the Environment Details value labelled Database Password.
Remove the original password pixels and replace them with twelve black mask
bullets. Preserve all other fields, labels, values, Copy buttons, colors,
borders, spacing, layout, and crop. No restyling or invented UI.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, November 2026
