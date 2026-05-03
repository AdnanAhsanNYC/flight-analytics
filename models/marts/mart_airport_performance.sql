SELECT
    origin_airport                                  AS airport_code,
    origin_airport_name                             AS airport_name,
    origin_state,
    AVG(origin_latitude)                            AS latitude,
    AVG(origin_longitude)                           AS longitude,
    flight_year,
    COUNT(*)                                        AS total_departures,
    ROUND(AVG(CASE WHEN is_on_time THEN 1.0
                   ELSE 0.0 END) * 100, 2)         AS on_time_rate_pct,
    ROUND(AVG(CASE WHEN is_cancelled THEN 1.0
                   ELSE 0.0 END) * 100, 2)         AS cancellation_rate_pct,
    ROUND(AVG(dep_delay), 2)                        AS avg_dep_delay_mins,
    ROUND(AVG(distance), 2)                         AS avg_distance
FROM {{ ref('int_flights_enriched') }}
GROUP BY origin_airport, origin_airport_name, origin_state, flight_year
ORDER BY flight_year, cancellation_rate_pct DESC