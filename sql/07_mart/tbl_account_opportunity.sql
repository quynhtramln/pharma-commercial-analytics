/* =============================================================================
   07_mart / tbl_account_opportunity.sql
   Purpose : Turn Q8 into one label per entity
   Source  : fact_interactions + fact_sales
   Target  : mart.tbl_account_opportunity
   -------------------------------------------------------------------------
   Logic (verified row by row against the tables in powerbi/HCP_Analytics.pbix)
     engagement = interactions (to the as-of date) of HCPs with an Active affiliation to the account
     sales      = Total Sales definition: negative quantity / non-positive price excluded, to the as-of date
     quadrant   = split at the median of each
   Output
     opportunity_quadrant (4 quadrants)
   Note
     No threshold query needed: the median is computed inside the build query.
   ============================================================================= */

-- ============================================================
-- BUILD
-- ============================================================


DROP TABLE IF EXISTS mart.tbl_account_opportunity;


WITH hcp_interactions AS (
	-- interactions per HCP up to the as-of date (any account)
	SELECT fi.hcp_key, COUNT(*) AS interactions
	FROM warehouse.fact_interactions AS fi
	JOIN warehouse.dim_date AS d ON fi.date_key = d.date_key
	WHERE d.full_date <= '2026-06-29'
	GROUP BY fi.hcp_key
),
account_engagement AS (
	-- Engagement Index: interactions of the HCPs with an Active affiliation to the account
	-- (same definition as the [Engagement Index] measure; not additive across accounts)
	SELECT af.account_key, SUM(hi.interactions) AS engagement_count
	FROM (SELECT DISTINCT account_key, hcp_key
	      FROM warehouse.fact_hcp_account_affiliation
	      WHERE status = 'Active') AS af
	JOIN hcp_interactions AS hi ON af.hcp_key = hi.hcp_key
	GROUP BY af.account_key
),
account_sales AS (
	SELECT f.account_key, SUM(f.sales_amount) AS total_sales
	FROM warehouse.fact_sales AS f
	JOIN warehouse.dim_date AS d ON f.date_key = d.date_key
	WHERE f.negative_quantity_flag = 0 AND f.non_positive_price_flag = 0   -- Business Rule 6
	  AND d.full_date <= '2026-06-29'
	GROUP BY f.account_key
),
account_metrics AS (
	SELECT
		a.account_key,
		ISNULL(e.engagement_count, 0) AS engagement_count,
		ISNULL(s.total_sales, 0)      AS total_sales
	FROM warehouse.dim_account AS a
	LEFT JOIN account_engagement AS e ON a.account_key = e.account_key
	LEFT JOIN account_sales      AS s ON a.account_key = s.account_key
),
with_medians AS (
	SELECT
		*,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY engagement_count) OVER () AS median_engagement,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_sales) OVER () AS median_sales
	FROM account_metrics
)
SELECT
	account_key, engagement_count, total_sales, median_engagement, median_sales,
	CASE
		WHEN engagement_count >= median_engagement AND total_sales < median_sales
			THEN 'Opportunity (High Engagement, Low Sales)'
		WHEN engagement_count >= median_engagement
			THEN 'High Engagement, High Sales'
		WHEN total_sales >= median_sales
			THEN 'Low Engagement, High Sales'
		ELSE 'Low Engagement, Low Sales'
	END AS opportunity_quadrant
INTO mart.tbl_account_opportunity
FROM with_medians;
