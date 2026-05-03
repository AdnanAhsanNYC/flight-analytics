SELECT
    CARRIER_CODE    AS airline_code,
    AIRLINE_NAME    AS airline_name
FROM {{ source('raw', 'AIRLINE_LOOKUP') }}