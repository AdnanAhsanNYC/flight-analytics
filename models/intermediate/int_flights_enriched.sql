WITH base AS (
    SELECT * FROM {{ ref('stg_flights') }}
)

SELECT
    *,
    COALESCE(carrier_delay, 0) +
    COALESCE(weather_delay, 0) +
    COALESCE(nas_delay, 0) +
    COALESCE(security_delay, 0) +
    COALESCE(late_aircraft_delay, 0)                AS total_delay_mins,

    CASE
        WHEN COALESCE(carrier_delay, 0) = GREATEST(
            COALESCE(carrier_delay, 0),
            COALESCE(weather_delay, 0),
            COALESCE(nas_delay, 0),
            COALESCE(security_delay, 0),
            COALESCE(late_aircraft_delay, 0)) 
             AND COALESCE(carrier_delay, 0) > 0
            THEN 'Carrier'
        WHEN COALESCE(weather_delay, 0) = GREATEST(
            COALESCE(carrier_delay, 0),
            COALESCE(weather_delay, 0),
            COALESCE(nas_delay, 0),
            COALESCE(security_delay, 0),
            COALESCE(late_aircraft_delay, 0))
             AND COALESCE(weather_delay, 0) > 0
            THEN 'Weather'
        WHEN COALESCE(nas_delay, 0) = GREATEST(
            COALESCE(carrier_delay, 0),
            COALESCE(weather_delay, 0),
            COALESCE(nas_delay, 0),
            COALESCE(security_delay, 0),
            COALESCE(late_aircraft_delay, 0))
             AND COALESCE(nas_delay, 0) > 0
            THEN 'NAS'
        WHEN COALESCE(late_aircraft_delay, 0) = GREATEST(
            COALESCE(carrier_delay, 0),
            COALESCE(weather_delay, 0),
            COALESCE(nas_delay, 0),
            COALESCE(security_delay, 0),
            COALESCE(late_aircraft_delay, 0))
             AND COALESCE(late_aircraft_delay, 0) > 0
            THEN 'Late Aircraft'
        WHEN COALESCE(security_delay, 0) > 0
            THEN 'Security'
        ELSE 'None'
    END                                             AS primary_delay_cause,

    CASE
        WHEN is_cancelled THEN 'Cancelled'
        WHEN arr_delay <= 0 THEN 'Early'
        WHEN arr_delay <= 15 THEN 'On Time'
        WHEN arr_delay <= 30 THEN 'Minor (1-30 min)'
        WHEN arr_delay <= 60 THEN 'Moderate (31-60 min)'
        ELSE 'Severe (60+ min)'
    END                                             AS delay_bucket

FROM base
WHERE is_diverted = FALSE