-- ============================================================
-- REFERENTIAL INTEGRITY CHECK
-- File name: referential_integrity_checks.sql
-- Purpose: Validate foreign key relationships and identify orphan references
-- Rules covered: Completeness-related DQ rules in the Data Quality Rule Catalog
-- Scope: raw_customer_accounts, hcp_account_affiliations, raw_interactions, raw_events, raw_event_registrations, raw_sales, raw_campaigns
-- Source: Data Quality Rule Catalog
-- Expected Result: Each rule should return 0 violations unless exceptions are explicitly documented
-- ============================================================


-- ============================================================
-- 01. raw_customer_accounts
-- ============================================================

-- ------------------------------------------------------------
-- parent_account_id
-- RI-013: parent_account_id must match raw_customer_accounts.account_id; orphan count must be 0
-- ------------------------------------------------------------
WITH orphan_records AS (
	-- Count child rows with a non-blank parent_account_id that has no matching account_id in the same table (orphan FK, self-referencing)
	SELECT COUNT(*) AS orphan_FK
	FROM raw.raw_customer_accounts AS child
	LEFT JOIN raw.raw_customer_accounts AS parent ON child.parent_account_id = parent.account_id
	WHERE child.parent_account_id IS NOT NULL AND TRIM(child.parent_account_id) != ''
		AND parent.account_id IS NULL
),
applicable_rows AS (
	-- Denominator = rows with a non-blank parent_account_id only, not the full table.
	-- Avoids diluting match_rate, since most accounts have no parent (parent_account_id is optional).
	SELECT COUNT(*) AS total_applicable
	FROM raw.raw_customer_accounts
	WHERE parent_account_id IS NOT NULL AND TRIM(parent_account_id) != ''
)
SELECT
	a.total_applicable AS child_rows,
	a.total_applicable - o.orphan_FK AS matched_rows,
	o.orphan_FK,
	CONCAT(
		CAST(ROUND((a.total_applicable - o.orphan_FK) * 100.0 / a.total_applicable, 2) AS DECIMAL(5,2)),
		'%'
	) AS match_rate,
	CASE WHEN o.orphan_FK > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM orphan_records o
CROSS JOIN applicable_rows a


-- RI-013: Drill-down: Unmatched Values (Orphan Records)
WITH unmatched AS (
	SELECT
		child.parent_account_id AS unmatched_value,
		COUNT(*) AS unmatched_value_count
	FROM raw.raw_customer_accounts AS child
	LEFT JOIN raw.raw_customer_accounts AS parent ON child.parent_account_id = parent.account_id
	WHERE child.parent_account_id IS NOT NULL AND TRIM(child.parent_account_id) != ''
		AND parent.account_id IS NULL
	GROUP BY child.parent_account_id
)
SELECT
	unmatched_value,
	unmatched_value_count,
	SUM(unmatched_value_count) OVER () AS total_unmatched,
	CONCAT(
		CAST(ROUND(unmatched_value_count * 100.0 / SUM(unmatched_value_count) OVER (), 2) AS DECIMAL(5,2)),
		'%'
	) AS total_unmatched_pct
FROM unmatched
ORDER BY unmatched_value_count DESC


-- ============================================================
-- 02. hcp_account_affiliations
-- ============================================================

