whenever sqlerror exit sql.sqlcode rollback
set define off
set serveroutput on
set feedback on

prompt ============================================================
prompt Product Recall Assistant - RECALL_OWNER Setup
prompt Connect as RECALL_OWNER. Never run this script as ADMIN.
prompt ============================================================

begin
    if user != 'RECALL_OWNER' then
        raise_application_error(
            -20001,
            'Wrong user: connect as RECALL_OWNER before running this script.'
        );
    end if;
end;
/

begin
    execute immediate 'drop property graph recall_graph';
exception
    when others then null;
end;
/

begin
    execute immediate 'drop package recall_investigation_api';
exception
    when others then
        if sqlcode != -4043 then raise; end if;
end;
/

begin
    delete from user_sdo_geom_metadata
    where table_name in ('STORES', 'RESPONSE_CENTERS', 'SUPPLIER_SITES');
    commit;
exception
    when others then null;
end;
/

begin
    for t in (
        select column_value as table_name
        from table(sys.odcivarchar2list(
            'RECALL_INVESTIGATIONS',
            'RECALL_QUERIES',
            'COMPLAINT_CHUNKS',
            'COMPLAINTS',
            'PURCHASES',
            'CUSTOMERS',
            'SHIPMENT_ITEMS',
            'BATCH_SHIPMENTS',
            'SHIPMENTS',
            'BATCH_COMPONENTS',
            'COMPONENT_BATCH_SITE_EDGES',
            'COMPONENT_BATCH_COMPONENT_EDGES',
            'SUPPLIER_SITE_EDGES',
            'COMPONENT_BATCHES',
            'COMPONENTS',
            'SUPPLIER_SITES',
            'SUPPLIERS',
            'RESPONSE_CENTERS',
            'STORES',
            'RECALL_ACTIONS',
            'BATCHES',
            'PRODUCTS'
        ))
    ) loop
        begin
            execute immediate 'drop table ' || t.table_name ||
                              ' cascade constraints purge';
        exception
            when others then
                if sqlcode != -942 then raise; end if;
        end;
    end loop;
end;
/

create table products (
    product_id    number primary key,
    sku           varchar2(30) not null unique,
    product_name  varchar2(100) not null,
    category      varchar2(50) not null,
    attributes    json not null
);

create table batches (
    batch_id         varchar2(20) primary key,
    product_id       number not null references products(product_id),
    manufactured_on  date not null,
    recall_status    varchar2(20) default 'CLEAR' not null,
    issue_code       varchar2(30),
    issue_summary    varchar2(300),
    constraint batches_status_ck
        check (recall_status in ('CLEAR', 'INVESTIGATING', 'RECALLED'))
);

create table recall_investigations (
    case_id         varchar2(30) primary key,
    batch_id        varchar2(20) not null references batches(batch_id),
    case_status     varchar2(20) default 'OPEN' not null,
    issue_code      varchar2(30) not null,
    issue_summary   varchar2(300) not null,
    source_channel  varchar2(30) not null,
    opened_at       timestamp,
    opened_by       varchar2(128),
    case_data       json not null,
    constraint recall_investigations_status_ck
        check (case_status in ('OPEN', 'REVIEW', 'CLOSED'))
);

create table recall_actions (
    action_id    number primary key,
    priority_no  number not null,
    action_code  varchar2(30) not null unique,
    action_text  varchar2(300) not null
);

create table stores (
    store_id     number primary key,
    store_code   varchar2(20) not null unique,
    store_name   varchar2(100) not null,
    region_code  varchar2(20) not null,
    longitude    number(9,6) not null,
    latitude     number(8,6) not null
);

create table response_centers (
    center_id    number primary key,
    center_name  varchar2(100) not null,
    longitude    number(9,6) not null,
    latitude     number(8,6) not null
);

create table suppliers (
    supplier_id    number primary key,
    supplier_name  varchar2(120) not null,
    tier_no        number not null,
    supplier_type  varchar2(40) not null,
    constraint suppliers_tier_ck check (tier_no in (1, 2))
);

create table supplier_sites (
    supplier_site_id  number primary key,
    supplier_id       number not null references suppliers(supplier_id),
    site_code         varchar2(30) not null unique,
    site_name         varchar2(120) not null,
    city              varchar2(80) not null,
    state_code        varchar2(2) not null,
    country_code      varchar2(2) default 'US' not null,
    longitude         number(9,6) not null,
    latitude          number(8,6) not null
);

create table components (
    component_id    number primary key,
    component_code  varchar2(40) not null unique,
    component_name  varchar2(120) not null,
    criticality     varchar2(20) not null,
    attributes      json not null,
    constraint components_criticality_ck
        check (criticality in ('LOW', 'MEDIUM', 'HIGH'))
);

create table component_batches (
    component_batch_id  varchar2(30) primary key,
    component_id        number not null references components(component_id),
    supplier_site_id    number not null references supplier_sites(supplier_site_id),
    supplier_lot_code   varchar2(40) not null,
    produced_at         timestamp not null,
    received_at         timestamp not null,
    quality_status      varchar2(20) not null,
    attributes          json not null,
    constraint component_batches_status_ck
        check (quality_status in ('CLEAR', 'WATCH', 'SUSPECT'))
);

create table batch_components (
    batch_component_id  number primary key,
    batch_id            varchar2(20) not null references batches(batch_id),
    component_batch_id  varchar2(30) not null
                            references component_batches(component_batch_id),
    quantity_per_unit   number default 1 not null,
    installed_at        timestamp not null,
    assembly_station    varchar2(30) not null,
    constraint batch_components_uq unique (batch_id, component_batch_id),
    constraint batch_components_qty_ck check (quantity_per_unit > 0)
);

create table component_batch_site_edges (
    edge_id             number primary key,
    component_batch_id  varchar2(30) not null
                            references component_batches(component_batch_id),
    supplier_site_id    number not null references supplier_sites(supplier_site_id),
    supplier_lot_code   varchar2(40) not null,
    produced_at         timestamp not null,
    received_at         timestamp not null
);

create table component_batch_component_edges (
    edge_id             number primary key,
    component_batch_id  varchar2(30) not null
                            references component_batches(component_batch_id),
    component_id        number not null references components(component_id)
);

create table supplier_site_edges (
    edge_id           number primary key,
    supplier_site_id  number not null references supplier_sites(supplier_site_id),
    supplier_id       number not null references suppliers(supplier_id)
);

create table shipments (
    shipment_id  number primary key,
    batch_id     varchar2(20) not null references batches(batch_id),
    shipped_on   date not null
);

create table batch_shipments (
    batch_shipment_id  number primary key,
    batch_id           varchar2(20) not null references batches(batch_id),
    shipment_id        number not null references shipments(shipment_id),
    constraint batch_shipments_shipment_uq unique (shipment_id)
);

create table shipment_items (
    shipment_item_id  number primary key,
    shipment_id       number not null references shipments(shipment_id),
    store_id          number not null references stores(store_id),
    units_sent        number not null,
    constraint shipment_items_units_ck check (units_sent > 0)
);

create table customers (
    customer_id    number primary key,
    full_name      varchar2(100) not null,
    email          varchar2(200) not null,
    home_store_id  number not null references stores(store_id)
);

create table purchases (
    purchase_id   number primary key,
    customer_id   number not null references customers(customer_id),
    store_id      number not null references stores(store_id),
    batch_id      varchar2(20) not null references batches(batch_id),
    purchased_on  date not null,
    quantity      number default 1 not null,
    constraint purchases_quantity_ck check (quantity > 0)
);

create table complaints (
    complaint_id    number primary key,
    customer_id     number not null references customers(customer_id),
    reported_batch  varchar2(20),
    complaint_data  json not null,
    created_at      timestamp default systimestamp not null
);

create table complaint_chunks (
    chunk_id      number primary key,
    complaint_id  number not null references complaints(complaint_id),
    chunk_text    varchar2(1000) not null
);

