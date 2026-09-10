set long 100000
set pagesize 100

select recall_lab_api.get_recall_context('B-482') as recall_context;

prompt Expected summary:
prompt   batchId                 B-482
prompt   status                  INVESTIGATING
prompt   investigationCaseId     CASE-B482-2026
prompt   affectedStoreCount      120
prompt   unitsSent               2400
prompt   customerExposureCount   600
prompt   componentBatchCount     25
prompt   supplierSiteCount       25
prompt   complaintIds            populated after Lab 4 model setup
prompt   firstAction             Quarantine remaining inventory...
