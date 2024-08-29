--combine all trip data tables into one
CREATE TABLE tripdata AS
SELECT * FROM tripdata_2023_01
UNION ALL
SELECT * FROM tripdata_2023_02
UNION ALL
SELECT * FROM tripdata_2023_03
UNION ALL
SELECT * FROM tripdata_2023_04
UNION ALL
SELECT * FROM tripdata_2023_05
UNION ALL
SELECT * FROM tripdata_2023_06
UNION ALL
SELECT * FROM tripdata_2023_07
UNION ALL
SELECT * FROM tripdata_2023_08
UNION ALL
SELECT * FROM tripdata_2023_09
UNION ALL
SELECT * FROM tripdata_2023_10
UNION ALL
SELECT * FROM tripdata_2023_11
UNION ALL
SELECT * FROM tripdata_2023_12;

--check the table
SELECT * FROM tripdata;
SELECT * FROM stations;

--check for duplicate records on tripdata
--ride_id is the primary key in the trip data table
SELECT
 COUNT(ride_id) - COUNT(DISTINCT ride_id) as num_of_duplicate
from
 tripdata;

--check for duplicate record on stations
--id is the primary key in the stations table
SELECT
 COUNT(id) - COUNT(DISTINCT id) as num_of_duplicate
from
 stations;

--detect invalid data in column
SELECT DISTINCT
 rideable_type
FROM
 tripdata;
SELECT DISTINCT
 member_casual
FROM
 tripdata;
/* the values for rideable_type and member_casual are valid */

--check the length of ride_id
SELECT ride_id, LENGTH(ride_id) AS length_of_ride_id
FROM tripdata;
/* found that the length of ride_id is 16 */

--check for ride_id with lengths other than 16
SELECT 
 *,
 LENGTH(ride_id)
FROM
 tripdata
WHERE
 LENGTH(ride_id) <> 16;
/* there are 3841 records where ride_id is other than 16 */

--check null values on tripdata table
SELECT
   COUNT(*) AS total_rows,
   SUM(CASE WHEN ride_id IS NULL THEN 1 ELSE 0 END) AS ride_id_null_count,
   SUM(CASE WHEN rideable_type IS NULL THEN 1 ELSE 0 END) AS rideable_type_null_count,
   SUM(CASE WHEN started_at IS NULL THEN 1 ELSE 0 END) AS started_at_null_count,
   SUM(CASE WHEN ended_at IS NULL THEN 1 ELSE 0 END) AS ended_at_null_count,
   SUM(CASE WHEN start_station_name IS NULL THEN 1 ELSE 0 END) AS start_station_name_null_count,
   SUM(CASE WHEN start_station_id IS NULL THEN 1 ELSE 0 END) AS start_station_id_null_count,
   SUM(CASE WHEN end_station_name IS NULL THEN 1 ELSE 0 END) AS end_station_name_null_count,
   SUM(CASE WHEN end_station_id IS NULL THEN 1 ELSE 0 END) AS end_station_id_null_count,
   SUM(CASE WHEN start_lat IS NULL THEN 1 ELSE 0 END) AS start_lat_null_count,
   SUM(CASE WHEN start_lng IS NULL THEN 1 ELSE 0 END) AS start_lng_null_count,
   SUM(CASE WHEN end_lat IS NULL THEN 1 ELSE 0 END) AS end_lat_null_count,
   SUM(CASE WHEN end_lng IS NULL THEN 1 ELSE 0 END) AS end_lng_null_count,
   SUM(CASE WHEN member_casual IS NULL THEN 1 ELSE 0 END) AS member_casual_null_count
FROM
    tripdata;

--create a backup before make any changes to our table
CREATE TABLE td_all AS
SELECT * FROM tripdata;

--create a temporary table
CREATE TABLE temp_table AS
SELECT DISTINCT ON (ride_id) *
FROM td_all
ORDER BY ride_id, ctid;
--check if temp_table has duplicates
SELECT ride_id, COUNT(*)
FROM temp_table
GROUP BY ride_id
HAVING COUNT(*) > 1;

--delete the original table td_all
DROP TABLE IF EXISTS td_all;
--rename the temporary table to the original table name
ALTER TABLE temp_table RENAME TO td_all;

--create a temporary table
CREATE TABLE temp_stat_table AS
SELECT DISTINCT ON (id) *
FROM stations
ORDER BY id, ctid;
--check if temp_stat_table has duplicates
SELECT id, COUNT(*)
FROM temp_stat_table
GROUP BY id
HAVING COUNT(*) > 1;

--delete the original table stations
DROP TABLE IF EXISTS stations;
--rename the temporary table to the original table name
ALTER TABLE temp_stat_table RENAME TO stations;

--check max dan min length of ride_id
SELECT 
 MAX(LENGTH (ride_id)) AS max_length,
 MIN(LENGTH (ride_id)) AS min_length