create table recall_queries (
    query_key     varchar2(30) primary key,
    search_text   varchar2(500) not null
);

insert into products values (
    10,
    'HEATPRO-200',
    'HeatPro Countertop Cooker',
    'Kitchen Appliance',
    json('{
      "voltage":120,
      "finish":"graphite",
      "warrantyMonths":24,
      "assemblyPlant":"Marlborough, MA",
      "components":[
        {"code":"THERMOSTAT","name":"Thermostat module","criticality":"HIGH"},
        {"code":"LINER","name":"Insulation liner","criticality":"MEDIUM"},
        {"code":"POWER-CORD","name":"Power cord assembly","criticality":"HIGH"},
        {"code":"THERMAL-SENSOR","name":"Thermal sensor","criticality":"HIGH"},
        {"code":"CONTACT-SET","name":"Copper contact set","criticality":"MEDIUM"}
      ]
    }')
);

insert into products values (
    20,
    'BLENDGO-100',
    'BlendGo Personal Blender',
    'Kitchen Appliance',
    json('{"voltage":120,"finish":"white","warrantyMonths":12}')
);

insert into batches values (
    'B-482', 10, date '2026-05-18', 'CLEAR', null, null
);

insert into batches values (
    'B-900', 20, date '2026-05-22', 'CLEAR', null, null
);

insert into recall_actions values (
    1, 1, 'QUARANTINE_INVENTORY',
    'Quarantine remaining B-482 inventory and stop sales at affected stores.'
);

insert into recall_actions values (
    2, 2, 'TRACE_COMPONENT_LOTS',
    'Trace thermostat, sensor, power-cord, liner, and contact-set lots back to each supplier site.'
);

insert into recall_actions values (
    3, 3, 'CONTACT_CUSTOMERS',
    'Start the approved customer contact workflow after recall-lead authorization.'
);

insert into stores values (
    101, 'BOS-01', 'Boston Downtown', 'NORTHEAST', -71.0589, 42.3601
);

insert into stores values (
    102, 'CAM-01', 'Cambridge Central', 'NORTHEAST', -71.1097, 42.3736
);

insert into stores values (
    103, 'PVD-01', 'Providence Place', 'NORTHEAST', -71.4128, 41.8240
);

insert into stores values (
    104, 'HFD-01', 'Hartford Market', 'NORTHEAST', -72.6851, 41.7637
);

insert into stores values (
    201, 'NYC-01', 'Manhattan Flagship', 'ATLANTIC', -74.0060, 40.7128
);

insert into stores values (
    202, 'NWK-01', 'Newark Market', 'ATLANTIC', -74.1724, 40.7357
);

insert into stores values (
    203, 'PHL-01', 'Philadelphia Center', 'ATLANTIC', -75.1652, 39.9526
);

insert into stores values (
    301, 'CHI-01', 'Chicago Loop', 'MIDWEST', -87.6298, 41.8781
);

insert into stores values (
    302, 'DET-01', 'Detroit North', 'MIDWEST', -83.0458, 42.3314
);

insert into stores values (
    303, 'MKE-01', 'Milwaukee River', 'MIDWEST', -87.9065, 43.0389
);

insert into response_centers values (
    1, 'Boston Recall Center', -71.0640, 42.3550
);

insert into response_centers values (
    2, 'New York Recall Center', -74.0100, 40.7100
);

insert into response_centers values (
    3, 'Chicago Recall Center', -87.6350, 41.8810
);

insert into response_centers values (
    4, 'Philadelphia Recall Center', -75.1635, 39.9520
);

insert into response_centers values (
    5, 'Detroit Recall Center', -83.0500, 42.3300
);

insert into suppliers values (1, 'ThermoWorks Controls', 1, 'component assembler');
insert into suppliers values (2, 'NorthStar Plastics', 1, 'molded liner supplier');
insert into suppliers values (3, 'SafeCord Assemblies', 1, 'power assembly supplier');
insert into suppliers values (4, 'SensorFab Micro', 2, 'thermal sensor sub-vendor');
insert into suppliers values (5, 'CopperLine Metals', 2, 'contact-set sub-vendor');

insert into supplier_sites values (
    401, 1, 'TWC-MA', 'ThermoWorks Lowell', 'Lowell', 'MA', 'US',
    -71.3162, 42.6334
);

insert into supplier_sites values (
    402, 2, 'NSP-CT', 'NorthStar New Haven', 'New Haven', 'CT', 'US',
    -72.9279, 41.3083
);

insert into supplier_sites values (
    403, 3, 'SCA-OH', 'SafeCord Columbus', 'Columbus', 'OH', 'US',
    -82.9988, 39.9612
);

insert into supplier_sites values (
    404, 4, 'SFM-TX', 'SensorFab Austin', 'Austin', 'TX', 'US',
    -97.7431, 30.2672
);

insert into supplier_sites values (
    405, 5, 'CLM-MI', 'CopperLine Grand Rapids', 'Grand Rapids', 'MI', 'US',
    -85.6681, 42.9634
);

insert into components values (
    501, 'THERMOSTAT', 'Thermostat module', 'HIGH',
    json('{"expectedOhms":12.4,"temperatureCutoffC":92}')
);

insert into components values (
    502, 'LINER', 'Insulation liner', 'MEDIUM',
    json('{"material":"phenolic composite","ratedTempC":180}')
);

insert into components values (
    503, 'POWER-CORD', 'Power cord assembly', 'HIGH',
    json('{"gauge":"16 AWG","plug":"NEMA 5-15P"}')
);

insert into components values (
    504, 'THERMAL-SENSOR', 'Thermal sensor', 'HIGH',
    json('{"sensorType":"NTC","calibrationWindow":"2026-Q2"}')
);

insert into components values (
    505, 'CONTACT-SET', 'Copper contact set', 'MEDIUM',
    json('{"alloy":"C110","plating":"tin"}')
);

insert into component_batches values (
    'CB-TSTAT-77', 501, 401, 'TWC-26-077',
    timestamp '2026-05-11 07:30:00',
    timestamp '2026-05-15 10:10:00',
    'SUSPECT',
    json('{"supplierCertificate":"TWC-QA-7781","subVendorLot":"SFM-26-331","calibrationShift":"late"}')
);

insert into component_batches values (
    'CB-LINER-44', 502, 402, 'NSP-26-044',
    timestamp '2026-05-09 12:45:00',
    timestamp '2026-05-14 15:25:00',
    'WATCH',
    json('{"supplierCertificate":"NSP-QA-5512","resinLot":"R-2026-18"}')
);

insert into component_batches values (
    'CB-CORD-19', 503, 403, 'SCA-26-019',
    timestamp '2026-05-08 09:00:00',
    timestamp '2026-05-13 16:05:00',
    'CLEAR',
    json('{"supplierCertificate":"SCA-QA-2109","continuityTest":"pass"}')
);

insert into component_batches values (
    'CB-SENSOR-331', 504, 404, 'SFM-26-331',
    timestamp '2026-05-05 06:20:00',
    timestamp '2026-05-12 09:40:00',
    'SUSPECT',
    json('{"supplierCertificate":"SFM-QA-9331","calibrationDriftPct":4.7}')
);

insert into component_batches values (
    'CB-CONTACT-88', 505, 405, 'CLM-26-088',
    timestamp '2026-05-06 14:15:00',
    timestamp '2026-05-13 11:50:00',
    'WATCH',
    json('{"supplierCertificate":"CLM-QA-4088","platingBatch":"TIN-742"}')
);

insert into batch_components values (
    10001, 'B-482', 'CB-TSTAT-77', 1,
    timestamp '2026-05-18 08:15:00', 'LINE-2'
);
insert into batch_components values (
    10002, 'B-482', 'CB-LINER-44', 1,
    timestamp '2026-05-18 08:24:00', 'LINE-2'
);
insert into batch_components values (
    10003, 'B-482', 'CB-CORD-19', 1,
    timestamp '2026-05-18 08:31:00', 'LINE-2'
);
insert into batch_components values (
    10004, 'B-482', 'CB-SENSOR-331', 1,
    timestamp '2026-05-18 08:36:00', 'LINE-2'
);
insert into batch_components values (
    10005, 'B-482', 'CB-CONTACT-88', 1,
    timestamp '2026-05-18 08:42:00', 'LINE-2'
);

