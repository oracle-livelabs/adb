# Source and asset traceability

## Content sources

| Source | Use and boundary |
|---|---|
| PeakGear lab source files | Technical sequence, object names, SQL, MCP checkpoints, and runtime gates. |
| Owner-confirmed working Unity mount SQL, supplied October 5, 2026 | Azure storage password, Databricks OAuth values, catalog endpoint, and discovery/read calls. Host ACL belongs to provider provisioning; the learner mount stays under PEAKGEAR_USER. |
| Owner-supplied LiveLabs Reservation Information screenshots, October 6, 2026 | OCI versus database credential fields and prepared environment details. Illustrative values only; the database password is redacted. |
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
| 6.1 | ai-enrichment/images/ai-enrichment-entry.png | 4 | View Overview and AI Enrichment entry point |
| 6.2 | ai-enrichment/images/ai-enrichment-review.png | 4 | AI Enrichment review form before Save |
| 8 | connect-codex/images/raw-question.png | 3 | Controlled stop before the Digital Intent contract is saved |
| 9 | ai-enrichment/images/same-question-after-enrichment.png | 4 | Same question after the annotation-backed contract |
| 11 | analytic-views/images/final-governed-answer.png | 6 | Governed category recommendation and drill-down |

## Still needed

| File | Lab | Required visible state |
|---|---:|---|
| connect-sources/images/lake-cache-policy.png | 2 | SQL Worksheet cache inspection for both mounted Iceberg tables |
| ai-enrichment/images/ai-enrichment-saved.png | 4 | Catalog Overview after the reviewed Description and Tags are saved |
| governed-question/images/governed-model-gap.png | 5 | Codex names time, hierarchy, and aggregation requirements without recommending |
| analytic-views/images/codex-builds-av.png | 6 | Codex creates and validates both Analytic Views |

## Publication checks

* The original Data Studio and Codex screenshots are retained dry-run evidence,
  not proof of a new reservation's current state. Reservation screenshots are
  explicitly examples. The Environment Details image was edited with Image
  Generation solely to mask the database password and is labelled a redacted
  illustration, not an unmodified execution capture.
* One image explains one action and preserves a useful header or breadcrumb.
* The source endpoints and client ID are owner-approved event values. Review
  unrelated database names, compartments, tenant labels, and browser identity
  before publishing externally.
* Each Markdown image has descriptive alt text.
* The old default-ai-profile.png remains a historical asset, not the current
  learner reference: profile names must come from the reservation.
* Do not claim Lake Cache acceleration without a verified plan and runtime
  comparison.

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
