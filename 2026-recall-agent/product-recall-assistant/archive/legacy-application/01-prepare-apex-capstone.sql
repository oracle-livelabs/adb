whenever sqlerror exit sql.sqlcode rollback
set define off
set serveroutput on size unlimited
set feedback on

prompt ============================================================
prompt Product Recall Assistant - Prepare the APEX Capstone
prompt Connect as RECALL_OWNER.
prompt ============================================================

begin
    if user != 'RECALL_OWNER' then
        raise_application_error(-20060, 'Wrong user: connect as RECALL_OWNER.');
    end if;
end;
/

begin
    execute immediate 'alter table recall_authorized_requests add (stores_geojson json)';
exception
    when others then
        if sqlcode != -1430 then raise; end if;
end;
/

begin
    execute immediate 'alter table recall_authorized_requests add (agent_answer clob)';
exception
    when others then
        if sqlcode != -1430 then raise; end if;
end;
/

create or replace package recall_context_sink authid definer as
    function store_context(
        p_batch_id in varchar2,
        p_context  in clob,
        p_stores   in clob
    ) return number;
end recall_context_sink;
/

create or replace package body recall_context_sink as
    function store_context(
        p_batch_id in varchar2,
        p_context  in clob,
        p_stores   in clob
    ) return number is
        l_request_id number;
        l_end_user   varchar2(128);
    begin
        select json_value(p_context, '$.endUser' returning varchar2(128))
        into   l_end_user
        from   dual;

        if l_end_user is null then
            raise_application_error(-20061, 'Captured context lacks an end user.');
        end if;

        insert into recall_authorized_requests(
            end_user_name, batch_id, context_json, stores_geojson
        ) values (
            l_end_user,
            upper(trim(p_batch_id)),
            json(p_context),
            json(p_stores)
        )
        returning request_id into l_request_id;

        commit;
        return l_request_id;
    end store_context;
end recall_context_sink;
/

show errors package body recall_context_sink

create or replace package recall_secure_api authid current_user as
    function current_end_user return varchar2;
    function get_secured_context(p_batch_id in varchar2) return clob;
    function get_secured_stores(p_batch_id in varchar2) return clob;
    function capture_secured_context(p_batch_id in varchar2) return number;
end recall_secure_api;
/

