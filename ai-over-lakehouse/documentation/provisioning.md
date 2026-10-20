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

The preserved [legacy ADMIN SQL](../scripts/00-admin-setup.sql) is an operator
reference only, not the automated reservation template and not a learner task.
Its example password must not override the password supplied by reservation
provisioning. Do not run it against an already prepared reservation just to
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
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
