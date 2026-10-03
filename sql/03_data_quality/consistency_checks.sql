-- ============================================================
-- CONSISTENCY CHECK
-- File name: consistency_checks.sql
-- Purpose: Identify inconsistencies in value casing, spelling, and representation
-- Rules covered: Consistency-related DQ rules in the Data Quality Rule Catalog
-- Scope: raw_hcp, raw_customer_accounts, raw_products, raw_field_reps, raw_events, raw_campaigns
-- Source: Data Quality Rule Catalog
-- Expected Result: Each rule should return 0 violations unless exceptions are explicitly documented
-- ============================================================

-- ============================================================
-- 01. raw_hcp
-- ============================================================

-- ------------------------------------------------------------
-- hcp_name
-- DQ-004: Equivalent HCP names should use a consistent case representation
-- ------------------------------------------------------------
WITH normalized AS (
	SELECT hcp_name, LOWER(TRIM(hcp_name)) AS normalized_name
	FROM raw.raw_hcp
	WHERE hcp_name IS NOT NULL AND TRIM(hcp_name) != ''
),
case_conflict_groups AS (
	SELECT normalized_name
	FROM normalized
	GROUP BY normalized_name
	HAVING COUNT(DISTINCT hcp_name) > 1
)
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_hcp), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct
FROM normalized n
JOIN case_conflict_groups c ON n.normalized_name = c.normalized_name


-- ------------------------------------------------------------
-- email
-- DQ-011: Equivalent email values should use a consistent case representation
-- ------------------------------------------------------------
WITH normalized AS (
	SELECT email, LOWER(TRIM(email)) AS normalized_email
	FROM raw.raw_hcp
	WHERE email IS NOT NULL AND TRIM(email) != ''
),
case_conflict_groups AS (
	SELECT normalized_email
	FROM normalized
	GROUP BY normalized_email
	HAVING COUNT(DISTINCT email) > 1
)
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_hcp), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct
FROM normalized n
JOIN case_conflict_groups c ON n.normalized_email = c.normalized_email


-- ============================================================
-- 02. raw_customer_accounts
-- ============================================================

-- ------------------------------------------------------------
-- account_name
-- DQ-019: Equivalent account names should use a consistent case representation
-- ------------------------------------------------------------
WITH normalized AS (
	SELECT account_name, LOWER(TRIM(account_name)) AS normalized_account_name
	FROM raw.raw_customer_accounts
	WHERE account_name IS NOT NULL AND TRIM(account_name) != ''
),
case_conflict_groups AS (
	SELECT normalized_account_name
	FROM normalized
	GROUP BY normalized_account_name
	HAVING COUNT(DISTINCT account_name) > 1
)
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_customer_accounts), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct
FROM normalized n
JOIN case_conflict_groups c ON n.normalized_account_name = c.normalized_account_name


-- ============================================================
-- 03. raw_products
-- ============================================================

-- ------------------------------------------------------------
-- product_name
-- DQ-043: Equivalent product names should use a consistent case representation
-- ------------------------------------------------------------
WITH normalized AS (
	SELECT product_name, LOWER(TRIM(product_name)) AS normalized_product_name
	FROM raw.raw_products
	WHERE product_name IS NOT NULL AND TRIM(product_name) != ''
),
case_conflict_groups AS (
	SELECT normalized_product_name
	FROM normalized
	GROUP BY normalized_product_name
	HAVING COUNT(DISTINCT product_name) > 1
)
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_products), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct
FROM normalized n
JOIN case_conflict_groups c ON n.normalized_product_name = c.normalized_product_name


-- ============================================================
-- 04. raw_field_reps
-- ============================================================

-- ------------------------------------------------------------
-- rep_name
-- DQ-054: Equivalent field-rep names should use a consistent case representation
-- ------------------------------------------------------------
WITH normalized AS (
	SELECT rep_name, LOWER(TRIM(rep_name)) AS normalized_rep_name
	FROM raw.raw_field_reps
	WHERE rep_name IS NOT NULL AND TRIM(rep_name) != ''
),
case_conflict_groups AS (
	SELECT normalized_rep_name
	FROM normalized
	GROUP BY normalized_rep_name
	HAVING COUNT(DISTINCT rep_name) > 1
)
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_field_reps), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct
FROM normalized n
JOIN case_conflict_groups c ON n.normalized_rep_name = c.normalized_rep_name


-- ============================================================
-- 05. raw_events
-- ============================================================

-- ------------------------------------------------------------
-- event_name
-- DQ-082: Equivalent event names should use a consistent case representation
-- ------------------------------------------------------------
WITH normalized AS (
	SELECT event_name, LOWER(TRIM(event_name)) AS normalized_event_name
	FROM raw.raw_events
	WHERE event_name IS NOT NULL AND TRIM(event_name) != ''
),
case_conflict_groups AS (
	SELECT normalized_event_name
	FROM normalized
	GROUP BY normalized_event_name
	HAVING COUNT(DISTINCT event_name) > 1
)
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_events), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct
FROM normalized n
JOIN case_conflict_groups c ON n.normalized_event_name = c.normalized_event_name


-- ============================================================
-- 06. raw_campaigns
-- ============================================================

-- ------------------------------------------------------------
-- campaign_name
-- DQ-128: Equivalent campaign names should use a consistent case representation
-- ------------------------------------------------------------
WITH normalized AS (
	SELECT campaign_name, LOWER(TRIM(campaign_name)) AS normalized_campaign_name
	FROM raw.raw_campaigns
	WHERE campaign_name IS NOT NULL AND TRIM(campaign_name) != ''
),
case_conflict_groups AS (
	SELECT normalized_campaign_name
	FROM normalized
	GROUP BY normalized_campaign_name
	HAVING COUNT(DISTINCT campaign_name) > 1
)
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_campaigns), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct
FROM normalized n
JOIN case_conflict_groups c ON n.normalized_campaign_name = c.normalized_campaign_name
