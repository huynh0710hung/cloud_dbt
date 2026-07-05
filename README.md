# cloud_dbt

An end-to-end e-commerce analytics pipeline that ingests raw event data from Kaggle, transforms it with dbt on BigQuery, and serves insights through a Looker Studio dashboard.

## Dashboard

[Looker Studio Dashboard](https://datastudio.google.com/s/vaDlraNu_jw)

## Architecture

```
Kaggle Dataset → Parquet → BigQuery (raw) → dbt (staging / transform / datamart) → Looker Studio
```

## Data Source

[eCommerce behavior data from multi-category store](https://www.kaggle.com/datasets/mkechinov/ecommerce-behavior-data-from-multi-category-store) — user event logs (view, cart, purchase) from a large online store.

## Project Structure

```
├── ingestion/
│   └── kaggle_to_parquet.py   # Downloads Kaggle dataset and converts CSVs to Parquet
└── dbt/
    └── models/
        ├── staging/            # Raw source cleaning (events, purchases)
        ├── transform/          # Dimensional model (users, products, categories, dates, fact_events)
        └── datamart/           # Analytics-ready marts
```

### dbt Datamart Models

| Model | Description |
|---|---|
| `dm_daily_summary` | Day-level traffic and revenue metrics |
| `dm_funnel_analysis` | Per-product funnel: views → cart → purchase |
| `dm_funnel_summary` | Aggregate funnel stage totals |
| `dm_product_performance` | Revenue, conversion rate, and order count by product |
| `dm_category_analysis` | Performance breakdown by category |
| `dm_brand_performance` | Revenue and conversion metrics by brand |
| `dm_customer_rfm` | RFM (Recency, Frequency, Monetary) segmentation |
| `dm_customer_ltv` | Customer lifetime value |
| `dm_user_cohort` | Cohort retention analysis |
| `dm_behavior_by_hour` | Event volume by hour of day |

## Setup

### 1. Ingestion

Install dependencies and configure Kaggle credentials (`~/.kaggle/kaggle.json`), then run:

```bash
pip install kaggle pyarrow
python ingestion/kaggle_to_parquet.py
```

This downloads `2019-Oct.csv` from the Kaggle dataset, streams it into `data.parquet`, and cleans up the zip.

### 2. dbt

```bash
cd dbt
pip install dbt-bigquery
dbt deps
dbt run
dbt test
```

Configure your BigQuery connection in `~/.dbt/profiles.yml` using the profile name `cloud_dbt`.
