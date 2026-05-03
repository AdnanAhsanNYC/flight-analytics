SELECT
    airline,
    flight_year,
    COUNT(*)                                        AS total_flights,
    SUM(CASE WHEN is_on_time THEN 1 ELSE 0 END)    AS on_time_flights,
    SUM(CASE WHEN is_cancelled THEN 1 ELSE 0 END)  AS cancelled_flights,
    ROUND(AVG(CASE WHEN is_on_time THEN 1.0 
                   ELSE 0.0 END) * 100, 2)         AS on_time_rate_pct,
    ROUND(AVG(CASE WHEN is_cancelled THEN 1.0 
                   ELSE 0.0 END) * 100, 2)         AS cancellation_rate_pct,
    ROUND(AVG(arr_delay), 2)                        AS avg_arr_delay_mins,
    ROUND(AVG(CASE WHEN is_delayed 
              THEN arr_delay END), 2)               AS avg_delay_when_delayed,
    ROUND(AVG(NULLIF(carrier_delay, 0)), 2)         AS avg_carrier_delay_mins,
    ROUND(AVG(NULLIF(weather_delay, 0)), 2)         AS avg_weather_delay_mins
FROM {{ ref('int_flights_enriched') }}
GROUP BY airline, flight_year
ORDER BY flight_year, on_time_rate_pct ASC