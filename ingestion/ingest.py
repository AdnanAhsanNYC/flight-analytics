"""Headless ingestion for the flight analytics pipeline.
Downloads BTS on-time performance data into a local DuckDB file.
Run from anywhere with: python ingestion/ingest.py
"""
from pathlib import Path
from datetime import date
import io, zipfile, time
import requests, pandas as pd, duckdb

# Paths resolve relative to THIS file, never the working directory
PROJECT_ROOT = Path(__file__).resolve().parent.parent
DUCKDB_PATH = PROJECT_ROOT / "data" / "flights.duckdb"
DUCKDB_PATH.parent.mkdir(parents=True, exist_ok=True)

# Rolling 10-year window. Shrink this for a quick local test (see note below).
CURRENT_YEAR = date.today().year
START_YEAR = CURRENT_YEAR - 1          # 10 calendar years inclusive

COLUMNS = [
    "FlightDate", "Reporting_Airline", "Origin", "OriginStateName",
    "Dest", "DestStateName", "DepDelay", "ArrDelay", "Cancelled",
    "Diverted", "CarrierDelay", "WeatherDelay", "NASDelay",
    "SecurityDelay", "LateAircraftDelay", "Distance", "AirTime", "CRSDepTime",
]
BTS_URL = ("https://transtats.bts.gov/PREZIP/"
           "On_Time_Reporting_Carrier_On_Time_Performance_1987_present_{y}_{m}.zip")

def setup_tables(con):
    con.execute("CREATE SCHEMA IF NOT EXISTS raw")
    con.execute("""
        CREATE OR REPLACE TABLE raw.flights (
            FLIGHTDATE VARCHAR, REPORTING_AIRLINE VARCHAR, ORIGIN VARCHAR,
            ORIGINSTATENAME VARCHAR, DEST VARCHAR, DESTSTATENAME VARCHAR,
            DEPDELAY DOUBLE, ARRDELAY DOUBLE, CANCELLED DOUBLE, DIVERTED DOUBLE,
            CARRIERDELAY DOUBLE, WEATHERDELAY DOUBLE, NASDELAY DOUBLE,
            SECURITYDELAY DOUBLE, LATEAIRCRAFTDELAY DOUBLE, DISTANCE DOUBLE,
            AIRTIME DOUBLE, CRSDEPTIME VARCHAR
        )
    """)

def load_month(con, year, month):
    url = BTS_URL.format(y=year, m=month)
    r = requests.get(url, timeout=120)
    if r.status_code != 200:
        print(f"  skip {year}-{month:02d}: HTTP {r.status_code}")
        return 0
    try:
        with zipfile.ZipFile(io.BytesIO(r.content)) as z:
            with z.open(z.namelist()[0]) as f:
                df = pd.read_csv(f, usecols=COLUMNS, encoding="latin1")
    except zipfile.BadZipFile:
        print(f"  skip {year}-{month:02d}: no data yet")
        return 0
    df.columns = [c.upper() for c in df.columns]
    con.execute("INSERT INTO raw.flights BY NAME SELECT * FROM df")
    return len(df)

def load_lookups(con):
    airlines = {
        'AA':'American Airlines','DL':'Delta Air Lines','UA':'United Airlines',
        'WN':'Southwest Airlines','B6':'JetBlue Airways','AS':'Alaska Airlines',
        'NK':'Spirit Airlines','F9':'Frontier Airlines','G4':'Allegiant Air',
        'HA':'Hawaiian Airlines','OO':'SkyWest Airlines','YX':'Republic Airways',
        'OH':'PSA Airlines','YV':'Mesa Airlines','EV':'ExpressJet Airlines',
        'QX':'Horizon Air','PT':'Piedmont Airlines','9E':'Endeavor Air','G7':'GoJet Airlines'
    }
    df_air = pd.DataFrame(list(airlines.items()), columns=["CARRIER_CODE","AIRLINE_NAME"])
    con.execute("CREATE OR REPLACE TABLE raw.airline_lookup AS SELECT * FROM df_air")

    cols = ['airport_id','name','city','country','iata','icao','lat','lon',
            'alt','tz','dst','tzdb','type','source']
    raw = requests.get("https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat").text
    ap = pd.read_csv(io.StringIO(raw), header=None, names=cols)
    ap = ap[(ap.country=="United States") & (ap.iata!="\\N") & (ap.iata.str.len()==3)]
    df_ap = ap[['iata','name','city','lat','lon']].copy()
    df_ap.columns = ["AIRPORT_CODE","AIRPORT_NAME","CITY","LATITUDE","LONGITUDE"]
    con.execute("CREATE OR REPLACE TABLE raw.airport_lookup AS SELECT * FROM df_ap")

def main():
    con = duckdb.connect(str(DUCKDB_PATH))
    setup_tables(con)
    total = 0
    for year in range(START_YEAR, CURRENT_YEAR + 1):
        for month in range(1, 13):
            n = load_month(con, year, month)
            total += n
            if n: print(f"  loaded {year}-{month:02d}: {n:,} (total {total:,})")
            time.sleep(1)
    load_lookups(con)
    print(f"\nDone. {total:,} flight rows in {DUCKDB_PATH}")
    con.close()

if __name__ == "__main__":
    main()
