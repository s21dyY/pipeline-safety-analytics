import sys
from pathlib import Path

import pandas as pd
from datetime import datetime, timezone

import os
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas
from cryptography.hazmat.primitives import serialization
# Read file
def read_source_file(path:Path) -> pd.DataFrame:
    sep = "\t" if path.suffix.lower() == ".txt" else ","
    return pd.read_csv(path, sep=sep, dtype=str, encoding="latin-1", low_memory=False)

# Initial Clean
def clean_column(df: pd.DataFrame) -> pd.DataFrame:
    clean = df.copy()
    clean.columns = ["".join(ch if ch.isalnum() else "_" for ch in col.strip()).upper() 
                     for col in clean.columns]
    return clean
def add_audit_col(df: pd.DataFrame, path: Path) -> pd.DataFrame:
    added = df.copy()
    added["_SOURCE_FILE"] = path.name
    added["_LOADED_AT"] = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")
    return added

# key loader
def load_private_key(path:str) -> bytes:
    with open(path, 'rb') as f:
        key = serialization.load_pem_private_key(f.read(), password=None)

    return key.private_bytes(
        encoding = serialization.Encoding.DER,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption(),
    )
def main():
    if len(sys.argv)!=3:
        sys.exit("Please use: python load_phmsa.py <file_path> <TABLE_NAME>")

    path = Path(sys.argv[1])
    table_name = sys.argv[2].upper()

    print(f"File path: {path.name}")
    print(f"Table name: {table_name}")

    df = read_source_file(path)
    df = clean_column(df)
    df = add_audit_col(df, path)

   
    conn = snowflake.connector.connect(
        account = os.environ["SNOWFLAKE_ACCOUNT"],
        user = "LOADER_USER",
        private_key = load_private_key(os.environ["SNOWFLAKE_LOADER_KEY_PATH"]),
        role = "LOADER",
        warehouse = "DBT_PIPELINE_WH",
        database = "RAW",
        sechma = "PHMSA" 
    )
    try:
        with conn.cursor() as cur:
            cur.execute("USE DATABASE RAW")
            cur.execute("USE SCHEMA PHMSA")

        success, nchunks, nrows, copy_results = write_pandas(
            conn, df, 
            table_name=table_name, 
            auto_create_table=True, 
            overwrite=True
        )

        if not success:
            sys.exit("Load failed") 
        print(f"Loaded {nrows:,} rows into RAW.PHMSA.{table_name}")     
    finally:
        conn.close()


if __name__ == "__main__":
    main()
   

