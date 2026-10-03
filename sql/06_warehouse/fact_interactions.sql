/* =============================================================================
   06_warehouse / fact_interactions.sql
   Purpose : Fact
   Target  : warehouse.fact_interactions
   Grain   : 1 rep-HCP interaction at an account
   -------------------------------------------------------------------------
   Keys
     FK date_key, hcp_key, account_key, rep_key, product_key
   ============================================================================= */


DROP TABLE IF EXISTS warehouse.fact_interactions;


CREATE TABLE warehouse.fact_interactions (
	interaction_key              INT PRIMARY KEY,
	date_key                     INT REFERENCES warehouse.dim_date(date_key),
	hcp_key                      INT REFERENCES warehouse.dim_hcp(hcp_key),
	account_key                  INT REFERENCES warehouse.dim_account(account_key),
	rep_key                      INT REFERENCES warehouse.dim_field_rep(rep_key),
	product_key                  INT REFERENCES warehouse.dim_product(product_key),
	interaction_id               VARCHAR(20)  NOT NULL UNIQUE,
	interaction_type             VARCHAR(50)  NULL,
	channel                      VARCHAR(50)  NULL,
	duration_minutes             INT          NULL,
	outcome                      NVARCHAR(50) NULL,
	engagement_score             DECIMAL(4,1) NULL,
	pre_hire_interaction_flag    BIT NOT NULL DEFAULT 0,
	negative_duration_flag       BIT NOT NULL DEFAULT 0,
	missing_outcome_flag         BIT NOT NULL DEFAULT 0
);


INSERT INTO warehouse.fact_interactions
SELECT
	i.interaction_key,
	YEAR(CAST(i.interaction_datetime AS DATE))*10000 + MONTH(CAST(i.interaction_datetime AS DATE))*100 + DAY(CAST(i.interaction_datetime AS DATE)),
	h.hcp_key, a.account_key, r.rep_key, p.product_key,
	i.interaction_id, i.interaction_type, i.channel, i.duration_minutes, i.outcome, i.engagement_score,
	i.pre_hire_interaction_flag, i.negative_duration_flag, i.missing_outcome_flag
FROM master.master_interactions AS i
JOIN master.master_hcp AS h ON i.hcp_id = h.hcp_id
JOIN master.master_customer_accounts AS a ON i.account_id = a.account_id
JOIN master.master_field_reps AS r ON i.rep_id = r.rep_id
JOIN master.master_products AS p ON i.product_id = p.product_id;
