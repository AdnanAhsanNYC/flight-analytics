"""Export mart tables from DuckDB to Google Sheets."""
from pathlib import Path
import duckdb
import pandas as pd
import gspread
import os
import json
from google.oauth2.service_account import Credentials

PROJECT_ROOT = Path(__file__).resolve().parent.parent
DUCKDB_PATH = PROJECT_ROOT / "data" / "flights.duckdb"
KEY_FILE = PROJECT_ROOT / "flight-analytics-499622-5f8207a26720.json"

# Your Google Sheet name — must match exactly
SHEET_NAME = "Flight Analytics Dashboard"

MARTS = {
    "mart_airline_performance": "SELECT * FROM main.mart_airline_performance",
    "mart_airport_performance": "SELECT * FROM main.mart_airport_performance",
    "mart_delay_causes":        "SELECT * FROM main.mart_delay_causes",
    "mart_monthly_trends":      "SELECT * FROM main.mart_monthly_trends",
    "mart_yoy_changes":         "SELECT * FROM main.mart_yoy_changes",
    "mart_route_performance":   "SELECT * FROM main.mart_route_performance",
}



def get_sheet_client():
    scopes = [
        "https://www.googleapis.com/auth/spreadsheets",
        "https://www.googleapis.com/auth/drive",
    ]
    # Use env var in CI, fall back to local file for development
    env_json = os.environ.get("GOOGLE_SERVICE_ACCOUNT_JSON")
    if env_json:
        info = json.loads(env_json)
        creds = Credentials.from_service_account_info(info, scopes=scopes)
    else:
        creds = Credentials.from_service_account_file(str(KEY_FILE), scopes=scopes)
    return gspread.authorize(creds)

def export_mart(worksheet, df):
    worksheet.clear()
    import numpy as np
    # Clean NaN and inf BEFORE converting to string
    df = df.replace([np.inf, -np.inf], np.nan)
    df = df.where(pd.notnull(df), None)
    data = [df.columns.tolist()] + [[None if v is None else str(v) for v in row] for row in df.values.tolist()]
    worksheet.update(data)
    print(f"  wrote {len(df)} rows")

def main():
    con = duckdb.connect(str(DUCKDB_PATH), read_only=True)
    client = get_sheet_client()
    spreadsheet = client.open(SHEET_NAME)

    for tab_name, query in MARTS.items():
        print(f"Exporting {tab_name}...")
        df = con.execute(query).df()
        try:
            worksheet = spreadsheet.worksheet(tab_name)
        except gspread.exceptions.WorksheetNotFound:
            worksheet = spreadsheet.add_worksheet(tab_name, rows=len(df)+1, cols=len(df.columns))
        export_mart(worksheet, df)

    con.close()
    print("\nAll marts exported to Google Sheets.")

if __name__ == "__main__":
    main()



