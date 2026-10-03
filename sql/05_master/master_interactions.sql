/* =============================================================================
   05_master / master_interactions.sql
   Purpose : Trusted entity: surrogate key, confirmed business fixes with audit, DQ flags
   Source  : stg.stg_interactions
   Target  : master.master_interactions
   -------------------------------------------------------------------------
   1. DETECT - decisions
     ISS-028 BR-033 before rep hire (31,428) -> pre_hire_interaction_flag (join stg_field_reps)
     ISS-029 BR-036 negative duration (601)  -> negative_duration_flag
     ISS-030 DQ-074 outcome NULL (7,341)     -> missing_outcome_flag
   2. RULES
     flags only - no values changed
   ============================================================================= */

-- ============================================================
-- 3. TRANSFORM
-- ============================================================
DROP TABLE IF EXISTS master.master_interactions;


CREATE TABLE master.master_interactions (
	interaction_key             INT IDENTITY(1,1) PRIMARY KEY,
	interaction_id              VARCHAR(20)   NOT NULL UNIQUE,
	interaction_datetime        DATETIME2     NOT NULL,
	hcp_id                      VARCHAR(20)   NOT NULL,
	account_id                  VARCHAR(20)   NOT NULL,
	rep_id                      VARCHAR(20)   NOT NULL,
	product_id                  VARCHAR(20)   NOT NULL,
	interaction_type            VARCHAR(50)   NULL,
	channel                     VARCHAR(50)   NULL,
	duration_minutes            INT           NULL,
	outcome                     NVARCHAR(50)  NULL,
	engagement_score            DECIMAL(4,1)  NULL,
	pre_hire_interaction_flag   BIT           NOT NULL DEFAULT 0,   -- ISS-028
	negative_duration_flag      BIT           NOT NULL DEFAULT 0,   -- ISS-029
	missing_outcome_flag        BIT           NOT NULL DEFAULT 0,   -- ISS-030
	master_load_date            DATETIME      NOT NULL DEFAULT GETDATE()
);


INSERT INTO master.master_interactions (
	interaction_id, interaction_datetime, hcp_id, account_id, rep_id, product_id,
	interaction_type, channel, duration_minutes, outcome, engagement_score,
	pre_hire_interaction_flag, negative_duration_flag, missing_outcome_flag
)
SELECT
	i.interaction_id, i.interaction_datetime, i.hcp_id, i.account_id, i.rep_id, i.product_id,
	i.interaction_type, i.channel, i.duration_minutes, i.outcome, i.engagement_score,
	CASE
		WHEN f.hire_date IS NOT NULL AND i.interaction_datetime < CAST(f.hire_date AS DATETIME2)
		THEN 1 ELSE 0
	END,
	CASE WHEN i.duration_minutes < 0 THEN 1 ELSE 0 END,
	CASE WHEN i.outcome IS NULL THEN 1 ELSE 0 END
FROM stg.stg_interactions AS i
LEFT JOIN stg.stg_field_reps AS f ON i.rep_id = f.rep_id;


-- ============================================================
-- 4. TEST - case level
-- ============================================================
-- Test 1: about 31,428 rows flagged (may differ slightly because of orphan rep_id)
SELECT COUNT(*) FROM master.master_interactions WHERE pre_hire_interaction_flag = 1;


-- Test 2: exactly 601 rows
SELECT COUNT(*) FROM master.master_interactions WHERE negative_duration_flag = 1;
-- Expected: 601


-- Test 3: exactly 7,341 rows
SELECT COUNT(*) FROM master.master_interactions WHERE missing_outcome_flag = 1;
-- Expected: 7,341

-- ============================================================
-- 5. VALIDATE - table level
-- ============================================================
SELECT
	(SELECT COUNT(*) FROM stg.stg_interactions) AS stg_count,
	(SELECT COUNT(*) FROM master.master_interactions) AS master_count;
-- Expected: 319,570 = 319,570
