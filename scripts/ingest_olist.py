"""Load selected Olist CSV files into PostgreSQL raw tables."""

from __future__ import annotations

import argparse
import csv
import logging
import os
import re
import sys
from pathlib import Path

import psycopg
from psycopg import sql


REQUIRED_FILES = (
    "olist_customers_dataset.csv",
    "olist_geolocation_dataset.csv",
    "olist_orders_dataset.csv",
    "olist_order_items_dataset.csv",
    "olist_order_payments_dataset.csv",
    "olist_order_reviews_dataset.csv",
    "olist_products_dataset.csv",
    "olist_sellers_dataset.csv",
    "product_category_name_translation.csv",
)
IDENTIFIER_PATTERN = re.compile(r"[^a-zA-Z0-9_]+")
LOGGER = logging.getLogger("olist_ingestion")


def normalize_identifier(value: str) -> str:
    """Convert a CSV heading into a safe PostgreSQL identifier."""
    identifier = IDENTIFIER_PATTERN.sub("_", value.strip()).strip("_").lower()
    if not identifier:
        raise ValueError(f"CSV heading {value!r} becomes an empty column name")
    if identifier[0].isdigit():
        identifier = f"_{identifier}"
    return identifier


def read_headers(csv_path: Path) -> list[str]:
    with csv_path.open("r", encoding="utf-8-sig", newline="") as source:
        header = next(csv.reader(source), None)

    if not header:
        raise ValueError(f"CSV file has no header row: {csv_path}")

    columns = [normalize_identifier(name) for name in header]
    if len(columns) != len(set(columns)):
        raise ValueError(f"CSV file has duplicate headings after normalization: {csv_path}")
    return columns


def copy_csv_to_table(
    connection: psycopg.Connection,
    csv_path: Path,
    schema_name: str,
    table_name: str,
) -> int:
    columns = read_headers(csv_path)
    schema_identifier = sql.Identifier(schema_name)
    table_identifier = sql.Identifier(table_name)
    column_identifiers = sql.SQL(", ").join(sql.Identifier(name) for name in columns)
    qualified_table = sql.SQL("{}.{}").format(schema_identifier, table_identifier)

    with connection.cursor() as cursor:
        cursor.execute(sql.SQL("CREATE SCHEMA IF NOT EXISTS {}").format(schema_identifier))
        column_definitions = sql.SQL(", ").join(
            sql.SQL("{} TEXT").format(sql.Identifier(name)) for name in columns
        )
        cursor.execute(
            sql.SQL("CREATE TABLE IF NOT EXISTS {} ({})").format(
                qualified_table, column_definitions
            )
        )

        cursor.execute(
            """
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = %s AND table_name = %s
            ORDER BY ordinal_position
            """,
            (schema_name, table_name),
        )
        existing_columns = [row[0] for row in cursor.fetchall()]
        if existing_columns != columns:
            raise ValueError(
                f"Column mismatch for {schema_name}.{table_name}. "
                f"Expected {existing_columns}, received {columns}. "
                "Keep the source schema stable or migrate the raw table explicitly."
            )

        cursor.execute(sql.SQL("TRUNCATE TABLE {}").format(qualified_table))

        copy_statement = sql.SQL(
            "COPY {} ({}) FROM STDIN WITH (FORMAT CSV, HEADER TRUE)"
        ).format(qualified_table, column_identifiers)
        with csv_path.open("r", encoding="utf-8-sig", newline="") as source:
            with cursor.copy(copy_statement) as copy:
                while chunk := source.read(1024 * 1024):
                    copy.write(chunk)

        cursor.execute(sql.SQL("SELECT COUNT(*) FROM {}").format(qualified_table))
        row_count = cursor.fetchone()[0]

    LOGGER.info("Loaded %s rows into %s.%s", row_count, schema_name, table_name)
    return row_count


def ingest(data_dir: Path, database_url: str, schema_name: str) -> dict[str, int]:
    missing_files = [name for name in REQUIRED_FILES if not (data_dir / name).is_file()]
    if missing_files:
        missing_list = "\n  - ".join(missing_files)
        raise FileNotFoundError(
            f"Missing required Olist CSV file(s) in {data_dir}:\n  - {missing_list}"
        )

    counts: dict[str, int] = {}
    with psycopg.connect(database_url) as connection:
        for file_name in REQUIRED_FILES:
            csv_path = data_dir / file_name
            table_name = file_name.removesuffix(".csv")
            counts[table_name] = copy_csv_to_table(
                connection=connection,
                csv_path=csv_path,
                schema_name=schema_name,
                table_name=table_name,
            )
    return counts


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Load Olist source CSVs into PostgreSQL raw tables."
    )
    parser.add_argument(
        "--data-dir",
        type=Path,
        default=Path("data/raw"),
        help="Folder containing the required Olist CSV files (default: data/raw).",
    )
    parser.add_argument(
        "--schema",
        default="raw",
        help="PostgreSQL schema to load into (default: raw).",
    )
    return parser.parse_args()


def main() -> int:
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    args = parse_args()
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        LOGGER.error("DATABASE_URL is not set. See the README for an example.")
        return 2

    try:
        counts = ingest(args.data_dir, database_url, args.schema)
    except (FileNotFoundError, ValueError, psycopg.Error) as error:
        LOGGER.error("Ingestion failed: %s", error)
        return 1

    total_rows = sum(counts.values())
    LOGGER.info("Ingestion complete: %s tables, %s total rows", len(counts), total_rows)
    return 0


if __name__ == "__main__":
    sys.exit(main())