-- ------------------------------------------------------------
-- hcp_id
-- RI-001: hcp_id must match raw_hcp.hcp_id; orphan count must be 0
-- ------------------------------------------------------------
WITH orphan_records AS (
	-- Count child rows with a non-blank id that has no matching id in parent table (orphan FK)
	SELECT COUNT(*) AS orphan_FK
	FROM raw.raw_hcp_account_affiliations AS child
	LEFT JOIN raw.raw_hcp AS parent ON child.hcp_id = parent.hcp_id
	WHERE child.hcp_id IS NOT NULL AND TRIM(child.hcp_id) != ''
		AND parent.hcp_id IS NULL
),
applicable_rows AS (
	-- Denominator = rows with a non-blank id only, not the full table.
	-- Avoids diluting match_rate if some rows have blank id.
	SELECT COUNT(*) AS total_applicable
	FROM raw.raw_hcp_account_affiliations
	WHERE hcp_id IS NOT NULL AND TRIM(hcp_id) != ''
)
SELECT
	a.total_applicable AS child_rows,
	a.total_applicable - o.orphan_FK AS matched_rows,
	o.orphan_FK,
	CONCAT(
		CAST(ROUND((a.total_applicable - o.orphan_FK) * 100.0 / a.total_applicable, 2) AS DECIMAL(5,2)),
		'%'
	) AS match_rate,
	CASE WHEN o.orphan_FK > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM orphan_records o
CROSS JOIN applicable_rows a


-- RI-001: Drill-down: Unmatched Values (Orphan Records)
WITH unmatched AS (
	SELECT
		child.hcp_id AS unmatched_value,
		COUNT(*) AS unmatched_value_count
	FROM raw.raw_hcp_account_affiliations AS child
	LEFT JOIN raw.raw_hcp AS parent ON child.hcp_id = parent.hcp_id
	WHERE child.hcp_id IS NOT NULL AND TRIM(child.hcp_id) != ''
		AND parent.hcp_id IS NULL
	GROUP BY child.hcp_id
)
SELECT
	unmatched_value,
	unmatched_value_count,
	SUM(unmatched_value_count) OVER () AS total_unmatched,
	CONCAT(
		CAST(ROUND(unmatched_value_count * 100.0 / SUM(unmatched_value_count) OVER (), 2) AS DECIMAL(5,2)),
		'%'
	) AS total_unmatched_pct
FROM unmatched
ORDER BY unmatched_value_count DESC


-- ------------------------------------------------------------
-- account_id
-- RI-002: account_id must match raw_customer_accounts.account_id; orphan count must be 0
-- ------------------------------------------------------------
WITH orphan_records AS (
	-- Count child rows with a non-blank id that has no matching id in parent table (orphan FK)
	SELECT COUNT(*) AS orphan_FK
	FROM raw.raw_hcp_account_affiliations AS child
	LEFT JOIN raw.raw_customer_accounts AS parent ON child.account_id = parent.account_id
	WHERE child.account_id IS NOT NULL AND TRIM(child.account_id) != ''
		AND parent.account_id IS NULL
),
applicable_rows AS (
	-- Denominator = rows with a non-blank id only, not the full table.
	-- Avoids diluting match_rate if some rows have blank id.
	SELECT COUNT(*) AS total_applicable
	FROM raw.raw_hcp_account_affiliations
	WHERE account_id IS NOT NULL AND TRIM(account_id) != ''
)
SELECT
	a.total_applicable AS child_rows,
	a.total_applicable - o.orphan_FK AS matched_rows,
	o.orphan_FK,
	CONCAT(
		CAST(ROUND((a.total_applicable - o.orphan_FK) * 100.0 / a.total_applicable, 2) AS DECIMAL(5,2)),
		'%'
	) AS match_rate,
	CASE WHEN o.orphan_FK > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM orphan_records o
CROSS JOIN applicable_rows a


-- RI-002: Drill-down: Unmatched Values (Orphan Records)
WITH unmatched AS (
	SELECT
		child.account_id AS unmatched_value,
		COUNT(*) AS unmatched_value_count
	FROM raw.raw_hcp_account_affiliations AS child
	LEFT JOIN raw.raw_customer_accounts AS parent ON child.account_id = parent.account_id
	WHERE child.account_id IS NOT NULL AND TRIM(child.account_id) != ''
		AND parent.account_id IS NULL
	GROUP BY child.account_id
)
SELECT
	unmatched_value,
	unmatched_value_count,
	SUM(unmatched_value_count) OVER () AS total_unmatched,
	CONCAT(
		CAST(ROUND(unmatched_value_count * 100.0 / SUM(unmatched_value_count) OVER (), 2) AS DECIMAL(5,2)),
		'%'
	) AS total_unmatched_pct
