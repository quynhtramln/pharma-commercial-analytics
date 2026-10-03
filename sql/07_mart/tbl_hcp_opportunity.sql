/* =============================================================================
   07_mart / tbl_hcp_opportunity.sql
   Purpose : Turn Q8 into one label per entity
   Source  : tbl_account_opportunity + fact_hcp_account_affiliation
   Target  : mart.tbl_hcp_opportunity
   -------------------------------------------------------------------------
   Output
     opportunity_quadrant inherited from primary account (D-12: latest affiliation used while ISS-016 is open)
   Note
     No threshold query needed: this table re-uses the account quadrant.
   ============================================================================= */

-- ============================================================
-- BUILD
-- ============================================================


DROP TABLE IF EXISTS mart.tbl_hcp_opportunity;


WITH ranked_affiliation AS (
	SELECT
		af.hcp_key, af.account_key,
		ROW_NUMBER() OVER (PARTITION BY af.hcp_key ORDER BY af.start_date DESC) AS rn
	FROM warehouse.fact_hcp_account_affiliation AS af
	WHERE af.primary_affiliation = 1 AND af.status = 'Active'
)
SELECT
	h.hcp_key,
	ra.account_key AS primary_account_key,
	ao.opportunity_quadrant
INTO mart.tbl_hcp_opportunity
FROM warehouse.dim_hcp AS h
LEFT JOIN ranked_affiliation AS ra ON h.hcp_key = ra.hcp_key AND ra.rn = 1
LEFT JOIN mart.tbl_account_opportunity AS ao ON ra.account_key = ao.account_key;
