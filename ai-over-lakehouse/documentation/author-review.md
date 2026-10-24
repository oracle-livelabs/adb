# PeakGear author review and release checklist

### Objectives

Check the learner flow, package requirements, and target-environment release gates before publication.

Estimated Time: 10 minutes to review; run a separate end-to-end dry run before
publication.

## Delivery status

The package matches the LiveLabs workshop layout: separate learner labs,
per-lab image folders, a sandbox loader/manifest, workshop details, source
traceability, and an author review. It is a local authoring package, not a
claim that the workshop is ready for public publication.

The default AI profile is instructor-prepared. The learner flow does not ask a
participant to create, edit, or validate an AI profile.

## Mandatory dry-run checks

- [ ] The default workshop page starts at Lab 1; no participant ADMIN setup is listed.
- [ ] PeakGear is introduced as fictional, and the cross-source query-hub
  business benefit is explained before setup.
- [ ] Before the event, every participant has a supported installed Codex
  client, account access, and permission to use local project-scoped MCP.
- [ ] Run the downloaded Starter Kit on a clean macOS laptop and a clean native
  Windows laptop: install packages, enter URL/password, save to the OS credential
  store, trust the local project, and obtain a ready MCP connection. Exercise
  Restart/Stop/Status on each OS and preserve unrelated project configuration.
  Offline tests do not replace these two target-machine dry runs.
- [ ] Reservation Information provides OCI Login Credentials separately from
  Database User and Database Password; the participant user is PEAKGEAR_USER.
- [ ] On a fresh reservation, verify whether the OCI login forces a first-use
  password change; keep it clearly separate from the database password.
- [ ] The reservation is active before starting or resuming; EXPIRED is not
  treated as an MCP configuration error.
- [ ] Provider provisioning already enabled `CREATE TABLE`, table space quota,
  the remaining required grants, ORDS, network
  ACL, Operations link, and AI profile before the reservation is marked ready.
- [ ] Operations credential and public database link read
  `CUSTOMER_RETURN_EVENTS`.
- [ ] Data Studio Region, Compartment, and Database Name match the reservation.
- [ ] Before release, validate that PEAKGEAR_USER can run the read-only
  V$PDBS cloud-identity lookup. Lab 3 Task 1 obtains ADP_URL before
  the OS-specific 01 setup script; participants do not switch to ADMIN.
- [ ] `PEAKGEAR_USER` can sign in using Environment Details → Database Password,
  not the OCI Login Credentials password or a sample password.
- [ ] View Login Info → Environment Details contains Azure Storage Password,
  Databricks Client ID, and Databricks Client Secret. A learner can copy the
  current replacement values without GitHub or a separate credential message.
- [ ] Data Studio UI creates the Azure credential and Unity/Iceberg mount.
- [ ] Lab 2's SQL note is explicitly reference-only, not a required learner
  step. In a separate test reservation, validate the reference with private
  View Login Info values and the Task 1 Azure credential. Confirm the same
  two Iceberg tables and Task 3 sample reads. Test missing placeholders, a
  missing Azure credential, and an existing mount: each must stop before any
  credential replacement. Preserve the exact error if mounting fails after
  credential creation; inspect existing objects before retrying.
- [ ] The catalog form explicitly selects both credentials before Add; expanding
  the connected catalog exposes tables without a mandatory extra refresh.
- [ ] Save separate, named live-source-check and local-snapshot worksheets.
  Explain live federation versus optional local copies for performance/enrichment.
- [ ] `PRODUCTS` and `DIGITAL_CLICKSTREAM_EVENTS` return real rows.
- [ ] Lab 2 reads up to five rows from each remote source before local raw-table
  creation; no full source count or data-caching exercise is present. Table
  creation completes and Sample Data shows rows for all three local tables.
- [ ] The default AI profile produces non-empty descriptions and tags for the
  table and every column; an editable dialog or pre-existing tags alone are not
  proof that fresh AI Enrichment succeeded.
- [ ] Codex `adp_get_connection_info` confirms the reserved database URL,
  `PEAKGEAR_USER`, a ready session, and the expected JSON response adapter.
