# Lab 4: Hear the Signal in the Noise: Prioritize Complaint Evidence with AI Vector Search

## Introduction

Kevin asks, “Which return complaints support the thermal-risk decision?” Customers do not describe the same problem in the same words. Exact keyword searches can miss a report of an electrical smell, an E7 code, or a cooker that is too hot to touch.

David's design keeps complaint text, structured observations, and recall eligibility together. Semantic ranking identifies similar descriptions, but the B-482 exposure filter and JSON observations remain part of the database query. A related phrase alone does not authorize unrelated complaints into the result.

Tim uses the loaded ONNX model to create vectors in Oracle AI Database, ranks complaint chunks with `VECTOR_DISTANCE`, and joins the matches back to the JSON evidence. He explains the distinction Kevin needs: vector search finds meaning; the database still controls which evidence is valid for this recall.

By the end of the lab, Kevin has a ranked evidence set led by complaints `9001`, `9002`, `9006`, `9003`, and `9007`, with unrelated B-900 evidence excluded. Tim will use this approved context in the assistant.

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

- Ensure `VECTOR(384, FLOAT32)` columns on the existing relational tables.
- Use the loaded ONNX embedding model in the database.
- Populate stored and query embeddings with `VECTOR_EMBEDDING`.
- Run `VECTOR_DISTANCE` against complaint chunks.
- Filter semantic search to complaints tied to `B-482` exposure.
- Combine vector results with JSON complaint observations.
- Produce the approved recall context used by the Select AI Agent lab.

## Task 1: Ensure Vector Data and Use the Loaded Model

Kevin needs complaint evidence that reflects meaning, not only matching words. David keeps vectors and source evidence together; Tim prepares the model-backed data.

1. Inspect the complaint text and query text that will become the embedding inputs.

    ```sql
    <copy>
    select table_name,
           column_name,
           data_type
    from   user_tab_columns
    where  table_name in ('COMPLAINT_CHUNKS', 'RECALL_QUERIES')
    order  by table_name, column_id;
    </copy>
    ```

    These relational text columns are the source for the stored complaint and query embeddings.

2. Confirm that the workshop model is available in `DATA_PUMP_DIR`.

    ```sql
    <copy>
    select directory_name
    from   all_directories
    where  directory_name = 'DATA_PUMP_DIR';
    </copy>
    ```

    The query should return `DATA_PUMP_DIR`. The backend deployment places the public `all_MiniLM_L12_v2.onnx` model there before the lab begins.

3. Ensure native vector columns on the existing relational tables. The block is safe to rerun after a previous Lab 4 attempt.

    ```sql
    <copy>
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
    </copy>
    ```

    `all_MiniLM_L12_v2` produces 384-dimensional text embeddings. The query vector uses the same model so both sides share one semantic space.

4. Confirm that the embedding model is available in Oracle AI Database 26ai.

    ```sql
    <copy>
    select model_name,
           mining_function,
           algorithm,
           model_size
    from   user_mining_models
    where  model_name = 'RECALL_MINILM_L12_V2';
    </copy>
    ```

    The query should return one row for `RECALL_MINILM_L12_V2` with `MINING_FUNCTION` set to `EMBEDDING` and `ALGORITHM` set to `ONNX`. The backend deployment loaded `all_MiniLM_L12_v2.onnx` from Oracle Object Storage. Inference runs locally in the database through the imported ONNX model; no external embedding API is called.

5. Populate both tables with in-database model inference.

    ```sql
    <copy>
    update complaint_chunks
    set    embedding = vector_embedding(
               recall_minilm_l12_v2 using chunk_text as data
           );

    update recall_queries
    set    query_vector = vector_embedding(
               recall_minilm_l12_v2 using search_text as data
           );

    commit;
    </copy>
    ```