FROM
 td_all;

/* since some ride_id values are not 16 characters long, 
we'll append 'X' to those that don't meet the length requirement */
UPDATE td_all
SET ride_id = RPAD(ride_id, 16, 'X')
WHERE LENGTH(ride_id) < 16;

--check for ride_id length is not equal to 16
SELECT 
 *,
 LENGTH(ride_id)
FROM
 td_all
WHERE
 LENGTH(ride_id) <> 16;

--trim for td_all table
UPDATE td_all
SET
 ride_id = TRIM(ride_id),
 rideable_type= TRIM(rideable_type),
 start_station_name = TRIM(start_station_name),
 end_station_name = TRIM(end_station_name),
 start_station_id = TRIM(start_station_id),
 end_station_id = TRIM(end_station_id),
 member_casual = TRIM(member_casual);

--trim for stations table
UPDATE stations
SET
 id = TRIM(id),
 station_name = TRIM(station_name),
 short_name = TRIM(short_name),
 status = TRIM(status),
 loc = TRIM(loc);

--check the station name
SELECT DISTINCT 
  start_station_id, 
  start_station_name
FROM td_all
WHERE start_station_id IS NOT NULL AND start_station_name IS NOT NULL
ORDER BY start_station_name;

SELECT DISTINCT 
  end_station_id, 
  end_station_name
FROM td_all
WHERE end_station_id IS NOT NULL AND end_station_name IS NOT NULL
ORDER BY end_station_name;

--check the start_station_name with start_station_id = '410'
SELECT
 start_station_name,
 start_station_id
FROM
 td_all
WHERE
 start_station_id = '410';

--replace all station names with ID '410' with 'Campbell Ave & Augusta Blvd'
UPDATE
 td_all
SET
 start_station_name ='Campbell Ave & Augusta Blvd'
WHERE
 start_station_id='410' AND start_station_name='410';

UPDATE
 td_all
SET
 end_station_name ='Campbell Ave & Augusta Blvd'
WHERE
 end_station_id='410' AND end_station_name='410';

--check if station_id is unique
SELECT DISTINCT 
  start_station_id, 
  start_station_name
FROM td_all
WHERE start_station_id IS NOT NULL AND start_station_name IS NOT NULL
ORDER BY start_station_id;

SELECT DISTINCT 
  end_station_id, 
  end_station_name
FROM td_all
WHERE end_station_id IS NOT NULL AND end_station_name IS NOT NULL
ORDER BY end_station_id;

--check stations table
SELECT *
FROM
 stations;

--check if short_name is unique
SELECT 
 COUNT(*) as total_rows, 
 COUNT(DISTINCT id) AS id,
 COUNT(DISTINCT station_name) AS station_name,
 COUNT(DISTINCT short_name) AS short_name
FROM stations;

--drop column that are not used
ALTER TABLE td_all DROP COLUMN start_station_id;
ALTER TABLE td_all DROP COLUMN end_station_id;
ALTER TABLE stations DROP COLUMN id;
ALTER TABLE stations DROP COLUMN short_name;
ALTER TABLE stations DROP COLUMN total_docks;
ALTER TABLE stations DROP COLUMN docks_in_service;
ALTER TABLE stations DROP COLUMN status;

--create index for optimization operations
CREATE INDEX idx_td_all_start_lat_lng ON td_all (start_lat, start_lng);
CREATE INDEX idx_td_all_start_station_name ON td_all (start_station_name);
CREATE INDEX idx_stations_lat_lng ON stations (lat, lng);

--create temporary table to determine the distance
CREATE TEMPORARY TABLE NearestStartStationTemp AS
SELECT
    td.ctid AS td_ctid,
    s.station_name,
    6371 * 2 * ASIN(SQRT(
        POWER(SIN(RADIANS(s.lat - td.start_lat) / 2), 2) +
        COS(RADIANS(td.start_lat)) * COS(RADIANS(s.lat)) *
        POWER(SIN(RADIANS(s.lng - td.start_lng) / 2), 2)
    )) AS distance
FROM
    td_all td
JOIN
    stations s
ON
    td.start_station_name IS NULL;

--create index to enchance the operations
CREATE INDEX idx_nearest_start_station_temp ON NearestStartStationTemp (td_ctid, distance);

--calculating the minimum distance and then finding the closest station
WITH ClosestStation AS (
    SELECT
        ns.td_ctid,
        ns.station_name
    FROM
        NearestStartStationTemp ns
    JOIN (
        SELECT
            td_ctid,
            MIN(distance) AS min_distance
        FROM
            NearestStartStationTemp
        GROUP BY
            td_ctid
    ) md
    ON
        ns.td_ctid = md.td_ctid
        AND ns.distance = md.min_distance
)
UPDATE
    td_all
SET
    start_station_name = cs.station_name