FROM unmatched
ORDER BY unmatched_value_count DESC


-- ============================================================
-- 03. raw_interactions
-- ============================================================

-- ------------------------------------------------------------
-- hcp_id
-- RI-003: hcp_id must match raw_hcp.hcp_id; orphan count must be 0
-- ------------------------------------------------------------
WITH orphan_records AS (
	-- Count child rows with a non-blank id that has no matching id in parent table (orphan FK)
	SELECT COUNT(*) AS orphan_FK
	FROM raw.raw_interactions AS child
	LEFT JOIN raw.raw_hcp AS parent ON child.hcp_id = parent.hcp_id
	WHERE child.hcp_id IS NOT NULL AND TRIM(child.hcp_id) != ''
		AND parent.hcp_id IS NULL
),
applicable_rows AS (
	-- Denominator = rows with a non-blank id only, not the full table.
	-- Avoids diluting match_rate if some rows have blank id.
	SELECT COUNT(*) AS total_applicable
	FROM raw.raw_interactions
	WHERE hcp_id IS NOT NULL AND TRIM(hcp_id) != ''
)
SELECT
	a.total_applicable AS child_rows,
	a.total_applicable - o.orphan_FK AS matched_rows,
	o.orphan_FK,
	CONCAT(
		CAST(ROUND((a.total_applicable - o.orphan_FK) * 100.0 / a.total_applicable, 2) AS DECIMAL(5,2)),
		'%'
	) AS match_rate,
	CASE WHEN o.orphan_FK > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM orphan_records o
CROSS JOIN applicable_rows a


-- RI-003: Drill-down: Unmatched Values (Orphan Records)
WITH unmatched AS (
	SELECT
		child.hcp_id AS unmatched_value,
		COUNT(*) AS unmatched_value_count
	FROM raw.raw_interactions AS child
	LEFT JOIN raw.raw_hcp AS parent ON child.hcp_id = parent.hcp_id
	WHERE child.hcp_id IS NOT NULL AND TRIM(child.hcp_id) != ''
		AND parent.hcp_id IS NULL
	GROUP BY child.hcp_id
)
SELECT
	unmatched_value,
	unmatched_value_count,
	SUM(unmatched_value_count) OVER () AS total_unmatched,
	CONCAT(
		CAST(ROUND(unmatched_value_count * 100.0 / SUM(unmatched_value_count) OVER (), 2) AS DECIMAL(5,2)),
		'%'
	) AS total_unmatched_pct
FROM unmatched
ORDER BY unmatched_value_count DESC


-- ------------------------------------------------------------
-- account_id
-- RI-004: account_id must match raw_customer_accounts.account_id; orphan count must be 0
-- ------------------------------------------------------------
WITH orphan_records AS (
	-- Count child rows with a non-blank id that has no matching id in parent table (orphan FK)
	SELECT COUNT(*) AS orphan_FK
	FROM raw.raw_interactions AS child
	LEFT JOIN raw.raw_customer_accounts AS parent ON child.account_id = parent.account_id
	WHERE child.account_id IS NOT NULL AND TRIM(child.account_id) != ''
		AND parent.account_id IS NULL
),
applicable_rows AS (
	-- Denominator = rows with a non-blank id only, not the full table.
	-- Avoids diluting match_rate if some rows have blank id.
	SELECT COUNT(*) AS total_applicable
	FROM raw.raw_interactions
	WHERE account_id IS NOT NULL AND TRIM(account_id) != ''
)
SELECT
	a.total_applicable AS child_rows,
	a.total_applicable - o.orphan_FK AS matched_rows,
	o.orphan_FK,
	CONCAT(
		CAST(ROUND((a.total_applicable - o.orphan_FK) * 100.0 / a.total_applicable, 2) AS DECIMAL(5,2)),
		'%'
	) AS match_rate,
	CASE WHEN o.orphan_FK > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM orphan_records o
