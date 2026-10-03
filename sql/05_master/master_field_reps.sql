/* =============================================================================
   05_master / master_field_reps.sql
   Purpose : Trusted entity: surrogate key, confirmed business fixes with audit, DQ flags
   Source  : stg.stg_field_reps
   Target  : master.master_field_reps
   -------------------------------------------------------------------------
   1. DETECT - decisions
     ISS-024 BR-028 base_city <> territory (153) -> base_city is correct, territory re-derived
     ISS-025 DQ-055 territory NULL (6)          -> filled from base_city (same mapping)
   2. RULES
     confirmed 10-pair base_city -> territory mapping applied to EVERY row
     territory_source records old value and reason (audit)
   ============================================================================= */

-- ============================================================
-- 3. TRANSFORM
-- ============================================================
DROP TABLE IF EXISTS master.master_field_reps;


CREATE TABLE master.master_field_reps (
	rep_key            INT IDENTITY(1,1) PRIMARY KEY,
	rep_id             VARCHAR(20)   NOT NULL UNIQUE,
	rep_name           NVARCHAR(100) NOT NULL,
	territory          VARCHAR(50)   NULL,
	territory_source   VARCHAR(150)  NOT NULL DEFAULT 'Original',
	base_city          NVARCHAR(100) NULL,
	hire_date          DATE          NULL,
	status             VARCHAR(20)   NULL,
	specialization     NVARCHAR(100) NULL,
	master_load_date   DATETIME      NOT NULL DEFAULT GETDATE()
);


WITH correct_mapping (base_city, correct_territory) AS (
	SELECT * FROM (VALUES
		('Binh Duong', 'South'),
		('Can Tho', 'Mekong'),
		('Da Nang', 'Central'),
		('Dong Nai', 'South'),
		('Hai Phong', 'North'),
		('Hanoi', 'North'),
		('Ho Chi Minh City', 'South'),
		('Khanh Hoa', 'Central'),
		('Nghe An', 'North'),
		('Quang Ninh', 'North')
	) AS v(base_city, correct_territory)
)
INSERT INTO master.master_field_reps (
	rep_id, rep_name, territory, territory_source, base_city, hire_date, status, specialization
)
SELECT
	r.rep_id, r.rep_name,
	m.correct_territory AS territory,
	CASE
	WHEN r.territory IS NULL AND m.correct_territory IS NOT NULL
		THEN 'Corrected (DQ-055: territory was blank, filled from base_city per approved mapping)'
	WHEN r.territory IS NULL AND m.correct_territory IS NULL
		THEN 'Unresolved (territory blank AND base_city missing/unmapped — cannot auto-correct)'
	WHEN r.territory <> m.correct_territory
		THEN 'Corrected (BR-028: territory mismatched base_city, realigned per approved mapping — was ''' + r.territory + ''')'
	ELSE 'Original'
	END AS territory_source,
	r.base_city, r.hire_date, r.status, r.specialization
FROM stg.stg_field_reps AS r
LEFT JOIN correct_mapping AS m ON r.base_city = m.base_city;


-- ============================================================
-- 4. TEST - case level
-- ============================================================
-- Test 1: exactly 153 rows corrected (BR-028)
SELECT COUNT(*) FROM master.master_field_reps WHERE territory_source LIKE 'Corrected (BR-028%';
-- Expected: 153


-- Test 2: exactly 6 rows filled (DQ-055)
SELECT COUNT(*) FROM master.master_field_reps WHERE territory_source LIKE 'Corrected (DQ-055%';
-- Expected: 6


-- Test 3: no mismatch left after the correction
SELECT COUNT(*) AS remaining_mismatch
FROM master.master_field_reps
WHERE territory IS NULL;
-- Expected: 0

-- ============================================================
-- 5. VALIDATE - table level
-- ============================================================
SELECT
	(SELECT COUNT(*) FROM stg.stg_field_reps) AS stg_count,
	(SELECT COUNT(*) FROM master.master_field_reps) AS master_count;
-- Expected: 220 = 220 (no rows lost or added, values corrected only)