create or replace package body recall_secure_api as
    function current_end_user return varchar2 is
        l_user varchar2(128);
    begin
        select json_value(
                   ora_end_user_context,
                   '$.USERNAME' returning varchar2(128)
               )
        into   l_user
        from   dual;
        return l_user;
    end current_end_user;

    function get_secured_context(p_batch_id in varchar2) return clob is
        l_result clob;
    begin
        select json_object(
                   'endUser' value current_end_user,
                   'batchId' value upper(trim(p_batch_id)),
                   'affectedStoreCount' value (
                       select count(distinct si.store_id)
                       from shipments sh
                       join shipment_items si on si.shipment_id = sh.shipment_id
                       where sh.batch_id = upper(trim(p_batch_id))
                   ),
                   'unitsSent' value (
                       select coalesce(sum(si.units_sent), 0)
                       from shipments sh
                       join shipment_items si on si.shipment_id = sh.shipment_id
                       where sh.batch_id = upper(trim(p_batch_id))
                   ),
                   'customerExposureCount' value (
                       select count(distinct p.customer_id)
                       from purchases p
                       where p.batch_id = upper(trim(p_batch_id))
                   ),
                   'componentBatchCount' value (
                       select count(*)
                       from batch_components bc
                       where bc.batch_id = upper(trim(p_batch_id))
                   ),
                   'supplierSiteCount' value (
                       select count(distinct cb.supplier_site_id)
                       from batch_components bc
                       join component_batches cb
                            on cb.component_batch_id = bc.component_batch_id
                       where bc.batch_id = upper(trim(p_batch_id))
                   ),
                   'semanticComplaints' value (
                       select json_arrayagg(
                                  json_object(
                                      'complaintId' value x.complaint_id,
                                      'text' value x.chunk_text,
                                      'distance' value round(x.distance, 4)
                                  ) order by x.distance returning clob
                              )
                       from (
                           select cc.complaint_id,
                                  cc.chunk_text,
                                  vector_distance(
                                      cc.embedding, q.query_vector, cosine
                                  ) as distance
                           from complaint_chunks cc
                           cross join recall_queries q
                           where q.query_key = 'HEAT_ODOR'
                           order by distance
                           fetch first 5 rows only
                       ) x
                   ) format json,
                   'firstAction' value (
                       select action_text
                       from recall_actions
                       where priority_no = 1
                   ),
                   'customerContactAuthorized' value 'false' format json
                   returning clob
               )
        into   l_result
        from   dual;
        return l_result;
    end get_secured_context;

    function get_secured_stores(p_batch_id in varchar2) return clob is
        l_result clob;
    begin
        select json_object(
                   'type' value 'FeatureCollection',
                   'features' value coalesce(
                       json_arrayagg(
                           json_object(
                               'type' value 'Feature',
                               'geometry' value json_object(
                                   'type' value 'Point',
                                   'coordinates' value json_array(
                                       x.longitude, x.latitude
                                   )
                               ),
                               'properties' value json_object(
                                   'storeId' value x.store_id,
                                   'storeCode' value x.store_code,
                                   'storeName' value x.store_name,
                                   'regionCode' value x.region_code,
                                   'unitsSent' value x.units_sent
                               )
                           ) order by x.store_id returning clob
                       ),
                       to_clob('[]')
                   ) format json
                   returning clob
               )
        into   l_result
        from (
            select s.store_id,
                   s.store_code,
                   s.store_name,
                   s.region_code,
                   s.location.sdo_point.x as longitude,
                   s.location.sdo_point.y as latitude,
                   sum(si.units_sent) as units_sent
            from shipments sh
            join shipment_items si on si.shipment_id = sh.shipment_id
            join stores s on s.store_id = si.store_id
            where sh.batch_id = upper(trim(p_batch_id))
            group by s.store_id, s.store_code, s.store_name, s.region_code,
                     s.location.sdo_point.x, s.location.sdo_point.y
        ) x;
        return l_result;
    end get_secured_stores;

    function capture_secured_context(p_batch_id in varchar2) return number is
        l_context clob;
        l_stores  clob;
    begin
        l_context := get_secured_context(p_batch_id);
        l_stores  := get_secured_stores(p_batch_id);
        return recall_context_sink.store_context(p_batch_id, l_context, l_stores);
    end capture_secured_context;
end recall_secure_api;
/

show errors package body recall_secure_api

grant execute on recall_secure_api to recall_end_user_login;

begin
    execute immediate q'~
        create table recall_apex_audit (
            audit_id       number generated always as identity primary key,
            app_user       varchar2(128) not null,
            event_type     varchar2(30) not null,
            batch_id       varchar2(20),
            event_detail   varchar2(1000),
            event_time     timestamp default systimestamp not null
        )~';
exception
    when others then
        if sqlcode != -955 then raise; end if;
end;
/

create or replace view recall_apex_metrics_v as
with latest as (
    select r.*,
           row_number() over (
               partition by end_user_name, batch_id
               order by created_at desc
           ) as rn
    from recall_authorized_requests r
    where end_user_name = upper(sys_context('APEX$SESSION', 'APP_USER'))
)
select request_id,
       end_user_name,
       batch_id,
       json_value(context_json, '$.affectedStoreCount' returning number)
           as affected_store_count,
       json_value(context_json, '$.unitsSent' returning number)
           as units_sent,
       json_value(context_json, '$.customerExposureCount' returning number)
           as customer_exposure_count,
       json_value(context_json, '$.firstAction' returning varchar2(300))
           as first_action,
       created_at
from latest
where rn = 1;

create or replace view recall_apex_stores_v as
with latest as (
    select r.*,
           row_number() over (
               partition by end_user_name, batch_id
               order by created_at desc
           ) as rn
    from recall_authorized_requests r
    where end_user_name = upper(sys_context('APEX$SESSION', 'APP_USER'))
)
select l.request_id,
       l.end_user_name,
       l.batch_id,
       j.store_id,
       j.store_code,
       j.store_name,
       j.region_code,
       j.units_sent,
       j.longitude,
       j.latitude,
       mdsys.sdo_geometry(
           2001,
           4326,
           mdsys.sdo_point_type(j.longitude, j.latitude, null),
           null,
           null
       ) as geometry
from latest l,
     json_table(
         l.stores_geojson,
         '$.features[*]'
         columns (
             store_id    number        path '$.properties.storeId',
             store_code  varchar2(20)  path '$.properties.storeCode',
             store_name  varchar2(100) path '$.properties.storeName',
             region_code varchar2(20)  path '$.properties.regionCode',
             units_sent  number        path '$.properties.unitsSent',
             longitude   number        path '$.geometry.coordinates[0]',
             latitude    number        path '$.geometry.coordinates[1]'
         )
     ) j
