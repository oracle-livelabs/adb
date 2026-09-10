whenever sqlerror exit sql.sqlcode rollback
set feedback on
set long 100000
set longchunksize 100000

prompt ============================================================
prompt Product Recall Assistant - Role-Aware Vector Test
prompt Connect as one Lab 7 local end user.
prompt ============================================================

declare
    l_end_user      varchar2(128);
    l_expected_role varchar2(128);
    l_role_count    number;
    l_chunk_count   number;
begin
    select json_value(
               ora_end_user_context,
               '$.USERNAME' returning varchar2(128)
           )
    into l_end_user;

    l_expected_role := case l_end_user
        when 'STORE_101_USER' then 'RECALL_STORE_101_DATA_ROLE'
        when 'REGION_NE_USER' then 'RECALL_REGION_NE_DATA_ROLE'
        when 'RECALL_LEAD_USER' then 'RECALL_LEAD_DATA_ROLE'
    end;

    if l_expected_role is null then
        raise_application_error(
            -20045,
            'Use an actual Lab 7 local end-user connection. ' ||
            'A saved connection label does not establish ORA_END_USER_CONTEXT.'
        );
    end if;

    select count(*)
    into l_role_count
    from v$end_user_data_role
    where role_name = l_expected_role;

    if l_role_count != 1 then
        raise_application_error(
            -20046,
            'Expected active data role ' || l_expected_role ||
            ' for ' || l_end_user || '.'
        );
    end if;

    if l_end_user = 'STORE_101_USER' then
        select count(*) into l_chunk_count from complaint_chunks;
        if l_chunk_count != 1 then
            raise_application_error(
                -20047,
                'STORE_101_USER must see exactly one complaint chunk. ' ||
                'Rerun the Lab 7 policy and reconnect.'
            );
        end if;
    end if;
end;
/

select json_value(
           ora_end_user_context,
           '$.USERNAME' returning varchar2(128)
       ) as end_user
;

select role_name
from v$end_user_data_role
order by role_name;

select cc.complaint_id,
       round(vector_distance(cc.embedding, q.query_vector, cosine), 4)
           as distance,
       cc.chunk_text
from complaint_chunks cc
cross join recall_queries q
where q.query_key = 'HEAT_ODOR'
and vector_distance(cc.embedding, q.query_vector, cosine) < 0.70
order by distance
fetch first 5 rows only;

select recall_secure_api.get_secured_context('B-482') as secured_context
;

prompt Expected semantic complaint IDs:
prompt   STORE_101_USER: 9001
prompt   REGION_NE_USER: 9001, 9002, 9006
prompt   RECALL_LEAD_USER: 9001, 9002, 9006, 9003, 9007
