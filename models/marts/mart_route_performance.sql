SELECT
    origin_airport                                      AS origin_code,
    origin_airport_name                                 AS origin_name,
    origin_state,
    dest_airport                                        AS dest_code,
    dest_airport_name                                   AS dest_name,
    flight_year,
    COUNT(*)                                            AS total_flights,
    ROUND(AVG(CASE WHEN is_on_time THEN 1.0
                   ELSE 0.0 END) * 100, 2)             AS on_time_rate_pct,
    ROUND(AVG(CASE WHEN is_cancelled THEN 1.0
                   ELSE 0.0 END) * 100, 2)             AS cancellation_rate_pct,
    ROUND(AVG(arr_delay), 2)                            AS avg_arr_delay_mins,
    ROUND(AVG(dep_delay), 2)                            AS avg_dep_delay_mins,
    ROUND(AVG(distance), 2)                             AS avg_distance_miles
FROM {{ ref('int_flights_enriched') }}
GROUP BY
    origin_airport, origin_airport_name, origin_state,
    dest_airport, dest_airport_name, flight_year
HAVING total_flights >= 100
ORDER BY total_flights DESC