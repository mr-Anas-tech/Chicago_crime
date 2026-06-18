
# Chicago Crime Data Analytics Pipeline (Analytics engineering  & data  analysis project)

This repository contains an enterprise-grade data transformation pipeline built using dbt (data build tool) and Google BigQuery. The project ingests raw, historical crime event logs from the city of Chicago, transforms them using analytical modeling layers, and prepares downstream datasets for advanced analysis in Python and Power BI.

---

## 1. Project Architecture Overview

The data pipeline strictly adheres to the **Medallion Architecture (Bronze -> Silver -> Gold)** to separate data cleaning, business logic application, and dimensional modeling:

1. **Source Layer (Bronze / Raw Ingestion):** Pulls the unrefined public crime dataset directly from Google BigQuery public data: `bigquery-public-data.chicago_crime.crime`.
2. **Staging Layer (Silver / Data Cleansing):** Managed via `stg_crime.sql`. This layer handles explicit type casting, sanitizes structural records, and utilizes conditional `coalesce` mappings to replace null values with standard fallbacks.
3. **Intermediate Layer (Silver / Transformation):** Managed via `int_chicago_crime.sql`. It centralizes complex calculations, extracts contextual date/time granular components, and translates text-based conditional flags into structured analytical metrics.
4. **Marts Layer (Gold / Presentation Layer):** Consolidated analytical views and tables exposing star schema entities:
   - `dim_chicago_crime_location`: A dimensional entity capturing distinct, unique block-level geographic details.
   - `dim_chicago_crime_type`: A classification entity containing deduplicated crime classification mappings (`iucr_code`).
   - `fct_chicago_crime`: The core transactional fact table capturing metric parameters, location pointers, and operational timestamps.

---

## 2. Comprehensive Layer-wise Code Breakdown

### A. Data Sources & Source Control (`chicago_crime.yml`)
- **Database Asset:** `bigquery-public-data`
- **Schema Boundary:** `chicago_crime`
- **Identified Table Object:** `crime`
- **Data Freshness and Ingestion Triggers:**
  - `loaded_at_field`: Tracked natively via the `updated_on` column.
  - `warn_after`: Set to 2 days (flags system warnings if upstream data stops populating).
  - `error_after`: Set to 3 days (triggers critical build failures if ingestion lags past thresholds).<img width="1787" height="663" alt="Screenshot 2026-06-18 103458" src="https://github.com/user-attachments/assets/56b045f7-2078-4280-9711-e08c1cda0d0b" />



### B. Staging Layer Model (`stg_crime.sql`)
This model parses, casts, and sanitizes fields to protect down-stream assets from unexpected null breaks or string formatting errors:
- **Primary Key Ingestion:** Standardized utilizing `coalesce(cast(unique_key as string), '0') as crime_id`.
- **String Field Sanitization:** Replaces null attributes with uniform missing values, such as converting blank descriptions via `coalesce(block, 'Unknown')`.
- **Temporal Component Split:** Extracts native calendar entities through expressions like `extract(date from timestamp(...)) as crime_date`.
- **Spatial Protection:** Employs `safe_cast(x_coordinate as float64)` to bypass runtime compilation crashes from corrupted spatial coordinate values.

### C. Intermediate Layer Model (`int_chicago_crime.sql`)
Acts as the central operational hub for calculating calculated data attributes and business logic rules:
- **Time Window Segmentation:** Extracts chronological attributes from core timestamps:
  - `extract(hour from crime_time) as crime_hour`
  - `extract(day from crime_date) as crime_day`
  - `extract(dayofweek from crime_date) as crime_week_days`
  - `extract(month from crime_date) as crime_month`
- **Operational Efficiency Metric:** Generates the audit lag between actual occurrence and database integration:
  - `datetime_diff(cast(report_updated_on as datetime), cast(crime_date as datetime), day) as report_latency_days`
- **Binary Normalization:** Standardizes string fields like `is_arrest` and `is_domestic` into predictable binary outputs (`1` for true, `0` for false, and `null` fallback).

### D. Analytical Marts Layer (Gold Models)

#### 1. Location Dimension (`dim_chicago_crime_location.sql`)
Materialized as a view to supply clean location metadata. It deduplicates multiple identical blocks using analytical window configurations:
```sql
row_number() over (partition by block order by crime_beat desc) as rn
where rn = 1

```
#### 2. Crime Type Classification Dimension (dim_chicago_crime_type.sql)
Extracts categorical details based on unique FBI and IUCR codes, making sure that dimensions maintain strict semantic grains for clean dashboard aggregation mapping:
```sql
row_number() over (partition by iucr_code order by fct_code) as rn
where rn = 1

```
#### 3. Crime Transactions Fact Table & BigQuery Joining Logic (fct_chicago_crime.sql)
In the final presentation layer inside Google BigQuery, the final analytical dataset is successfully compiled by implementing structured **Left Joins**. The central transactional facts are joined with the location and crime type dimensions using specialized left join relations to preserve the integrity of every logged crime event entry.
## 3. Downstream Processing & Advanced Data Analytics
Once the robust transformation workflow is completed inside Google BigQuery via dbt modeling layers, the curated data is dispatched for deep-dive analytics:
 1. **Python Data Science Workflow:** The fully modeled, high-quality analytical datasets are exported and loaded into Python data ecosystems (Pandas, NumPy, and Plotly) for intensive programmatic exploratory data analysis (EDA), pattern discovery, and statistical analytics.
 2. **Power BI Dashboards:** The curated star-schema models are seamlessly connected to Power BI to build highly dynamic, real-time, interactive security and executive operational dashboards to track crime spikes, report latency anomalies, and regional safety trends.
## 4. Execution & Testing Strategy
To guarantee strict compliance with data quality SLAs, schema testing assertions are declared within marts.yml:
 1. **Primary Key Assertions:** crime_id is verified under unique and not_null assertions to confirm no double counting or orphan rows bypass the modeling layer.
 2. **Execution Command Matrix:**
   * To build the complete repository architecture end-to-end:
```bash
     dbt build
     ```
- To run data freshness tests against upstream BigQuery datasets:
```bash
     dbt source freshness
     ```


```
