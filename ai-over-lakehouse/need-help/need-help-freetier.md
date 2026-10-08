# Need Help?

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
| Starter Kit setup in Terminal | Database Password for PEAKGEAR&#95;USER | Environment Details |

For the Starter Kit's **Lab Data Studio URL** prompt, use the **ADP&#95;URL**
returned by the SQL in **Lab 3 → Task 1 → step 1**.

The reservation supplies the database account and password. Copy its
**Database Password** for Data Studio and MCP setup; the OCI Login Credentials
password, your Mac password, and passwords shown in example screenshots are
for different purposes. Nothing appears when you paste the database password
into the Terminal prompt; press **Return** after pasting it.

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
in that task if the check fails.

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
