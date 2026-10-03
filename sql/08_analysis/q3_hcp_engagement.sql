/* =============================================================================
   08_analysis / q3_hcp_engagement.sql
   Purpose : Q3 - Which HCPs have strong engagement with priority products?
   Source  : warehouse.*, mart.*
   -------------------------------------------------------------------------
   Result (as of 2026-06-29)
     Priority products = 24.9 % of interactions; average score 5.5 with no meaningful spread by specialty or channel.
   Read with
     docs/06_insights_and_recommendations.md
   ============================================================================= */


SELECT
	h.specialty, h.territory,
	COUNT(*) AS total_interactions,
	AVG(f.engagement_score) AS avg_engagement_score
FROM warehouse.fact_interactions AS f
JOIN warehouse.dim_hcp AS h ON f.hcp_key = h.hcp_key
JOIN warehouse.dim_product AS p ON f.product_key = p.product_key
WHERE p.priority_flag = 1
GROUP BY h.specialty, h.territory
ORDER BY avg_engagement_score DESC;
