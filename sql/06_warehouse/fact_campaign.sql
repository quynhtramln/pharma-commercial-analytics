/* =============================================================================
   06_warehouse / fact_campaign.sql
   Purpose : Fact
   Target  : warehouse.fact_campaign
   Grain   : 1 campaign
   -------------------------------------------------------------------------
   Keys
     FK product_key, start_date_key, end_date_key
   Note
     role-playing date: start active, end inactive (USERELATIONSHIP) - D-07
   ============================================================================= */


DROP TABLE IF EXISTS warehouse.fact_campaign;


CREATE TABLE warehouse.fact_campaign (
	campaign_key                    INT PRIMARY KEY,
	product_key                     INT REFERENCES warehouse.dim_product(product_key),
	start_date_key                  INT NULL REFERENCES warehouse.dim_date(date_key),
	end_date_key                    INT NULL REFERENCES warehouse.dim_date(date_key),
	campaign_id                     VARCHAR(20)    NOT NULL UNIQUE,
	campaign_name                   NVARCHAR(200)  NULL,
	campaign_type                   VARCHAR(50)    NULL,
	target_hcp_count                INT            NULL,
	budget                          DECIMAL(12,2)  NULL,
	status                          VARCHAR(20)    NULL,
	missing_campaign_name_flag      BIT NOT NULL DEFAULT 0,
	missing_campaign_type_flag      BIT NOT NULL DEFAULT 0,
	start_after_end_flag            BIT NOT NULL DEFAULT 0,
	negative_target_hcp_count_flag  BIT NOT NULL DEFAULT 0,
	missing_status_flag             BIT NOT NULL DEFAULT 0
);


INSERT INTO warehouse.fact_campaign
SELECT
	c.campaign_key, p.product_key,
	CASE WHEN c.start_date IS NULL THEN NULL
		ELSE YEAR(c.start_date)*10000 + MONTH(c.start_date)*100 + DAY(c.start_date) END,
	CASE WHEN c.end_date IS NULL THEN NULL
		ELSE YEAR(c.end_date)*10000 + MONTH(c.end_date)*100 + DAY(c.end_date) END,
	c.campaign_id, c.campaign_name, c.campaign_type, c.target_hcp_count, c.budget, c.status,
	c.missing_campaign_name_flag, c.missing_campaign_type_flag, c.start_after_end_flag,
	c.negative_target_hcp_count_flag, c.missing_status_flag
FROM master.master_campaigns AS c
JOIN master.master_products AS p ON c.product_id = p.product_id;
