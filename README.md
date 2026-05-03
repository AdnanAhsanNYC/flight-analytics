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