CROSS JOIN applicable_rows a


-- RI-004: Drill-down: Unmatched Values (Orphan Records)
WITH unmatched AS (
	SELECT
		child.account_id AS unmatched_value,
		COUNT(*) AS unmatched_value_count
	FROM raw.raw_interactions AS child
	LEFT JOIN raw.raw_customer_accounts AS parent ON child.account_id = parent.account_id
	WHERE child.account_id IS NOT NULL AND TRIM(child.account_id) != ''
		AND parent.account_id IS NULL
	GROUP BY child.account_id
)
SELECT
	unmatched_value,
	unmatched_value_count,
	SUM(unmatched_value_count) OVER () AS total_unmatched,
	CONCAT(
		CAST(ROUND(unmatched_value_count * 100.0 / SUM(unmatched_value_count) OVER (), 2) AS DECIMAL(5,2)),
		'%'
	) AS total_unmatched_pct
FROM unmatched
ORDER BY unmatched_value_count DESC


-- ------------------------------------------------------------
-- rep_id
-- RI-005: rep_id must match raw_field_reps.rep_id; orphan count must be 0
-- ------------------------------------------------------------
WITH orphan_records AS (
	-- Count child rows with a non-blank id that has no matching id in parent table (orphan FK)
	SELECT COUNT(*) AS orphan_FK
	FROM raw.raw_interactions AS child
	LEFT JOIN raw.raw_field_reps AS parent ON child.rep_id = parent.rep_id
	WHERE child.rep_id IS NOT NULL AND TRIM(child.rep_id) != ''
		AND parent.rep_id IS NULL
),
applicable_rows AS (
	-- Denominator = rows with a non-blank id only, not the full table.
	-- Avoids diluting match_rate if some rows have blank id.
	SELECT COUNT(*) AS total_applicable
	FROM raw.raw_interactions
	WHERE rep_id IS NOT NULL AND TRIM(rep_id) != ''
)
SELECT
	a.total_applicable AS child_rows,
	a.total_applicable - o.orphan_FK AS matched_rows,
	o.orphan_FK,
	CONCAT(
		CAST(ROUND((a.total_applicable - o.orphan_FK) * 100.0 / a.total_applicable, 2) AS DECIMAL(5,2)),
		'%'
	) AS match_rate,
	CASE WHEN o.orphan_FK > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM orphan_records o
CROSS JOIN applicable_rows a


-- RI-005: Drill-down: Unmatched Values (Orphan Records)
WITH unmatched AS (
	SELECT
		child.rep_id AS unmatched_value,
		COUNT(*) AS unmatched_value_count
	FROM raw.raw_interactions AS child
	LEFT JOIN raw.raw_field_reps AS parent ON child.rep_id = parent.rep_id
	WHERE child.rep_id IS NOT NULL AND TRIM(child.rep_id) != ''
		AND parent.rep_id IS NULL
	GROUP BY child.rep_id
)
SELECT
	unmatched_value,
	unmatched_value_count,
	SUM(unmatched_value_count) OVER () AS total_unmatched,
	CONCAT(
		CAST(ROUND(unmatched_value_count * 100.0 / SUM(unmatched_value_count) OVER (), 2) AS DECIMAL(5,2)),
		'%'
	) AS total_unmatched_pct
FROM unmatched
ORDER BY unmatched_value_count DESC


