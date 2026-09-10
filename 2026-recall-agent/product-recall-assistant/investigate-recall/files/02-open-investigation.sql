whenever sqlerror exit sql.sqlcode rollback
set feedback on
set long 100000
set longchunksize 100000

prompt ============================================================
prompt Product Recall Assistant - Inspect and Open the JSON Case
prompt Connect as RECALL_OWNER.
prompt ============================================================

prompt --- Reported case JSON before the investigation opens ---

select case_id,
       case_status,
       json_serialize(case_data returning clob pretty) as case_json
from   recall_investigations
where  case_id = 'CASE-B482-2026';

prompt Expected before first run: REVIEW with workflowState REPORTED.

update recall_investigations
set    case_status = 'OPEN',
       opened_at = systimestamp,
       opened_by = user,
       case_data = json_transform(
           case_data,
           set '$.workflowState' = 'OPEN',
           set '$.openedBy' = user,
           set '$.openedAt' = to_char(
               systimestamp,
               'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM'
           )
       )
where  case_id = 'CASE-B482-2026'
and    batch_id = 'B-482'
and    case_status = 'REVIEW'
and    json_value(case_data, '$.workflowState') = 'REPORTED';

update batches b
set    recall_status = 'INVESTIGATING',
       issue_code = 'THERMAL-ODOR',
       issue_summary =
           'Reports of overheating, electrical odor, and early shutoff.'
where  b.batch_id = 'B-482'
and    exists (
           select 1
           from   recall_investigations i
           where  i.case_id = 'CASE-B482-2026'
           and    i.batch_id = b.batch_id
           and    i.case_status = 'OPEN'
           and    json_value(i.case_data, '$.workflowState') = 'OPEN'
       );

commit;

select i.case_id,
       i.case_status,
       b.recall_status,
       json_value(i.case_data, '$.workflowState') as json_workflow_state,
       json_value(i.case_data, '$.openedBy') as json_opened_by,
       json_value(i.case_data, '$.openedAt') as json_opened_at,
       json_serialize(i.case_data returning clob pretty) as case_json
from   recall_investigations i
join   batches b on b.batch_id = i.batch_id
where  i.case_id = 'CASE-B482-2026';

prompt Expected after update: OPEN, INVESTIGATING, JSON workflowState OPEN.