insert into component_batch_site_edges values (
    11001, 'CB-TSTAT-77', 401, 'TWC-26-077',
    timestamp '2026-05-11 07:30:00',
    timestamp '2026-05-15 10:10:00'
);
insert into component_batch_site_edges values (
    11002, 'CB-LINER-44', 402, 'NSP-26-044',
    timestamp '2026-05-09 12:45:00',
    timestamp '2026-05-14 15:25:00'
);
insert into component_batch_site_edges values (
    11003, 'CB-CORD-19', 403, 'SCA-26-019',
    timestamp '2026-05-08 09:00:00',
    timestamp '2026-05-13 16:05:00'
);
insert into component_batch_site_edges values (
    11004, 'CB-SENSOR-331', 404, 'SFM-26-331',
    timestamp '2026-05-05 06:20:00',
    timestamp '2026-05-12 09:40:00'
);
insert into component_batch_site_edges values (
    11005, 'CB-CONTACT-88', 405, 'CLM-26-088',
    timestamp '2026-05-06 14:15:00',
    timestamp '2026-05-13 11:50:00'
);

insert into component_batch_component_edges values (12001, 'CB-TSTAT-77', 501);
insert into component_batch_component_edges values (12002, 'CB-LINER-44', 502);
insert into component_batch_component_edges values (12003, 'CB-CORD-19', 503);
insert into component_batch_component_edges values (12004, 'CB-SENSOR-331', 504);
insert into component_batch_component_edges values (12005, 'CB-CONTACT-88', 505);

insert into supplier_site_edges values (13001, 401, 1);
insert into supplier_site_edges values (13002, 402, 2);
insert into supplier_site_edges values (13003, 403, 3);
insert into supplier_site_edges values (13004, 404, 4);
insert into supplier_site_edges values (13005, 405, 5);

insert into shipments values (5001, 'B-482', date '2026-06-02');
insert into shipments values (5002, 'B-482', date '2026-06-03');
insert into shipments values (5003, 'B-900', date '2026-06-03');
insert into shipments values (5004, 'B-482', date '2026-06-04');
insert into shipments values (5005, 'B-482', date '2026-06-05');
insert into shipments values (5006, 'B-482', date '2026-06-06');

insert into batch_shipments values (6001, 'B-482', 5001);
insert into batch_shipments values (6002, 'B-482', 5002);
insert into batch_shipments values (6003, 'B-900', 5003);
insert into batch_shipments values (6004, 'B-482', 5004);
insert into batch_shipments values (6005, 'B-482', 5005);
insert into batch_shipments values (6006, 'B-482', 5006);

insert into shipment_items values (7001, 5001, 101, 12);
insert into shipment_items values (7002, 5001, 102, 8);
insert into shipment_items values (7003, 5002, 103, 6);
insert into shipment_items values (7004, 5002, 104, 7);
insert into shipment_items values (7005, 5002, 201, 10);
insert into shipment_items values (7006, 5003, 202, 14);
insert into shipment_items values (7007, 5004, 301, 5);
insert into shipment_items values (7008, 5005, 202, 9);
insert into shipment_items values (7009, 5005, 203, 11);
insert into shipment_items values (7010, 5006, 302, 13);
insert into shipment_items values (7011, 5006, 303, 9);

insert into customers values (1001, 'Alice Carter', 'alice@example.invalid', 101);
insert into customers values (1002, 'Ben Ortiz', 'ben@example.invalid', 101);
insert into customers values (1003, 'Cara Singh', 'cara@example.invalid', 102);
insert into customers values (1004, 'Diego Martin', 'diego@example.invalid', 103);
insert into customers values (1005, 'Emma Brooks', 'emma@example.invalid', 201);
insert into customers values (1006, 'Frank Chen', 'frank@example.invalid', 301);
insert into customers values (1007, 'Grace Kim', 'grace@example.invalid', 202);
insert into customers values (1008, 'Hannah Diaz', 'hannah@example.invalid', 101);
insert into customers values (1009, 'Ian Foster', 'ian@example.invalid', 104);
insert into customers values (1010, 'Jia Patel', 'jia@example.invalid', 202);
insert into customers values (1011, 'Kai Morgan', 'kai@example.invalid', 203);
insert into customers values (1012, 'Lena Wright', 'lena@example.invalid', 302);
insert into customers values (1013, 'Mateo Rivera', 'mateo@example.invalid', 302);
insert into customers values (1014, 'Nora Bell', 'nora@example.invalid', 303);
insert into customers values (1015, 'Owen Price', 'owen@example.invalid', 102);
insert into customers values (1016, 'Priya Shah', 'priya@example.invalid', 104);
insert into customers values (1017, 'Quinn Adams', 'quinn@example.invalid', 201);

insert into purchases values (8001, 1001, 101, 'B-482', date '2026-06-08', 1);
insert into purchases values (8002, 1002, 101, 'B-482', date '2026-06-09', 1);
insert into purchases values (8003, 1003, 102, 'B-482', date '2026-06-10', 1);
insert into purchases values (8004, 1004, 103, 'B-482', date '2026-06-11', 1);
insert into purchases values (8005, 1005, 201, 'B-482', date '2026-06-12', 1);
insert into purchases values (8006, 1006, 301, 'B-482', date '2026-06-13', 1);
insert into purchases values (8007, 1007, 202, 'B-900', date '2026-06-13', 1);
insert into purchases values (8008, 1008, 101, 'B-482', date '2026-06-10', 1);
insert into purchases values (8009, 1009, 104, 'B-482', date '2026-06-11', 1);
insert into purchases values (8010, 1010, 202, 'B-482', date '2026-06-12', 1);
insert into purchases values (8011, 1011, 203, 'B-482', date '2026-06-13', 1);
insert into purchases values (8012, 1012, 302, 'B-482', date '2026-06-14', 1);
insert into purchases values (8013, 1013, 302, 'B-482', date '2026-06-14', 1);
insert into purchases values (8014, 1014, 303, 'B-482', date '2026-06-15', 1);
insert into purchases values (8015, 1015, 102, 'B-482', date '2026-06-11', 1);
insert into purchases values (8016, 1016, 104, 'B-482', date '2026-06-12', 1);
insert into purchases values (8017, 1017, 201, 'B-482', date '2026-06-13', 1);

insert into complaints values (
    9001, 1001, 'B-482',
    json('{"channel":"web","severity":"high","symptom":"overheating","observations":{"surfaceTemp":"too hot to touch","odor":"burning plastic"},"narrative":"The cooker became extremely hot and produced a burning plastic odor after first use."}'),
    timestamp '2026-06-14 09:15:00'
);

insert into complaints values (
    9002, 1003, null,
    json('{"channel":"phone","severity":"high","symptom":"odor","observations":{"surfaceTemp":"hot exterior","cycle":"first cycle"},"narrative":"The appliance felt too hot to touch and smelled electrical during its first cycle."}'),
    timestamp '2026-06-14 10:30:00'
);

insert into complaints values (
    9003, 1005, 'B-482',
    json('{"channel":"store","severity":"medium","symptom":"crackling","observations":{"sound":"crackle","shutdown":"yes"},"narrative":"The unit made a crackling sound, became hot, and then stopped working."}'),
    timestamp '2026-06-15 11:20:00'
);

insert into complaints values (
    9004, 1006, 'B-482',
    json('{"channel":"web","severity":"low","symptom":"packaging","observations":{"carton":"dented"},"narrative":"The shipping carton was dented, but the product works normally."}'),
    timestamp '2026-06-15 14:00:00'
);

