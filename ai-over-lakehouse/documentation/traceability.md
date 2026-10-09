# Source and asset traceability

## Content sources

| Source | Use and boundary |
|---|---|
| PeakGear lab source files | Technical sequence, object names, SQL, MCP checkpoints, and runtime gates. |
| Owner-confirmed working Unity mount SQL, supplied October 5, 2026 | Azure storage password, Databricks OAuth values, catalog endpoint, and discovery/read calls. Host ACL belongs to provider provisioning; the learner mount stays under PEAKGEAR_USER. |
| Owner-supplied LiveLabs Reservation Information screenshots, October 6, 2026 | OCI versus database credential fields and prepared environment details. Illustrative values only; the database password is redacted. |
| Owner-supplied Data Studio screenshots, October 8, 2026 | Lab 4 local-table Catalog, AI Enrichment entry and review, and saved annotations. Unmodified UI examples; Task 2 defines the reviewed contract, not the example's AI suggestions. |
| Participant-authorized Data Studio and Codex sessions | UI screenshots captured during the working dry run. |
| Official Oracle documentation | Public Learn More links and supported product behavior. |

The event owner approved including the shared lab passwords, Azure storage
password, Databricks client ID, client secret, and source endpoints for
copy/paste. See `assets/event-lab-values.md`. The two Databricks screenshots
use the original uploaded images with their endpoint and client ID visible.
Password fields remain masked by the authentic UI; complete values are printed
in the instructions. No source-data export, ADMIN login, or OCI API private key
is added to the package.

## Captured screenshots

| Source upload | Published file | Lab | Visible state |
|---|---|---:|---|
| 1.1 | connect-sources/images/azure-credential-start.png | 2 | Database Settings, Credentials, Create credential |
| 1.2 | connect-sources/images/create-azure-storage-credential.png | 2 | Azure storage credential, password masked |
| 2.1 | connect-sources/images/add-iceberg-catalog.png | 2 | Catalog Add menu and Iceberg catalog choice |
| 2.2 | connect-sources/images/mount-iceberg-catalog.png | 2 | Unity mount form, approved workspace endpoint visible |
| 2.3 | connect-sources/images/create-iceberg-catalog-credential.png | 2 | Iceberg OAuth credential, approved endpoint and client ID visible, UI password field masked |
| 3 | connect-sources/images/connected-iceberg-tables.png | 2 | Mounted catalog exposes the two Iceberg tables |
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
* The source endpoints and client ID are owner-approved event values. Review
  unrelated database names, compartments, tenant labels, and browser identity
  before publishing externally.
* Each Markdown image has descriptive alt text.
* Lab 4 screenshots are unmodified and contain no visible passwords or tokens.
  Their database labels are examples. The review and saved screenshots do not
  prove fresh AI generation, an ALTER TABLE target check, or completion of the
  exact Task 2 contract; learner captions preserve these evidence boundaries.
* The old default-ai-profile.png remains a historical asset, not the current
  learner reference: profile names must come from the reservation.

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
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
