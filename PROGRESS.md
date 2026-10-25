# Project progress checkpoint

Last updated: 2026-10-25

## Completed

- Built an end-to-end Olist e-commerce pipeline with Docker Compose, PostgreSQL 17, Airflow 3.3.1, dbt Core 1.10.22, dbt-postgres 1.10.2, and Metabase.
- Added Python ingestion for all nine source CSVs. It validates required files and headers, then uses PostgreSQL COPY inside a transaction to refresh the selected raw tables.
- Added 20 dbt models across staging, facts, dimensions, and reporting marts. The marts cover monthly sales, delivery performance by state, product performance, payment mix, and category review scores.
- Added 35 dbt data-quality checks for required identifiers and reporting dimensions.
- Added a GitHub Actions workflow that builds the pipeline on the synthetic sample data.
- Initialized a local Git repository on branch main and committed the project. The local .env and full data files are excluded by .gitignore.
- Published the project to https://github.com/Pranav-Prakash-Patil/ecommerce-data-pipeline and pushed the main branch.
- Added scripts/download_olist.ps1 for retrieving and checking the public source dataset from Kaggle.
- Completed and saved the Metabase connection, Orders by status question, and E-commerce Operations Dashboard in Our analytics.
- Configured persistent Docker volumes for PostgreSQL data, Metabase state, and Airflow metadata/auth files.

## Verified local run

- Airflow, PostgreSQL, and Metabase are currently running at http://localhost:8080, localhost:5432, and http://localhost:3000.
- The Airflow DAG olist_ecommerce_pipeline is enabled and has a successful recorded run: manual__2026-10-25T15:05:42.536886+00:00.
- That successful run ingested all nine synthetic source tables (22 total rows), then built all 20 dbt models and passed all 35 checks: 55 total dbt build results, with no failures.
- The sample data is intentionally small and synthetic. The project is currently configured to use it so the pipeline works immediately after startup.
- The Metabase dashboard and saved questions persist in the metabase-data volume. The dashboard currently reflects the synthetic sample tables.
- The first GitHub Actions run can be checked in the repository's Actions tab; local sample pipeline execution is already verified above.

## Full Olist dataset

- Download the nine real CSV files with scripts/download_olist.ps1, following the Kaggle attribution and license terms described in README.md.
- After downloading, set OLIST_DATA_DIR=/opt/airflow/data/raw in .env and recreate only the Airflow service with docker compose up -d --force-recreate airflow.
- Trigger olist_ecommerce_pipeline in Airflow. The existing dbt model names are stable, so Metabase can continue using the same warehouse connection and saved questions.
- A full-data transfer was attempted but the network repeatedly throttled or interrupted the source archive. Incomplete download files were removed; data/raw contains no CSVs. No full-data run has been claimed.

## Useful commands

- Start or resume services: docker compose up -d
- Check services: docker compose ps
- Trigger the pipeline: docker compose exec -T airflow airflow dags trigger olist_ecommerce_pipeline
- List successful runs: docker compose exec -T airflow airflow dags list-runs olist_ecommerce_pipeline --state success
- Open Airflow: http://localhost:8080
- Open Metabase: http://localhost:3000
- Stop services and preserve stored data: docker compose down

Do not use docker compose down -v unless you intend to delete the PostgreSQL, Metabase, and Airflow named volumes.
