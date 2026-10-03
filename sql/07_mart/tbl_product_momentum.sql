/* =============================================================================
   07_mart / tbl_product_momentum.sql
   Purpose : Turn Q7 into one label per entity
   Source  : fact_sales + fact_interactions
   Target  : mart.tbl_product_momentum
   -------------------------------------------------------------------------
   Logic (verified row by row against the tables in powerbi/HCP_Analytics.pbix)
     current = sales in the 90 days up to the as-of date: date > 2026-06-29 - 90 and <= 2026-06-29
     prior   = the 90 days before that
     sales exclude negative quantity and non-positive price (same as the Total Sales measure)
     tiers   = 33rd / 67th percentile of sales momentum; engagement trend uses the same windows
   Output
     momentum_tier: Rising / Stable / Declining / New / Inactive
   ============================================================================= */

-- ============================================================
-- BUILD
-- ============================================================


DROP TABLE IF EXISTS mart.tbl_product_momentum;


WITH sales_periods AS (
	SELECT
		f.product_key,
		SUM(CASE WHEN d.full_date >  DATEADD(DAY, -90, '2026-06-29') AND d.full_date <= '2026-06-29'
		         THEN f.sales_amount ELSE 0 END) AS current_sales,
		SUM(CASE WHEN d.full_date >  DATEADD(DAY, -180, '2026-06-29') AND d.full_date <= DATEADD(DAY, -90, '2026-06-29')
		         THEN f.sales_amount ELSE 0 END) AS prior_sales
	FROM warehouse.fact_sales AS f
	JOIN warehouse.dim_date AS d ON f.date_key = d.date_key
	WHERE f.negative_quantity_flag = 0 AND f.non_positive_price_flag = 0   -- Business Rule 6
	GROUP BY f.product_key
),
engagement_periods AS (
	SELECT
		f.product_key,
		COUNT(CASE WHEN d.full_date >  DATEADD(DAY, -90, '2026-06-29') AND d.full_date <= '2026-06-29' THEN 1 END) AS current_interactions,
		COUNT(CASE WHEN d.full_date >  DATEADD(DAY, -180, '2026-06-29') AND d.full_date <= DATEADD(DAY, -90, '2026-06-29') THEN 1 END) AS prior_interactions
	FROM warehouse.fact_interactions AS f
	JOIN warehouse.dim_date AS d ON f.date_key = d.date_key
	GROUP BY f.product_key
),
combined AS (
	SELECT
		sp.product_key,
		sp.current_sales, sp.prior_sales,
		CASE WHEN sp.prior_sales > 0 THEN (sp.current_sales - sp.prior_sales) * 100.0 / sp.prior_sales END AS sales_momentum_pct,
		ep.current_interactions, ep.prior_interactions,
		CASE WHEN ep.prior_interactions > 0 THEN (ep.current_interactions - ep.prior_interactions) * 100.0 / ep.prior_interactions END AS engagement_trend_pct
	FROM sales_periods AS sp
	LEFT JOIN engagement_periods AS ep ON sp.product_key = ep.product_key
),
with_pctile AS (
	SELECT *,
		PERCENTILE_CONT(0.33) WITHIN GROUP (ORDER BY sales_momentum_pct) OVER () AS p33,
		PERCENTILE_CONT(0.67) WITHIN GROUP (ORDER BY sales_momentum_pct) OVER () AS p67
	FROM combined
	WHERE sales_momentum_pct IS NOT NULL
)
SELECT
	product_key, current_sales, prior_sales, sales_momentum_pct, current_interactions, prior_interactions, engagement_trend_pct,
	CASE WHEN sales_momentum_pct < p33 THEN 'Declining'
		WHEN sales_momentum_pct > p67 THEN 'Rising'
		ELSE 'Stable' END AS momentum_tier
INTO mart.tbl_product_momentum
FROM with_pctile
UNION ALL
SELECT product_key, current_sales, prior_sales, NULL, current_interactions, prior_interactions, engagement_trend_pct,
	CASE WHEN prior_sales = 0 AND current_sales > 0 THEN 'New' ELSE 'Inactive' END
FROM combined WHERE prior_sales = 0;


-- ============================================================
-- THRESHOLD ANALYSIS - run after the build to review the percentile cut-offs
-- (p33 / p67 split the entities into three equal-sized tiers)
-- ============================================================
 


WITH stats AS (
	SELECT
		sales_momentum_pct,
		MIN(sales_momentum_pct) OVER () AS min_val,
		PERCENTILE_CONT(0.33) WITHIN GROUP (ORDER BY sales_momentum_pct) OVER() AS p33,
		PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY sales_momentum_pct) OVER() AS median,
		PERCENTILE_CONT(0.67) WITHIN GROUP (ORDER BY sales_momentum_pct) OVER() AS p67,
		MAX(sales_momentum_pct) OVER () AS max_val
	FROM mart.tbl_product_momentum
	WHERE sales_momentum_pct IS NOT NULL
)
SELECT DISTINCT min_val, p33, median, p67, max_val FROM stats;