-- ------------------------------------------------------------
-- product_id
-- RI-006: product_id must match raw_products.product_id; orphan count must be 0
-- ------------------------------------------------------------
WITH orphan_records AS (
	-- Count child rows with a non-blank id that has no matching id in parent table (orphan FK)
	SELECT COUNT(*) AS orphan_FK
	FROM raw.raw_interactions AS child
	LEFT JOIN raw.raw_products AS parent ON child.product_id = parent.product_id
	WHERE child.product_id IS NOT NULL AND TRIM(child.product_id) != ''
		AND parent.product_id IS NULL
),
applicable_rows AS (
	-- Denominator = rows with a non-blank id only, not the full table.
	-- Avoids diluting match_rate if some rows have blank id.
	SELECT COUNT(*) AS total_applicable
	FROM raw.raw_interactions
	WHERE product_id IS NOT NULL AND TRIM(product_id) != ''
)
SELECT
	a.total_applicable AS child_rows,
	a.total_applicable - o.orphan_FK AS matched_rows,
	o.orphan_FK,
	CONCAT(
		CAST(ROUND((a.total_applicable - o.orphan_FK) * 100.0 / a.total_applicable, 2) AS DECIMAL(5,2)),
		'%'
	) AS match_rate,
	CASE WHEN o.orphan_FK > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM orphan_records o
CROSS JOIN applicable_rows a


-- RI-006: Drill-down: Unmatched Values (Orphan Records)
WITH unmatched AS (
	SELECT
		child.product_id AS unmatched_value,
		COUNT(*) AS unmatched_value_count
	FROM raw.raw_interactions AS child
	LEFT JOIN raw.raw_products AS parent ON child.product_id = parent.product_id
	WHERE child.product_id IS NOT NULL AND TRIM(child.product_id) != ''
		AND parent.product_id IS NULL
	GROUP BY child.product_id
)
SELECT
	unmatched_value,
	unmatched_value_count,
	SUM(unmatched_value_count) OVER () AS total_unmatched,
	CONCAT(
		CAST(ROUND(unmatched_value_count * 100.0 / SUM(unmatched_value_count) OVER (), 2) AS DECIMAL(5,2)),
		'%'
	) AS total_unmatched_pct
FROM unmatched
ORDER BY unmatched_value_count DESC


-- ============================================================
-- 04. raw_events
-- ============================================================

-- ------------------------------------------------------------
-- product_id
-- RI-007: product_id must match raw_products.product_id; orphan count must be 0
-- ------------------------------------------------------------
WITH orphan_records AS (
	-- Count child rows with a non-blank id that has no matching id in parent table (orphan FK)
	SELECT COUNT(*) AS orphan_FK
	FROM raw.raw_events AS child
	LEFT JOIN raw.raw_products AS parent ON child.product_id = parent.product_id
	WHERE child.product_id IS NOT NULL AND TRIM(child.product_id) != ''
		AND parent.product_id IS NULL
),
applicable_rows AS (
	-- Denominator = rows with a non-blank id only, not the full table.
	-- Avoids diluting match_rate if some rows have blank id.
	SELECT COUNT(*) AS total_applicable
	FROM raw.raw_events
	WHERE product_id IS NOT NULL AND TRIM(product_id) != ''
)
SELECT
	a.total_applicable AS child_rows,
	a.total_applicable - o.orphan_FK AS matched_rows,
	o.orphan_FK,
	CONCAT(
		CAST(ROUND((a.total_applicable - o.orphan_FK) * 100.0 / a.total_applicable, 2) AS DECIMAL(5,2)),
		'%'
	) AS match_rate,
	CASE WHEN o.orphan_FK > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM orphan_records o
CROSS JOIN applicable_rows a


-- RI-007: Drill-down: Unmatched Values (Orphan Records)
WITH unmatched AS (
	SELECT
		child.product_id AS unmatched_value,
		COUNT(*) AS unmatched_value_count
	FROM raw.raw_events AS child
	LEFT JOIN raw.raw_products AS parent ON child.product_id = parent.product_id
	WHERE child.product_id IS NOT NULL AND TRIM(child.product_id) != ''
		AND parent.product_id IS NULL
	GROUP BY child.product_id
)
SELECT
	unmatched_value,
	unmatched_value_count,
	SUM(unmatched_value_count) OVER () AS total_unmatched,
	CONCAT(
		CAST(ROUND(unmatched_value_count * 100.0 / SUM(unmatched_value_count) OVER (), 2) AS DECIMAL(5,2)),
		'%'
	) AS total_unmatched_pct
