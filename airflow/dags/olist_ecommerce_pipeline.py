"""Airflow workflow for loading and transforming the Olist dataset."""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

import pendulum
from airflow.sdk import dag, task


PROJECT_ROOT = Path("/opt/airflow")
DBT_LOG_PATH = Path("/opt/airflow/logs/dbt")
DBT_TARGET_PATH = Path("/opt/airflow/logs/dbt-target")


@dag(
    dag_id="olist_ecommerce_pipeline",
    description="Load Olist CSV files into PostgreSQL and build dbt analytics models.",
    schedule=None,
    start_date=pendulum.datetime(2024, 1, 1, tz="UTC"),
    catchup=False,
    default_args={"owner": "pranav", "retries": 1},
    tags=["ecommerce", "olist", "portfolio"],
)
def olist_ecommerce_pipeline():
    @task
    def load_raw_data() -> None:
        data_dir = os.environ.get("OLIST_DATA_DIR", "/opt/airflow/data/sample")
        script_path = PROJECT_ROOT / "scripts" / "ingest_olist.py"
        subprocess.run(
            [sys.executable, str(script_path), "--data-dir", data_dir],
            check=True,
            cwd=PROJECT_ROOT,
        )

    @task
    def build_analytics_models() -> None:
        dbt_project = PROJECT_ROOT / "dbt"
        subprocess.run(
            [
                "dbt",
                "build",
                "--project-dir",
                str(dbt_project),
                "--profiles-dir",
                str(dbt_project),
                "--log-path",
                str(DBT_LOG_PATH),
                "--target-path",
                str(DBT_TARGET_PATH),
            ],
            check=True,
            cwd=dbt_project,
        )

    load_raw_data() >> build_analytics_models()


olist_ecommerce_pipeline()
