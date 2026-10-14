# Need Help?

Estimated Time: As needed; troubleshooting only.

### Objectives

Distinguish reservation, login, and MCP issues and prepare an actionable support request.

## Introduction

Use this page if you cannot sign in to your prepared LiveLabs reservation or
need help with a workshop step. Keep the reservation active while you work.
Record the lab, task, step, and exact error so the instructor can help you
resume from the same point.

## Find the correct reservation credentials

Open **LiveLabs → Reservation Information** and use the values from your
current reservation:

| Where you are signing in | Values to copy | Where to find them |
|---|---|---|
| OCI Console, using Launch OCI | Username and Password | Login Credentials |
| Data Studio database connection | Database User and Database Password | Environment Details |
| Starter Kit setup in Terminal or PowerShell | Database Password for PEAKGEAR&#95;USER | Environment Details |

For the Starter Kit's **Lab Data Studio URL** prompt, use the **ADP&#95;URL**
returned by the SQL in **Lab 3 → Task 1 → step 1**.

The reservation supplies the database account and password. Copy its
**Database Password** for Data Studio and MCP setup; the OCI Login Credentials
password, your laptop password, and passwords shown in example screenshots are
for different purposes. Nothing appears when you paste the database password
into the local shell prompt; press **Return** on Mac or **Enter** on Windows.

If the supplied database credentials are rejected, check that you selected
the current reservation's database and copied **Database Password**. Retain
the exact error and ask the instructor to check the reservation. Password
creation and account changes are performed by the environment owner.

## LiveLab MCP connection

Successful Data Studio sign-in and completed setup prompts do not confirm
that the Codex task is connected. Open the configured **peakgear-livelab**
project, create a new task there, and complete **Lab 3 → Task 2**. Continue
only when the connection check reports the current reservation's URL,
PEAKGEAR&#95;USER, and **session&#95;ready = true**. Use the recovery instructions
below if the check fails.

### Restart the local MCP process

On macOS, open Terminal on your laptop and run:

~~~sh
<copy>
zsh "$HOME/.local/share/peakgear-livelab/peakgear-livelab-admin.command"
</copy>
~~~

Choose **1 — Start LiveLab cleanly — stop PeakGear LiveLab only**.

On Windows, open Windows PowerShell on your laptop and run:

~~~powershell
<copy>
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\peakgear-livelab\02-peakgear-livelab-admin.ps1" -Action Restart
</copy>
~~~

Open the configured local project and create a new Codex task. The restart
refreshes PeakGear MCP only; it does not remove database tables, annotations,
or other MCP servers. For Windows status or stop, use **-Action Status** or
**-Action Stop** in the same command.

If setup reports that password storage failed, retain the error and ask the
instructor to check the OS credential store. If Windows reports that scripts
are blocked by organizational policy, ask the organizer to provide an approved
installation path rather than disabling that policy.

### AI Enrichment errors

If AI Enrichment reports invalid or missing column tags, retain the exact
message and selected table name for the instructor. The instructor verifies
the provisioned AI profile; restarting local MCP does not repair enrichment.
Keep the dialog's existing data until the error is understood. After a save
timeout or connection error, check Catalog for your edits before retrying:
some annotations may already have been saved.

## How to Format Your Support Email Request

Send your support request to **livelabs-help-adbs_us@oracle.com**. Copy the
following template into your email draft; it includes the recipient and
workshop name. Fill in the lab, task, step, and result.
If the header's question-mark link puts **undefined** in the subject, replace
it with the Subject line below.

~~~text
<copy>
To: livelabs-help-adbs_us@oracle.com
Subject: Question about workshop: PeakGear: From Raw Sources to Governed Answers with Codex

Workshop: PeakGear: From Raw Sources to Governed Answers with Codex
Environment: LiveLabs sandbox
Lab / Task / Step:
Expected result:
Actual result / exact error:
Troubleshooting already tried:
</copy>
~~~

Attach a screenshot of the error with passwords and tokens hidden. Include
the steps you tried and whether the error occurred again on retry.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
