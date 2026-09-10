whenever sqlerror exit sql.sqlcode rollback
set define off
set serveroutput on size unlimited
set feedback on

prompt ============================================================
prompt Product Recall Assistant - Lab 6 ORDS Module
prompt Connect as ADMIN. RECALL_APP_USER parses the delivery handlers.
prompt RECALL_OWNER continues to own all data and approved package code.
prompt ============================================================

begin
    if user != 'ADMIN' then
        raise_application_error(-20034, 'Wrong user: connect as ADMIN.');
    end if;
end;
/

begin
    ords_admin.enable_schema(
        p_enabled             => false,
        p_schema              => 'RECALL_OWNER',
        p_url_mapping_type    => 'BASE_PATH',
        p_url_mapping_pattern => 'recall_owner',
        p_auto_rest_auth      => true
    );

    ords_admin.enable_schema(
        p_enabled             => true,
        p_schema              => 'RECALL_APP_USER',
        p_url_mapping_type    => 'BASE_PATH',
        p_url_mapping_pattern => 'recall',
        p_auto_rest_auth      => true
    );

    ords_admin.delete_module(
        p_schema      => 'RECALL_APP_USER',
        p_module_name => 'recall.api.v1'
    );

    ords_admin.define_module(
        p_schema         => 'RECALL_APP_USER',
        p_module_name    => 'recall.api.v1',
        p_base_path      => 'api/v1/',
        p_items_per_page => 0,
        p_status         => 'PUBLISHED',
        p_comments       => 'PII-safe Product Recall Assistant API'
    );

    ords_admin.define_template(
        p_schema      => 'RECALL_APP_USER',
        p_module_name => 'recall.api.v1',
        p_pattern     => 'health'
    );
    ords_admin.define_handler(
        p_schema      => 'RECALL_APP_USER',
        p_module_name => 'recall.api.v1',
        p_pattern     => 'health',
        p_method      => 'GET',
        p_source_type => ords.source_type_plsql,
        p_source      => q'~begin
  owa_util.mime_header('application/json', false);
  owa_util.http_header_close;
  htp.prn('{"status":"ok","service":"product-recall-assistant"}');
end;~'
    );

    ords_admin.define_template(
        p_schema      => 'RECALL_APP_USER',
        p_module_name => 'recall.api.v1',
        p_pattern     => 'batches/:batch_id/context'
    );
    ords_admin.define_handler(
        p_schema      => 'RECALL_APP_USER',
        p_module_name => 'recall.api.v1',
        p_pattern     => 'batches/:batch_id/context',
        p_method      => 'GET',
        p_source_type => ords.source_type_plsql,
        p_source      => q'~begin
  owa_util.mime_header('application/json', false);
  owa_util.http_header_close;
  htp.prn(recall_owner.recall_lab_api.get_recall_context(:batch_id));
end;~'
    );

    ords_admin.define_template(
        p_schema      => 'RECALL_APP_USER',
        p_module_name => 'recall.api.v1',
        p_pattern     => 'batches/:batch_id/stores'
    );
    ords_admin.define_handler(
        p_schema      => 'RECALL_APP_USER',
        p_module_name => 'recall.api.v1',
        p_pattern     => 'batches/:batch_id/stores',
        p_method      => 'GET',
        p_source_type => ords.source_type_plsql,
        p_source      => q'~begin
  owa_util.mime_header('application/geo+json', false);
  owa_util.http_header_close;
  htp.prn(recall_owner.recall_lab_api.get_affected_stores(:batch_id));
end;~'
    );

    ords_admin.define_template(
        p_schema      => 'RECALL_APP_USER',
        p_module_name => 'recall.api.v1',
        p_pattern     => 'batches/:batch_id/component-sites'
    );
    ords_admin.define_handler(
        p_schema      => 'RECALL_APP_USER',
        p_module_name => 'recall.api.v1',
        p_pattern     => 'batches/:batch_id/component-sites',
        p_method      => 'GET',
        p_source_type => ords.source_type_plsql,
        p_source      => q'~begin
  owa_util.mime_header('application/geo+json', false);
  owa_util.http_header_close;
  htp.prn(recall_owner.recall_lab_api.get_component_sites(:batch_id));
end;~'
    );

    declare
        l_roles    owa.vc_arr;
        l_patterns owa.vc_arr;
        l_modules  owa.vc_arr;
    begin
        l_modules(1) := 'recall.api.v1';
        ords_admin.define_privilege(
            p_schema         => 'RECALL_APP_USER',
            p_privilege_name => 'recall.api.authenticated',
            p_roles          => l_roles,
            p_patterns       => l_patterns,
            p_modules        => l_modules,
            p_label          => 'Authenticated recall API',
            p_description    => 'Requires an authenticated database identity.'
        );
    end;

    commit;
end;
/

prompt ORDS module published under /ords/recall/api/v1/.
prompt Routes: health, batches/:batch_id/context, batches/:batch_id/stores,
prompt         batches/:batch_id/component-sites.
prompt Verify from an HTTP client: an unauthenticated request must return 401.
