/* =============================================================================
   08_analysis / q2_account_growth.sql
   Purpose : Q2 - Which customer accounts drive growth?
   Source  : warehouse.*, mart.*
   -------------------------------------------------------------------------
   Result (as of 2026-06-29)
     Tiers split 367 Growing / 366 Stable / 367 Declining; Pharmacy +4.2 % and Wholesaler -2.1 % (last 90 vs prior 90 days).
   Read with
     docs/06_insights_and_recommendations.md
   ============================================================================= */


SELECT TOP 20
	a.account_id, a.account_name, a.account_type, a.territory,
	g.current_period_sales, g.prior_period_sales, g.growth_pct, g.growth_tier
FROM mart.tbl_account_growth AS g
JOIN warehouse.dim_account AS a ON g.account_key = a.account_key
WHERE g.growth_tier = 'Growing'
ORDER BY g.growth_pct DESC;


SELECT growth_tier, COUNT(*) AS account_count 
FROM mart.tbl_account_growth 
GROUP BY growth_tier;