insert into complaints values (
    9005, 1007, 'B-900',
    json('{"channel":"email","severity":"low","symptom":"missing accessory","observations":{"part":"travel lid"},"narrative":"The blender package did not include the travel lid."}'),
    timestamp '2026-06-16 08:45:00'
);

insert into complaints values (
    9006, 1009, 'B-482',
    json('{"channel":"web","severity":"high","symptom":"error-code","observations":{"display":"E7","odor":"hot plastic"},"narrative":"The display flashed E7 before the cooker smelled hot and shut itself off."}'),
    timestamp '2026-06-16 10:20:00'
);

insert into complaints values (
    9007, 1010, null,
    json('{"channel":"phone","severity":"medium","symptom":"warm-plug","observations":{"plug":"warm","odor":"electrical"},"narrative":"The plug and cord felt warm, and there was an electrical odor near the outlet."}'),
    timestamp '2026-06-16 12:40:00'
);

insert into complaints values (
    9008, 1011, 'B-482',
    json('{"channel":"store","severity":"low","symptom":"cosmetic","observations":{"panel":"scuffed"},"narrative":"The side panel had a cosmetic scuff when the box was opened."}'),
    timestamp '2026-06-17 09:05:00'
);

insert into complaints values (
    9009, 1013, 'B-482',
    json('{"channel":"web","severity":"medium","symptom":"timer-reset","observations":{"timer":"reset once"},"narrative":"The timer reset once during preheat, but the unit did not overheat."}'),
    timestamp '2026-06-17 11:10:00'
);

insert into complaints values (
    9010, 1014, 'B-482',
    json('{"channel":"email","severity":"low","symptom":"manual","observations":{"document":"missing quick start card"},"narrative":"The quick start card was missing from the carton."}'),
    timestamp '2026-06-17 13:25:00'
);

insert into complaint_chunks values (
    9101, 9001,
    'The cooker became extremely hot and produced a burning plastic odor after first use.'
);

insert into complaint_chunks values (
    9102, 9002,
    'The appliance felt too hot to touch and smelled electrical during its first cycle.'
);

insert into complaint_chunks values (
    9103, 9003,
    'The unit made a crackling sound, became hot, and then stopped working.'
);

insert into complaint_chunks values (
    9104, 9004,
    'The shipping carton was dented, but the product works normally.'
);

insert into complaint_chunks values (
    9105, 9005,
    'The blender package did not include the travel lid.'
);

insert into complaint_chunks values (
    9106, 9006,
    'The display flashed E7 before the cooker smelled hot and shut itself off.'
);

insert into complaint_chunks values (
    9107, 9007,
    'The plug and cord felt warm, and there was an electrical odor near the outlet.'
);

insert into complaint_chunks values (
    9108, 9008,
    'The side panel had a cosmetic scuff when the box was opened.'
);

insert into complaint_chunks values (
    9109, 9009,
    'The timer reset once during preheat, but the unit did not overheat.'
);

insert into complaint_chunks values (
    9110, 9010,
    'The quick start card was missing from the carton.'
);

insert into recall_queries values (
    'HEAT_ODOR',
    'overheating unusual odor warm plug electrical smell after first use'
);

prompt Generating deterministic portfolio-scale recall data...

declare
    type number_list is table of number;
    type varchar2_list is table of varchar2(100);

    l_core_store_ids number_list := number_list(
        101, 102, 103, 104, 201, 202, 203, 301, 302, 303
    );
    l_core_customer_deficits number_list := number_list(
        2, 3, 4, 3, 3, 4, 4, 4, 3, 4
    );
    l_missing_center_store_ids number_list := number_list(
        102, 103, 104, 202, 303
    );

    -- Inland metro anchors keep generated points on continental U.S. land.
    l_ne_longitudes number_list := number_list(
        -71.8023, -72.5898, -72.6851, -73.7562, -76.1474
    );
    l_ne_latitudes number_list := number_list(
        42.2626, 42.1015, 41.7637, 42.6526, 43.0481
    );
    l_atlantic_longitudes number_list := number_list(
        -79.9959, -76.8867, -77.4360, -78.6382, -80.8431
    );
    l_atlantic_latitudes number_list := number_list(
        40.4406, 40.2732, 37.5407, 35.7796, 35.2271
    );
    l_midwest_longitudes number_list := number_list(
        -82.9988, -86.1581, -90.1994, -93.6091, -95.9980
    );
    l_midwest_latitudes number_list := number_list(
        39.9612, 39.7684, 38.6270, 41.6005, 41.2565
    );
    l_south_longitudes number_list := number_list(
        -84.3880, -86.8025, -86.7816, -90.0490, -92.2896
    );
    l_south_latitudes number_list := number_list(
        33.7490, 33.5207, 36.1627, 35.1495, 34.7465
    );
    l_west_longitudes number_list := number_list(
        -104.9903, -112.0740, -111.8910, -106.6504, -116.2023
    );
    l_west_latitudes number_list := number_list(
        39.7392, 33.4484, 40.7608, 35.0844, 43.6150
    );
    l_control_longitudes number_list := number_list(
        -97.3301, -95.9928, -94.5786, -96.7026, -97.5164
    );
    l_control_latitudes number_list := number_list(
        37.6872, 36.1540, 39.0997, 40.8136, 35.4676
    );

    l_site_longitudes number_list := number_list(
        -71.3162, -72.9279, -82.9988, -97.7431, -85.6681,
        -119.7871, -84.3880, -117.4260, -80.8431, -104.9903
    );
    l_site_latitudes number_list := number_list(
        42.6334, 41.3083, 39.9612, 30.2672, 42.9634,
        36.7378, 33.7490, 47.6588, 35.2271, 39.7392
    );
    l_site_cities varchar2_list := varchar2_list(
        'Lowell', 'New Haven', 'Columbus', 'Austin', 'Grand Rapids',
        'Fresno', 'Atlanta', 'Spokane', 'Charlotte', 'Denver'
    );
    l_site_states varchar2_list := varchar2_list(
        'MA', 'CT', 'OH', 'TX', 'MI', 'CA', 'GA', 'WA', 'NC', 'CO'
    );

    l_customer_id       number := 20000;
    l_purchase_id       number := 20000;
    l_generated_count   number := 0;
    l_store_id          number;
    l_supplier_id       number;
    l_supplier_site_id  number;
    l_component_id      number;
    l_batch_id          varchar2(20);
    l_component_batch_id varchar2(30);
    l_longitude         number;
    l_latitude          number;
    l_coordinate_index  pls_integer;
    l_cluster_no        pls_integer;

    procedure set_store_coordinate(
        p_relative_index in pls_integer,
        p_longitudes     in number_list,
        p_latitudes      in number_list
    ) is
    begin
        l_coordinate_index := mod(p_relative_index - 1, p_longitudes.count) + 1;
        l_cluster_no := trunc((p_relative_index - 1) / p_longitudes.count);
        l_longitude := p_longitudes(l_coordinate_index) +
            case l_cluster_no
                when 1 then  0.035
                when 2 then -0.035
                when 3 then  0.035
                when 4 then -0.035
                else 0
            end;
        l_latitude := p_latitudes(l_coordinate_index) +
            case l_cluster_no
                when 1 then  0.020
                when 2 then  0.020
                when 3 then -0.020
                when 4 then -0.020
                when 5 then  0.040
                else 0
            end;
    end set_store_coordinate;
