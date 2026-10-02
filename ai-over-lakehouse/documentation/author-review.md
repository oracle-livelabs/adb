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

- [ ] Lab-only `ADMIN` can create or verify `PEAKGEAR_USER`.
- [ ] Operations credential and public database link read
  `CUSTOMER_RETURN_EVENTS`.
- [ ] Generated Data Studio URL opens the assigned environment.
- [ ] `PEAKGEAR_USER` can sign in after the required logout/login.
- [ ] Data Studio UI creates the Azure credential and Unity/Iceberg mount.
- [ ] `PRODUCTS` and `DIGITAL_CLICKSTREAM_EVENTS` return real rows.
- [ ] The default AI profile is ready and AI Enrichment exposes editable fields.
- [ ] Codex `adp_get_connection_info` confirms `PEAKGEAR_USER` and a ready
  session.
- [ ] The raw question receives an appropriately cautious answer.
- [ ] The enrichment checkpoint is saved and visible in Catalog.
- [ ] Codex identifies the cross-source governed-model gap.
- [ ] Codex creates, validates, and queries both Analytic Views.
- [ ] Every screenshot in `traceability.md` is captured, redacted, and inserted
  with alt text.
- [ ] All local image links and the sandbox manifest resolve in a local preview.

## Known release gates

* The cache behavior must be rerun and described accurately. Do not present a
  cache policy as a successful acceleration proof without query-plan evidence.
* The exact current Data Studio labels for Azure credential and Unity mount UI
  require capture before those steps are published.
* The currently available LiveLab MCP build tools must be verified in the
  target event release before promising autonomous Analytic View creation.
* No secret from a chat transcript or local shell history may be committed.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, September 2026
