# E-Commerce Customer & Sales Analysis Using SQL

## Project Overview

This project uses SQLite SQL to analyse transaction-level e-commerce data and answer practical business questions around revenue, customer value, product performance, repeat purchasing and customer recency.

Python/Pandas is used to load the Excel source into SQLite and display results, while the core analysis is performed in SQL.

## Business Questions

1. What are the key sales KPIs?
2. Which countries generate the most revenue?
3. Who are the highest-value and most frequent customers?
4. How does revenue change over time?
5. Which products generate the most revenue and unit volume?
6. What proportion of customers are repeat buyers?
7. Which customers are active, at risk or inactive?
8. Which valuable customers should be prioritised for retention?

## Tools & Skills

- SQLite / SQL
- Python
- Pandas
- Matplotlib
- Google Colab
- Aggregations and filtering
- CTEs
- `CASE WHEN`
- `HAVING`
- Window functions: `RANK()` and `LAG()`
- `INNER JOIN`
- Date analysis with `strftime()` and `julianday()`

## Dataset

The project uses the **UCI Online Retail** dataset, containing transaction records for a UK-based online retailer.

Source: https://archive.ics.uci.edu/dataset/352/online+retail

The raw dataset contains **541,909 rows**. After excluding missing customer IDs, cancellations, non-positive quantities and non-positive prices, the analysis-ready table contains **397,884 rows**.

## Key KPIs

| KPI | Result |
|---|---:|
| Total Revenue | £8,911,407.90 |
| Total Orders | 18,532 |
| Total Customers | 4,338 |
| Total Units Sold | 5,167,812 |
| Average Order Value | £480.87 |

## Key Findings

- The **United Kingdom generated about 82% of cleaned revenue**, making the business highly concentrated in its home market.
- Some customers create value through **very large orders**, while others create value through **high purchase frequency**.
- Revenue accelerated strongly from **September through November 2011**, with November the strongest complete month at about **£1.16 million**.
- Product revenue and sales volume do not always move together; revenue-per-unit helps explain the difference.
- Approximately **65.58% of identified customers were repeat buyers**.
- Only **20 customers (about 0.46%)** were classified as High Value using the project thresholds, yet they generated about **23.9% of cleaned revenue**.
- Recency analysis identified **1,222 At Risk** and **1,449 Inactive** customers.
- Combining recency, frequency and monetary value helps identify valuable customers who may deserve retention attention.

## Business Recommendations

1. Prioritise high-value repeat customers for retention and relationship management.
2. Create re-engagement campaigns for valuable customers classified as At Risk or Inactive.
3. Investigate growth opportunities in strong non-UK markets to reduce geographic concentration.
4. Evaluate customer value using both order frequency and order size.
5. Compare product revenue, unit volume and revenue-per-unit instead of relying on one measure.
6. Extend the analysis into formal RFM scoring or cohort analysis.

## Repository Structure

```text
ecommerce-customer-analysis-sql/
├── data/
│   └── Online Retail.xlsx
├── ecommerce_sql_analysis.ipynb
├── ecommerce_analysis.sql
└── README.md
```

## Files

- `ecommerce_sql_analysis.ipynb` — complete analysis with SQL outputs, explanations and one supporting chart
- `ecommerce_analysis.sql` — standalone, commented SQL queries
- `data/Online Retail.xlsx` — source dataset
- `README.md` — project summary and findings

## Limitations

- Value and recency thresholds are project-defined and not universal business standards.
- The dataset covers approximately one year, limiting long-term seasonality analysis.
- December 2011 is incomplete and is excluded from full-month comparisons.
- Operational descriptions such as `POSTAGE` and `Manual` appear in the product field and may need further cleaning.
- The analysis is descriptive and does not establish causality or predict future behaviour.