begin
    -- Portfolio dimensions provide realistic background data around B-482.
    for i in 1 .. 98 loop
        insert into products values (
            1000 + i,
            'PORTFOLIO-' || to_char(i, 'FM0000'),
            case mod(i, 5)
                when 0 then 'HomeChef Multi-Cooker ' || to_char(i, 'FM000')
                when 1 then 'BlendGo Personal Blender ' || to_char(i, 'FM000')
                when 2 then 'SteamPro Garment Care ' || to_char(i, 'FM000')
                when 3 then 'AirPure Room Filter ' || to_char(i, 'FM000')
                else 'BrewPoint Coffee System ' || to_char(i, 'FM000')
            end,
            case mod(i, 4)
                when 0 then 'Kitchen Appliance'
                when 1 then 'Home Environment'
                when 2 then 'Garment Care'
                else 'Small Appliance'
            end,
            json_object(
                'modelYear' value 2026,
                'voltage' value case when mod(i, 7) = 0 then 240 else 120 end,
                'warrantyMonths' value 12 + (mod(i, 3) * 12),
                'finish' value case mod(i, 4)
                    when 0 then 'graphite'
                    when 1 then 'white'
                    when 2 then 'stainless'
                    else 'black'
                end,
                'portfolioFamily' value 'FAMILY-' || to_char(mod(i, 12) + 1, 'FM00')
                returning json
            )
        );
    end loop;

    for i in 1 .. 118 loop
        insert into batches values (
            'B-GEN-' || to_char(i, 'FM000'),
            1001 + mod(i - 1, 98),
            date '2025-10-01' + i,
            case when mod(i, 23) = 0 then 'INVESTIGATING' else 'CLEAR' end,
            case when mod(i, 23) = 0 then 'ROUTINE-QA' end,
            case when mod(i, 23) = 0
                then 'Routine portfolio quality review generated for workshop context.'
            end
        );
    end loop;

    -- Historical investigations make case opening a realistic business workflow.
    for i in 1 .. 100 loop
        insert into recall_investigations values (
            'CASE-HIST-' || to_char(i, 'FM000'),
            'B-GEN-' || to_char(i, 'FM000'),
            case when mod(i, 7) = 0 then 'REVIEW' else 'CLOSED' end,
            case mod(i, 4)
                when 0 then 'PACKAGING-DAMAGE'
                when 1 then 'MOTOR-NOISE'
                when 2 then 'MISSING-ACCESSORY'
                else 'COSMETIC-DEFECT'
            end,
            'Historical portfolio investigation retained for trend and control analysis.',
            case mod(i, 3)
                when 0 then 'CUSTOMER_CARE'
                when 1 then 'QUALITY_REPORT'
                else 'RETAIL_PARTNER'
            end,
            timestamp '2025-10-01 09:00:00' + numtodsinterval(i * 12, 'HOUR'),
            'QUALITY_ANALYST_' || to_char(mod(i, 12) + 1, 'FM00'),
            json_object(
                'workflow' value 'PRODUCT_QUALITY',
                'portfolioControl' value true,
                'riskBand' value case mod(i, 3)
                    when 0 then 'LOW'
                    when 1 then 'MEDIUM'
                    else 'ROUTINE'
                end,
                'sourceReference' value 'HIST-' || to_char(i, 'FM0000')
                returning json
            )
        );
    end loop;

    -- The focal case starts as a reported JSON document awaiting analyst action.
    insert into recall_investigations values (
        'CASE-B482-2026',
        'B-482',
        'REVIEW',
        'THERMAL-ODOR',
        'Reports of overheating, electrical odor, and early shutoff.',
        'QUALITY_REPORT',
        null,
        null,
        json_object(
            'workflow' value 'PRODUCT_RECALL',
            'workflowState' value 'REPORTED',
            'caseId' value 'CASE-B482-2026',
            'batchId' value 'B-482',
            'sourceChannel' value 'QUALITY_REPORT',
            'reportedAt' value '2026-06-01T08:30:00-04:00',
            'reportedBy' value 'QUALITY_MONITOR',
            'signals' value json_array(
                'OVERHEATING',
                'ELECTRICAL_ODOR',
                'EARLY_SHUTOFF'
                returning json
            ) format json,
            'customerContactAuthorized' value false
            returning json
        )
    );

    for i in 4 .. 100 loop
        insert into recall_actions values (
            i,
            i,
            'FOLLOWUP_ACTION_' || to_char(i, 'FM000'),
            case mod(i, 5)
                when 0 then 'Confirm distributor inventory and quarantine status.'
                when 1 then 'Validate supplier certificate and incoming inspection evidence.'
                when 2 then 'Schedule regional service capacity and replacement inventory.'
                when 3 then 'Document regulator, retailer, and customer communication readiness.'
                else 'Review closure evidence and retain the decision audit record.'
            end
        );
    end loop;

    -- Add 140 stores. The first 110 are affected by B-482; 30 are controls.
    for i in 1 .. 140 loop
        if i <= 20 then
            set_store_coordinate(i, l_ne_longitudes, l_ne_latitudes);
        elsif i <= 50 then
            set_store_coordinate(
                i - 20, l_atlantic_longitudes, l_atlantic_latitudes
            );
        elsif i <= 80 then
            set_store_coordinate(
                i - 50, l_midwest_longitudes, l_midwest_latitudes
            );
        elsif i <= 95 then
            set_store_coordinate(i - 80, l_south_longitudes, l_south_latitudes);
        elsif i <= 110 then
            set_store_coordinate(i - 95, l_west_longitudes, l_west_latitudes);
        else
            set_store_coordinate(
                i - 110, l_control_longitudes, l_control_latitudes
            );
        end if;

        insert into stores values (
            1000 + i,
            'GEN-' || to_char(i, 'FM000'),
            case mod(i, 5)
                when 0 then 'Market Square Store '
                when 1 then 'Central Avenue Store '
                when 2 then 'Regional Mall Store '
                when 3 then 'Commerce Park Store '
                else 'Downtown Store '
            end || to_char(i, 'FM000'),
            case
                when i <= 20 then 'NORTHEAST'
                when i <= 50 then 'ATLANTIC'
                when i <= 80 then 'MIDWEST'
                when i <= 95 then 'SOUTH'
                when i <= 110 then 'WEST'
                else 'CONTROL'
            end,
            l_longitude,
            l_latitude
        );
    end loop;

    -- Every affected store has a nearby authorized response location.
    for i in 1 .. l_missing_center_store_ids.count loop
        insert into response_centers
        select 5 + i,
               store_name || ' Recall Desk',
               longitude,
               latitude
        from   stores
        where  store_id = l_missing_center_store_ids(i);
    end loop;

    for i in 1 .. 110 loop
        insert into response_centers
        select 10 + i,
               store_name || ' Recall Desk',
               longitude,
               latitude
        from   stores
        where  store_id = 1000 + i;
    end loop;

    for i in 1 .. 115 loop
        l_supplier_id := 100 + i;
        insert into suppliers values (
            l_supplier_id,
            case mod(i, 5)
                when 0 then 'Precision Thermal Systems '
                when 1 then 'North American Polymer Works '
                when 2 then 'Certified Cable Assemblies '
                when 3 then 'Micro Sensor Fabrication '
                else 'Industrial Contact Metals '
            end || to_char(i, 'FM000'),
            case when mod(i, 4) = 0 then 2 else 1 end,
            case when mod(i, 4) = 0 then 'sub-component supplier'
                 else 'component manufacturer'
            end
        );
    end loop;

    for i in 1 .. 145 loop
        l_supplier_id := 101 + mod(i - 1, 115);
        l_supplier_site_id := 1000 + i;
        l_coordinate_index := mod(i - 1, l_site_longitudes.count) + 1;
        l_cluster_no := trunc((i - 1) / l_site_longitudes.count);
        l_longitude := l_site_longitudes(l_coordinate_index) +
            ((mod(l_cluster_no, 5) - 2) * 0.012);
        l_latitude := l_site_latitudes(l_coordinate_index) +
            ((trunc(l_cluster_no / 5) - 1) * 0.012);

        insert into supplier_sites values (
            l_supplier_site_id,
            l_supplier_id,
            'SITE-' || to_char(i, 'FM000'),
            'Certified Production Site ' || to_char(i, 'FM000'),
            l_site_cities(l_coordinate_index),
            l_site_states(l_coordinate_index),
            'US',
            l_longitude,
            l_latitude
        );

        insert into supplier_site_edges values (
            20000 + i,
            l_supplier_site_id,
            l_supplier_id
        );
    end loop;

    for i in 1 .. 115 loop
        l_component_id := 1000 + i;
        insert into components values (
            l_component_id,
            'SUBPART-' || to_char(i, 'FM000'),
            case mod(i, 6)
                when 0 then 'Thermal cutoff harness '
                when 1 then 'Control board connector '
                when 2 then 'Heating chamber fastener '
                when 3 then 'Insulation shield segment '
                when 4 then 'Power relay contact '
                else 'Temperature sensing lead '
            end || to_char(i, 'FM000'),
            case mod(i, 5)
                when 0 then 'HIGH'
                when 1 then 'HIGH'
                when 2 then 'MEDIUM'
                else 'LOW'
            end,
            json_object(
                'drawingRevision' value 'REV-' || chr(65 + mod(i, 6)),
                'inspectionPlan' value 'IP-' || to_char(i, 'FM0000'),
                'materialClass' value case mod(i, 4)
                    when 0 then 'electrical'
                    when 1 then 'polymer'
                    when 2 then 'metal'
                    else 'sensor'
                end,
                'traceRequired' value case when mod(i, 3) = 0 then true else false end
                returning json
            )
        );
    end loop;

    -- Generate 295 component lots and all graph edge records.
    for i in 1 .. 295 loop
        l_component_batch_id := 'CB-GEN-' || to_char(i, 'FM0000');
        l_component_id := 1001 + mod(i - 1, 115);
        l_supplier_site_id := 1001 + mod(i - 1, 145);
        l_batch_id := case
            when i <= 20 then 'B-482'
            else 'B-GEN-' || to_char(mod(i - 21, 118) + 1, 'FM000')
        end;

        insert into component_batches values (
            l_component_batch_id,
            l_component_id,
            l_supplier_site_id,
            'LOT-26-' || to_char(i, 'FM0000'),
            timestamp '2026-04-01 06:00:00' + numtodsinterval(i * 3, 'HOUR'),
            timestamp '2026-04-05 09:00:00' + numtodsinterval(i * 3, 'HOUR'),
            case
                when i <= 20 and mod(i, 3) = 0 then 'SUSPECT'
                when i <= 20 then 'WATCH'
                when mod(i, 19) = 0 then 'WATCH'
                else 'CLEAR'
            end,
            json_object(
                'supplierCertificate' value 'CERT-26-' || to_char(i, 'FM0000'),
                'subVendorLot' value 'SVL-26-' || to_char(mod(i * 7, 9000) + 1000),
                'inspectionScore' value 92 + mod(i, 9),
                'countryOfOrigin' value 'US',
                'traceTimestamp' value to_char(
                    timestamp '2026-04-05 09:00:00' + numtodsinterval(i * 3, 'HOUR'),
                    'YYYY-MM-DD"T"HH24:MI:SS'
                )
                returning json
            )
        );

        insert into batch_components values (
            30000 + i,
            l_batch_id,
            l_component_batch_id,
            case when mod(i, 17) = 0 then 2 else 1 end,
            timestamp '2026-05-18 09:00:00' + numtodsinterval(i * 2, 'MINUTE'),
            'LINE-' || to_char(mod(i, 6) + 1)
        );

        insert into component_batch_site_edges values (
            40000 + i,
            l_component_batch_id,
            l_supplier_site_id,
            'LOT-26-' || to_char(i, 'FM0000'),
            timestamp '2026-04-01 06:00:00' + numtodsinterval(i * 3, 'HOUR'),
            timestamp '2026-04-05 09:00:00' + numtodsinterval(i * 3, 'HOUR')
        );

        insert into component_batch_component_edges values (
            50000 + i,
            l_component_batch_id,
            l_component_id
        );
    end loop;

    -- Product JSON now lists every major component and traceable sub-part used by B-482.
    update products p
    set    attributes = (
               select json_object(
                          'voltage' value 120,
                          'finish' value 'graphite',
                          'warrantyMonths' value 24,
                          'assemblyPlant' value 'Marlborough, MA',
                          'components' value json_arrayagg(
                              json_object(
                                  'code' value component_code,
                                  'name' value component_name,
                                  'criticality' value criticality
                                  returning json
                              )
                              order by component_code
                              returning json
                          )
                          returning json
                      )
               from (
                   select distinct c.component_code,
                                   c.component_name,
                                   c.criticality
                   from   batch_components bc
                   join   component_batches cb
                          on cb.component_batch_id = bc.component_batch_id
                   join   components c
                          on c.component_id = cb.component_id
                   where  bc.batch_id = 'B-482'
               )
           )
    where  p.product_id = 10;

    -- Extend B-482 to 120 stores and 2,400 shipped units.
    for i in 1 .. 110 loop
        insert into shipments values (
            10000 + i,
            'B-482',
            date '2026-06-06' + mod(i, 20)
        );
        insert into batch_shipments values (20000 + i, 'B-482', 10000 + i);
        insert into shipment_items values (30000 + i, 10000 + i, 1000 + i, 21);
    end loop;

    -- Historical control shipments keep graph and relational workloads realistic.
    for i in 1 .. 84 loop
        l_batch_id := 'B-GEN-' || to_char(mod(i - 1, 118) + 1, 'FM000');
        l_store_id := 1001 + mod(109 + i, 140);
        insert into shipments values (11000 + i, l_batch_id, date '2026-01-01' + i);
        insert into batch_shipments values (21000 + i, l_batch_id, 11000 + i);
        insert into shipment_items values (
            31000 + i,
            11000 + i,
            l_store_id,
            8 + mod(i, 25)
        );
    end loop;

    -- Bring each original affected store to five exposed customers.
    for i in 1 .. l_core_store_ids.count loop
        for j in 1 .. l_core_customer_deficits(i) loop
            l_customer_id := l_customer_id + 1;
            l_purchase_id := l_purchase_id + 1;
            insert into customers values (
                l_customer_id,
                'Recall Customer ' || to_char(l_customer_id),
                'recall.customer.' || to_char(l_customer_id) || '@example.invalid',
                l_core_store_ids(i)
            );
            insert into purchases values (
                l_purchase_id,
                l_customer_id,
                l_core_store_ids(i),
                'B-482',
                date '2026-06-08' + mod(l_customer_id, 21),
                1
            );
        end loop;
    end loop;

    -- Five exposed customers per generated affected store: 600 total for B-482.
    for i in 1 .. 110 loop
        for j in 1 .. 5 loop
            l_customer_id := l_customer_id + 1;
            l_purchase_id := l_purchase_id + 1;
            insert into customers values (
                l_customer_id,
                'Recall Customer ' || to_char(l_customer_id),
                'recall.customer.' || to_char(l_customer_id) || '@example.invalid',
                1000 + i
            );
            insert into purchases values (
                l_purchase_id,
                l_customer_id,
                1000 + i,
                'B-482',
                date '2026-06-08' + mod(i + j, 21),
                case when mod(i + j, 19) = 0 then 2 else 1 end
            );
        end loop;
    end loop;

    -- Four hundred control customers and purchases support selectivity comparisons.
    for i in 1 .. 400 loop
        l_store_id := 1001 + mod(i - 1, 140);
        l_batch_id := 'B-GEN-' || to_char(mod(i - 1, 118) + 1, 'FM000');
        insert into customers values (
            30000 + i,
            'Portfolio Customer ' || to_char(i, 'FM0000'),
            'portfolio.customer.' || to_char(i, 'FM0000') || '@example.invalid',
            l_store_id
        );
        insert into purchases values (
            30000 + i,
            30000 + i,
            l_store_id,
            l_batch_id,
            date '2026-01-15' + mod(i, 150),
            1 + mod(i, 2)
        );
    end loop;

    -- Add 190 B-482 complaints outside the Northeast role scope.
    l_generated_count := 0;
    for r in (
        select p.customer_id
        from   purchases p
        join   stores s on s.store_id = p.store_id
        where  p.batch_id = 'B-482'
        and    s.region_code != 'NORTHEAST'
        and    p.customer_id >= 20000
        order  by p.customer_id
        fetch  first 190 rows only
    ) loop
        l_generated_count := l_generated_count + 1;
        insert into complaints values (
            10000 + l_generated_count,
            r.customer_id,
            case when mod(l_generated_count, 4) = 0 then null else 'B-482' end,
            json_object(
                'channel' value case mod(l_generated_count, 4)
                    when 0 then 'web'
                    when 1 then 'phone'
                    when 2 then 'store'
                    else 'email'
                end,
                'severity' value case when mod(l_generated_count, 9) = 0
                    then 'medium' else 'low'
                end,
                'symptom' value case mod(l_generated_count, 5)
                    when 0 then 'packaging'
                    when 1 then 'cosmetic'
                    when 2 then 'timer-reset'
                    when 3 then 'operating-noise'
                    else 'documentation'
                end,
                'observations' value json_object(
                    'inspection' value 'No thermal damage observed',
                    'followUp' value 'Standard service review'
                    returning json
                ),
                'narrative' value 'Customer reported a non-thermal service observation during the B-482 recall review.'
                returning json
            ),
            timestamp '2026-06-18 08:00:00' +
                numtodsinterval(l_generated_count * 17, 'MINUTE')
        );
        insert into complaint_chunks values (
            20000 + l_generated_count,
            10000 + l_generated_count,
            'Non-thermal service observation recorded during the B-482 recall review.'
        );
    end loop;

    -- Add 100 unrelated portfolio complaints as negative vector controls.
    for i in 1 .. 100 loop
        insert into complaints values (
            11000 + i,
            30000 + i,
            'B-GEN-' || to_char(mod(i - 1, 118) + 1, 'FM000'),
            json_object(
                'channel' value case mod(i, 3)
                    when 0 then 'web'
                    when 1 then 'phone'
                    else 'email'
                end,
                'severity' value 'low',
                'symptom' value case mod(i, 3)
                    when 0 then 'missing-accessory'
                    when 1 then 'shipping-damage'
                    else 'documentation'
                end,
                'observations' value json_object(
                    'thermalIssue' value false,
                    'portfolioControl' value true
                    returning json
                ),
                'narrative' value 'Unrelated portfolio service case retained as a vector-search control.'
                returning json
            ),
            timestamp '2026-03-01 09:00:00' + numtodsinterval(i * 5, 'HOUR')
        );
        insert into complaint_chunks values (
            21000 + i,
            11000 + i,
            'Unrelated portfolio service case about accessories, shipping, or documentation.'
        );
    end loop;

    for i in 1 .. 99 loop
        insert into recall_queries values (
            'QRY_' || to_char(i, 'FM000'),
            case mod(i, 5)
                when 0 then 'packaging damage and missing documentation'
                when 1 then 'motor noise and vibration during operation'
                when 2 then 'cosmetic finish and panel alignment issue'
                when 3 then 'shipping delay and retail inventory status'
                else 'routine warranty and accessory request'
            end
        );
    end loop;
