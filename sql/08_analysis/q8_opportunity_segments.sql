/* =============================================================================
   08_analysis / q8_opportunity_segments.sql
   Purpose : Q8 - Which HCP / account segments represent opportunity?
   Source  : warehouse.*, mart.*
   -------------------------------------------------------------------------
   Result (as of 2026-06-29)
     274 opportunity accounts and 768 opportunity HCPs; 2,846 HCPs have no active primary affiliation.
   Read with
     docs/06_insights_and_recommendations.md
   ============================================================================= */


SELECT opportunity_quadrant, COUNT(*) AS account_count 
FROM mart.tbl_account_opportunity 
GROUP BY opportunity_quadrant;


SELECT opportunity_quadrant, COUNT(*) AS hcp_count 
FROM mart.tbl_hcp_opportunity 
GROUP BY opportunity_quadrant;
