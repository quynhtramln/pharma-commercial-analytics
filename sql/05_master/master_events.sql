/* =============================================================================
   05_master / master_events.sql
   Purpose : Trusted entity: surrogate key, confirmed business fixes with audit, DQ flags
   Source  : stg.stg_events
   Target  : master.master_events
   -------------------------------------------------------------------------
   1. DETECT - decisions
     ISS-033 BR-045 event before launch (85) -> pre_launch_event_flag
             valid pre-launch activity, excluded from post-launch analysis
   2. RULES
     join stg_products.launch_date; start_date < launch_date -> 1
   ============================================================================= */

-- ============================================================
-- 3. TRANSFORM
-- ============================================================
DROP TABLE IF EXISTS master.master_events;


CREATE TABLE master.master_events (
	event_key             INT IDENTITY(1,1) PRIMARY KEY,
	event_id              VARCHAR(20)    NOT NULL UNIQUE,
	event_name            NVARCHAR(200)  NOT NULL,
	event_type            VARCHAR(50)    NULL,
	start_date            DATE           NOT NULL,
	end_date              DATE           NULL,
	city                  NVARCHAR(100)  NULL,
	territory             VARCHAR(50)    NULL,
	product_id            VARCHAR(20)    NOT NULL,
	budget                DECIMAL(12,2)  NULL,
	status                VARCHAR(20)    NULL,
	pre_launch_event_flag BIT            NOT NULL DEFAULT 0,   -- ISS-033
	master_load_date      DATETIME       NOT NULL DEFAULT GETDATE()
);


INSERT INTO master.master_events (
	event_id, event_name, event_type, start_date, end_date, city, territory, product_id, budget, status,
	pre_launch_event_flag
)
SELECT
	e.event_id, e.event_name, e.event_type, e.start_date, e.end_date, e.city, e.territory, e.product_id, e.budget, e.status,
	CASE
		WHEN p.launch_date IS NOT NULL AND e.start_date < p.launch_date
		THEN 1 ELSE 0
	END
FROM stg.stg_events AS e
LEFT JOIN stg.stg_products AS p ON e.product_id = p.product_id;


-- ============================================================
-- 4. TEST - case level
-- ============================================================
SELECT COUNT(*) 
FROM master.master_events 
WHERE pre_launch_event_flag = 1;
-- Expected: about 85 (may differ slightly because of dedup / launch_date sentinel)

-- ============================================================
-- 5. VALIDATE - table level
-- ============================================================
SELECT
	(SELECT COUNT(*) FROM stg.stg_events) AS stg_count,
	(SELECT COUNT(*) FROM master.master_events) AS master_count;
-- Expected: 550 = 550