end;
/

create index shipments_batch_ix on shipments(batch_id);
create index purchases_batch_ix on purchases(batch_id);
create index recall_investigations_batch_ix on recall_investigations(batch_id);
create index complaint_chunks_complaint_ix on complaint_chunks(complaint_id);
create index graph_batch_shipments_ix
    on batch_shipments(batch_id, shipment_id);
create index graph_shipment_items_ix
    on shipment_items(shipment_id, store_id);
create index graph_purchases_ix
    on purchases(store_id, customer_id, batch_id);
create index graph_component_site_ix
    on component_batch_site_edges(component_batch_id, supplier_site_id);
create index graph_component_type_ix
    on component_batch_component_edges(component_batch_id, component_id);
create index graph_supplier_site_ix
    on supplier_site_edges(supplier_site_id, supplier_id);

create or replace view recall_affected_stores_v as
select x.batch_id,
       s.store_id,
       s.store_code,
       s.store_name,
       s.region_code,
       x.units_sent,
       s.longitude,
       s.latitude,
       cast(null as mdsys.sdo_geometry) as location
from   (
           select sh.batch_id,
                  si.store_id,
                  sum(si.units_sent) as units_sent
           from   shipments sh
           join   shipment_items si on si.shipment_id = sh.shipment_id
           group  by sh.batch_id, si.store_id
       ) x
