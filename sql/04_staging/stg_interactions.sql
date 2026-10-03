/* =============================================================================
   04_staging / stg_interactions.sql
   Purpose : Clean, type and de-duplicate raw_interactions
   Source  : raw.raw_interactions
   Target  : stg.stg_interactions (+ stg.quarantine_interactions / mapping table where relevant)
   Grain   : 1 row = 1 rep-HCP interaction at an account (interaction_id)
   -------------------------------------------------------------------------
   1. DETECT - handled here
     ISS-027 DQ-063  640 exact-duplicate interaction_id     -> dedup
     ISS-030 DQ-074  outcome NULL (7,341)                    -> NULLIF
     RI              hcp 'HCP99999' / account 'ACC99999'     -> quarantine
   NOT handled in staging, and why
     ISS-028 BR-033  interaction before rep hire (31,428, 10.13 %) cross-table -> master flag
     ISS-029 BR-036  negative duration_minutes (601)  value kept, cast only  -> master flag
   2. RULES
     interaction_id, hcp_id, account_id, rep_id, product_id  TRIM, mandatory
     interaction_datetime                                     TRY_CAST DATETIME2
     interaction_type, channel, outcome                       TRIM + NULLIF
     duration_minutes                                         TRY_CAST INT, negatives kept
     engagement_score                                         TRY_CAST DECIMAL(4,1)
   ============================================================================= */

-- ============================================================
-- 3. TRANSFORM
-- ============================================================
DROP TABLE IF EXISTS stg.stg_interactions;
DROP TABLE IF EXISTS stg.quarantine_interactions;


CREATE TABLE stg.stg_interactions (
	stg_interaction_key   INT IDENTITY(1,1) PRIMARY KEY,
	interaction_id        VARCHAR(20)   NOT NULL,
	interaction_datetime  DATETIME2     NOT NULL,
	hcp_id                VARCHAR(20)   NOT NULL,
	account_id            VARCHAR(20)   NOT NULL,
	rep_id                VARCHAR(20)   NOT NULL,
	product_id            VARCHAR(20)   NOT NULL,
	interaction_type      VARCHAR(50)   NULL,
	channel               VARCHAR(50)   NULL,
	duration_minutes      INT           NULL,
	outcome               NVARCHAR(50)  NULL,
	engagement_score      DECIMAL(4,1)  NULL,
	stg_load_date         DATETIME      NOT NULL DEFAULT GETDATE()
);


CREATE TABLE stg.quarantine_interactions (
	quarantine_key        INT IDENTITY(1,1) PRIMARY KEY,
	interaction_id        VARCHAR(20)   NULL,
	interaction_datetime  VARCHAR(30)   NULL,
	hcp_id                VARCHAR(20)   NULL,
	account_id            VARCHAR(20)   NULL,
	rep_id                VARCHAR(20)   NULL,
	product_id            VARCHAR(20)   NULL,
	interaction_type      VARCHAR(50)   NULL,
	channel               VARCHAR(50)   NULL,
	duration_minutes      VARCHAR(20)   NULL,
	outcome               NVARCHAR(50)  NULL,
	engagement_score      VARCHAR(20)   NULL,
	quarantine_reason     VARCHAR(200)  NOT NULL,
	quarantine_load_date  DATETIME      NOT NULL DEFAULT GETDATE()
);


-- Step A: move sentinel foreign keys to quarantine
INSERT INTO stg.quarantine_interactions (
	interaction_id, interaction_datetime, hcp_id, account_id, rep_id, product_id,
	interaction_type, channel, duration_minutes, outcome, engagement_score, quarantine_reason
)
SELECT
	TRIM(interaction_id), TRIM(interaction_datetime), TRIM(hcp_id), TRIM(account_id), TRIM(rep_id), TRIM(product_id),
	TRIM(interaction_type), TRIM(channel), TRIM(duration_minutes), TRIM(outcome), TRIM(engagement_score),
	CASE
		WHEN TRIM(hcp_id) = 'HCP99999' AND TRIM(account_id) = 'ACC99999'
			THEN 'Sentinel FK: both hcp_id=HCP99999 and account_id=ACC99999'
		WHEN TRIM(hcp_id) = 'HCP99999' THEN 'Sentinel FK: hcp_id=HCP99999'
		WHEN TRIM(account_id) = 'ACC99999' THEN 'Sentinel FK: account_id=ACC99999'
	END
FROM raw.raw_interactions
WHERE TRIM(hcp_id) = 'HCP99999' OR TRIM(account_id) = 'ACC99999';


-- Step B: clean and de-duplicate the valid rows
WITH cleaned AS (
	SELECT
		TRIM(interaction_id) AS interaction_id,
		TRY_CAST(interaction_datetime AS DATETIME2) AS interaction_datetime,
		TRIM(hcp_id) AS hcp_id,
		TRIM(account_id) AS account_id,
		TRIM(rep_id) AS rep_id,
		TRIM(product_id) AS product_id,
		NULLIF(TRIM(interaction_type), '') AS interaction_type,
		NULLIF(TRIM(channel), '') AS channel,
		TRY_CAST(duration_minutes AS INT) AS duration_minutes,
		NULLIF(TRIM(outcome), '') AS outcome,
		TRY_CAST(engagement_score AS DECIMAL(4,1)) AS engagement_score
	FROM raw.raw_interactions
	WHERE TRIM(hcp_id) <> 'HCP99999' AND TRIM(account_id) <> 'ACC99999'
),
deduped AS (
	SELECT
		*,
		ROW_NUMBER() OVER (
			PARTITION BY interaction_id, interaction_datetime, hcp_id, account_id, rep_id, product_id,
				interaction_type, channel, duration_minutes, outcome, engagement_score
			ORDER BY (SELECT NULL)
		) AS rn
	FROM cleaned
)
INSERT INTO stg.stg_interactions (
	interaction_id, interaction_datetime, hcp_id, account_id, rep_id, product_id,
	interaction_type, channel, duration_minutes, outcome, engagement_score, stg_load_date
)
SELECT
	interaction_id, interaction_datetime, hcp_id, account_id, rep_id, product_id,
	interaction_type, channel, duration_minutes, outcome, engagement_score, GETDATE()
FROM deduped
WHERE rn = 1


-- ============================================================
-- 4. TEST - case level
-- ============================================================
-- Test 1: no sentinel FK left in the staging table
SELECT COUNT(*)
FROM stg.stg_interactions
WHERE hcp_id = 'HCP99999' OR account_id = 'ACC99999'
-- Expected: 0


-- Test 2: negative duration_minutes must still be present (not changed)
SELECT COUNT(*) AS still_negative
FROM stg.stg_interactions
WHERE duration_minutes < 0
-- Expected: > 0 (about 601, slightly fewer if some rows were quarantined)


-- Test 3: engagement_score converted to a numeric type
SELECT TOP 5 engagement_score
FROM stg.stg_interactions

-- ============================================================
-- 5. VALIDATE - table level
-- ============================================================
-- V1: row conservation
SELECT
	(SELECT COUNT(*) FROM raw.raw_interactions) AS raw_count,
	(SELECT COUNT(*) FROM stg.quarantine_interactions) AS quarantined_count,
	(SELECT COUNT(*) FROM stg.stg_interactions) AS staged_count;
-- raw_count must equal quarantined_count + staged_count + exact duplicates removed


-- V2: no duplicate interaction_id left in staging
SELECT interaction_id, COUNT(*) FROM stg.stg_interactions GROUP BY interaction_id HAVING COUNT(*) > 1;
-- Expected: 0 rows