where l.rn = 1;

create or replace view recall_apex_complaints_v as
with latest as (
    select r.*,
           row_number() over (
               partition by end_user_name, batch_id
               order by created_at desc
           ) as rn
    from recall_authorized_requests r
    where end_user_name = upper(sys_context('APEX$SESSION', 'APP_USER'))
)
select l.request_id,
       l.end_user_name,
       l.batch_id,
       j.complaint_id,
       j.complaint_text,
       j.distance
from latest l,
     json_table(
         l.context_json,
         '$.semanticComplaints[*]'
         columns (
             complaint_id   number         path '$.complaintId',
             complaint_text varchar2(1000) path '$.text',
             distance       number         path '$.distance'
         )
     ) j
where l.rn = 1;

create or replace package recall_apex_api authid definer as
    function current_app_user return varchar2;
    function role_label return varchar2;
    function current_context(p_batch_id in varchar2 default 'B-482') return clob;
    function get_authorized_agent_answer(
        p_batch_id in varchar2 default 'B-482'
    ) return clob;
    function ask_recall_agent(p_batch_id in varchar2 default 'B-482') return clob;
    procedure log_event(
        p_event_type   in varchar2,
        p_batch_id     in varchar2 default 'B-482',
        p_event_detail in varchar2 default null
    );
end recall_apex_api;
/

create or replace package body recall_apex_api as
    function current_app_user return varchar2 is
        l_user varchar2(128) := upper(sys_context('APEX$SESSION', 'APP_USER'));
    begin
        if l_user not in ('STORE_101_USER', 'REGION_NE_USER', 'RECALL_LEAD_USER') then
            raise_application_error(-20062, 'This APEX user has no recall persona.');
        end if;
        return l_user;
    end current_app_user;

    function role_label return varchar2 is
    begin
        return case current_app_user
                   when 'STORE_101_USER' then apex_lang.message('RECALL_ROLE_STORE')
                   when 'REGION_NE_USER' then apex_lang.message('RECALL_ROLE_REGION')
                   when 'RECALL_LEAD_USER' then apex_lang.message('RECALL_ROLE_LEAD')
               end;
    end role_label;

    function current_context(p_batch_id in varchar2 default 'B-482') return clob is
        l_context clob;
    begin
        select json_serialize(context_json returning clob)
        into   l_context
        from (
            select context_json
            from recall_authorized_requests
            where end_user_name = current_app_user
            and batch_id = upper(trim(p_batch_id))
            order by created_at desc
        )
        where rownum = 1;
        return l_context;
    exception
        when no_data_found then
            raise_application_error(-20063, 'No secured recall capture exists for this user.');
    end current_context;

    procedure log_event(
        p_event_type   in varchar2,
        p_batch_id     in varchar2 default 'B-482',
        p_event_detail in varchar2 default null
    ) is
        pragma autonomous_transaction;
    begin
        insert into recall_apex_audit(app_user, event_type, batch_id, event_detail)
        values (
            current_app_user,
            upper(substr(trim(p_event_type), 1, 30)),
            upper(trim(p_batch_id)),
            substr(p_event_detail, 1, 1000)
        );
        commit;
    end log_event;

    function get_authorized_agent_answer(
        p_batch_id in varchar2 default 'B-482'
    ) return clob is
        l_answer  clob;
    begin
        select agent_answer
        into   l_answer
        from (
            select agent_answer
            from recall_authorized_requests
            where end_user_name = current_app_user
            and batch_id = upper(trim(p_batch_id))
            order by created_at desc
        )
        where rownum = 1;

        if l_answer is null then
            raise_application_error(-20065, 'The trusted owner has not generated this secured answer.');
        end if;

        log_event(
            'AGENT_ANSWER_VIEW',
            p_batch_id,
            'Stored authorized recall summary displayed'
        );
        return l_answer;
    end get_authorized_agent_answer;

    function ask_recall_agent(p_batch_id in varchar2 default 'B-482') return clob is
    begin
        return get_authorized_agent_answer(p_batch_id);
    end ask_recall_agent;
end recall_apex_api;
/

show errors package body recall_apex_api

prompt APEX capstone database interface is ready.
