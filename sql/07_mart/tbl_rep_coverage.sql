/* =============================================================================
   07_mart / tbl_rep_coverage.sql
   Purpose : Turn Q5 into one label per entity
   Source  : fact_interactions + dim_field_rep + dim_hcp
   Target  : mart.tbl_rep_coverage
   -------------------------------------------------------------------------
   Logic (verified row by row against the tables in powerbi/HCP_Analytics.pbix)
     coverage = distinct active HCPs in the rep's territory the rep reached up to the as-of date
                / all active HCPs in that territory; tiers = 33rd / 67th percentile
   Output
     rep_performance_tier: High / Medium / Low
   ============================================================================= */

-- ============================================================
-- BUILD
-- ============================================================


DROP TABLE IF EXISTS mart.tbl_rep_coverage;


WITH territory_universe AS (
	SELECT r.rep_key, COUNT(DISTINCT h.hcp_key) AS total_active_hcp_in_territory
	FROM warehouse.dim_field_rep AS r
	JOIN warehouse.dim_hcp AS h ON h.territory = r.territory AND h.status = 'Active'
	GROUP BY r.rep_key
),
visited AS (
	SELECT fi.rep_key, COUNT(DISTINCT fi.hcp_key) AS visited_active_hcp
	FROM warehouse.fact_interactions AS fi
	JOIN warehouse.dim_date AS d ON fi.date_key = d.date_key AND d.full_date <= '2026-06-29'   -- as-of date
	JOIN warehouse.dim_field_rep AS r ON fi.rep_key = r.rep_key
	JOIN warehouse.dim_hcp AS h ON fi.hcp_key = h.hcp_key AND h.status = 'Active' AND h.territory = r.territory
	GROUP BY fi.rep_key
),
combined AS (
	SELECT
		u.rep_key, u.total_active_hcp_in_territory, ISNULL(v.visited_active_hcp,0) AS visited_active_hcp,
		CAST(ISNULL(v.visited_active_hcp,0) AS FLOAT) / NULLIF(u.total_active_hcp_in_territory,0) * 100 AS coverage_rate_pct
	FROM territory_universe AS u
	LEFT JOIN visited AS v ON u.rep_key = v.rep_key
),
with_pctile AS (
	SELECT *,
		PERCENTILE_CONT(0.33) WITHIN GROUP (ORDER BY coverage_rate_pct) OVER () AS p33,
		PERCENTILE_CONT(0.67) WITHIN GROUP (ORDER BY coverage_rate_pct) OVER () AS p67
	FROM combined
)
SELECT
	rep_key, total_active_hcp_in_territory, visited_active_hcp, coverage_rate_pct,
	CASE WHEN coverage_rate_pct < p33 THEN 'Low'
		WHEN coverage_rate_pct > p67 THEN 'High'
		ELSE 'Medium' END AS rep_performance_tier
INTO mart.tbl_rep_coverage
FROM with_pctile;


-- ============================================================
-- THRESHOLD ANALYSIS - run after the build to review the percentile cut-offs
-- (p33 / p67 split the entities into three equal-sized tiers)
-- ============================================================
 


WITH stats AS (
	SELECT
		coverage_rate_pct,
		MIN(coverage_rate_pct) OVER () AS min_val,
		PERCENTILE_CONT(0.33) WITHIN GROUP (ORDER BY coverage_rate_pct) OVER() AS p33,
		PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY coverage_rate_pct) OVER() AS median,
		PERCENTILE_CONT(0.67) WITHIN GROUP (ORDER BY coverage_rate_pct) OVER() AS p67,
		MAX(coverage_rate_pct) OVER () AS max_val
	FROM mart.tbl_rep_coverage
	WHERE coverage_rate_pct IS NOT NULL
)
SELECT DISTINCT min_val, p33, median, p67, max_val FROM stats;
