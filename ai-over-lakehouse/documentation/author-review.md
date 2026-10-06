# PeakGear author review and release checklist

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

- [ ] The default workshop page starts at Lab 2; no participant ADMIN setup is listed.
- [ ] Reservation Information provides OCI Login Credentials separately from
  Database User and Database Password; the participant user is PEAKGEAR_USER.
- [ ] Provider provisioning already enabled the required grants, ORDS, network
  ACL, Operations link, and AI profile before the reservation is marked ready.
- [ ] Operations credential and public database link read
  `CUSTOMER_RETURN_EVENTS`.
- [ ] Data Studio Region, Compartment, and Database Name match the reservation.
- [ ] Lab 2 obtains the actual Database Actions HTTPS origin without an ADMIN
  login; Lab 4 and the Starter Kit reuse it before 01-setup-peakgear-mcp.command.
- [ ] `PEAKGEAR_USER` can sign in using Environment Details → Database Password,
  not the OCI Login Credentials password or a sample password.
- [ ] Data Studio UI creates the Azure credential and Unity/Iceberg mount.
- [ ] `PRODUCTS` and `DIGITAL_CLICKSTREAM_EVENTS` return real rows.
- [ ] The default AI profile is ready and AI Enrichment exposes editable fields.
- [ ] Codex `adp_get_connection_info` confirms the reserved database URL,
  `PEAKGEAR_USER`, a ready session, and the expected JSON response adapter.
- [ ] The raw question receives an appropriately cautious answer.
- [ ] Lab 5 saves reviewed descriptions and tags for all three raw views,
  including the product-name and join-key column definitions; the metadata is
  visible in Catalog.
- [ ] Lab 6 reuses the Lab 5 annotations without repeating AI Enrichment.
- [ ] The enriched simple answer uses product names from the reviewed product
  catalog; aggregation precedes the label join and duplicate product keys stop it.
- [ ] Codex identifies the cross-source governed-model gap.
- [ ] Codex creates, validates, and queries both Analytic Views.
- [ ] Every screenshot in `traceability.md` is captured, reviewed, and inserted
  with alt text.
- [ ] All local image links and the sandbox manifest resolve in a local preview.
- [ ] Every learner code block has a working Copy button, and the Starter Kit
  download returns the current ZIP rather than a stale cached version.
- [ ] Reservation screenshots are labelled examples; no visible database or OCI
  password is published. The edited environment illustration is labelled redacted.

## Known release gates

* The cache behavior must be rerun and described accurately. Do not present a
  cache policy as a successful acceleration proof without query-plan evidence.
* The exact current Data Studio labels for Azure credential and Unity mount UI
  require capture before those steps are published.
* The currently available LiveLab MCP build tools must be verified in the
  target event release before promising autonomous Analytic View creation.
* Only the event-owner-approved shared values in `assets/event-lab-values.md`
  are included. Do not add unrelated credentials, ADMIN passwords, or OCI API
  private keys. The owner-confirmed mount script is the source for the Azure
  and Databricks values; a new end-to-end dry run is still required.
* Participant database passwords come only from the active LiveLabs reservation.
  The legacy provider SQL is not a learner step or a source of the live password.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
