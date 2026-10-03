/* =============================================================================
   06_warehouse / fact_hcp_account_affiliation.sql
   Purpose : Fact
   Target  : warehouse.fact_hcp_account_affiliation
   Grain   : 1 HCP-account relationship for a period
   -------------------------------------------------------------------------
   Keys
     FK hcp_key, account_key
   Note
     factless bridge - resolves HCP <-> account many-to-many
   ============================================================================= */


DROP TABLE IF EXISTS warehouse.fact_hcp_account_affiliation;


CREATE TABLE warehouse.fact_hcp_account_affiliation (
	affiliation_key             INT PRIMARY KEY,
	hcp_key                     INT REFERENCES warehouse.dim_hcp(hcp_key),
	account_key                 INT REFERENCES warehouse.dim_account(account_key),
	affiliation_id              VARCHAR(20)  NOT NULL UNIQUE,
	role                        NVARCHAR(50) NULL,
	primary_affiliation         BIT          NULL,
	start_date                  DATE         NOT NULL,
	end_date                    DATE         NULL,
	status                      VARCHAR(20)  NULL,
	date_swap_applied           BIT NOT NULL DEFAULT 0,
	primary_overlap_flag        BIT NOT NULL DEFAULT 0,
	status_date_mismatch_flag   BIT NOT NULL DEFAULT 0
);


INSERT INTO warehouse.fact_hcp_account_affiliation
SELECT
	af.affiliation_key, h.hcp_key, a.account_key, af.affiliation_id, af.role, af.primary_affiliation,
	af.start_date, af.end_date, af.status, af.date_swap_applied, af.primary_overlap_flag, af.status_date_mismatch_flag
FROM master.master_hcp_account_affiliations AS af
JOIN master.master_hcp AS h ON af.hcp_id = h.hcp_id
JOIN master.master_customer_accounts AS a ON af.account_id = a.account_id;
