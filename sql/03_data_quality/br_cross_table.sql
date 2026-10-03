/* =============================================================================
   03_data_quality / br_cross_table.sql
   Purpose : Business rules that need two tables - the issues staging must NOT fix
   Source  : raw.*
   -------------------------------------------------------------------------
   Lesson
     BR-009 first returned 13 violations using GETDATE(); re-run at the fixed
     as-of date 2026-06-29 -> 0 (ISS-010 closed, decision D-09).
   ============================================================================= */


-- ============================================================
-- BUSINESS RULE: RAW_EVENT_REGISTRATION_BEFORE_EVENT_DATE
-- File: br_event_registration_before_event_date.sql
-- Purpose: Validate that event registrations occur before the event start date
-- Rules covered: BR-046
-- Scope: raw_event_registrations.registration_date, raw_events.start_date
-- Source: Business Rule Catalog
-- Expected Result: 0 violations unless exceptions are explicitly documented
-- ============================================================

-- ------------------------------------------------------------
-- registration_date, event_id
-- BR-046: Event registration must occur on or before the event start date
-- ------------------------------------------------------------
WITH applicable_rows AS (
	SELECT
		r.registration_id,
		TRY_CAST(r.registration_date AS DATE) AS registration_date_parsed,
		e.start_date
	FROM raw.raw_event_registrations AS r
	JOIN raw.raw_events AS e ON r.event_id = e.event_id
	WHERE r.event_id IS NOT NULL AND TRIM(r.event_id) != ''
		AND TRY_CAST(r.registration_date AS DATE) IS NOT NULL
),
violations AS (
	SELECT registration_id
	FROM applicable_rows
	WHERE registration_date_parsed > start_date
)
SELECT
	(SELECT COUNT(*) FROM applicable_rows) AS applicable_row_count,
	(SELECT COUNT(*) FROM violations) AS violation_count,
	CONCAT(CAST(ROUND((SELECT COUNT(*) FROM violations) * 100.0 / NULLIF((SELECT COUNT(*) FROM applicable_rows),0), 2) AS DECIMAL(5,2)), '%') AS violation_pct,
	CASE WHEN (SELECT COUNT(*) FROM violations) > 0 THEN 'Fail' ELSE 'Pass' END AS status

-- ============================================================
-- BUSINESS RULE: RAW_SALES_AFTER_PRODUCT_LAUNCH
-- File: br_sales_after_product_launch.sql
-- Purpose: Validate that sales occur on or after the product launch date
-- Rules covered: BR-050
-- Scope: raw_sales.sales_date, raw_sales.product_id, raw_products.product_id, raw_products.launch_date
-- Source: Business Rule Catalog
-- Expected Result: 0 violations unless exceptions are explicitly documented
-- ============================================================

-- ------------------------------------------------------------
-- sales_date, product_id
-- BR-050: Sales cannot occur before the product launch date
-- ------------------------------------------------------------
WITH applicable_rows AS (
	SELECT
		s.sales_id,
		TRY_CAST(s.sales_date AS DATE) AS sales_date_parsed,
		TRY_CAST(p.launch_date AS DATE) AS launch_date_parsed
	FROM raw.raw_sales AS s
	JOIN raw.raw_products AS p ON s.product_id = p.product_id
	WHERE s.product_id IS NOT NULL AND TRIM(s.product_id) != ''
		AND TRY_CAST(s.sales_date AS DATE) IS NOT NULL
		AND TRY_CAST(p.launch_date AS DATE) IS NOT NULL
),
violations AS (
	SELECT sales_id
	FROM applicable_rows
	WHERE sales_date_parsed < launch_date_parsed
)
SELECT
	(SELECT COUNT(*) FROM applicable_rows) AS applicable_row_count,
	(SELECT COUNT(*) FROM violations) AS violation_count,
	CONCAT(CAST(ROUND((SELECT COUNT(*) FROM violations) * 100.0 / NULLIF((SELECT COUNT(*) FROM applicable_rows),0), 2) AS DECIMAL(5,2)), '%') AS violation_pct,
	CASE WHEN (SELECT COUNT(*) FROM violations) > 0 THEN 'Fail' ELSE 'Pass' END AS status

-- ============================================================
-- BUSINESS RULE: RAW_ACTIVE_HCP_RECENT_ENGAGEMENT
-- File: br_active_hcp_recent_engagement.sql
-- Purpose: Validate that active HCPs have recent engagement activity
-- Rules covered: BR-009
-- Scope: raw_hcp.hcp_id, raw_hcp.status, raw_interactions.hcp_id, raw_interactions.interaction_datetime
-- Source: Business Rule Catalog
-- Expected Result: 0 violations unless exceptions are explicitly documented
-- ============================================================

