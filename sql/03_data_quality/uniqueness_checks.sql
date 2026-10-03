-- ============================================================
-- UNIQUENESS CHECK
-- Purpose: Assess the uniqueness of values and identify duplicates in the column.

-- File name: uniqueness_checks.sql
-- Purpose: Assess the uniqueness of values and identify duplicates in the column
-- Rules covered: Uniqueness-related DQ rules in the Data Quality Rule Catalog
-- Scope: raw_hcp, raw_customer_accounts, hcp_account_affiliations, raw_products, raw_field_reps, raw_interactions, raw_events, raw_event_registrations, raw_sales, raw_campaigns
-- Source: Data Quality Rule Catalog
-- Expected Result: Each rule should return 0 violations unless exceptions are explicitly documented
-- ============================================================

-- ============================================================
-- 01. raw_hcp
-- ============================================================

-- ------------------------------------------------------------
-- hcp_id
-- DQ-002: hcp_id must be unique; duplicate count must be 0
-- ------------------------------------------------------------
SELECT
	COUNT(*) - COUNT(DISTINCT hcp_id) AS violation_count,
	CONCAT(
		CAST(ROUND((COUNT(*) - COUNT(DISTINCT hcp_id)) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		 '%'
	) AS violation_pct,
	CASE
		WHEN (COUNT(*) - COUNT(DISTINCT hcp_id) * 100.0 / COUNT(*)) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp
WHERE hcp_id IS NOT NULL AND TRIM(hcp_id) != ''


-- ------------------------------------------------------------
-- email
-- DQ-140: email must be unique; duplicate count must be 0
-- ------------------------------------------------------------
-- [BEFORE - outdated] Filters NULL/blank but not the "invalid-email" sentinel yet, gives 54.
SELECT
	COUNT(*) - COUNT(DISTINCT email) AS violation_count,
	CONCAT(
		CAST(ROUND((COUNT(*) - COUNT(DISTINCT email)) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		 '%'
	) AS violation_pct,
	CASE
		WHEN (COUNT(*) - COUNT(DISTINCT email) * 100.0 / COUNT(*)) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp
WHERE email IS NOT NULL AND TRIM(email) != ''


-- [AFTER - current] Also excludes "invalid-email" sentinel (DQ-142).
SELECT
	COUNT(*) - COUNT(DISTINCT email) AS violation_count,
	CONCAT(
		CAST(ROUND((COUNT(*) - COUNT(DISTINCT email)) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN (COUNT(*) - COUNT(DISTINCT email)) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp
WHERE email IS NOT NULL AND TRIM(email) <> '' AND email <> 'invalid-email'


-- ------------------------------------------------------------
-- phone
-- DQ-141: phone must be unique; duplicate count must be 0
-- ------------------------------------------------------------
-- [BEFORE - outdated] Filters NULL/blank but not the "12345" sentinel yet, gives 49.

SELECT
	COUNT(*) - COUNT(DISTINCT phone) AS violation_count,
	CONCAT(
		CAST(ROUND((COUNT(*) - COUNT(DISTINCT phone)) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		 '%'
	) AS violation_pct,
	CASE
		WHEN (COUNT(*) - COUNT(DISTINCT phone) * 100.0 / COUNT(*)) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp
WHERE phone IS NOT NULL AND TRIM(phone) != ''


-- [AFTER - current] Also excludes "12345" sentinel (DQ-143).
SELECT
	COUNT(*) - COUNT(DISTINCT phone) AS violation_count,
	CONCAT(
		CAST(ROUND((COUNT(*) - COUNT(DISTINCT phone)) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		 '%'
	) AS violation_pct,
	CASE
		WHEN (COUNT(*) - COUNT(DISTINCT phone) * 100.0 / COUNT(*)) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp
WHERE phone IS NOT NULL AND TRIM(phone) != '' AND phone != '12345'


-- ============================================================
-- 02. raw_customer_accounts
-- ============================================================

-- ------------------------------------------------------------
-- account_id
-- DQ-016: account_id must be unique; duplicate count must be 0
-- ------------------------------------------------------------
SELECT
	COUNT(*) - COUNT(DISTINCT account_id) AS violation_count,
	CONCAT(
		CAST(ROUND((COUNT(*) - COUNT(DISTINCT account_id)) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		 '%'
	) AS violation_pct,
	CASE
		WHEN (COUNT(*) - COUNT(DISTINCT account_id) * 100.0 / COUNT(*)) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_customer_accounts
WHERE account_id IS NOT NULL AND TRIM(account_id) != ''


-- ============================================================
-- 03. hcp_account_affiliations
-- ============================================================

-- ------------------------------------------------------------
-- affiliation_id
-- DQ-029: affiliation_id must be unique; duplicate count must be 0
-- ------------------------------------------------------------
SELECT
	COUNT(*) - COUNT(DISTINCT affiliation_id) AS violation_count,
	CONCAT(
		CAST(ROUND((COUNT(*) - COUNT(DISTINCT affiliation_id)) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		 '%'
	) AS violation_pct,
	CASE
		WHEN (COUNT(*) - COUNT(DISTINCT affiliation_id) * 100.0 / COUNT(*)) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp_account_affiliations
WHERE affiliation_id IS NOT NULL AND TRIM(affiliation_id) != ''


-- ============================================================
-- 04. raw_products
-- ============================================================

-- ------------------------------------------------------------
-- product_id
-- DQ-040: product_id must be unique; duplicate count must be 0
-- ------------------------------------------------------------
SELECT
	COUNT(*) - COUNT(DISTINCT product_id) AS violation_count,
	CONCAT(
		CAST(ROUND((COUNT(*) - COUNT(DISTINCT product_id)) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		 '%'
	) AS violation_pct,
	CASE
		WHEN (COUNT(*) - COUNT(DISTINCT product_id) * 100.0 / COUNT(*)) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_products
WHERE product_id IS NOT NULL AND TRIM(product_id) != ''


-- ============================================================
-- 05. raw_field_reps
-- ============================================================

-- ------------------------------------------------------------
-- rep_id
-- DQ-051: rep_id must be unique; duplicate count must be 0
-- ------------------------------------------------------------
SELECT
	COUNT(*) - COUNT(DISTINCT rep_id) AS violation_count,
	CONCAT(
		CAST(ROUND((COUNT(*) - COUNT(DISTINCT rep_id)) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		 '%'
	) AS violation_pct,
	CASE
		WHEN (COUNT(*) - COUNT(DISTINCT rep_id) * 100.0 / COUNT(*)) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_field_reps
WHERE rep_id IS NOT NULL AND TRIM(rep_id) != ''


-- ============================================================
-- 06. raw_interactions
-- ============================================================

-- ------------------------------------------------------------
-- interaction_id
-- DQ-063: interaction_id must be unique; duplicate count must be 0
-- ------------------------------------------------------------
SELECT
	COUNT(*) - COUNT(DISTINCT interaction_id) AS violation_count,
	CONCAT(
		CAST(ROUND((COUNT(*) - COUNT(DISTINCT interaction_id)) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		 '%'
	) AS violation_pct,
	CASE
		WHEN (COUNT(*) - COUNT(DISTINCT interaction_id) * 100.0 / COUNT(*)) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_interactions
WHERE interaction_id IS NOT NULL AND TRIM(interaction_id) != ''


-- ============================================================
-- 07. raw_events
-- ============================================================

-- ------------------------------------------------------------
-- event_id
-- DQ-079: event_id must be unique; duplicate count must be 0
-- ------------------------------------------------------------
SELECT
	COUNT(*) - COUNT(DISTINCT event_id) AS violation_count,
	CONCAT(
		CAST(ROUND((COUNT(*) - COUNT(DISTINCT event_id)) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		 '%'
	) AS violation_pct,
	CASE
		WHEN (COUNT(*) - COUNT(DISTINCT event_id) * 100.0 / COUNT(*)) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_events
WHERE event_id IS NOT NULL AND TRIM(event_id) != ''


-- ============================================================
-- 08. raw_event_registrations
-- ============================================================

-- ------------------------------------------------------------
-- registration_id
-- DQ-096: registration_id must be unique; duplicate count must be 0
-- ------------------------------------------------------------
SELECT
	COUNT(*) - COUNT(DISTINCT registration_id) AS violation_count,
	CONCAT(
		CAST(ROUND((COUNT(*) - COUNT(DISTINCT registration_id)) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		 '%'
	) AS violation_pct,
	CASE
		WHEN (COUNT(*) - COUNT(DISTINCT registration_id) * 100.0 / COUNT(*)) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_event_registrations
WHERE registration_id IS NOT NULL AND TRIM(registration_id) != ''


-- ============================================================
-- 09. raw_sales
-- ============================================================

-- ------------------------------------------------------------
-- sales_id
-- DQ-107: sales_id must be unique; duplicate count must be 0
-- ------------------------------------------------------------
SELECT
	COUNT(*) - COUNT(DISTINCT sales_id) AS violation_count,
	CONCAT(
		CAST(ROUND((COUNT(*) - COUNT(DISTINCT sales_id)) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		 '%'
	) AS violation_pct,
	CASE
		WHEN (COUNT(*) - COUNT(DISTINCT sales_id) * 100.0 / COUNT(*)) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_sales
WHERE sales_id IS NOT NULL AND TRIM(sales_id) != ''


-- ============================================================
-- 10. raw_campaigns
-- ============================================================

-- ------------------------------------------------------------
-- campaign_id
-- DQ-125: campaign_id must be unique; duplicate count must be 0
-- ------------------------------------------------------------
SELECT
	COUNT(*) - COUNT(DISTINCT campaign_id) AS violation_count,
	CONCAT(
		CAST(ROUND((COUNT(*) - COUNT(DISTINCT campaign_id)) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		 '%'
	) AS violation_pct,
	CASE
		WHEN ((COUNT(*) - COUNT(DISTINCT campaign_id)) * 100.0 / COUNT(*)) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_campaigns
WHERE campaign_id IS NOT NULL AND TRIM(campaign_id) != ''
