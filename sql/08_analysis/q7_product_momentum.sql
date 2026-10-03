/* =============================================================================
   08_analysis / q7_product_momentum.sql
   Purpose : Q7 - Which products / therapeutic areas gain or lose momentum?
   Source  : warehouse.*, mart.*
   -------------------------------------------------------------------------
   Result (as of 2026-06-29)
     14 Rising / 13 Stable / 13 Declining products; 6 of 10 priority products are Declining; Oncology -2.1 % (90 days).
   Read with
     docs/06_insights_and_recommendations.md
   ============================================================================= */


SELECT
	p.product_id, p.product_name, p.therapeutic_area,
	m.current_sales, m.prior_sales, m.sales_momentum_pct, m.engagement_trend_pct, m.momentum_tier
FROM mart.tbl_product_momentum AS m
JOIN warehouse.dim_product AS p ON m.product_key = p.product_key
ORDER BY m.sales_momentum_pct DESC;
