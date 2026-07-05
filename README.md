# Retail Analytics Case Study - SQL

## Overview
This project is a SQL-driven analysis of retail sales data, built to simulate a real-world business analytics workflow — from raw data ingestion to actionable insight. Using MySQL, the project loads three separate datasets, validates data quality, and runs a series of analytical queries to answer core retail business questions: which products perform best, how customers behave over time, and how revenue trends month to month.

The goal isn't just to write queries — it's to demonstrate the kind of SQL reasoning a retail analytics team would actually use: ranking, cohort-style segmentation, and time-series comparison, not just basic SELECTs.

##  🎯 Problem Statement
Retail businesses generate large volumes of transactional data but often lack visibility into:
- Which products and categories drive the most revenue
- Whether customers are one-time buyers or repeat purchasers
- How revenue is trending month over month
- Which customer segments are most valuable

This project answers those questions directly from raw CSV data using pure SQL — no BI tool, no external analytics layer.

## 🗂️ Datasets

| File | Description |
|---|---|
| `customer_profiles.csv` | Customer ID, Age, Gender, Location, Join Date |
| `sales_transaction.csv` | Transaction ID, Customer ID, Product ID, Quantity, Date, Price |
| `product_inventory.csv` | Product ID, Name, Category, Stock Level, Price |

## 🎯 Approach

1. **Database & Schema Setup**
   Created a dedicated database (`customer_profile_data`) and three normalized tables, then loaded the CSVs via `LOAD DATA LOCAL INFILE`.

2. **Data Quality Checks**
   Ran null-value checks across all three tables before analysis, to avoid drawing conclusions from incomplete records.

3. **Exploratory Data Analysis (EDA)**
   - **Product performance:** total transactions, quantity sold, revenue, and average selling price per product
   - **Category performance:** revenue and volume aggregated by product category
   - **Customer purchase frequency:** average orders per customer, segmented by gender
   - **Product ranking:** used `DENSE_RANK()` to rank products by quantity sold, surfacing top and bottom performers
   - **Month-over-month growth:** used `LAG()` to compute revenue change percentage between consecutive months
   - **Customer segmentation:** bucketed customers into Low / Mid / High value tiers based on order count
   - **Repeat purchase analysis:** calculated the share of one-time vs. repeat buyers

##  🔧 Tech Stack
- **MySQL** — window functions (`DENSE_RANK()`, `LAG()`), CTEs (`WITH`)

## 🧠 Key Insight Areas
- Top and bottom performing products/categories
- Revenue growth trajectory over time
- Customer value distribution (who to retain vs. who's low-engagement)
- Repeat purchase rate as a proxy for customer loyalty

## ▶️ How to Run
1. Set up a local MySQL instance and enable `local_infile`.
2. Update the file paths in the `LOAD DATA LOCAL INFILE` statements to match your local file system.
3. Execute `customer_profiles.sql` in order — it creates the schema, loads data, and runs the analysis queries sequentially.

## Limitations / Next Steps
- File paths are currently hardcoded to a local system; converting to relative paths or parameterizing them would make the project portable for anyone cloning the repo.
- No visualization layer — results are query outputs only. A natural extension would be connecting this to Tableau/Power BI or a Python notebook for charting.
- Segmentation thresholds (Low/Mid/High) are currently fixed values — worth stating explicitly in the README what those cutoffs are, since that's a judgment call, not a derived metric.

## 🙋‍♂️ Author
**Prajapati Hirilal**
- GitHub: [@your-username](https://github.com/hiri2007)
- LinkedIn: [your-linkedin](https://www.linkedin.com/in/hirilal-prajapati-a06963378/)
