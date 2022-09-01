create or replace procedure add_graph authid current_user as
    user_name varchar2(100) := user;
begin
    -- Drop the graph
    begin
        workshop.write('attempt to drop graph graph', 1);
        opg_apis.drop_pg(graph_name => 'MOVIE_RECOMMENDATIONS');
    exception
        when others then
            workshop.write('no graph to drop');
        
    end;
    
    -- Create the graph
    workshop.write('create movie_recommendations graph', 2);
    opg_apis.create_pg(graph_owner => user_name, graph_name => 'MOVIE_RECOMMENDATIONS', tbs_set => 'DATA', options => 'SKIP_INDEX=T');
    
    -- create vertex
    workshop.write('create graph vertices', 2);
    execute immediate q'[
    INSERT /*+ append */ INTO MOVIE_RECOMMENDATIONSVT$
    (VID, VL, K, T, V, VN, VT)
    SELECT VID, VL, K, T, V, VN, VT
    FROM (
      SELECT 
        VID, VL, K, T, V, VN, VT
      FROM(
        WITH T0 AS (
          SELECT /*+ materialize */
            round(sys_op_combined_hash(n'"MOVIE"' || '|' || TABLE_KEY)/2) AS VID
            , VL, "AWARDS", "BUDGET", "CAST", "CREW", "GENRES", "GROSS", "LIST_PRICE", "MAIN_SUBJECT", "MOVIE_ID", "NOMINATIONS", "OPENING_DATE", "RUNTIME", "SKU", "STUDIO", "SUMMARY", "TITLE", "VIEWS", "YEAR"
          FROM ( 
            SELECT 
              "MOVIE_ID" AS TABLE_KEY
              , n'MOVIE' AS VL, "AWARDS", "BUDGET", "CAST", "CREW", "GENRES", "GROSS", "LIST_PRICE", "MAIN_SUBJECT", "MOVIE_ID", "NOMINATIONS", "OPENING_DATE", "RUNTIME", "SKU", "STUDIO", "SUMMARY", "TITLE", "VIEWS", "YEAR"
            FROM "MOVIE"
          )
        )
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "AWARDS" AS n'AWARDS'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "BUDGET" AS n'BUDGET'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "CAST" AS n'CAST'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "CREW" AS n'CREW'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "GENRES" AS n'GENRES'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "GROSS" AS n'GROSS'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "LIST_PRICE" AS n'LIST_PRICE'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "MAIN_SUBJECT" AS n'MAIN_SUBJECT'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "MOVIE_ID" AS n'MOVIE_ID'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "NOMINATIONS" AS n'NOMINATIONS'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VT, 'SYYYY-MM-DD"T"HH24:MI:SS.FF9TZH:TZM') AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(5) AS T,
              to_nchar(null) as V, to_number(null) as VN, from_tz(cast(property_value as timestamp), '+00:00') as VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "OPENING_DATE" AS n'OPENING_DATE'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "RUNTIME" AS n'RUNTIME'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "SKU" AS n'SKU'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "STUDIO" AS n'STUDIO'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "SUMMARY" AS n'SUMMARY'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "TITLE" AS n'TITLE'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "VIEWS" AS n'VIEWS'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "YEAR" AS n'YEAR'
            )
          )
        )
      )
    )]';
    commit;
    
    -- Create a second vertex
    workshop.write('create second graph vertex', 2);
    
    execute immediate q'[
    INSERT /*+ append */ INTO MOVIE_RECOMMENDATIONSVT$
    (VID, VL, K, T, V, VN, VT)
    SELECT VID, VL, K, T, V, VN, VT
    FROM (
      SELECT 
        VID, VL, K, T, V, VN, VT
      FROM(
        WITH T0 AS (
          SELECT /*+ materialize */
            round(sys_op_combined_hash(n'"CUSTOMER_PROMOTIONS"' || '|' || TABLE_KEY)/2) AS VID
            , VL, "AGE", "CITY", "COMMUTE_DISTANCE", "CONTINENT", "COUNTRY", "COUNTRY_CODE", "CREDIT_BALANCE", "CUST_ID", "EDUCATION", "EMAIL", "FIRST_NAME", "FULL_TIME", "GENDER", "HOUSEHOLD_SIZE", "INCOME", "INCOME_LEVEL", "INSUFF_FUNDS_INCIDENTS", "JOB_TYPE", "LAST_NAME", "LATE_MORT_RENT_PMTS", "LOC_LAT", "LOC_LONG", "MARITAL_STATUS", "MORTGAGE_AMT", "NUM_CARS", "NUM_MORTGAGES", "PET", "POSTAL_CODE", "PROMOTION_RESPONSE", "RENT_OWN", "SEGMENT_ID", "STATE_PROVINCE", "STREET_ADDRESS", "WORK_EXPERIENCE", "YRS_CURRENT_EMPLOYER", "YRS_CUSTOMER", "YRS_RESIDENCE"
          FROM ( 
            SELECT 
              "CUST_ID" AS TABLE_KEY
              , n'CUSTOMER_PROMOTIONS' AS VL, "AGE", "CITY", "COMMUTE_DISTANCE", "CONTINENT", "COUNTRY", "COUNTRY_CODE", "CREDIT_BALANCE", "CUST_ID", "EDUCATION", "EMAIL", "FIRST_NAME", "FULL_TIME", "GENDER", "HOUSEHOLD_SIZE", "INCOME", "INCOME_LEVEL", "INSUFF_FUNDS_INCIDENTS", "JOB_TYPE", "LAST_NAME", "LATE_MORT_RENT_PMTS", "LOC_LAT", "LOC_LONG", "MARITAL_STATUS", "MORTGAGE_AMT", "NUM_CARS", "NUM_MORTGAGES", "PET", "POSTAL_CODE", "PROMOTION_RESPONSE", "RENT_OWN", "SEGMENT_ID", "STATE_PROVINCE", "STREET_ADDRESS", "WORK_EXPERIENCE", "YRS_CURRENT_EMPLOYER", "YRS_CUSTOMER", "YRS_RESIDENCE"
            FROM "CUSTOMER_PROMOTIONS"
          )
        )
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "AGE" AS n'AGE'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "CITY" AS n'CITY'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "COMMUTE_DISTANCE" AS n'COMMUTE_DISTANCE'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "CONTINENT" AS n'CONTINENT'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "COUNTRY" AS n'COUNTRY'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "COUNTRY_CODE" AS n'COUNTRY_CODE'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "CREDIT_BALANCE" AS n'CREDIT_BALANCE'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "CUST_ID" AS n'CUST_ID'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "EDUCATION" AS n'EDUCATION'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "EMAIL" AS n'EMAIL'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "FIRST_NAME" AS n'FIRST_NAME'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "FULL_TIME" AS n'FULL_TIME'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "GENDER" AS n'GENDER'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "HOUSEHOLD_SIZE" AS n'HOUSEHOLD_SIZE'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "INCOME" AS n'INCOME'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "INCOME_LEVEL" AS n'INCOME_LEVEL'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "INSUFF_FUNDS_INCIDENTS" AS n'INSUFF_FUNDS_INCIDENTS'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "JOB_TYPE" AS n'JOB_TYPE'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "LAST_NAME" AS n'LAST_NAME'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "LATE_MORT_RENT_PMTS" AS n'LATE_MORT_RENT_PMTS'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "LOC_LAT" AS n'LOC_LAT'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "LOC_LONG" AS n'LOC_LONG'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "MARITAL_STATUS" AS n'MARITAL_STATUS'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "MORTGAGE_AMT" AS n'MORTGAGE_AMT'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "NUM_CARS" AS n'NUM_CARS'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "NUM_MORTGAGES" AS n'NUM_MORTGAGES'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "PET" AS n'PET'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "POSTAL_CODE" AS n'POSTAL_CODE'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "PROMOTION_RESPONSE" AS n'PROMOTION_RESPONSE'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "RENT_OWN" AS n'RENT_OWN'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "SEGMENT_ID" AS n'SEGMENT_ID'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "STATE_PROVINCE" AS n'STATE_PROVINCE'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "STREET_ADDRESS" AS n'STREET_ADDRESS'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "WORK_EXPERIENCE" AS n'WORK_EXPERIENCE'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "YRS_CURRENT_EMPLOYER" AS n'YRS_CURRENT_EMPLOYER'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "YRS_CUSTOMER" AS n'YRS_CUSTOMER'
            )
          )
        )
      UNION ALL
        SELECT VID, VL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            VID, VL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "YRS_RESIDENCE" AS n'YRS_RESIDENCE'
            )
          )
        )
      )
    )]';
    
    commit;
    
    workshop.write('adding graph edges', 2);
    execute immediate q'[
    INSERT /*+ append */ INTO MOVIE_RECOMMENDATIONSGE$
    (EID, SVID, DVID, EL, K, T, V, VN, VT)
    SELECT EID, SVID, DVID, EL, K, T, V, VN, VT
    FROM (
      SELECT 
        EID, SVID, DVID, EL, K, T, V, VN, VT
      FROM(
        WITH T0 AS (
          SELECT /*+ materialize */
            round(sys_op_combined_hash(n'"CUSTSALES_PROMOTIONS"' || '|' || TABLE_KEY)/2) AS EID, SVID, DVID
            , EL, "APP", "CUST_ID", "DAY_ID", "DEVICE", "DISCOUNT_TYPE", "GENRE_ID", "MOVIE_ID", "OS", "PAYMENT_METHOD"
          FROM ( 
            SELECT 
              "CUST_ID" || '|' || "DAY_ID" || '|' || "MOVIE_ID" AS TABLE_KEY,
              round(sys_op_combined_hash(n'"CUSTOMER_PROMOTIONS"' || '|' || "CUST_ID")/2) AS SVID,
              round(sys_op_combined_hash(n'"MOVIE"' || '|' || "MOVIE_ID")/2) AS DVID
              , n'RENTED' AS EL, "APP", "CUST_ID", "DAY_ID", "DEVICE", "DISCOUNT_TYPE", "GENRE_ID", "MOVIE_ID", "OS", "PAYMENT_METHOD"
            FROM "CUSTSALES_PROMOTIONS"
            WHERE "CUST_ID" IS NOT NULL AND "MOVIE_ID" IS NOT NULL
          )
        )
        SELECT EID, SVID, DVID, EL, K, T, V, VN, VT
        FROM (
          SELECT
            EID, SVID, DVID, EL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "APP" AS n'APP'
            )
          )
        )
      UNION ALL
        SELECT EID, SVID, DVID, EL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            EID, SVID, DVID, EL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "CUST_ID" AS n'CUST_ID'
            )
          )
        )
      UNION ALL
        SELECT EID, SVID, DVID, EL, K, T, to_nchar(VT, 'SYYYY-MM-DD"T"HH24:MI:SS.FF9TZH:TZM') AS V, VN, VT
        FROM (
          SELECT
            EID, SVID, DVID, EL, K,
              to_number(5) AS T,
              to_nchar(null) as V, to_number(null) as VN, from_tz(cast(property_value as timestamp), '+00:00') as VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "DAY_ID" AS n'DAY_ID'
            )
          )
        )
      UNION ALL
        SELECT EID, SVID, DVID, EL, K, T, V, VN, VT
        FROM (
          SELECT
            EID, SVID, DVID, EL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "DEVICE" AS n'DEVICE'
            )
          )
        )
      UNION ALL
        SELECT EID, SVID, DVID, EL, K, T, V, VN, VT
        FROM (
          SELECT
            EID, SVID, DVID, EL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "DISCOUNT_TYPE" AS n'DISCOUNT_TYPE'
            )
          )
        )
      UNION ALL
        SELECT EID, SVID, DVID, EL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            EID, SVID, DVID, EL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "GENRE_ID" AS n'GENRE_ID'
            )
          )
        )
      UNION ALL
        SELECT EID, SVID, DVID, EL, K, T, to_nchar(VN, 'TM9', 'NLS_Numeric_Characters=''.,''') || n'' AS V, VN, VT
        FROM (
          SELECT
            EID, SVID, DVID, EL, K,
              to_number(4) AS T,
              to_nchar(null) as V, to_number(property_value) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "MOVIE_ID" AS n'MOVIE_ID'
            )
          )
        )
      UNION ALL
        SELECT EID, SVID, DVID, EL, K, T, V, VN, VT
        FROM (
          SELECT
            EID, SVID, DVID, EL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "OS" AS n'OS'
            )
          )
        )
      UNION ALL
        SELECT EID, SVID, DVID, EL, K, T, V, VN, VT
        FROM (
          SELECT
            EID, SVID, DVID, EL, K,
              to_number(1) AS T,
              to_nchar(property_value) as V, to_number(null) as VN, to_timestamp_tz(null) VT
          FROM T0
          UNPIVOT (
            property_value FOR K IN (
              "PAYMENT_METHOD" AS n'PAYMENT_METHOD'
            )
          )
        )
      )
    )]';
    
    commit;
    
    workshop.write('update graph index', 2);
    opg_apis.create_pg(graph_owner => user_name, graph_name => 'MOVIE_RECOMMENDATIONS', dop => 2, tbs_set => 'DATA', options => 'SKIP_TABLE=T');

    workshop.write('graph updates complete.', 1);
    
    
    
end add_graph;
/

begin
    workshop.exec('grant execute on add_graph to public');
end;
/