FROM
    ClosestStation cs
WHERE
    td_all.ctid = cs.td_ctid
    AND td_all.start_station_name IS NULL;

--create index for optimization operations
CREATE INDEX idx_td_all_end_lat_lng ON td_all (end_lat, end_lng);
CREATE INDEX idx_td_all_end_station_name ON td_all (end_station_name);

--create temporary table to determine the distance
CREATE TEMPORARY TABLE NearestEndStationTemp AS
SELECT
    td.ctid AS td_ctid,
    s.station_name,
    6371 * 2 * ASIN(SQRT(
        POWER(SIN(RADIANS(s.lat - td.end_lat) / 2), 2) +
        COS(RADIANS(td.end_lat)) * COS(RADIANS(s.lat)) *
        POWER(SIN(RADIANS(s.lng - td.end_lng) / 2), 2)
    )) AS distance
FROM
    td_all td
JOIN
    stations s
ON
    td.end_station_name IS NULL;

--create index to enchance the operations
CREATE INDEX idx_nearest_end_station_temp ON NearestEndStationTemp (td_ctid, distance);

--calculating the minimum distance and then finding the closest station
WITH ClosestEndStation AS (
    SELECT
        ns.td_ctid,
        ns.station_name
    FROM
        NearestEndStationTemp ns
    JOIN (
        SELECT
            td_ctid,
            MIN(distance) AS min_distance
        FROM
            NearestEndStationTemp
        GROUP BY
            td_ctid
    ) md
    ON
        ns.td_ctid = md.td_ctid
        AND ns.distance = md.min_distance
)

--update start_station_name on td_all table
UPDATE
    td_all
SET
    end_station_name = cs.station_name
FROM
    ClosestEndStation cs
WHERE
    td_all.ctid = cs.td_ctid
    AND td_all.end_station_name IS NULL;

--update start_lng and start_lat
UPDATE td_all
SET
    start_lng = s1.lng,
    start_lat = s1.lat
FROM
    stations s1
WHERE
    td_all.start_station_name = s1.station_name;

--update end_lng and end_lat
UPDATE td_all
SET
    end_lng = s2.lng,
    end_lat = s2.lat
FROM
    stations s2
WHERE
    td_all.end_station_name = s2.station_name;

--check if there are still records that null
SELECT
 SUM(CASE WHEN start_station_name IS NULL THEN 1 ELSE 0 END) AS start_station_name_null_count,
 SUM(CASE WHEN end_station_name IS NULL THEN 1 ELSE 0 END) AS end_station_name_null_count,
 SUM(CASE WHEN start_lat IS NULL THEN 1 ELSE 0 END) AS start_lat_null_count,
 SUM(CASE WHEN start_lng IS NULL THEN 1 ELSE 0 END) AS start_lng_null_count,
 SUM(CASE WHEN end_lat IS NULL THEN 1 ELSE 0 END) AS end_lat_null_count,
 SUM(CASE WHEN end_lng IS NULL THEN 1 ELSE 0 END) AS end_lng_null_count
FROM
    td_all;

--fill the null values of end_lat and end_lng for the non-null end_station_name
UPDATE td_all
SET 
    end_lat = s.lat,
    end_lng = s.lng
FROM 
    stations s
WHERE 
    td_all.end_station_name = s.station_name
    AND td_all.end_lat IS NULL
    AND td_all.end_lng IS NULL;

--check if there are still records that null
SELECT
 SUM(CASE WHEN start_station_name IS NULL THEN 1 ELSE 0 END) AS start_station_name_null_count,
 SUM(CASE WHEN end_station_name IS NULL THEN 1 ELSE 0 END) AS end_station_name_null_count,
 SUM(CASE WHEN start_lat IS NULL THEN 1 ELSE 0 END) AS start_lat_null_count,
 SUM(CASE WHEN start_lng IS NULL THEN 1 ELSE 0 END) AS start_lng_null_count,
 SUM(CASE WHEN end_lat IS NULL THEN 1 ELSE 0 END) AS end_lat_null_count,
 SUM(CASE WHEN end_lng IS NULL THEN 1 ELSE 0 END) AS end_lng_null_count
FROM
    td_all;

/* check end_lat and end_lng that are null or have value of 0 
but end_station_name is not null */
SELECT 
 end_station_name,
 end_lat,
 end_lng
FROM td_all
WHERE (end_lat IS NULL OR end_lat = 0)
  AND (end_lng IS NULL OR end_lng = 0)
  AND (end_station_name IS NOT NULL);

--fill the null and zero (0) values of end_lat and end_lng
WITH station_coords AS (
    SELECT 
        end_station_name, 
        MAX(end_lat) AS end_lat, 
        MAX(end_lng) AS end_lng
    FROM 
        td_all
    WHERE 
        end_lat IS NOT NULL AND end_lat != 0
        AND end_lng IS NOT NULL AND end_lng != 0
    GROUP BY 
        end_station_name
)
UPDATE td_all
SET 
    end_lat = sc.end_lat,
    end_lng = sc.end_lng
