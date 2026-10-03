/* =============================================================================
   05_master / master_campaigns.sql
   Purpose : Trusted entity: surrogate key, confirmed business fixes with audit, DQ flags
   Source  : stg.stg_campaigns
   Target  : master.master_campaigns
   -------------------------------------------------------------------------
   1. DETECT - decisions
     ISS-047 name NULL · ISS-049 type NULL · ISS-050 start > end (CAM0062)
     ISS-051 negative target_hcp_count · ISS-055 status NULL -> one *_flag per issue
   2. RULES
     flags only - no values changed
   ============================================================================= */

-- ============================================================
-- 3. TRANSFORM
-- ============================================================
DROP TABLE IF EXISTS master.master_campaigns;


CREATE TABLE master.master_campaigns (
	campaign_key                     INT IDENTITY(1,1) PRIMARY KEY,
	campaign_id                      VARCHAR(20)    NOT NULL UNIQUE,
	campaign_name                    NVARCHAR(200)  NULL,
	campaign_type                    VARCHAR(50)    NULL,
	product_id                       VARCHAR(20)    NOT NULL,
	start_date                       DATE           NULL,
	end_date                         DATE           NULL,
	target_hcp_count                 INT            NULL,
	budget                           DECIMAL(12,2)  NULL,
	status                           VARCHAR(20)    NULL,
	missing_campaign_name_flag       BIT NOT NULL DEFAULT 0,   -- ISS-047
	missing_campaign_type_flag       BIT NOT NULL DEFAULT 0,   -- ISS-049
	start_after_end_flag             BIT NOT NULL DEFAULT 0,   -- ISS-050
	negative_target_hcp_count_flag   BIT NOT NULL DEFAULT 0,   -- ISS-051
	missing_status_flag              BIT NOT NULL DEFAULT 0,   -- ISS-055
	master_load_date                 DATETIME NOT NULL DEFAULT GETDATE()
);


INSERT INTO master.master_campaigns (
	campaign_id, campaign_name, campaign_type, product_id, start_date, end_date,
	target_hcp_count, budget, status,
	missing_campaign_name_flag, missing_campaign_type_flag, start_after_end_flag,
	negative_target_hcp_count_flag, missing_status_flag
)
SELECT
	campaign_id, campaign_name, campaign_type, product_id, start_date, end_date,
	target_hcp_count, budget, status,
	CASE WHEN campaign_name IS NULL THEN 1 ELSE 0 END,
	CASE WHEN campaign_type IS NULL THEN 1 ELSE 0 END,
	CASE WHEN start_date IS NOT NULL AND end_date IS NOT NULL AND start_date > end_date THEN 1 ELSE 0 END,
	CASE WHEN target_hcp_count < 0 THEN 1 ELSE 0 END,
	CASE WHEN status IS NULL THEN 1 ELSE 0 END
FROM stg.stg_campaigns;

-- ============================================================
-- 4. TEST - case level
-- ============================================================
SELECT
	(SELECT COUNT(*) FROM master.master_campaigns WHERE missing_campaign_name_flag = 1) AS c1,
	(SELECT COUNT(*) FROM master.master_campaigns WHERE missing_campaign_type_flag = 1) AS c2,
	(SELECT COUNT(*) FROM master.master_campaigns WHERE start_after_end_flag = 1) AS c3,
	(SELECT COUNT(*) FROM master.master_campaigns WHERE negative_target_hcp_count_flag = 1) AS c4,
	(SELECT COUNT(*) FROM master.master_campaigns WHERE missing_status_flag = 1) AS c5;
-- Expected: 1,1,1,1,1 (69 rows, no quarantine/dedup effect on the rest)

-- ============================================================
-- 5. VALIDATE - table level
-- ============================================================
SELECT
	(SELECT COUNT(*) FROM stg.stg_campaigns) AS stg_count,
	(SELECT COUNT(*) FROM master.master_campaigns) AS master_count;
-- Expected: 69 = 69