FROM unmatched
ORDER BY unmatched_value_count DESC


-- ============================================================
-- 05. raw_event_registrations
-- ============================================================

-- ------------------------------------------------------------
-- event_id
-- RI-008: event_id must match raw_events.event_id; orphan count must be 0
-- ------------------------------------------------------------
WITH orphan_records AS (
	-- Count child rows with a non-blank id that has no matching id in parent table (orphan FK)
	SELECT COUNT(*) AS orphan_FK
	FROM raw.raw_event_registrations AS child
	LEFT JOIN raw.raw_events AS parent ON child.event_id = parent.event_id
	WHERE child.event_id IS NOT NULL AND TRIM(child.event_id) != ''
		AND parent.event_id IS NULL
),
applicable_rows AS (
	-- Denominator = rows with a non-blank id only, not the full table.
	-- Avoids diluting match_rate if some rows have blank id.
	SELECT COUNT(*) AS total_applicable
	FROM raw.raw_event_registrations
	WHERE event_id IS NOT NULL AND TRIM(event_id) != ''
)
SELECT
	a.total_applicable AS child_rows,
	a.total_applicable - o.orphan_FK AS matched_rows,
	o.orphan_FK,
	CONCAT(
		CAST(ROUND((a.total_applicable - o.orphan_FK) * 100.0 / a.total_applicable, 2) AS DECIMAL(5,2)),
		'%'
	) AS match_rate,
	CASE WHEN o.orphan_FK > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM orphan_records o
CROSS JOIN applicable_rows a


-- RI-008: Drill-down: Unmatched Values (Orphan Records)
WITH unmatched AS (
	SELECT
		child.event_id AS unmatched_value,
		COUNT(*) AS unmatched_value_count
	FROM raw.raw_event_registrations AS child
	LEFT JOIN raw.raw_events AS parent ON child.event_id = parent.event_id
	WHERE child.event_id IS NOT NULL AND TRIM(child.event_id) != ''
		AND parent.event_id IS NULL
	GROUP BY child.event_id
)
SELECT
	unmatched_value,
	unmatched_value_count,
	SUM(unmatched_value_count) OVER () AS total_unmatched,
	CONCAT(
		CAST(ROUND(unmatched_value_count * 100.0 / SUM(unmatched_value_count) OVER (), 2) AS DECIMAL(5,2)),
		'%'
	) AS total_unmatched_pct
FROM unmatched
ORDER BY unmatched_value_count DESC


-- ------------------------------------------------------------
-- hcp_id
-- RI-009: hcp_id must match raw_hcp.hcp_id; orphan count must be 0
-- ------------------------------------------------------------
WITH orphan_records AS (
	-- Count child rows with a non-blank id that has no matching id in parent table (orphan FK)
	SELECT COUNT(*) AS orphan_FK
	FROM raw.raw_event_registrations AS child
	LEFT JOIN raw.raw_hcp AS parent ON child.hcp_id = parent.hcp_id
	WHERE child.hcp_id IS NOT NULL AND TRIM(child.hcp_id) != ''
		AND parent.hcp_id IS NULL
),
applicable_rows AS (
	-- Denominator = rows with a non-blank id only, not the full table.
	-- Avoids diluting match_rate if some rows have blank id.
	SELECT COUNT(*) AS total_applicable
	FROM raw.raw_event_registrations
	WHERE hcp_id IS NOT NULL AND TRIM(hcp_id) != ''
)
SELECT
	a.total_applicable AS child_rows,
	a.total_applicable - o.orphan_FK AS matched_rows,
	o.orphan_FK,
	CONCAT(
		CAST(ROUND((a.total_applicable - o.orphan_FK) * 100.0 / a.total_applicable, 2) AS DECIMAL(5,2)),
		'%'
	) AS match_rate,
	CASE WHEN o.orphan_FK > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM orphan_records o
CROSS JOIN applicable_rows a