FROM 
    station_coords sc
WHERE 
    td_all.end_station_name = sc.end_station_name
    AND (td_all.end_lat IS NULL OR td_all.end_lat = 0)
    AND (td_all.end_lng IS NULL OR td_all.end_lng = 0);

--fill end_station_name with 'Unaivailable'
UPDATE td_all
SET end_station_name='Unavailable'
WHERE end_station_name IS NULL AND
 end_lat IS NULL AND
 end_lng IS NULL;

--create ride_length column
ALTER TABLE td_all
ADD ride_length INT;

--filling in the ride_length column
UPDATE td_all
SET ride_length = EXTRACT(EPOCH FROM (ended_at - started_at)) / 60;

/* it is impossible for ride_legth to be negative (duration 
always positif). therefore, we need to check if there are 
any negative values in ride_length */

--check negative values in ride_length
SELECT *
FROM td_all 
WHERE ride_length <0;

--swapped started_at and ended_at
UPDATE td_all
SET started_at = new_started_at,
    ended_at = new_ended_at
FROM (
    SELECT
        ride_id,
        CASE WHEN started_at > ended_at THEN ended_at ELSE started_at END AS new_started_at,
        CASE WHEN started_at > ended_at THEN started_at ELSE ended_at END AS new_ended_at
    FROM td_all
    WHERE started_at > ended_at
) subquery
WHERE td_all.ride_id = subquery.ride_id;

--recalculate ride_length
UPDATE td_all
SET ride_length = EXTRACT(EPOCH FROM (ended_at - started_at)) / 60
WHERE ride_length < 0;

--check mix and max values of ride_length
SELECT 
    MAX(ride_length) AS max_ride_length,
    MIN(ride_length) AS min_ride_length
FROM td_all;

--create new table ride_length_outliers
CREATE TABLE ride_length_outliers AS
SELECT * FROM td_all
WHERE ride_length < 1 OR
      ride_length> 1440;
--delete outliers from td_all table
DELETE FROM td_all
WHERE ride_length < 1 OR
      ride_length> 1440;

--add column day_name
ALTER TABLE td_all
ADD day_name TEXT;

--set value of day_name
UPDATE td_all
SET day_name = TO_CHAR(started_at, 'Day');

--add column hour
ALTER TABLE td_all
ADD hour TEXT;

--set value of hour
UPDATE td_all
SET hour = CASE
    WHEN EXTRACT(HOUR FROM started_at) = 0 THEN '12 AM'
    WHEN EXTRACT(HOUR FROM started_at) = 12 THEN '12 PM'
    WHEN EXTRACT(HOUR FROM started_at) < 12 THEN CONCAT(EXTRACT(HOUR FROM started_at)::TEXT, ' AM')
    WHEN EXTRACT(HOUR FROM started_at) >= 13 THEN CONCAT((EXTRACT(HOUR FROM started_at) - 12)::TEXT, ' PM')
END;

--add colum day_period
ALTER TABLE td_all
ADD day_period TEXT;

--set value of day_period
UPDATE td_all
SET day_period = CASE
  WHEN EXTRACT(HOUR FROM started_at) >= 0 AND EXTRACT(HOUR FROM started_at) < 6 THEN 'Early Morning'
  WHEN EXTRACT(HOUR FROM started_at) >= 6 AND EXTRACT(HOUR FROM started_at) < 11 THEN 'Morning'
  WHEN EXTRACT(HOUR FROM started_at) >= 11 AND EXTRACT(HOUR FROM started_at) < 13 THEN 'Midday'
  WHEN EXTRACT(HOUR FROM started_at) >= 13 AND EXTRACT(HOUR FROM started_at) < 18 THEN 'Afternoon'
  WHEN EXTRACT(HOUR FROM started_at) >= 18 AND EXTRACT(HOUR FROM started_at) < 22 THEN 'Evening'
 ELSE 'Late Night'
END;

--add column month
ALTER TABLE td_all
ADD month TEXT;

--set value of column
UPDATE td_all
SET month = TO_CHAR(started_at, 'Month');

--add column season
ALTER TABLE td_all
ADD season TEXT;

--set value of season
UPDATE td_all
SET season = CASE
  WHEN EXTRACT(MONTH FROM started_at) IN (12,1,2) THEN 'Winter'
  WHEN EXTRACT(MONTH FROM started_at) IN (3,4,5) THEN 'Spring'
  WHEN EXTRACT(MONTH FROM started_at) IN (6,7,8) THEN 'Summer'
  WHEN EXTRACT(MONTH FROM started_at) IN (9,10,11) THEN 'Fall'
END;
