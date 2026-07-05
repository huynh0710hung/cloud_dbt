# E-Commerce Analytics Pipeline (cloud_dbt)

An end-to-end data engineering project that ingests raw e-commerce event data from Kaggle, transforms it through a layered dbt pipeline on BigQuery, and serves insights through a Looker Studio dashboard.

**Dashboard:** [Looker Studio →](https://datastudio.google.com/s/vaDlraNu_jw)

---

## Tech Stack

| Layer | Tool |
|---|---|
| Ingestion | Python + Kaggle API + PyArrow |
| Storage | BigQuery + Parquet |
| Transformation | dbt-core + dbt-bigquery |

---

## Architecture

```
Kaggle (CSV zip)
      │
      ▼
kaggle_to_parquet.py          # stream CSV → Parquet (zstd compressed)
      │
      ▼
data.parquet → BigQuery (raw)
      │
      ▼ dbt run
┌─────────────────────────────────────────┐
│  STAGING (view)                         │
│  stg_events         stg_purchases       │
└─────────────┬───────────────────────────┘
              │
┌─────────────▼───────────────────────────┐
│  TRANSFORM (table)                      │
│  dim_users      dim_products            │
│  dim_categories dim_dates               │
│  fact_events                            │
└─────────────┬───────────────────────────┘
              │
┌─────────────▼───────────────────────────┐
│  DATAMART (table)                       │
│  dm_daily_summary   dm_funnel_analysis  │
│  dm_funnel_summary  dm_brand_performance│
│  dm_product_performance                 │
│  dm_category_analysis                   │
│  dm_customer_rfm    dm_customer_ltv     │
│  dm_user_cohort     dm_behavior_by_hour │
└─────────────────────────────────────────┘
              │
              ▼
       Looker Studio
```

---

## Datamarts

| Model | Description |
|---|---|
| `dm_daily_summary` | Day-level traffic and revenue metrics |
| `dm_funnel_analysis` | Per-product funnel: views → cart → purchase |
| `dm_funnel_summary` | Aggregate funnel stage totals |
| `dm_product_performance` | Revenue, conversion rate, and order count by product |
| `dm_category_analysis` | Performance breakdown by category |
| `dm_brand_performance` | Revenue and conversion metrics by brand |
| `dm_customer_rfm` | Customer segmentation: Champions / Loyal / At Risk / Lost |
| `dm_customer_ltv` | Estimated lifetime value per user |
| `dm_user_cohort` | Cohort retention analysis |
| `dm_behavior_by_hour` | Shopping behaviour by hour of day |

---

## Quickstart

**1. Clone and install dependencies**
```bash
git clone https://github.com/huynh0710hung/cloud_dbt
cd cloud_dbt
pip install kaggle pyarrow dbt-bigquery
```

**2. Configure credentials**

- Kaggle: place `kaggle.json` at `~/.kaggle/kaggle.json`
- BigQuery: configure `~/.dbt/profiles.yml` with profile name `cloud_dbt`

**3. Ingest data**
```bash
python ingestion/kaggle_to_parquet.py
```
Downloads `2019-Oct.csv` from the [eCommerce behavior dataset](https://www.kaggle.com/datasets/mkechinov/ecommerce-behavior-data-from-multi-category-store), streams it to `data.parquet`, and uploads to BigQuery.

**4. Install dbt packages**
```bash
cd dbt
dbt deps
```

**5. Run the pipeline**
```bash
dbt run
```

**6. Run data quality tests**
```bash
dbt test
```

**7. Explore lineage and docs**
```bash
dbt docs generate && dbt docs serve
# Open http://localhost:8080
```

---

## Project Structure

```
cloud_dbt/
├── ingestion/
│   └── kaggle_to_parquet.py   # Download Kaggle dataset → Parquet
└── dbt/
    ├── models/
    │   ├── staging/            # Raw source → cast, rename, filter
    │   ├── transform/          # Dimensions + fact table
    │   └── datamart/           # Analytics-ready aggregates
    ├── dbt_project.yml
    └── packages.yml
```
