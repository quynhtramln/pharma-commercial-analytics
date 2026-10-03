/* =============================================================================
   04_staging / stg_campaigns.sql
   Purpose : Clean, type and de-duplicate raw_campaigns
   Source  : raw.raw_campaigns
   Target  : stg.stg_campaigns (+ stg.quarantine_campaigns / mapping table where relevant)
   Grain   : 1 row = 1 campaign (campaign_id)
   -------------------------------------------------------------------------
   1. DETECT - handled here
     ISS-046 DQ-125  2 exact-duplicate campaign_id          -> dedup
     ISS-048 BR-058  campaign_type 'hcp engagement'          -> 'HCP Engagement'
     ISS-052 BR-062  status 'active'                         -> 'Active'
     ISS-053 DQ-132  start_date '2026-13-05'                 -> TRY_CAST -> NULL
     ISS-054 DQ-134  end_date '2025-02-30'                   -> TRY_CAST -> NULL
     ISS-047/049/055 name / type / status NULL               -> NULLIF
     RI              product 'PRD999'                        -> quarantine
   NOT handled in staging, and why
     ISS-050 BR-059  start > end (CAM0062) cause not confirmed -> master flag
     ISS-051 BR-060  negative target_hcp_count  value kept    -> master flag
   2. RULES
     campaign_id, product_id  TRIM, mandatory
     campaign_type, status    TRIM + case fix + NULLIF
     start_date, end_date     TRY_CAST DATE
     target_hcp_count         TRY_CAST INT, negatives kept
     budget                   TRY_CAST DECIMAL
   ============================================================================= */

-- ============================================================
-- 3. TRANSFORM
-- ============================================================
DROP TABLE IF EXISTS stg.stg_campaigns;
DROP TABLE IF EXISTS stg.quarantine_campaigns;


CREATE TABLE stg.stg_campaigns (
	stg_campaign_key    INT IDENTITY(1,1) PRIMARY KEY,
	campaign_id         VARCHAR(20)    NOT NULL,
	campaign_name       NVARCHAR(200)  NULL,
	campaign_type       VARCHAR(50)    NULL,
	product_id          VARCHAR(20)    NOT NULL,
	start_date          DATE           NULL,
	end_date            DATE           NULL,
	target_hcp_count    INT            NULL,
	budget              DECIMAL(12,2)  NULL,
	status              VARCHAR(20)    NULL,
	stg_load_date       DATETIME       NOT NULL DEFAULT GETDATE()
);


CREATE TABLE stg.quarantine_campaigns (
	quarantine_key       INT IDENTITY(1,1) PRIMARY KEY,
	campaign_id          VARCHAR(20)   NULL,
	campaign_name        NVARCHAR(200) NULL,
	campaign_type        VARCHAR(50)   NULL,
	product_id           VARCHAR(20)   NULL,
	start_date           VARCHAR(20)   NULL,
	end_date             VARCHAR(20)   NULL,
	target_hcp_count     VARCHAR(20)   NULL,
	budget               VARCHAR(20)   NULL,
	status               VARCHAR(20)   NULL,
	quarantine_reason    VARCHAR(200)  NOT NULL,
	quarantine_load_date DATETIME      NOT NULL DEFAULT GETDATE()
);


-- Step A: move sentinel foreign keys to quarantine
INSERT INTO stg.quarantine_campaigns (
	campaign_id, campaign_name, campaign_type, product_id, start_date, end_date, target_hcp_count, budget, status, quarantine_reason
)
SELECT
	TRIM(campaign_id), TRIM(campaign_name), TRIM(campaign_type), TRIM(product_id),
	TRIM(start_date), TRIM(end_date), TRIM(target_hcp_count), TRIM(budget), TRIM(status),
	'Sentinel FK: product_id=PRD999'
FROM raw.raw_campaigns
WHERE TRIM(product_id) = 'PRD999';


-- Step B: clean and de-duplicate the valid rows
WITH cleaned AS (
	SELECT
		TRIM(campaign_id) AS campaign_id,
		NULLIF(TRIM(campaign_name), '') AS campaign_name,
		CASE
			WHEN LOWER(TRIM(campaign_type)) = 'hcp engagement' THEN 'HCP Engagement'
			ELSE NULLIF(TRIM(campaign_type), '')
		END AS campaign_type,
		TRIM(product_id) AS product_id,
		TRY_CAST(start_date AS DATE) AS start_date,
		TRY_CAST(end_date AS DATE) AS end_date,
		TRY_CAST(target_hcp_count AS INT) AS target_hcp_count,
		TRY_CAST(budget AS DECIMAL(12,2)) AS budget,
		CASE
			WHEN LOWER(TRIM(status)) = 'active' THEN 'Active'
			ELSE NULLIF(TRIM(status), '')
		END AS status
	FROM raw.raw_campaigns
	WHERE TRIM(product_id) <> 'PRD999'
),
deduped AS (
	SELECT
		*,
		ROW_NUMBER() OVER (
			PARTITION BY campaign_id, campaign_name, campaign_type, product_id, start_date, end_date, target_hcp_count, budget, status
			ORDER BY (SELECT NULL)
		) AS rn
	FROM cleaned
)
INSERT INTO stg.stg_campaigns (
	campaign_id, campaign_name, campaign_type, product_id, start_date, end_date, target_hcp_count, budget, status, stg_load_date
)
SELECT
	campaign_id, campaign_name, campaign_type, product_id, start_date, end_date, target_hcp_count, budget, status, GETDATE()
FROM deduped
WHERE rn = 1;


-- ============================================================
-- 4. TEST - case level
-- ============================================================
-- Test 1: case standardised
SELECT DISTINCT campaign_type FROM stg.stg_campaigns;
SELECT DISTINCT status FROM stg.stg_campaigns;


-- Test 2: the 2 malformed dates must become NULL
SELECT campaign_id, start_date, end_date FROM stg.stg_campaigns WHERE start_date IS NULL OR end_date IS NULL;


-- Test 3: no sentinel FK left in the staging table
SELECT COUNT(*) FROM stg.stg_campaigns WHERE product_id = 'PRD999';
-- Expected: 0

-- ============================================================
-- 5. VALIDATE - table level
-- ============================================================
SELECT
	(SELECT COUNT(*) FROM raw.raw_campaigns) AS raw_count,
	(SELECT COUNT(*) FROM stg.quarantine_campaigns) AS quarantined_count,
	(SELECT COUNT(*) FROM stg.stg_campaigns) AS staged_count;
-- Expected: 72 = 1 (quarantine) + staged + 2 (dedup) -> staged = 69


SELECT campaign_id, COUNT(*) FROM stg.stg_campaigns GROUP BY campaign_id HAVING COUNT(*) > 1;
-- Expected: 0 rows