-- ------------------------------------------------------------
-- hcp_id, status, interaction_datetime
-- BR-009: Active HCPs should have at least one interaction within the last 90 days
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_hcp WHERE status = 'Active'), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_hcp AS h
WHERE h.status = 'Active'
	AND NOT EXISTS (
		SELECT 1
		FROM raw.raw_interactions AS i
		WHERE i.hcp_id = h.hcp_id
			AND i.interaction_datetime IS NOT NULL AND TRIM(i.interaction_datetime) != ''
			AND TRY_CAST(i.interaction_datetime AS DATETIME) IS NOT NULL
			AND DATEDIFF(DAY, TRY_CAST(i.interaction_datetime AS DATETIME), GETDATE()) < 90
	)

-- ============================================================
-- BUSINESS RULE: RAW_EVENT_AFTER_PRODUCT_LAUNCH
-- File: br_event_after_product_launch.sql
-- Purpose: Validate that events occur on or after the product launch date
-- Rules covered: BR-045
-- Scope: raw_events.event_id, raw_events.product_id, raw_events.start_date, raw_products.product_id, raw_products.launch_date
-- Source: Business Rule Catalog
-- Expected Result: 0 violations unless exceptions are explicitly documented
-- ============================================================

-- ------------------------------------------------------------
-- product_id, start_date, launch_date
-- BR-045: A product-related event should not occur before product launch
-- ------------------------------------------------------------
WITH applicable_rows AS (
	SELECT
		e.event_id,
		e.start_date,
		TRY_CAST(p.launch_date AS DATE) AS launch_date_parsed
	FROM raw.raw_events AS e
	JOIN raw.raw_products AS p ON e.product_id = p.product_id
	WHERE e.product_id IS NOT NULL AND TRIM(e.product_id) != ''
		AND TRY_CAST(p.launch_date AS DATE) IS NOT NULL
),
violations AS (
	SELECT event_id
	FROM applicable_rows
	WHERE start_date < launch_date_parsed
)
SELECT
	COUNT(*) AS applicable_row_count,
	(SELECT COUNT(*) FROM violations) AS violation_count,
	CONCAT(CAST(ROUND((SELECT COUNT(*) FROM violations) * 100.0 / NULLIF(COUNT(*),0), 2) AS DECIMAL(5,2)), '%') AS violation_pct,
	CASE WHEN (SELECT COUNT(*) FROM violations) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM applicable_rows AS a

-- ============================================================
-- BUSINESS RULE: RAW_INTERACTION_AFTER_REP_HIRE
-- File: br_interaction_after_rep_hire.sql
-- Purpose: Validate that interactions occur on or after the rep hire date
-- Rules covered: BR-033
-- Scope: raw_interactions.interaction_datetime, raw_interactions.rep_id, raw_field_reps.rep_id, raw_field_reps.hire_date
-- Source: Business Rule Catalog
-- Expected Result: 0 violations unless exceptions are explicitly documented
-- ============================================================

-- ------------------------------------------------------------
-- rep_id, interaction_datetime, hire_date
-- BR-033: A field representative should not have an interaction before their hire date
-- ------------------------------------------------------------
WITH applicable_rows AS (
	SELECT
		i.interaction_id,
		TRY_CAST(i.interaction_datetime AS DATE) AS interaction_date_parsed,
		TRY_CAST(f.hire_date AS DATE) AS hire_date_parsed
	FROM raw.raw_interactions AS i
	JOIN raw.raw_field_reps AS f ON i.rep_id = f.rep_id
	WHERE i.interaction_datetime IS NOT NULL AND TRIM(i.interaction_datetime) != ''
		AND TRY_CAST(i.interaction_datetime AS DATE) IS NOT NULL
		AND TRY_CAST(f.hire_date AS DATE) IS NOT NULL
),
violations AS (
	SELECT interaction_id
	FROM applicable_rows
	WHERE interaction_date_parsed < hire_date_parsed
)
SELECT
	(SELECT COUNT(*) FROM applicable_rows) AS applicable_row_count,
	(SELECT COUNT(*) FROM violations) AS violation_count,
	CONCAT(CAST(ROUND((SELECT COUNT(*) FROM violations) * 100.0 / NULLIF((SELECT COUNT(*) FROM applicable_rows),0), 2) AS DECIMAL(5,2)), '%') AS violation_pct,
	CASE WHEN (SELECT COUNT(*) FROM violations) > 0 THEN 'Fail' ELSE 'Pass' END AS status


 
