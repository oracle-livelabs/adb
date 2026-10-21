# Source and asset traceability

Estimated Time: 5 minutes to review.

### Objectives

Record the sources and screenshot provenance for the HOL6091 revision.

This author-only file records the sources used for the October 21 HOL6091 revision. It is not a learner lab.

## Source precedence

| Source | Contribution |
|---|---|
| Owner's October 2026 narrated `lab_instruction_changes.mp4` | Primary UI route, successful steps, new cleanse/Data Load/AI Enrichment/worksheet-AI demonstrations |
| Mike Matthews, `AIW Medallion Workshop v2 Notes MM 8th Oct (1).docx` | Persona naming, clearer setup and worksheet guidance, Gold statistics, hands-on enrichment, removal of legacy appendices |
| Owner's two explicit Lab 5 prompt decisions | Both prompts concern Gold; use worksheet AI, inspect and repair generated SQL when it selects another source |
| Existing workshop and working SQL | Case-sensitive object names, Bronze/Silver checks, cross-tier inventory query, Gold validation SQL |
| Public Oracle documentation | General catalog, Data Load, AI Assistant, and Select AI behavior; not proof of event runtime |

The source documents and recording are Oracle-owned workshop material. No external image or dataset was copied. The raw video and transcript remain outside the repository. Frames with visible passwords, secret keys, or credential panels were excluded. Published frames were cropped to the relevant UI; no result was fabricated.

## New screenshot provenance

| Image | Video position | Evidence |
|---|---:|---|
| `lab1-launch-workshop.png` | 01:12 | LiveLabs reservation card and Launch Workshop |
| `lab2-title-case.png` | 09:08 | Data Cleanse step; `PRODUCT_NAME` Modify Case = Title case |
| `lab2-iceberg-target.png` | 10:48 | Optional Data Load wizard; Apache Iceberg target connection |
| `lab2-data-load-append.png` | 11:20 | Optional Data Load; enriched sales source and Append action |
| `lab2-silver-sample.png` | 15:38 | Published Silver rows with standardized product names |
| `lab4-ai-enrichment-west.png` | 21:50 | Gold description says West only; `SALES_REGION` has `west` tag |
| `lab5-worksheet-ai-prompt.png` | 24:57 | Worksheet toolbar AI control and separate prompt bar |
| `lab5-gold-sql-result.png` | 27:20 | Reviewed Gold SQL, including latest-month subquery, and returned rows |

Earlier `review-*.png` screenshots remain where still relevant. `review-query-with-ai.png` is no longer used by Lab 5 because the owner chose worksheet AI. Screen captures are evidence of UI controls, not proof that every learner run will succeed.

## Public references

* [Explore data with Catalog Navigator](https://docs.oracle.com/en/cloud/paas/autonomous-database/data-studio-guide/explore-data-catalog.html)
* [Create a Data Load](https://docs.oracle.com/en/database/data-integration/data-transforms/using/create-data-load.html)
* [Use the AI Assistant in Data Studio](https://docs.oracle.com/en/cloud/paas/autonomous-database/data-studio-guide/use-ai-assistant.html)
* [Select AI concepts](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/select-ai-concepts.html)

## Boundaries

The video shows worksheet AI choosing a general sales table for an unqualified prompt. The new lab therefore requires learners to inspect and, when needed, repair both `FROM` clauses before running Gold analysis. This is a user-approved instruction, not a claim that AI always selects Gold. The video also includes an intermediate validation warning while editing a flow; it is excluded from the learner procedure and remains an event dry-run item. No live database execution was performed during this documentation edit.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
