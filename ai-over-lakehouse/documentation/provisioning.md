# Provider-only provisioning boundary

Estimated Time: Reference only; not a timed learner task.

### Objectives

Separate provider-owned setup from learner steps and identify the prerequisites for a ready reservation.

The learner workshop starts at **Lab 1**. LiveLabs provisioning must complete
before the reservation is ready. Participants do not connect as ADMIN.

The environment provider prepares:

* the assigned database and PEAKGEAR_USER account with its reservation-specific
  Database Password, `CREATE TABLE`, enough table space quota for three local
  raw snapshots and supporting aggregate/model tables, and the remaining
  object-creation privileges;
* ADLS_PEAKGEAR_DATA and DBX_PEAKGEAR_OAUTH source credentials owned by
  PEAKGEAR_USER, ready for catalog mounting;
* ORDS / Database Actions access for that user;
* the required Databricks network ACL;
* the public PEAKGEAR_OPERATIONS_LINK pointing to the event Operations source;
* Resource Principal and IAM prerequisites; and
* the Data Studio AI profile named in the reservation's Environment Details.

Before release, validate the read-only ADP_URL lookup from Lab 3, Task 1 in a
Data Studio SQL Worksheet connected as PEAKGEAR_USER. It reads the current
PDB's name and public domain from V$PDBS.CLOUD_IDENTITY. If the query fails or
returns no URL, repair and retest the reservation before participants begin.
Do not ask participants to switch to ADMIN. Do not add a broad catalog-view
grant as a workaround without confirming the minimum required privilege for
the target environment.

LiveLabs exposes OCI Login Credentials and Tenancy Information separately from
Environment Details. Those details must include Database Name, Database User,
Database Password, AI Profile Name, and Operations Database Link. OCI and
database passwords must not be confused or copied from illustrative screenshots.

## Provisioned source credentials

Provision both credentials before marking the reservation ready:

| Credential owned by PEAKGEAR_USER | Purpose |
|---|---|
| ADLS_PEAKGEAR_DATA | Read the prepared Iceberg files in Azure Blob Storage |
| DBX_PEAKGEAR_OAUTH | Authenticate to the prepared Databricks Unity Catalog |

Create and maintain their protected values only in the private provisioning
workflow. Learners select the saved credentials in Data Studio. They do not
create, replace, refresh, or delete them, and do not need Azure Storage Password,
Databricks Client ID, or Databricks Client Secret in View Login Info. The
reservation's Database Password is still required for Data Studio and MCP.

Before marking a fresh reservation ready:

1. Sign in to the assigned database as PEAKGEAR_USER. Verify that both names
   are visible in USER_CREDENTIALS and selectable in Data Studio. Credentials
   available only to ADMIN do not satisfy this participant check.
2. Complete the Lab 2 UI mount using the existing credentials and public
   settings. Both Iceberg tables and the Operations returns table must return
   sample rows; all three local snapshots must be created successfully.
3. In a separate fresh reservation, validate the optional SQL mount. A wrong
   participant identity or either missing credential must stop before mounting.
   An existing catalog must be left intact. Confirm that neither SQL reference
   creates, replaces, refreshes, or deletes credentials, including on retry.
4. Run the offline package/security tests and verify the regenerated ZIP.
   Inspect screenshots before publishing. Static checks do not establish that
   provisioning or the live mount succeeds.

If a credential is missing or invalid, repair the private provisioning and
retest the reservation. Do not ask learners to enter source secrets or switch
to ADMIN. Keep the documented credential names stable when rotating values.

Previously published values must remain revoked/rotated by their service
owners, with access-audit follow-up tracked privately. Updating the learner
flow does not purge Git history or revoke older downloaded copies.

## Provider-only SQL reference

The preserved [legacy ADMIN SQL](../scripts/00-admin-setup.sql) is an operator
reference only, not the automated reservation template and not a learner task.
Its protected-value placeholders must be filled only in a private operator
worksheet; unfilled password blocks fail before creating an account or credential.
The reservation's provisioned password remains authoritative. Do not run it against an already prepared reservation just to
follow the workshop. Provider templates and their secrets are maintained in the
provisioning workflow, not supplied to participants as extra setup steps.

If the participant checkpoint fails, repair the reservation rather than asking
learners to grant privileges, create profiles, or use ADMIN. Verify the provider
template with a new reservation before release; a static workshop review does
not prove successful provisioning. Verify that the participant can create the
Lab 5 tables, dimensions, hierarchies, and AV through explicit SQL DDL in
adp_run_query; the learner does not use adp_build_analytic_view or ADMIN access.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, November 2026
