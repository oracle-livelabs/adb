create or replace procedure add_spatial_pizza authid current_user as 
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
            insert into user_sdo_geom_metadata values (
             'PIZZA_LOCATION',
             user||'.LATLON_TO_GEOMETRY(lat,lon)',
              sdo_dim_array(
                  sdo_dim_element('X', -180, 180, 0.05),
                  sdo_dim_element('Y', -90, 90, 0.05)),
              4326
               );
               
            commit;
        exception
            when others then
                workshop.write('unable to update spatial metadata for pizza_location', -1);             
                workshop.write(sqlerrm);                 
        end;

        begin
            workshop.write('create spatial indexes', 2);
            workshop.exec ( 'CREATE INDEX pizza_location_sidx ON pizza_location (latlon_to_geometry(lat,lon)) INDEXTYPE IS mdsys.spatial_index_v2 PARAMETERS (''layer_gtype=POINT'')' );     
        exception
            when others then
                workshop.write('unable to create spatial index on pizza_location', -1);             
                workshop.write(sqlerrm);                 
        end;    
 
end add_spatial_pizza;
/

begin
    workshop.exec('grant execute on add_spatial_pizza to public');
end;
/