- [ ] The raw question receives an appropriately cautious answer.
- [ ] Lab 4 saves reviewed descriptions and tags for all three raw tables,
  including the product-name and join-key column definitions; the metadata is
  visible in Catalog.
- [ ] Useful generated descriptions/tags remain. Only incorrect or missing
  business rules are edited; arbitrary tag-name equality or 28 annotation rows
  are not pass criteria. Verify the simple ranking and AV workflow with these
  minimally edited annotations, including repeated event PRODUCT_ID values.
- [ ] Lab 5 reuses the Lab 4 annotations without repeating AI Enrichment.
- [ ] Lab 5 contains the harder question, model requirements, AV creation,
  and final governed answer in order; there is no separate Lab 6.
- [ ] The enriched simple answer uses product names from the reviewed product
  catalog; aggregation precedes the label join and duplicate product keys stop it.
- [ ] The answer states the actual latest completed month available in the
  source, excluding the database's current and future months. Historical data
  is not presented as current live demand.
- [ ] Codex identifies the cross-source governed-model gap.
- [ ] Without a validated governed Analytic View, the harder question returns no ranking,
  figures, or provisional recommendation.
- [ ] A missing unknown-category annotation alone does not block the AV build.
  Codex follows a saved handling rule when present; otherwise it applies the
  explicit Lab 3 default, keeps missing-category measures in reconciliation,
  reports them separately, and does not infer business categories or change
  raw data. Missing essential metric definitions and ambiguous product keys
  still block interpretation.
- [ ] Lab 3 Task 2 establishes the complete boundary once, including the
  conditional AV workflow, without authorizing a build. Lab 5 Task 3 uses the
  same Codex task and contains only the short authorized build request, not
  another boundary prompt.
- [ ] Codex reuses a suitable existing AV and dependencies, or creates one AV
  through explicit SQL DDL in `adp_run_query`; it does not use
  `adp_build_analytic_view` or create exploratory AVs.
- [ ] Digital events and returned quantities are aggregated independently by
  product/month before combination. Both SUM measures reconcile for the latest
  shared completed month, with one consolidated final health check.
- [ ] After a timeout, Codex inspects existing objects before retrying and
  repeats checks only after a failure or relevant change.
- [ ] Every screenshot in `traceability.md` is captured, reviewed, and inserted
  with alt text.
- [ ] All local image links and the sandbox manifest resolve in a local preview.
- [ ] Every learner code block has a working Copy button, and the Starter Kit
  download returns the current ZIP rather than a stale cached version.
- [ ] Reservation screenshots are labelled examples; no visible database or OCI
  password is published. The edited environment illustration is labelled redacted.

## Known release gates

* The product-grain check must pass before joining labels or building a model;
  resolving duplicate reads must not mean arbitrarily deduplicating source data.
* Confirm the Data Studio AI Enrichment dialog targets `ALTER TABLE` for each
  local raw table. Lab 4 now has table-based entry, review, and saved-state
  screenshots; they illustrate the UI but do not prove the target check or
  exact contract completeness. Replace the remaining historical raw-question
  and enriched-answer captures.
* Local tables are snapshots; a new reservation dry run must validate the
  one-time copy duration, quota, and product-key uniqueness before analytics.
* The exact current Data Studio labels for Azure credential and Unity mount UI
  require capture before those steps are published.
* Verify that `adp_run_query` can execute the required explicit SQL DDL as
  PEAKGEAR_USER in the target event release. The Lab 5 workflow does not use
  the high-level Analytic View builder.
* Do not publish passwords, SAS tokens, concrete Databricks client IDs, client
  secrets, or private keys in text, SQL, screenshots, or the Starter Kit ZIP.
  Run the offline credential regression checks before publishing.
* Verify View Login Info exposes all three Lab 2 protected fields. The backend
  update is external to this PR. Service owners must revoke/rotate previously
  exposed credentials and audit access; a new reservation must then complete
  Lab 2 with the replacement values. Removing files does not purge Git history.
* Participant database passwords come only from the active LiveLabs reservation.
  The legacy provider SQL is not a learner step or a source of the live password.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
