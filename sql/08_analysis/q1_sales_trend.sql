/* =============================================================================
   08_analysis / q1_sales_trend.sql
   Purpose : Q1 - How are sales trending by month, territory, account type, product and therapeutic area?
   Source  : warehouse.*, mart.*
   -------------------------------------------------------------------------
   Result (as of 2026-06-29)
     Total Sales 2023-01-01 to 2026-06-29 = $482.2M; flat year on year (~$138M/yr); North 41.9 % of sales.
   Read with
     docs/06_insights_and_recommendations.md
   ============================================================================= */


SELECT
	d.year, d.month,
	f.territory,
	a.account_type,
	p.therapeutic_area,
	SUM(f.sales_amount) AS total_sales,
	SUM(f.quantity) AS total_quantity,
	AVG(f.unit_price) AS avg_unit_price
FROM warehouse.fact_sales AS f
JOIN warehouse.dim_date AS d ON f.date_key = d.date_key
JOIN warehouse.dim_account AS a ON f.account_key = a.account_key
JOIN warehouse.dim_product AS p ON f.product_key = p.product_key
WHERE f.negative_quantity_flag = 0      -- same exclusion as the Total Sales measure (Business Rule 6)
  AND f.non_positive_price_flag = 0
  AND d.full_date <= '2026-06-29'       -- as-of date, same as the report filter
GROUP BY d.year, d.month, f.territory, a.account_type, p.therapeutic_area
ORDER BY d.year, d.month;