-- RI-009: Drill-down: Unmatched Values (Orphan Records)
WITH unmatched AS (
	SELECT
		child.hcp_id AS unmatched_value,
		COUNT(*) AS unmatched_value_count
	FROM raw.raw_event_registrations AS child
	LEFT JOIN raw.raw_hcp AS parent ON child.hcp_id = parent.hcp_id
	WHERE child.hcp_id IS NOT NULL AND TRIM(child.hcp_id) != ''
		AND parent.hcp_id IS NULL
	GROUP BY child.hcp_id
)
SELECT
	unmatched_value,
	unmatched_value_count,
	SUM(unmatched_value_count) OVER () AS total_unmatched,
	CONCAT(
		CAST(ROUND(unmatched_value_count * 100.0 / SUM(unmatched_value_count) OVER (), 2) AS DECIMAL(5,2)),
		'%'
	) AS total_unmatched_pct
FROM unmatched
ORDER BY unmatched_value_count DESC


-- ============================================================
-- 06. raw_sales
-- ============================================================

-- ------------------------------------------------------------
-- account_id
-- RI-010: account_id must match raw_customer_accounts.account_id; orphan count must be 0
-- ------------------------------------------------------------
WITH orphan_records AS (
	-- Count child rows with a non-blank id that has no matching id in parent table (orphan FK)
	SELECT COUNT(*) AS orphan_FK
	FROM raw.raw_sales AS child
	LEFT JOIN raw.raw_customer_accounts AS parent ON child.account_id = parent.account_id
	WHERE child.account_id IS NOT NULL AND TRIM(child.account_id) != ''
		AND parent.account_id IS NULL
),
applicable_rows AS (
	-- Denominator = rows with a non-blank id only, not the full table.
	-- Avoids diluting match_rate if some rows have blank id.
	SELECT COUNT(*) AS total_applicable
	FROM raw.raw_sales
	WHERE account_id IS NOT NULL AND TRIM(account_id) != ''
)
SELECT
	a.total_applicable AS child_rows,
	a.total_applicable - o.orphan_FK AS matched_rows,
	o.orphan_FK,
	CONCAT(
		CAST(ROUND((a.total_applicable - o.orphan_FK) * 100.0 / a.total_applicable, 2) AS DECIMAL(5,2)),
		'%'
	) AS match_rate,
	CASE WHEN o.orphan_FK > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM orphan_records o
CROSS JOIN applicable_rows a


-- RI-010: Drill-down: Unmatched Values (Orphan Records)
WITH unmatched AS (
	SELECT
		child.account_id AS unmatched_value,
		COUNT(*) AS unmatched_value_count
	FROM raw.raw_sales AS child
	LEFT JOIN raw.raw_customer_accounts AS parent ON child.account_id = parent.account_id
	WHERE child.account_id IS NOT NULL AND TRIM(child.account_id) != ''
		AND parent.account_id IS NULL
	GROUP BY child.account_id
)
SELECT
	unmatched_value,
	unmatched_value_count,
	SUM(unmatched_value_count) OVER () AS total_unmatched,
	CONCAT(
		CAST(ROUND(unmatched_value_count * 100.0 / SUM(unmatched_value_count) OVER (), 2) AS DECIMAL(5,2)),
		'%'
	) AS total_unmatched_pct
FROM unmatched
ORDER BY unmatched_value_count DESC


-- ------------------------------------------------------------
-- product_id
-- RI-011: product_id must match raw_products.product_id; orphan count must be 0
-- ------------------------------------------------------------
WITH orphan_records AS (
	-- Count child rows with a non-blank id that has no matching id in parent table (orphan FK)
	SELECT COUNT(*) AS orphan_FK
	FROM raw.raw_sales AS child
	LEFT JOIN raw.raw_products AS parent ON child.product_id = parent.product_id
	WHERE child.product_id IS NOT NULL AND TRIM(child.product_id) != ''
		AND parent.product_id IS NULL
),
applicable_rows AS (
	-- Denominator = rows with a non-blank id only, not the full table.
	-- Avoids diluting match_rate if some rows have blank id.
	SELECT COUNT(*) AS total_applicable
	FROM raw.raw_sales
	WHERE product_id IS NOT NULL AND TRIM(product_id) != ''
)
SELECT
	a.total_applicable AS child_rows,
	a.total_applicable - o.orphan_FK AS matched_rows,
	o.orphan_FK,
	CONCAT(
		CAST(ROUND((a.total_applicable - o.orphan_FK) * 100.0 / a.total_applicable, 2) AS DECIMAL(5,2)),
		'%'
	) AS match_rate,
	CASE WHEN o.orphan_FK > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM orphan_records o
