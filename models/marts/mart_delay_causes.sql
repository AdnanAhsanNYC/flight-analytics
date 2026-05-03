SELECT
    flight_year,
    flight_month,
    primary_delay_cause,
    COUNT(*)                                        AS total_flights,
    SUM(total_delay_mins)                           AS total_delay_mins,
    ROUND(AVG(total_delay_mins), 2)                 AS avg_delay_mins,
    SUM(carrier_delay)                              AS total_carrier_delay_mins,
    SUM(weather_delay)                              AS total_weather_delay_mins,
    SUM(nas_delay)                                  AS total_nas_delay_mins,
    SUM(late_aircraft_delay)                        AS total_late_aircraft_delay_mins,
    SUM(security_delay)                             AS total_security_delay_mins
FROM {{ ref('int_flights_enriched') }}
WHERE primary_delay_cause != 'None'
GROUP BY flight_year, flight_month, primary_delay_cause
ORDER BY flight_year, flight_month