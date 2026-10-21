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

## Private source-credential fields — backend release prerequisite

Coordinate these exact field labels with the LiveLabs backend owner before
releasing the updated learner flow. The PR changes documentation and packages;
it does not add backend fields or rotate remote credentials.

| View Login Info → Environment Details field | Learner use in Lab 2 |
|---|---|
| Azure Storage Password | Azure credential Password |
| Databricks Client ID | Iceberg OAuth2 credential Client ID |
| Databricks Client Secret | Iceberg OAuth2 credential Client secret |

Populate the fields only through the private provisioning/backend workflow.
Never place their values in GitHub, a public PR, screenshots, or a Starter Kit.
The public endpoint and storage username in the field reference remain
non-secret connection settings. Do not change their meaning or the learner's
object aliases when supplying replacement credentials.

The previous values were public. Their service owners must revoke/rotate them
and audit Azure Storage and Databricks access. Do not reuse exposed values
merely because the current files no longer contain them. This PR does not
rewrite repository history, remove previously downloaded ZIPs, or invalidate
cached copies.

Before marking the reservation ready:

1. Confirm all three private fields are present and non-empty for a fresh
   reservation and visible only through the intended reservation access.
   Verify the backend field limits and Copy buttons preserve each complete
   value, including long storage passwords, without truncation, inserted
   whitespace, or an ellipsis being copied as part of the value.
2. Complete Lab 2 as PEAKGEAR_USER using only those fields and the documented
   public settings. Both Iceberg tables and the Operations returns table must
   return sample rows; all three local snapshots must be created successfully.
3. Verify that an unfilled optional SQL credential block fails before a
   credential-creation call. Test the filled alternative in a separate fresh
   reservation, not on top of the UI-created credentials.
4. Rebuild the ZIP and run the offline package/security tests. Inspect
   credential screenshots before publishing.
5. Obtain service-owner confirmation that exposed values are revoked and
   replacement values work. Record access-audit follow-up privately.

If a protected field is absent, learners stop and ask the instructor. They
must not search Git history or use another reservation's credentials.

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
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
