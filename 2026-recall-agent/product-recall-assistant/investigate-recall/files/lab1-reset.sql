set feedback on

update recall_investigations
set    case_status = 'REVIEW',
       opened_at = null,
       opened_by = null,
       case_data = json_transform(
           case_data,
           set '$.workflowState' = 'REPORTED',
           remove '$.openedBy',
           remove '$.openedAt'
       )
where  case_id = 'CASE-B482-2026'
and    batch_id = 'B-482';

update batches
set    recall_status = 'CLEAR',
       issue_code = null,
       issue_summary = null
where  batch_id = 'B-482';

commit;

select i.case_id,
       i.case_status,
       b.recall_status,
       json_value(i.case_data, '$.workflowState') as json_workflow_state
from   recall_investigations i
join   batches b on b.batch_id = i.batch_id
where  i.case_id = 'CASE-B482-2026';

prompt Lab 1 reset complete. Expected: REVIEW, CLEAR, and REPORTED.