CROSS JOIN applicable_rows a


-- RI-011: Drill-down: Unmatched Values (Orphan Records)
WITH unmatched AS (
	SELECT
		child.product_id AS unmatched_value,
		COUNT(*) AS unmatched_value_count
	FROM raw.raw_sales AS child
	LEFT JOIN raw.raw_products AS parent ON child.product_id = parent.product_id
	WHERE child.product_id IS NOT NULL AND TRIM(child.product_id) != ''
		AND parent.product_id IS NULL
	GROUP BY child.product_id
)
SELECT
	unmatched_value,
	unmatched_value_count,
	SUM(unmatched_value_count) OVER () AS total_unmatched,
	CONCAT(
		CAST(ROUND(unmatched_value_count * 100.0 / SUM(unmatched_value_count) OVER (), 2) AS DECIMAL(5,2)),
		'%'
	) AS total_unmatched_pct
FROM unmatched
ORDER BY unmatched_value_count DESC


-- ============================================================
-- 07. raw_campaigns
-- ============================================================

-- ------------------------------------------------------------
-- product_id
-- RI-012: product_id must match raw_products.product_id; orphan count must be 0
-- ------------------------------------------------------------
WITH orphan_records AS (
	-- Count child rows with a non-blank id that has no matching id in parent table (orphan FK)
	SELECT COUNT(*) AS orphan_FK
	FROM raw.raw_campaigns AS child
	LEFT JOIN raw.raw_products AS parent ON child.product_id = parent.product_id
	WHERE child.product_id IS NOT NULL AND TRIM(child.product_id) != ''
		AND parent.product_id IS NULL
),
applicable_rows AS (
	-- Denominator = rows with a non-blank id only, not the full table.
	-- Avoids diluting match_rate if some rows have blank id.
	SELECT COUNT(*) AS total_applicable
	FROM raw.raw_campaigns
	WHERE product_id IS NOT NULL AND TRIM(product_id) != ''
)
SELECT
	a.total_applicable AS child_rows,
	a.total_applicable - o.orphan_FK AS matched_rows,
	o.orphan_FK,
	CONCAT(
		CAST(ROUND((a.total_applicable - o.orphan_FK) * 100.0 / a.total_applicable, 2) AS DECIMAL(5,2)),
		'%'
	) AS match_rate,
	CASE WHEN o.orphan_FK > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM orphan_records o
CROSS JOIN applicable_rows a


-- RI-012: Drill-down: Unmatched Values (Orphan Records)
WITH unmatched AS (
	SELECT
		child.product_id AS unmatched_value,
		COUNT(*) AS unmatched_value_count
	FROM raw.raw_campaigns AS child
	LEFT JOIN raw.raw_products AS parent ON child.product_id = parent.product_id
	WHERE child.product_id IS NOT NULL AND TRIM(child.product_id) != ''
		AND parent.product_id IS NULL
	GROUP BY child.product_id
)
SELECT
	unmatched_value,
	unmatched_value_count,
	SUM(unmatched_value_count) OVER () AS total_unmatched,
	CONCAT(
		CAST(ROUND(unmatched_value_count * 100.0 / SUM(unmatched_value_count) OVER (), 2) AS DECIMAL(5,2)),
		'%'
	) AS total_unmatched_pct
FROM unmatched
ORDER BY unmatched_value_count DESC
