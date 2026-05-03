# US Flight Delay Analytics Pipeline

An end-to-end analytics engineering project analyzing 55M+ US domestic flights 
from 2016 to 2026 using Python, Snowflake, dbt Cloud, and Looker Studio.

## Live Dashboard
[View on Looker Studio](https://datastudio.google.com/reporting/3760834f-c80e-4fb3-a6ac-4873a1f6c7cb/page/NB2wF)

![Dashboard Preview](outputs/dFlight_Delay_Dashboard.png)

## Problem Statement
US airline on-time performance has been declining despite record passenger volumes. 
This project builds a production-style ELT pipeline to identify which airlines, 
airports, and delay causes are driving performance trends — and how COVID reshaped 
air travel from 2020 through recovery.

## Stack
| Layer | Tool |
|-------|------|
| Ingestion | Python (requests, pandas, snowflake-connector) |
| Data Warehouse | Snowflake |
| Transformation | dbt Cloud |
| Visualization | Looker Studio |
| Version Control | Git / GitHub |

## Pipeline Architecture
BTS API → Python → Snowflake (RAW) → dbt Cloud → Snowflake (DBT_DEV) → Looker Studio

## Project Structure
```
flight-analytics/
├── models/
│   ├── staging/          ← stg_flights, stg_airline_lookup, stg_airport_lookup
│   ├── intermediate/     ← int_flights_enriched (joins + business logic)
│   └── marts/            ← airline performance, airport performance, delay causes, monthly trends
├── notebooks/            ← Python ingestion scripts
├── data/clean/           ← exported mart CSVs for Looker Studio
└── outputs/              ← dashboard screenshots
```

## dbt Models
| Model | Layer | Description |
|-------|-------|-------------|
| stg_flights | Staging | Cleans raw BTS data, casts types, adds delay flags |
| stg_airline_lookup | Staging | Maps airline codes to full names |
| stg_airport_lookup | Staging | Maps airport codes to full names and coordinates |
| int_flights_enriched | Intermediate | Joins lookups, adds delay buckets and primary cause |
| mart_airline_performance | Mart | On-time rate and delay metrics by airline and year |
| mart_airport_performance | Mart | Departure performance and cancellation rate by airport |
| mart_delay_causes | Mart | Delay minute breakdown by cause type and month |
| mart_monthly_trends | Mart | Monthly flight volume and on-time rate time series |

## dbt Tests
- 18 tests passing across all models
- not_null, accepted_values, and unique constraints enforced

## Key Findings
1. **COVID collapsed air travel by 37% in 2020** — monthly flights dropped from 
   620k to 180k at the lowest point in May 2020
2. **Southwest Airlines December 2022 meltdown** is clearly visible as a spike 
   in cancellation rate
3. **Carrier delays account for the largest share** of total delay minutes 
   across all years — airlines are more responsible for delays than weather or the FAA
4. **West Virginia has the highest average departure delay** of any state 
   despite having low total flight volume

## Data Source
- **Provider:** Bureau of Transportation Statistics (BTS)
- **Dataset:** Airline On-Time Performance Data
- **Link:** https://www.transtats.bts.gov
- **Period:** January 2016 — January 2026
- **Scale:** 55M+ flight records across 18 columns

## Data Dictionary
| Column | Description |
|--------|-------------|
| flight_date | Date of the flight |
| airline | Reporting airline code |
| airline_full_name | Full airline name from lookup |
| origin_airport | Origin airport code |
| origin_airport_name | Full airport name from lookup |
| origin_state | Departure state |
| arr_delay | Arrival delay in minutes (negative = early) |
| dep_delay | Departure delay in minutes |
| is_cancelled | Boolean flag for cancelled flights |
| is_delayed | Boolean flag for arr_delay > 15 mins |
| carrier_delay | Minutes attributable to airline |
| weather_delay | Minutes attributable to weather |
| nas_delay | Minutes attributable to FAA/air traffic |
| late_aircraft_delay | Minutes from cascading prior flight delay |
| primary_delay_cause | Largest single delay cause for that flight |
| delay_bucket | Categorical: Early / On Time / Minor / Moderate / Severe |