join   stores s on s.store_id = x.store_id;

create or replace view recall_customer_exposure_v as
select p.batch_id,
       p.customer_id,
       p.store_id,
       p.purchase_id,
       p.purchased_on,
       p.quantity
from   purchases p;

create or replace view recall_component_trace_v as
select bc.batch_id,
       bc.component_batch_id,
       c.component_id,
       c.component_code,
       c.component_name,
       c.criticality,
       cb.quality_status,
       cb.supplier_lot_code,
       cb.produced_at,
       cb.received_at,
       bc.installed_at,
       bc.assembly_station,
       ss.supplier_site_id,
       ss.site_code,
       ss.site_name,
       ss.city,
       ss.state_code,
       ss.longitude,
       ss.latitude,
       cast(null as mdsys.sdo_geometry) as location,
       s.supplier_id,
       s.supplier_name,
       s.tier_no,
       s.supplier_type
from   batch_components bc
join   component_batches cb
       on cb.component_batch_id = bc.component_batch_id
join   components c
       on c.component_id = cb.component_id
join   supplier_sites ss
       on ss.supplier_site_id = cb.supplier_site_id
join   suppliers s
       on s.supplier_id = ss.supplier_id;

create or replace package recall_lab_api authid definer as
    function get_recall_context(p_batch_id in varchar2) return clob;
    function get_spatial_impact(p_batch_id in varchar2) return clob;
end recall_lab_api;
/

