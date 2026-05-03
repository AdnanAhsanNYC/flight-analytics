SELECT
    flight_year,
    flight_month,
    flight_quarter,
    COUNT(*)                                        AS total_flights,
    SUM(CASE WHEN is_on_time THEN 1 ELSE 0 END)    AS on_time_flights,
    SUM(CASE WHEN is_cancelled THEN 1 ELSE 0 END)  AS cancelled_flights,
    ROUND(AVG(CASE WHEN is_on_time THEN 1.0
                   ELSE 0.0 END) * 100, 2)         AS on_time_rate_pct,
    ROUND(AVG(CASE WHEN is_cancelled THEN 1.0
                   ELSE 0.0 END) * 100, 2)         AS cancellation_rate_pct,
    ROUND(AVG(arr_delay), 2)                        AS avg_arr_delay_mins,
    SUM(total_delay_mins)                           AS total_delay_mins
FROM {{ ref('int_flights_enriched') }}
GROUP BY flight_year, flight_month, flight_quarter
ORDER BY flight_year, flight_month