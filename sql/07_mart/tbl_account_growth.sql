/* =============================================================================
   07_mart / tbl_account_growth.sql
   Purpose : Turn Q2 into one label per entity
   Source  : fact_sales
   Target  : mart.tbl_account_growth
   -------------------------------------------------------------------------
   Logic (verified row by row against the tables in powerbi/HCP_Analytics.pbix)
     current = sales in the 90 days up to the as-of date: date > 2026-06-29 - 90 and <= 2026-06-29
     prior   = the 90 days before that
     sales exclude negative quantity and non-positive price (same as the Total Sales measure)
     tiers   = 33rd / 67th percentile of growth
   Output
     growth_tier: Growing / Stable / Declining / New / Inactive
   ============================================================================= */

-- ============================================================
-- BUILD
-- ============================================================


DROP TABLE IF EXISTS mart.tbl_account_growth;


WITH periods AS (
	SELECT
		f.account_key,
		SUM(CASE WHEN d.full_date >  DATEADD(DAY, -90, '2026-06-29') AND d.full_date <= '2026-06-29'
		         THEN f.sales_amount ELSE 0 END) AS current_period_sales,
		SUM(CASE WHEN d.full_date >  DATEADD(DAY, -180, '2026-06-29') AND d.full_date <= DATEADD(DAY, -90, '2026-06-29')
		         THEN f.sales_amount ELSE 0 END) AS prior_period_sales
	FROM warehouse.fact_sales AS f
	JOIN warehouse.dim_date AS d ON f.date_key = d.date_key
	WHERE f.negative_quantity_flag = 0 AND f.non_positive_price_flag = 0   -- Business Rule 6
	GROUP BY f.account_key
),
with_growth AS (
	SELECT *,
		CASE WHEN prior_period_sales > 0 THEN (current_period_sales - prior_period_sales) * 100.0 / prior_period_sales END AS growth_pct
	FROM periods
),
with_pctile AS (
	SELECT *,
		PERCENTILE_CONT(0.33) WITHIN GROUP (ORDER BY growth_pct) OVER () AS p33,
		PERCENTILE_CONT(0.67) WITHIN GROUP (ORDER BY growth_pct) OVER () AS p67
	FROM with_growth
	WHERE growth_pct IS NOT NULL
)
SELECT
	account_key, current_period_sales, prior_period_sales, growth_pct,
	CASE WHEN growth_pct < p33 THEN 'Declining'
		WHEN growth_pct > p67 THEN 'Growing'
		ELSE 'Stable' END AS growth_tier
INTO mart.tbl_account_growth
FROM with_pctile
UNION ALL
SELECT account_key, current_period_sales, prior_period_sales, NULL,
	CASE WHEN prior_period_sales = 0 AND current_period_sales > 0 THEN 'New' ELSE 'Inactive' END
FROM with_growth WHERE prior_period_sales = 0;


-- ============================================================
-- THRESHOLD ANALYSIS - run after the build to review the percentile cut-offs
-- (p33 / p67 split the entities into three equal-sized tiers)
-- ============================================================
 


WITH stats AS (
	SELECT
		growth_pct,
		MIN(growth_pct) OVER () AS min_val,
		PERCENTILE_CONT(0.33) WITHIN GROUP (ORDER BY growth_pct) OVER() AS p33,
		PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY growth_pct) OVER() AS median,
		PERCENTILE_CONT(0.67) WITHIN GROUP (ORDER BY growth_pct) OVER() AS p67,
		MAX(growth_pct) OVER () AS max_val
	FROM mart.tbl_account_growth
	WHERE growth_pct IS NOT NULL
)
SELECT DISTINCT min_val, p33, median, p67, max_val 
FROM stats;
