/* =============================================================================
   04_staging / stg_events.sql
   Purpose : Clean, type and de-duplicate raw_events
   Source  : raw.raw_events
   Target  : stg.stg_events (+ stg.quarantine_events / mapping table where relevant)
   Grain   : 1 row = 1 medical event (event_id)
   -------------------------------------------------------------------------
   1. DETECT - handled here
     ISS-031 DQ-079  2 exact-duplicate event_id             -> dedup
     ISS-032 BR-039  end_date sentinel '2020-01-01' (confirmed) -> NULL
   NOT handled in staging, and why
     ISS-033 BR-045  event before product launch (85) cross-table -> master flag
   2. RULES
     event_id, event_name, product_id    TRIM, mandatory
     event_type, city, territory, status TRIM + NULLIF
     start_date / end_date               TRY_CAST DATE; end_date '2020-01-01' -> NULL
     budget                              TRY_CAST DECIMAL(12,2)
   ============================================================================= */

-- ============================================================
-- 3. TRANSFORM
-- ============================================================
DROP TABLE IF EXISTS stg.stg_events;


CREATE TABLE stg.stg_events (
	stg_event_key   INT IDENTITY(1,1) PRIMARY KEY,
	event_id        VARCHAR(20)    NOT NULL,
	event_name      NVARCHAR(200)  NOT NULL,
	event_type      VARCHAR(50)    NULL,
	start_date      DATE           NOT NULL,
	end_date        DATE           NULL,
	city            NVARCHAR(100)  NULL,
	territory       VARCHAR(50)    NULL,
	product_id      VARCHAR(20)    NOT NULL,
	budget          DECIMAL(12,2)  NULL,
	status          VARCHAR(20)    NULL,
	stg_load_date   DATETIME       NOT NULL DEFAULT GETDATE()
);


WITH cleaned AS (
	SELECT
		TRIM(event_id) AS event_id,
		TRIM(event_name) AS event_name,
		NULLIF(TRIM(event_type), '') AS event_type,
		TRY_CAST(start_date AS DATE) AS start_date,
		CASE
			WHEN TRY_CAST(end_date AS DATE) = '2020-01-01' THEN NULL
			ELSE TRY_CAST(end_date AS DATE)
		END AS end_date,
		NULLIF(TRIM(city), '') AS city,
		NULLIF(TRIM(territory), '') AS territory,
		TRIM(product_id) AS product_id,
		TRY_CAST(budget AS DECIMAL(12,2)) AS budget,
		NULLIF(TRIM(status), '') AS status
	FROM raw.raw_events
),
deduped AS (
	SELECT
		*,
		ROW_NUMBER() OVER (
			PARTITION BY event_id, event_name, event_type, start_date, end_date, city, territory, product_id, budget, status
			ORDER BY (SELECT NULL)
		) AS rn
	FROM cleaned
)
INSERT INTO stg.stg_events (
	event_id, event_name, event_type, start_date, end_date, city, territory, product_id, budget, status, stg_load_date
)
SELECT
	event_id, event_name, event_type, start_date, end_date, city, territory, product_id, budget, status, GETDATE()
FROM deduped
WHERE rn = 1;


-- ============================================================
-- 4. TEST - case level
-- ============================================================
-- Test 1: end_date = 2020-01-01 must become NULL
SELECT r.event_id, r.end_date AS raw_end_date, s.end_date AS stg_end_date
FROM raw.raw_events r JOIN stg.stg_events s ON r.event_id = s.event_id
WHERE r.end_date = '2020-01-01';
-- Expected: stg_end_date all NULL


-- Test 2: BR-045 (event before launch) still present, deliberately not changed
SELECT COUNT(*) AS changed_rows
FROM raw.raw_events r
JOIN stg.stg_events s ON r.event_id = s.event_id
WHERE TRIM(r.start_date) <> CONVERT(VARCHAR, s.start_date, 23);
-- Expected: 0 (start_date unchanged)

-- ============================================================
-- 5. VALIDATE - table level
-- ============================================================
SELECT
	(SELECT COUNT(*) FROM raw.raw_events) AS raw_count,
	(SELECT COUNT(*) FROM stg.stg_events) AS stg_count;
-- Expected: raw = 552, stg = 550


SELECT event_id, COUNT(*) 
FROM stg.stg_events 
GROUP BY event_id 
HAVING COUNT(*) > 1;


-- Expected: 0 rows
SELECT COUNT(*) AS remaining_sentinel 
FROM stg.stg_events 
WHERE end_date = '2020-01-01';
-- Expected: 0
