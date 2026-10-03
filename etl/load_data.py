import os
import pandas as pd
from sqlalchemy import create_engine

db_name = os.getenv("POSTGRES_DB")
db_user = os.getenv("POSTGRES_USER")
db_password = os.getenv("POSTGRES_PASSWORD")
db_host = os.getenv("POSTGRES_HOST")
db_port = os.getenv("POSTGRES_PORT")

engine = create_engine(
    f"postgresql+psycopg2://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"
)

def load_table(table_name):
    file_path = f'retail_data_generator/output/{table_name}.csv'

    print(f"Loading data from {file_path} into {table_name} table...")

    df = pd.read_csv(file_path)

    print(f"Rows read from CSV: {len(df)}")

    df.to_sql(
        table_name,
        engine,
        if_exists='append',
        index=False
    )

    print(f"Data loaded into {table_name} table.")

tables = [
    "product_categories",
    "aisles",
    "customers",
    "suppliers",
    "products",
    "promotions",
    "promotion_items",
    "supplier_products",
    "orders",
    "order_items",
    "payments",
    "supplier_deliveries",
    "returns",
]

for table in tables:
    load_table(table)