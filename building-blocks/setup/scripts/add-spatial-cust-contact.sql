create or replace procedure add_spatial_cust_contact authid current_user as 
begin
 
        -- function
        workshop.write('adding spatial requirements', 1);
        workshop.write('create function latlon_to_geometry',2);
        workshop.exec ( '
            CREATE OR REPLACE FUNCTION latlon_to_geometry (
               latitude   IN  NUMBER,
               longitude  IN  NUMBER
            ) RETURN sdo_geometry
               DETERMINISTIC
               IS
               BEGIN
               --first ensure valid lat/lon input
               IF latitude IS NULL OR longitude IS NULL
               OR latitude NOT BETWEEN -90 AND 90
               OR longitude NOT BETWEEN -180 AND 180 THEN
                 RETURN NULL;
               ELSE
               --return point geometry
                RETURN sdo_geometry(
                        2001, --identifier for a point geometry
                        4326, --identifier for lat/lon coordinate system
                        sdo_point_type(
                         longitude, latitude, NULL),
                        NULL, NULL);
               END IF;
               END;
        ' );

        begin
            -- SPATIAL METADATA UPDATES
            workshop.write('add spatial metadata', 2);

            insert into user_sdo_geom_metadata values (
             'CUSTOMER_CONTACT',
             user||'.LATLON_TO_GEOMETRY(loc_lat,loc_long)',
              sdo_dim_array(
                  sdo_dim_element('X', -180, 180, 0.05), --longitude bounds and tolerance in meters
                  sdo_dim_element('Y', -90, 90, 0.05)),  --latitude bounds and tolerance in meters
              4326 --identifier for lat/lon coordinate system
                );
             commit;
        exception
            when others then
                workshop.write('unable to update spatial metadata for customer_contact', -1);             
                workshop.write(sqlerrm);                 
        end;

        -- Add spatial indexes
        begin
            workshop.write('create spatial indexes', 2);
            workshop.exec ( 'CREATE INDEX customer_sidx ON customer_contact (latlon_to_geometry(loc_lat,loc_long)) INDEXTYPE IS mdsys.spatial_index_v2 PARAMETERS (''layer_gtype=POINT'')' );            
        exception
            when others then
                workshop.write('unable to create spatial index on customer_contact', -1);             
                workshop.write(sqlerrm);                 
        end;    
 
end add_spatial_cust_contact;
/
begin
    workshop.exec('grant execute on add_spatial_cust_contact to public');
end;
/