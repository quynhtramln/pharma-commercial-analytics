/* =============================================================================
   08_analysis / q5_field_force_coverage.sql
   Purpose : Q5 - How effectively does the field force cover active HCPs / accounts?
   Source  : warehouse.*, mart.*
   -------------------------------------------------------------------------
   Result (as of 2026-06-29)
     Every active HCP was reached at least once; per-rep territory coverage averages ~23 % (territories are shared).
   Read with
     docs/06_insights_and_recommendations.md
   ============================================================================= */


SELECT
	r.territory, r.rep_id, r.rep_name,
	c.total_active_hcp_in_territory, c.visited_active_hcp, c.coverage_rate_pct, c.rep_performance_tier
FROM mart.tbl_rep_coverage AS c
JOIN warehouse.dim_field_rep AS r ON c.rep_key = r.rep_key
ORDER BY c.coverage_rate_pct DESC;
