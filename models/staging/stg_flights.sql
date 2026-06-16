SELECT
    FLIGHTDATE::DATE                                AS flight_date,
    REPORTING_AIRLINE                               AS airline,
    ORIGIN                                          AS origin_airport,
    ORIGINSTATENAME                                 AS origin_state,
    DEST                                            AS dest_airport,
    DESTSTATENAME                                   AS dest_state,
    DEPDELAY::FLOAT                                 AS dep_delay,
    ARRDELAY::FLOAT                                 AS arr_delay,
    CANCELLED = 1                                   AS is_cancelled,
    DIVERTED = 1                                    AS is_diverted,
    CARRIERDELAY::FLOAT                             AS carrier_delay,
    WEATHERDELAY::FLOAT                             AS weather_delay,
    NASDELAY::FLOAT                                 AS nas_delay,
    SECURITYDELAY::FLOAT                            AS security_delay,
    LATEAIRCRAFTDELAY::FLOAT                        AS late_aircraft_delay,
    DISTANCE::FLOAT                                 AS distance,
    AIRTIME::FLOAT                                  AS air_time,
    CRSDEPTIME::VARCHAR                             AS scheduled_dep_time,
    YEAR(FLIGHTDATE::DATE)                          AS flight_year,
    MONTH(FLIGHTDATE::DATE)                         AS flight_month,
    QUARTER(FLIGHTDATE::DATE)                       AS flight_quarter,
    CASE WHEN ARRDELAY::FLOAT > 15 
         THEN TRUE ELSE FALSE END                   AS is_delayed,
    CASE WHEN ARRDELAY::FLOAT <= 15
          AND CANCELLED = 0
         THEN TRUE ELSE FALSE END                   AS is_on_time
FROM {{ source('raw', 'flights') }}