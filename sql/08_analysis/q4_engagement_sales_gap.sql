/* =============================================================================
   08_analysis / q4_engagement_sales_gap.sql
   Purpose : Q4 - Which accounts have strong HCP engagement but low commercial penetration?
   Source  : warehouse.*, mart.*
   -------------------------------------------------------------------------
   Result (as of 2026-06-29)
     274 accounts (24.9 %) are high engagement / low sales; 105 of them in North.
   Read with
     docs/06_insights_and_recommendations.md
   ============================================================================= */


SELECT TOP 20
	a.account_id, a.account_name, a.territory,
	o.engagement_count, o.total_sales
FROM mart.tbl_account_opportunity AS o
JOIN warehouse.dim_account AS a ON o.account_key = a.account_key
WHERE o.opportunity_quadrant = 'Opportunity (High Engagement, Low Sales)'
ORDER BY o.engagement_count DESC;
