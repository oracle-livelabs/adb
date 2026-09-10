# Lab 4: Hear the Signal in the Noise: Prioritize Complaint Evidence with AI Vector Search

## Introduction

Priya Nair, a Customer Signals Analyst, is listening to reports that do not use the same words. One customer says “too hot to touch,” another reports an electrical smell, and another sees an E7 code before shutoff. Other complaints mention packaging, cosmetics, or an unrelated product. If Priya searches only for exact terms, the strongest evidence can disappear in the noise.

Your mission is to find the complaints that describe the same B-482 thermal pattern, even when the wording changes. You will ensure native vector columns, use the loaded `all_MiniLM_L12_v2.onnx` model to generate embeddings inside Oracle AI Database 26ai, and rank exposed complaints with `VECTOR_DISTANCE`. You will then join those semantic matches to structured JSON observations. The differentiator is that meaning-based ranking and the underlying evidence stay together in the database, where the recall filter still controls which complaints can enter the result.

By the end of the lab, the approved context will prioritize complaints `9001`, `9002`, `9006`, `9003`, and `9007`, while excluding the unrelated B-900 complaint. Priya can hand the response team a ranked signal with observable supporting details.

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

    The two samples provide visible evidence that both tables contain populated vectors. `VECTOR_SERIALIZE` converts each sample to readable text, and `SUBSTR` keeps the result compact. The complete runnable version is [`00-vector-setup.sql`](files/00-vector-setup.sql).

## Task 2: Rank Semantic Complaint Evidence

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

3. Run [`01-vector-evidence.sql`](files/01-vector-evidence.sql) to execute all vector checkpoints.

You have completed Lab 4. Lab 5 registers the approved context function as a Select AI Agent tool.

## Troubleshooting

| Symptom | Likely cause | Recovery |
|---|---|---|
| Vector query returns no rows | The model was not loaded or embeddings are null | Ask the facilitator to verify the backend deployment, then rerun the vector steps. |
| Complaint order differs | Model revision or model metadata changed | Confirm both tables use `RECALL_MINILM_L12_V2`; exact ordering can vary slightly. |
| Model check returns no rows | The backend deployment did not load `RECALL_MINILM_L12_V2` | Ask the facilitator to verify the backend deployment. |
| ONNX model file is missing | The backend deployment did not place the model in `DATA_PUMP_DIR` | Ask the facilitator to verify the backend deployment and the directory contents. |
| Context status is `CLEAR` | Lab 1 case-opening command did not run | Run `02-open-investigation.sql`. |
| Context omits component fields | The approved API package is incomplete | Ask the facilitator to verify the backend deployment. |

## Learn More

- [Oracle AI Vector Search User Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/)
- [VECTOR_DISTANCE SQL function](https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/vector_distance.html)

## Acknowledgements

- **Author:** Oracle AI World 2026 Product Recall Assistant workshop team
- **Last updated:** July 2026
