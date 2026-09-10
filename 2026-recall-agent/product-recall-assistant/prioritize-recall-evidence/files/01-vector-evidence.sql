set feedback on
set pagesize 100
set long 100000
set longchunksize 100000

prompt ============================================================
prompt 1. Semantic complaint ranking with AI Vector Search
prompt ============================================================

select cc.complaint_id,
       round(vector_distance(cc.embedding, q.query_vector, cosine), 4)
           as cosine_distance,
       json_value(c.complaint_data, '$.severity') as severity,
       json_value(c.complaint_data, '$.symptom') as symptom,
       cc.chunk_text
from   complaint_chunks cc
join   complaints c
       on c.complaint_id = cc.complaint_id
cross  join recall_queries q
where  q.query_key = 'HEAT_ODOR'
and   (
          c.reported_batch = 'B-482'
          or c.customer_id in (
              select customer_id
              from   recall_customer_exposure_v
              where  batch_id = 'B-482'
          )
      )
order  by vector_distance(cc.embedding, q.query_vector, cosine)
fetch  first 5 rows only;

prompt Expected thermal-risk IDs: 9001, 9002, 9006, 9003, 9007.
prompt Exact ordering can vary slightly by model revision.

prompt ============================================================
prompt 2. Combine vector matches with JSON observations
prompt ============================================================

with ranked as (
    select cc.complaint_id,
           vector_distance(cc.embedding, q.query_vector, cosine) as distance
    from   complaint_chunks cc
    join   complaints c
           on c.complaint_id = cc.complaint_id
    cross  join recall_queries q
    where  q.query_key = 'HEAT_ODOR'
    and   (
              c.reported_batch = 'B-482'
              or c.customer_id in (
                  select customer_id
                  from   recall_customer_exposure_v
                  where  batch_id = 'B-482'
              )
          )
    order  by distance
    fetch  first 5 rows only
)
select r.complaint_id,
       round(r.distance, 4) as cosine_distance,
       json_value(c.complaint_data, '$.observations.odor') as odor,
       json_value(c.complaint_data, '$.observations.display') as display_code,
       json_value(c.complaint_data, '$.observations.plug') as plug_state
from   ranked r
join   complaints c
       on c.complaint_id = r.complaint_id
order  by r.distance;

prompt Expected: semantic evidence and JSON observations in one result.
prompt NULL means the requested JSON key is absent from that complaint document.
prompt odor is present for selected thermal complaints; display is present for 9006; plug is present for 9007.

prompt ============================================================
prompt 3. Approved context for the agent lab
prompt ============================================================

select recall_lab_api.get_recall_context('B-482') as recall_context
;

prompt Expected summary:
prompt   batchId                 B-482
prompt   status                  INVESTIGATING
prompt   affectedStoreCount      120
prompt   unitsSent               2400
prompt   customerExposureCount   600
prompt   componentBatchCount     25
prompt   supplierSiteCount       25
prompt   complaintIds            9001, 9002, 9006, 9003, 9007
prompt   firstAction             Quarantine remaining inventory...
