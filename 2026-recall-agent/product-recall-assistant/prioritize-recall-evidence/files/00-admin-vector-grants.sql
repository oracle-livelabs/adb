whenever sqlerror exit sql.sqlcode rollback
set serveroutput on size unlimited
set feedback on
set pagesize 100
set linesize 220

prompt ============================================================
prompt Product Recall Assistant - ADMIN Vector Model Download
prompt Run once as ADMIN before Lab 4.
prompt ============================================================

begin
    if user != 'ADMIN' then
        raise_application_error(-20061, 'Wrong user: connect as ADMIN.');
    end if;
end;
/

grant execute on dbms_cloud to recall_owner;
grant read on directory data_pump_dir to recall_owner;

begin
    dbms_cloud.get_object(
        credential_name => null,
        directory_name => 'DATA_PUMP_DIR',
        object_uri     => 'https://adwc4pm.objectstorage.us-ashburn-1.oci.customer-oci.com/p/eLddQappgBJ7jNi6Guz9m9LOtYe2u8LWY19GfgU8flFK4N9YgP4kTlrE9Px3pE12/n/adwc4pm/b/OML-Resources/o/all_MiniLM_L12_v2.onnx'
    );
end;
/

declare
    l_exists     boolean;
    l_file_size  number;
    l_block_size binary_integer;
begin
    utl_file.fgetattr(
        location    => 'DATA_PUMP_DIR',
        filename    => 'all_MiniLM_L12_v2.onnx',
        fexists     => l_exists,
        file_length => l_file_size,
        block_size  => l_block_size
    );

    if not l_exists or l_file_size is null or l_file_size = 0 then
        raise_application_error(-20062, 'The ONNX model was not written to DATA_PUMP_DIR.');
    end if;

    dbms_output.put_line('Public ONNX model downloaded: ' || l_file_size || ' bytes.');
end;
/

prompt ADMIN vector model download completed. Disconnect ADMIN.
