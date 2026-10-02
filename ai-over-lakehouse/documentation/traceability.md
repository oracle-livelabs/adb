# Source and asset traceability

## Content sources

| Source | Use and boundary |
|---|---|
| PeakGear lab source files | Technical sequence, object names, SQL, MCP checkpoints, and runtime gates. |
| Participant-authorized Data Studio and Codex sessions | UI screenshots captured during the working dry run. |
| Official Oracle documentation | Public Learn More links and supported product behavior. |

No password, SAS token, OAuth client secret, or source-data export is included
in this package. Databricks endpoint and client-ID values have been redacted
from the two credential/mount screenshots.

## Captured screenshots

| Source upload | Published file | Lab | Visible state |
|---|---|---:|---|
| 1.1 | connect-sources/images/azure-credential-start.png | 3 | Database Settings, Credentials, Create credential |
| 1.2 | connect-sources/images/create-azure-storage-credential.png | 3 | Azure storage credential, password masked |
| 2.1 | connect-sources/images/add-iceberg-catalog.png | 3 | Catalog Add menu and Iceberg catalog choice |
| 2.2 | connect-sources/images/mount-iceberg-catalog.png | 3 | Unity mount form, workspace endpoint redacted |
| 2.3 | connect-sources/images/create-iceberg-catalog-credential.png | 3 | Iceberg OAuth credential, endpoint and client ID redacted |
| 3 | connect-sources/images/connected-iceberg-tables.png | 3 | Mounted catalog exposes the two Iceberg tables |
| 5 | connect-peakgear/images/default-ai-profile.png | 2 | Existing Data Studio NL2SQL profile with Resource Principal |
| 6.1 | ai-enrichment/images/ai-enrichment-entry.png | 5 | View Overview and AI Enrichment entry point |
| 6.2 | ai-enrichment/images/ai-enrichment-review.png | 5 | AI Enrichment review form before Save |
| 8 | connect-codex/images/raw-question.png | 4 | Controlled stop before the Digital Intent contract is saved |
| 9 | ai-enrichment/images/same-question-after-enrichment.png | 5 | Same question after the annotation-backed contract |
| 11 | analytic-views/images/final-governed-answer.png | 7 | Governed category recommendation and drill-down |

## Still needed

| File | Lab | Required visible state |
|---|---:|---|
| connect-sources/images/lake-cache-policy.png | 3 | SQL Worksheet cache inspection for both mounted Iceberg tables |
| ai-enrichment/images/ai-enrichment-saved.png | 5 | Catalog Overview after the reviewed Description and Tags are saved |
| governed-question/images/governed-model-gap.png | 6 | Codex names time, hierarchy, and aggregation requirements without recommending |
| analytic-views/images/codex-builds-av.png | 7 | Codex creates and validates both Analytic Views |

## Publication checks

* Screenshots are authentic dry-run evidence; they are not fabricated.
* One image explains one action and preserves a useful header or breadcrumb.
* Review database names, regions, compartments, tenant labels, and browser
  identity before publishing externally.
* Each Markdown image has descriptive alt text.
* Do not claim Lake Cache acceleration without a verified plan and runtime
  comparison.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, September 2026
