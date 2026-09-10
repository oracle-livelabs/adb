whenever sqlerror exit sql.sqlcode rollback
set serveroutput on
set feedback on

prompt ============================================================
prompt Product Recall Assistant - Refresh Continental U.S. Locations
prompt Connect as RECALL_OWNER. Use for an existing expanded dataset.
prompt ============================================================

declare
    type number_list is table of number;
    type varchar2_list is table of varchar2(100);

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

    l_longitude        number;
    l_latitude         number;
    l_coordinate_index pls_integer;
    l_cluster_no       pls_integer;

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
    if user != 'RECALL_OWNER' then
        raise_application_error(-20070, 'Wrong user: connect as RECALL_OWNER.');
    end if;

    for i in 1 .. 140 loop
        if i <= 20 then
            set_store_coordinate(i, l_ne_longitudes, l_ne_latitudes);
        elsif i <= 50 then
            set_store_coordinate(i - 20, l_atlantic_longitudes, l_atlantic_latitudes);
        elsif i <= 80 then
            set_store_coordinate(i - 50, l_midwest_longitudes, l_midwest_latitudes);
        elsif i <= 95 then
            set_store_coordinate(i - 80, l_south_longitudes, l_south_latitudes);
        elsif i <= 110 then
            set_store_coordinate(i - 95, l_west_longitudes, l_west_latitudes);
        else
            set_store_coordinate(i - 110, l_control_longitudes, l_control_latitudes);
        end if;

        update stores
        set longitude = l_longitude,
            latitude = l_latitude,
            location = mdsys.sdo_geometry(l_longitude, l_latitude)
        where store_id = 1000 + i;
    end loop;

    update response_centers rc
    set (longitude, latitude, location) = (
        select s.longitude, s.latitude, s.location
        from stores s
        where s.store_id = 990 + rc.center_id
    )
    where rc.center_id between 11 and 120;

    for i in 1 .. 145 loop
        l_coordinate_index := mod(i - 1, l_site_longitudes.count) + 1;
        l_cluster_no := trunc((i - 1) / l_site_longitudes.count);
        l_longitude := l_site_longitudes(l_coordinate_index) +
            ((mod(l_cluster_no, 5) - 2) * 0.012);
        l_latitude := l_site_latitudes(l_coordinate_index) +
            ((trunc(l_cluster_no / 5) - 1) * 0.012);

        update supplier_sites
        set city = l_site_cities(l_coordinate_index),
            state_code = l_site_states(l_coordinate_index),
            longitude = l_longitude,
            latitude = l_latitude,
            location = mdsys.sdo_geometry(l_longitude, l_latitude)
        where supplier_site_id = 1000 + i;
    end loop;

    commit;
end;
/

select 'STORES' as location_type,
       count(*) as total_points,
       min(s.location.sdo_point.x) as min_longitude,
       max(s.location.sdo_point.x) as max_longitude,
       min(s.location.sdo_point.y) as min_latitude,
       max(s.location.sdo_point.y) as max_latitude
from stores s
union all
select 'SUPPLIER_SITES', count(*),
       min(ss.location.sdo_point.x), max(ss.location.sdo_point.x),
       min(ss.location.sdo_point.y), max(ss.location.sdo_point.y)
from supplier_sites ss;

prompt Continental U.S. store, response-center, and supplier-site locations refreshed.