6. Verify the model and generated vectors.

    ```sql
    <copy>
    select model_name,
           mining_function,
           algorithm,
           model_size
    from   user_mining_models
    where  model_name = 'RECALL_MINILM_L12_V2';

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
    </copy>
    ```

    The two samples provide visible evidence that both tables contain populated vectors. `VECTOR_SERIALIZE` converts each sample to readable text, and `SUBSTR` keeps the result compact.

## Task 2: Rank Semantic Complaint Evidence

Kevin asks which reports most closely match the thermal pattern. David uses semantic ranking within the recall boundary; Tim runs the vector search.

1. Find the five complaint chunks closest to the workshop query vector.

    ```sql
    <copy>
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
    </copy>
    ```

    The top five should be the thermal-risk complaints `9001`, `9002`, `9006`, `9003`, and `9007`; exact ordering can vary slightly by model revision. Lower cosine distance means stronger similarity.

2. Explain why complaint `9005` is absent:

    - It belongs to batch `B-900`.
    - Its customer did not buy batch `B-482`.
    - The query filters semantic search to the current recall exposure.

## Task 3: Combine Vector and JSON Evidence

Kevin needs the reason behind a ranking. David joins semantic results to structured observations; Tim combines both forms of evidence.

1. Join the ranked vector results back to JSON observations.

    ```sql
    <copy>
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
    </copy>
    ```

    This query keeps semantic ranking and structured JSON observations in one result set.

    **Interpret the `NULL` values:** The complaint documents use a flexible JSON shape, so an observation column is `NULL` when that complaint does not contain the requested JSON key. For example, `odor` appears for complaints such as `9001`, `9006`, and `9007`; `display_code` appears for `9006`; and `plug_state` appears for `9007`. The missing values are intentional and demonstrate how relational ranking can be combined with sparse JSON attributes.

## Task 4: Produce the Approved Recall Context

Kevin needs a compact approved context for the desk. David defines that boundary; Tim produces it for the governed assistant.

1. Call the approved package that consolidates the investigation facts.

    ```sql
    <copy>
    select recall_lab_api.get_recall_context('B-482') as recall_context;
    </copy>
    ```

2. Compare the output with this checkpoint.

    ```json
    {
      "batchId": "B-482",
      "status": "INVESTIGATING",
      "product": "HeatPro Countertop Cooker",
      "investigationCaseId": "CASE-B482-2026",
      "affectedStoreCount": 120,
      "unitsSent": 2400,
      "customerExposureCount": 600,
      "componentBatchCount": 25,
      "supplierSiteCount": 25,
      "complaintIds": [9001, 9002, 9006, 9003, 9007],
      "firstAction": "Quarantine remaining B-482 inventory and stop sales at affected stores."
    }
    ```

3. The queries in this task provide the vector checkpoints.

You have completed Lab 4. Lab 5 registers the approved context function as a Select AI Agent tool.

## Troubleshooting

| Symptom | Likely cause | Recovery |
|---|---|---|
| Vector query returns no rows | The model was not loaded or embeddings are null | Ask the facilitator to verify the backend deployment, then rerun the vector steps. |
| Complaint order differs | Model revision or model metadata changed | Confirm both tables use `RECALL_MINILM_L12_V2`; exact ordering can vary slightly. |
| Model check returns no rows | The backend deployment did not load `RECALL_MINILM_L12_V2` | Ask the facilitator to verify the backend deployment. |
| ONNX model file is missing | The backend deployment did not place the model in `DATA_PUMP_DIR` | Ask the facilitator to verify the backend deployment and the directory contents. |
| Context status is `CLEAR` | Lab 1 case-opening command did not run | Return to Lab 1 and open the investigation. |
| Context omits component fields | The approved API package is incomplete | Ask the facilitator to verify the backend deployment. |

## Learn More

- [Oracle AI Vector Search User Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/)
- [VECTOR_DISTANCE SQL function](https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/vector_distance.html)

## Acknowledgements

- **Author:** Tim Cline, Product Management Architect
- Contributors: David Start, Director and Kevin Lazarz, Senior Manager
- **Last updated:** October 2026
