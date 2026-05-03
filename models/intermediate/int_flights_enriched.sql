WITH base AS (
    SELECT * FROM {{ ref('stg_flights') }}
),

airlines AS (
    SELECT * FROM {{ ref('stg_airline_lookup') }}
),

airports_origin AS (
    SELECT * FROM {{ ref('stg_airport_lookup') }}
),

airports_dest AS (
    SELECT * FROM {{ ref('stg_airport_lookup') }}
)

SELECT
    base.*,
    COALESCE(airlines.airline_name, base.airline)      AS airline_full_name,
    COALESCE(airports_origin.airport_name, base.origin_airport) AS origin_airport_name,
    airports_origin.latitude                            AS origin_latitude,
    airports_origin.longitude                           AS origin_longitude,
    COALESCE(airports_dest.airport_name, base.dest_airport) AS dest_airport_name,

    COALESCE(base.carrier_delay, 0) +
    COALESCE(base.weather_delay, 0) +
    COALESCE(base.nas_delay, 0) +
    COALESCE(base.security_delay, 0) +
    COALESCE(base.late_aircraft_delay, 0)               AS total_delay_mins,

    CASE
        WHEN COALESCE(base.carrier_delay, 0) = GREATEST(
            COALESCE(base.carrier_delay, 0),
            COALESCE(base.weather_delay, 0),
            COALESCE(base.nas_delay, 0),
            COALESCE(base.security_delay, 0),
            COALESCE(base.late_aircraft_delay, 0))
             AND COALESCE(base.carrier_delay, 0) > 0
            THEN 'Carrier'
        WHEN COALESCE(base.weather_delay, 0) = GREATEST(
            COALESCE(base.carrier_delay, 0),
            COALESCE(base.weather_delay, 0),
            COALESCE(base.nas_delay, 0),
            COALESCE(base.security_delay, 0),
            COALESCE(base.late_aircraft_delay, 0))
             AND COALESCE(base.weather_delay, 0) > 0
            THEN 'Weather'
        WHEN COALESCE(base.nas_delay, 0) = GREATEST(
            COALESCE(base.carrier_delay, 0),
            COALESCE(base.weather_delay, 0),
            COALESCE(base.nas_delay, 0),
            COALESCE(base.security_delay, 0),
            COALESCE(base.late_aircraft_delay, 0))
             AND COALESCE(base.nas_delay, 0) > 0
            THEN 'NAS'
        WHEN COALESCE(base.late_aircraft_delay, 0) = GREATEST(
            COALESCE(base.carrier_delay, 0),
            COALESCE(base.weather_delay, 0),
            COALESCE(base.nas_delay, 0),
            COALESCE(base.security_delay, 0),
            COALESCE(base.late_aircraft_delay, 0))
             AND COALESCE(base.late_aircraft_delay, 0) > 0
            THEN 'Late Aircraft'
        WHEN COALESCE(base.security_delay, 0) > 0
            THEN 'Security'
        ELSE 'None'
    END                                                 AS primary_delay_cause,

    CASE
        WHEN base.is_cancelled THEN 'Cancelled'
        WHEN base.arr_delay <= 0 THEN 'Early'
        WHEN base.arr_delay <= 15 THEN 'On Time'
        WHEN base.arr_delay <= 30 THEN 'Minor (1-30 min)'
        WHEN base.arr_delay <= 60 THEN 'Moderate (31-60 min)'
        ELSE 'Severe (60+ min)'
    END                                                 AS delay_bucket

FROM base
LEFT JOIN airlines ON base.airline = airlines.airline_code
LEFT JOIN airports_origin ON base.origin_airport = airports_origin.airport_code
LEFT JOIN airports_dest ON base.dest_airport = airports_dest.airport_code
WHERE base.is_diverted = FALSE