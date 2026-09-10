whenever sqlerror exit sql.sqlcode rollback
set define on
set verify off
set serveroutput on
set feedback on
set pagesize 100
set linesize 220

prompt ============================================================
prompt Product Recall Assistant - Load the public ONNX embedding model
prompt Connect as RECALL_OWNER after the ADMIN model download and Labs 1 through 3.
prompt ============================================================

begin
    if user != 'RECALL_OWNER' then
        raise_application_error(-20060, 'Wrong user: connect as RECALL_OWNER.');
    end if;
end;
/

prompt --- Ensure native vector columns on the relational tables ---

declare
    procedure run_ddl(
        p_sql          in varchar2,
        p_ignored_code in number
    ) is
    begin
        execute immediate p_sql;
    exception
        when others then
            if sqlcode != p_ignored_code then
                raise;
            end if;
    end;
begin
    -- Lab 4 can be rerun after the backend deployment. Ignore only the
    -- expected duplicate-column condition; unexpected errors still stop it.
    run_ddl(
        'alter table complaint_chunks add (embedding vector(384, float32))',
        -1430
    );
    run_ddl(
        'alter table recall_queries add (query_vector vector(384, float32))',
        -1430
    );
end;
/

prompt --- Load all_MiniLM_L12_v2 from DATA_PUMP_DIR into the database ---

begin
    begin
        dbms_vector.drop_onnx_model(
            model_name => 'RECALL_MINILM_L12_V2',
            force      => true
        );
    exception
        when others then null;
    end;

    dbms_vector.load_onnx_model(
        directory  => 'DATA_PUMP_DIR',
        file_name  => 'all_MiniLM_L12_v2.onnx',
        model_name => 'RECALL_MINILM_L12_V2'
    );
end;
/

prompt --- Populate stored and query embeddings with in-database inference ---

update complaint_chunks
set    embedding = vector_embedding(
           recall_minilm_l12_v2 using chunk_text as data
       );

update recall_queries
set    query_vector = vector_embedding(
           recall_minilm_l12_v2 using search_text as data
       );

commit;

prompt --- Verify the model and vector columns ---

select model_name,
       mining_function,
       algorithm,
       model_size
from   user_mining_models
where  model_name = 'RECALL_MINILM_L12_V2';

select table_name,
       column_name,
       data_type,
       data_length
from   user_tab_columns
where  (table_name = 'COMPLAINT_CHUNKS' and column_name = 'EMBEDDING')
or     (table_name = 'RECALL_QUERIES' and column_name = 'QUERY_VECTOR')
order  by table_name;

select chunk_id,
       substr(vector_serialize(embedding), 1, 500) as embedding_sample
from   complaint_chunks
where  embedding is not null
fetch  first 1 row only;

select query_key,
       substr(vector_serialize(query_vector), 1, 500) as query_vector_sample
from   recall_queries
where  query_vector is not null
fetch  first 1 row only;

prompt Expected: one populated vector sample from each table.
prompt Vector setup complete. Continue with Task 2.