create or replace package body recall_lab_api as
    function get_recall_context(p_batch_id in varchar2) return clob is
        l_result         clob;
        l_complaint_ids  clob := '[]';
        l_batch_id       varchar2(20) := upper(trim(p_batch_id));
    begin
        -- Lab 4 adds the vector columns. Keep the Lab 1 package valid before
        -- that promotion, then use the same package after embeddings exist.
        begin
            execute immediate q'~
                select nvl(
                           json_arrayagg(
                               x.complaint_id
                               order by x.distance
                               returning clob
                           ),
                           to_clob('[]')
                       )
                from (
                    select cc.complaint_id,
                           vector_distance(
                               cc.embedding,
                               q.query_vector,
                               cosine
                           ) as distance
                    from complaint_chunks cc
                    join complaints c
                         on c.complaint_id = cc.complaint_id
                    cross join recall_queries q
                    where q.query_key = 'HEAT_ODOR'
                    and (
                        c.reported_batch = :batch_id
                        or c.customer_id in (
                            select customer_id
                            from recall_customer_exposure_v
                            where batch_id = :batch_id
                        )
                    )
                    order by distance
                    fetch first 5 rows only
                ) x~'
            into   l_complaint_ids
            using  l_batch_id, l_batch_id;
        exception
            when others then
                if sqlcode = -904 then
                    l_complaint_ids := '[]';
                else
                    raise;
                end if;
        end;

        select json_object(
                   'batchId' value b.batch_id,
                   'status' value b.recall_status,
                   'product' value p.product_name,
                   'investigationCaseId' value (
                       select max(i.case_id) keep (dense_rank last order by i.opened_at)
                       from recall_investigations i
                       where i.batch_id = l_batch_id
                       and i.case_status = 'OPEN'
                   ),
                   'affectedStoreCount' value (
                       select count(*)
                       from recall_affected_stores_v a
                       where a.batch_id = l_batch_id
                   ),
                   'unitsSent' value (
                       select sum(a.units_sent)
                       from recall_affected_stores_v a
                       where a.batch_id = l_batch_id
                   ),
                   'customerExposureCount' value (
                       select count(distinct e.customer_id)
                       from recall_customer_exposure_v e
                       where e.batch_id = l_batch_id
                   ),
                   'componentBatchCount' value (
                       select count(*)
                       from recall_component_trace_v t
                       where t.batch_id = l_batch_id
                   ),
                   'supplierSiteCount' value (
                       select count(distinct t.supplier_site_id)
                       from recall_component_trace_v t
                       where t.batch_id = l_batch_id
                   ),
                   'componentTrace' value (
                       select json_arrayagg(
                                  json_object(
                                      'componentCode' value t.component_code,
                                      'componentBatchId' value t.component_batch_id,
                                      'qualityStatus' value t.quality_status,
                                      'supplier' value t.supplier_name,
                                      'supplierSite' value t.site_code,
                                      'supplierTier' value t.tier_no,
                                      'producedAt' value t.produced_at,
                                      'receivedAt' value t.received_at,
                                      'installedAt' value t.installed_at
                                  )
                                  order by t.installed_at
                                  returning clob
                              )
                       from recall_component_trace_v t
                       where t.batch_id = l_batch_id
                   ) format json,
                   'complaintIds' value l_complaint_ids format json,
                   'firstAction' value (
                       select action_text
                       from recall_actions
                       where priority_no = 1
                   ),
                   'customerContactAuthorized' value 'false' format json
                   returning clob
               )
        into   l_result
        from   batches b
        join   products p on p.product_id = b.product_id
        where  b.batch_id = l_batch_id;

        return l_result;
    exception
        when no_data_found then
            select json_object(
                       'error' value 'UNKNOWN_BATCH',
                       'batchId' value l_batch_id
                       returning clob
                   )
            into   l_result;

            return l_result;
    end get_recall_context;

    function get_spatial_impact(p_batch_id in varchar2) return clob is
        l_result   clob;
        l_batch_id varchar2(20) := upper(trim(p_batch_id));
    begin
        -- Keep the spatial SQL dynamic so Lab 1 compiles before Lab 2 adds
        -- the LOCATION columns and replaces the placeholder views.
        execute immediate q'~
            with nearest_centers as (
                select a.store_id,
                       a.region_code,
                       a.units_sent,
                       rc.center_name,
                       row_number() over (
                           partition by a.store_id
                           order by sdo_geom.sdo_distance(
                               a.location,
                               rc.location,
                               0.00001,
                               'unit=km'
                           )
                       ) as rn
                from   recall_affected_stores_v a
                cross  join response_centers rc
                where  a.batch_id = :batch_id
            ),
            region_summary as (
                select region_code,
                       count(*) as store_count,
                       sum(units_sent) as units_sent
                from   nearest_centers
                where  rn = 1
                group  by region_code
            ),
            center_summary as (
                select center_name,
                       count(*) as store_count,
                       sum(units_sent) as units_sent
                from   nearest_centers
                where  rn = 1
                group  by center_name
            )
            select json_object(
                       'batchId' value :batch_id,
                       'responseRadiusKm' value 25,
                       'affectedStoreCount' value (
                           select count(*)
                           from   nearest_centers
                           where  rn = 1
                       ),
                       'unitsSent' value (
                           select sum(units_sent)
                           from   nearest_centers
                           where  rn = 1
                       ),
                       'storesWithinResponseRadius' value (
                           select count(distinct a.store_id)
                           from   recall_affected_stores_v a
                           cross  join response_centers rc
                           where  a.batch_id = :batch_id
                           and    sdo_within_distance(
                                      a.location,
                                      rc.location,
                                      'distance=25 unit=km'
                                  ) = 'TRUE'
                       ),
                       'regions' value (
                           select json_arrayagg(
                                      json_object(
                                          'region' value region_code,
                                          'storeCount' value store_count,
                                          'unitsSent' value units_sent
                                          returning clob
                                      )
                                      order by region_code
                                      returning clob
                                  )
                           from   region_summary
                       ) format json,
                       'nearestResponseCenters' value (
                           select json_arrayagg(
                                      json_object(
                                          'center' value center_name,
                                          'storeCount' value store_count,
                                          'unitsSent' value units_sent
                                          returning clob
                                      )
                                      order by center_name
                                      returning clob
                                  )
                           from   center_summary
                       ) format json
                       returning clob
                   )
            ~'
        into   l_result
        using  l_batch_id, l_batch_id, l_batch_id;

        return l_result;
    exception
        when no_data_found then
            select json_object(
                       'error' value 'UNKNOWN_BATCH',
                       'batchId' value l_batch_id
                       returning clob
                   )
            into   l_result;

            return l_result;
    end get_spatial_impact;
end recall_lab_api;
/

show errors package body recall_lab_api

begin
    for r in (
        select object_name, object_type
        from   user_objects
        where  status = 'INVALID'
        and    object_name in (
                   'RECALL_LAB_API',
                   'RECALL_COMPONENT_TRACE_V'
               )
    ) loop
        raise_application_error(
            -20002,
            'Invalid setup object: ' || r.object_type || ' ' || r.object_name
        );
    end loop;
end;
/

declare
    l_row_count number;
begin
    for r in (
        select column_value as table_name
        from table(sys.odcivarchar2list(
            'PRODUCTS',
            'BATCHES',
            'RECALL_INVESTIGATIONS',
            'RECALL_ACTIONS',
            'STORES',
            'RESPONSE_CENTERS',
            'SUPPLIERS',
            'SUPPLIER_SITES',
            'COMPONENTS',
            'COMPONENT_BATCHES',
            'BATCH_COMPONENTS',
            'COMPONENT_BATCH_SITE_EDGES',
            'COMPONENT_BATCH_COMPONENT_EDGES',
            'SUPPLIER_SITE_EDGES',
            'SHIPMENTS',
            'BATCH_SHIPMENTS',
            'SHIPMENT_ITEMS',
            'CUSTOMERS',
            'PURCHASES',
            'COMPLAINTS',
            'COMPLAINT_CHUNKS',
            'RECALL_QUERIES'
        ))
    ) loop
        execute immediate 'select count(*) from ' || r.table_name
            into l_row_count;

        if l_row_count < 100 then
            raise_application_error(
                -20003,
                'Generated table ' || r.table_name ||
                ' has only ' || l_row_count || ' rows; expected at least 100.'
            );
        end if;
    end loop;
end;
/

declare
    l_affected_stores   number;
    l_units_sent        number;
    l_exposed_customers number;
    l_component_batches number;
    l_supplier_sites    number;
begin
    select count(*), nvl(sum(units_sent), 0)
    into   l_affected_stores, l_units_sent
    from   recall_affected_stores_v
    where  batch_id = 'B-482';

    select count(distinct customer_id)
    into   l_exposed_customers
    from   recall_customer_exposure_v
    where  batch_id = 'B-482';

    select count(*), count(distinct supplier_site_id)
    into   l_component_batches, l_supplier_sites
    from   recall_component_trace_v
    where  batch_id = 'B-482';

    if l_affected_stores != 120
       or l_units_sent != 2400
       or l_exposed_customers != 600
       or l_component_batches != 25
       or l_supplier_sites != 25
    then
        raise_application_error(
            -20003,
            'Seed verification failed: stores=' || l_affected_stores ||
            ', units=' || l_units_sent ||
            ', customers=' || l_exposed_customers ||
            ', component batches=' || l_component_batches ||
            ', supplier sites=' || l_supplier_sites
        );
    end if;
end;
/

grant execute on recall_lab_api to recall_api_role;

commit;

prompt Setup complete.
prompt Reference state before case opening:
prompt   B-482 status = CLEAR.
prompt   CASE-B482-2026 status = REVIEW; JSON workflowState = REPORTED.
prompt Expected Lab 1 outcome after opening CASE-B482-2026:
prompt   120 affected stores, 2,400 units, 600 exposed customers.
prompt   25 component batches from 25 supplier/sub-vendor sites.
prompt   Lab 4 will populate the local ONNX embeddings for semantic complaints.
prompt All tables, indexes, views, and the approved read package are
prompt owned by RECALL_OWNER. RECALL_APP_USER receives package access
prompt only through RECALL_API_ROLE. Lab 3 creates RECALL_GRAPH.
