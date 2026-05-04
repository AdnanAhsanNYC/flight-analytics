WITH yearly AS (
    SELECT
        airline_full_name                               AS airline,
        flight_year,
        COUNT(*)                                        AS total_flights,
        ROUND(AVG(CASE WHEN is_on_time THEN 1.0
                       ELSE 0.0 END) * 100, 2)         AS on_time_rate_pct,
        ROUND(AVG(CASE WHEN is_cancelled THEN 1.0
                       ELSE 0.0 END) * 100, 2)         AS cancellation_rate_pct,
        ROUND(AVG(arr_delay), 2)                        AS avg_arr_delay_mins
    FROM {{ ref('int_flights_enriched') }}
    GROUP BY airline_full_name, flight_year
),

yoy AS (
    SELECT
        airline,
        flight_year,
        total_flights,
        on_time_rate_pct,
        cancellation_rate_pct,
        avg_arr_delay_mins,
        LAG(on_time_rate_pct) OVER (
            PARTITION BY airline ORDER BY flight_year
        )                                               AS prev_year_on_time_rate,
        LAG(avg_arr_delay_mins) OVER (
            PARTITION BY airline ORDER BY flight_year
        )                                               AS prev_year_avg_delay,
        LAG(total_flights) OVER (
            PARTITION BY airline ORDER BY flight_year
        )                                               AS prev_year_total_flights
    FROM yearly
)

SELECT
    *,
    ROUND(on_time_rate_pct - prev_year_on_time_rate, 2)         AS yoy_on_time_rate_change,
    ROUND(avg_arr_delay_mins - prev_year_avg_delay, 2)          AS yoy_delay_change_mins,
    ROUND((total_flights - prev_year_total_flights) 
          / NULLIF(prev_year_total_flights, 0) * 100, 2)        AS yoy_flight_volume_pct_change
FROM yoy
ORDER BY airline, flight_year