/* =============================================================================
   07_mart / 00_mart_views.sql
   Purpose : Expose the warehouse to consumers through the mart schema
   Target  : mart.vw_*
   -------------------------------------------------------------------------
   Note
     vw_fact_interactions adds engagement_tier (High >= 8, Medium >= 5, Low).
   ============================================================================= */


CREATE VIEW mart.vw_dim_hcp AS SELECT * FROM warehouse.dim_hcp;
CREATE VIEW mart.vw_dim_account AS SELECT * FROM warehouse.dim_account;
CREATE VIEW mart.vw_dim_product AS SELECT * FROM warehouse.dim_product;
CREATE VIEW mart.vw_dim_field_rep AS SELECT * FROM warehouse.dim_field_rep;
CREATE VIEW mart.vw_dim_event AS SELECT * FROM warehouse.dim_event;
CREATE VIEW mart.vw_dim_date AS SELECT * FROM warehouse.dim_date;
CREATE VIEW mart.vw_fact_sales AS SELECT * FROM warehouse.fact_sales;
CREATE VIEW mart.vw_fact_interactions AS
SELECT
	f.*,
	CASE
		WHEN f.engagement_score >= 8 THEN 'High'
		WHEN f.engagement_score >= 5 THEN 'Medium'
		WHEN f.engagement_score IS NOT NULL THEN 'Low'
		ELSE NULL
	END AS engagement_tier
FROM warehouse.fact_interactions AS f;
CREATE VIEW mart.vw_fact_event_registrations AS SELECT * FROM warehouse.fact_event_registrations;
CREATE VIEW mart.vw_fact_hcp_account_affiliation AS SELECT * FROM warehouse.fact_hcp_account_affiliation;
CREATE VIEW mart.vw_fact_campaign AS SELECT * FROM warehouse.fact_campaign;
