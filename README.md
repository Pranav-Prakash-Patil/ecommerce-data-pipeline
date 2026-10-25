# E-commerce Data Pipeline

An end-to-end data engineering portfolio project built around the Brazilian E-Commerce Public Dataset by Olist. The pipeline turns source CSV files into a documented analytics warehouse for orders, customers, products, sellers, payments, and delivery performance.

The public source dataset is available on [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). The repository will contain only a tiny, clearly synthetic sample for local development; download the original files from Kaggle for real analysis.

## Project modules

1. **Source data** — Olist CSV files, with a small synthetic sample for development.
2. **Python ingestion** — validate expected files and headers, then load source rows into PostgreSQL's `raw` schema. Each ingestion is a repeatable full refresh of the selected raw tables.
3. **Warehouse** — PostgreSQL schemas for raw input and dbt-managed analytics models.
4. **Transformations** — dbt SQL models that clean source columns and build order, customer, product, seller, payment, review, and delivery reporting tables.
5. **Data quality** — ingestion safeguards for required inputs and headers, plus dbt `not_null` and `unique` checks on key identifiers and reporting dimensions.
6. **Orchestration** — Apache Airflow runs ingestion and dbt in sequence and records task logs and retries.
7. **Analytics** — Metabase charts and dashboards, with a starter order-status chart already saved.
8. **Project delivery** — Docker Compose for local services, Git/GitHub for version control, and GitHub Actions for sample-pipeline CI.

## Technology stack

| Area | Technology |
| --- | --- |
| Ingestion | Python 3.12, standard library CSV tools, psycopg 3 |
| Warehouse | PostgreSQL |
| Transformations | SQL, dbt Core, dbt-postgres |
| Orchestration | Apache Airflow |
| Dashboards | Metabase |
| Local environment | Docker Desktop, Docker Compose |
| Version control and delivery | Git, GitHub, GitHub Actions |

The local sample pipeline includes all nine source tables. It builds 20 dbt models and runs 35 data-quality checks. The synthetic sample validates the workflow; use the full Olist data for meaningful analysis.

## Run the local pipeline

### 1. Get the dataset

Download the Olist dataset from Kaggle into `data/raw/` with the helper script:

```powershell
py -3.12 -m pip install --user kaggle
.\scripts\download_olist.ps1
```

The public dataset download works without authentication. Kaggle lists it as 45 MB with nine CSV files. It is licensed CC BY-NC-SA 4.0; attribute Olist and follow the noncommercial and share-alike terms when distributing derived work. See the [Olist dataset page](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

The helper checks for these nine files:

- `olist_orders_dataset.csv`
- `olist_order_items_dataset.csv`
- `olist_customers_dataset.csv`
- `olist_geolocation_dataset.csv`
- `olist_products_dataset.csv`
- `olist_sellers_dataset.csv`
- `olist_order_payments_dataset.csv`
- `olist_order_reviews_dataset.csv`
- `product_category_name_translation.csv`

Do not commit the downloaded files. The repository's `.gitignore` excludes `data/raw/` contents.

### 2. Prepare Python

```powershell
cd ecommerce-data-pipeline
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
```

### 3. Start the local services

Install Docker Desktop, then run:

```powershell
if (!(Test-Path .env)) { Copy-Item .env.example .env }
docker compose up -d --build
```

This starts PostgreSQL, Airflow, and Metabase. Airflow runs in standalone mode for local learning; PostgreSQL stores the project warehouse.

If the Airflow build cannot reach `pypi.org` from Docker, build it with an accessible package index first, then start the services:

```powershell
docker compose build --build-arg PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple airflow
docker compose up -d
```

### 4. Run ingestion directly (optional)

To run the Python loader directly on Windows, set `DATABASE_URL` to the local database, then run:

```powershell
$env:DATABASE_URL = "postgresql://ecommerce:ecommerce@localhost:5432/ecommerce"
python scripts/ingest_olist.py --data-dir data/sample
```

Use `data/raw` instead of `data/sample` after downloading the source dataset.

For the Airflow workflow, change `OLIST_DATA_DIR` in `.env` to `/opt/airflow/data/raw`, then run `docker compose up -d --force-recreate airflow`.

The loader replaces each selected raw table inside a database transaction. It does not append a duplicate copy when rerun. All raw columns are initially stored as text; type casting and business logic belong in the dbt transformation layer.

### 5. Run and inspect the pipeline in Airflow

1. Open <http://localhost:8080> and sign in with the local Airflow account. On a fresh setup, read the generated credentials from the mounted Airflow volume with:

   ```powershell
   docker compose exec airflow cat /opt/airflow/logs/simple_auth_manager_passwords.json.generated
   ```

   Keep that output private. This project stores Airflow metadata and its local auth file in the persistent `airflow-logs` volume.
2. Open **Dags**, find `olist_ecommerce_pipeline`, and use its **Trigger Dag** action.
3. Choose **Single Run**, then **Trigger**. Open the new run and confirm both `load_raw_data` and `build_analytics_models` are green/successful.

The first task validates the input CSVs and refreshes nine raw PostgreSQL tables. The second runs `dbt build`, which creates staging models, facts, dimensions, and analytics marts, then runs the data-quality checks. The synthetic sample is only a workflow demonstration, not meaningful business data.

### 6. Explore the warehouse in Metabase

Metabase is available at <http://localhost:3000>. Its initial setup and PostgreSQL connection are complete for this local project. The saved database is **E-commerce Warehouse**; inside the Docker network it connects to host `postgres`, port `5432`, database `ecommerce`.

The starter dashboard **E-commerce Operations Dashboard** is saved in **Our analytics** and contains **Orders by status**, a bar chart counting `fct_orders` by `order_status`. The analytics schema also includes `mart_monthly_sales`, `mart_delivery_performance_by_state`, `mart_product_performance`, `mart_payment_mix`, and `mart_category_review_scores`. To add a chart, browse **E-commerce Warehouse → analytics**, open a model, use **Summarize** and **Group by**, then save the question and add it to the dashboard.

### 7. Start and stop the local services

From the project folder, run `docker compose up -d` to start the containers after a computer restart. Run `docker compose ps` to check their status. Open Airflow at <http://localhost:8080> and Metabase at <http://localhost:3000>. Use `docker compose down` to stop the services; this preserves the database volume. Avoid `docker compose down -v` unless you intend to delete the local database and Metabase data.

## Planned analytics

- Gross sales and order count by day, month, product category, and seller.
- Average delivery time and on-time delivery rate.
- Cancellation and order-status trends.
- Payment type and installment patterns.
- Customer and seller geographic summaries.

## Publish the project to GitHub

This project is tracked locally on the `main` branch and includes a GitHub Actions workflow. To publish it, create an empty GitHub repository, then add it as the remote and push:

```powershell
git remote add origin https://github.com/<YOUR_USERNAME>/ecommerce-data-pipeline.git
git push -u origin main
```

The `.gitignore` excludes `.env` and files under `data/raw/`; keep it that way. Do not upload local credentials or the downloaded source data.

## Repository layout

```text
ecommerce-data-pipeline/
├── data/
│   ├── raw/                 # Downloaded source files (ignored by Git)
│   └── sample/              # Tiny synthetic inputs for development
├── airflow/
│   └── dags/
├── dbt/
│   ├── models/
│   ├── dbt_project.yml
│   └── profiles.yml
├── docker/
│   └── airflow/
├── scripts/
│   └── ingest_olist.py
├── docker-compose.yml
├── README.md
└── requirements.txt
```
