# Layoffs SQL Analysis

Analysis of global tech-sector layoff trends using PostgreSQL, covering the period from 2020 through early 2023. The work spans the full data pipeline — schema design, raw ingestion, a multi-step cleaning workflow, and exploratory analysis — all implemented purely in SQL.

---

## Overview

The tech industry shed hundreds of thousands of jobs in the post-pandemic correction. This project examines that data at scale: which companies cut deepest, which sectors were most exposed, how layoffs evolved month-over-month, and where geographically the impact concentrated. The analysis is designed to surface patterns that are meaningful to business stakeholders, not just data practitioners.

---

## Dataset

| Field | Type | Description |
|---|---|---|
| `company` | TEXT | Company name |
| `location` | TEXT | City |
| `industry` | TEXT | Sector |
| `total_laid_off` | INTEGER | Headcount reduction |
| `percentage_laid_off` | NUMERIC | Share of workforce |
| `date` | DATE | Announcement date |
| `stage` | TEXT | Funding stage at time of layoff |
| `country` | TEXT | Country |
| `funds_raised_millions` | NUMERIC | Total capital raised (USD) |

---

## Pipeline

### 1. Ingestion & Staging

Raw data is loaded into a `layoffs` and a working copy — `layoffs_staging` — is created before any modifications are made to the source data, preserving a clean rollback point throughout the cleaning process.

### 2. Data Cleaning

All transformations are applied to `layoffs_staging`. The cleaning sequence:

- **Deduplication** — duplicate records identified via `ROW_NUMBER()` partitioned across all meaningful columns; confirmed against source before deletion
- **Whitespace normalisation** — company names trimmed; count of distinct raw vs. trimmed values validated pre- and post-update
- **Industry standardisation** — free-text variants consolidated (e.g. `Crypto Currency`, `CryptoCurrency` → `Crypto`)
- **Location & country standardisation** — diacritic corrections (`Dusseldorf` → `Düsseldorf`, `Malmo` → `Malmö`) and trailing punctuation removed from country names
- **Date parsing & type casting** — `MM/DD/YYYY` strings converted to native `DATE` using `TO_DATE()`, followed by an `ALTER COLUMN` to enforce the correct type at the schema level
- **NULL imputation** — missing `industry` values back-filled via a self-join on `company` and `location`, where a non-null counterpart exists in the same dataset
- **Uninformative row removal** — records with both `total_laid_off` and `percentage_laid_off` null are dropped, as they carry no analytical value

### 3. Exploratory Analysis

Queries address the following:

- **Top affected companies** — ranked by total headcount reduction across the full dataset
- **Complete shutdowns** — companies reporting 100% workforce reduction, cross-referenced against funds raised to identify high-capital failures
- **Sector exposure** — aggregate layoffs by industry to identify which verticals contracted most sharply
- **Geographic distribution** — country-level totals highlighting where impact was most concentrated
- **Temporal trends** — year-over-year aggregation, and a month-by-month rolling total using `SUM() OVER (ORDER BY month)` to track cumulative scale
- **Funding stage analysis** — layoffs broken down by company maturity stage, from Seed through Post-IPO
- **Annual company rankings** — top 3 companies by layoffs for each calendar year, using `DENSE_RANK()` partitioned by year

---

## Stack

PostgreSQL · SQL (DDL, DML, window functions, CTEs)
