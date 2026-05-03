SELECT
    AIRPORT_CODE    AS airport_code,
    AIRPORT_NAME    AS airport_name,
    CITY            AS city,
    LATITUDE        AS latitude,
    LONGITUDE       AS longitude
FROM {{ source('raw', 'AIRPORT_LOOKUP') }}