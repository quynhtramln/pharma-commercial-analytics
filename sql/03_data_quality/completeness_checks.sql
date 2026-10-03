-- ============================================================
-- COMPLETENESS CHECK
-- File name: completeness_checks.sql 
-- Purpose: Identify NULL, blank, or whitespace-only values in required fields
-- Rules covered: Completeness-related DQ rules in the Data Quality Rule Catalog
-- Scope: raw_hcp, raw_customer_accounts, hcp_account_affiliations, raw_products, raw_field_reps, raw_interactions, raw_events, raw_event_registrations, raw_sales, raw_campaigns
-- Source: Data Quality Rule Catalog
-- Expected Result: Each rule should return 0 violations unless exceptions are explicitly documented
-- ============================================================

-- ============================================================
-- 01. raw_hcp
-- ============================================================

-- ------------------------------------------------------------
-- hcp_id
-- DQ-001: hcp_id must be populated for required fields
-- ------------------------------------------------------------
SELECT
 	SUM(CASE WHEN hcp_id IS NULL OR TRIM(hcp_id) = '' THEN 1 ELSE 0 END) AS violation_count,
 	CONCAT(
 		CAST(ROUND(SUM(CASE WHEN hcp_id IS NULL  OR TRIM(hcp_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
 		'%'
 	) AS violation_pct,
 	CASE
 		WHEN SUM(CASE WHEN hcp_id IS NULL OR TRIM(hcp_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
 		ELSE 'Pass'
 	END AS status
FROM raw.raw_hcp


-- ------------------------------------------------------------
-- hcp_name
-- DQ-003: hcp_name must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN hcp_name IS NULL OR TRIM(hcp_name) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN hcp_name IS NULL  OR TRIM(hcp_name) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN hcp_name IS NULL OR TRIM(hcp_name) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp


-- ------------------------------------------------------------
-- hcp_type
-- DQ-005: hcp_type must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN hcp_type IS NULL OR TRIM(hcp_type) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN hcp_type IS NULL  OR TRIM(hcp_type) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN hcp_type IS NULL OR TRIM(hcp_type) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp


-- ------------------------------------------------------------
-- specialty
-- DQ-006: specialty must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN specialty IS NULL OR TRIM(specialty) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN specialty IS NULL  OR TRIM(specialty) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN specialty IS NULL OR TRIM(specialty) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp


-- ------------------------------------------------------------
-- city
-- DQ-007: city must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN city IS NULL OR TRIM(city) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN city IS NULL  OR TRIM(city) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN city IS NULL OR TRIM(city) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp


-- ------------------------------------------------------------
-- territory
-- DQ-008: territory must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN territory IS NULL OR TRIM(territory) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN territory IS NULL  OR TRIM(territory) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN territory IS NULL OR TRIM(territory) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp


-- ------------------------------------------------------------
-- email
-- DQ-009: email must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN email IS NULL OR TRIM(email) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN email IS NULL  OR TRIM(email) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN email IS NULL OR TRIM(email) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp

-- DQ-142: email must not contain known placeholder/dummy values
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN email = 'invalid-email' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN email = 'invalid-email' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN email = 'invalid-email' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp


-- ------------------------------------------------------------
-- phone
-- DQ-012: phone must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN phone IS NULL OR TRIM(phone) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN phone IS NULL  OR TRIM(phone) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN phone IS NULL OR TRIM(phone) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp


-- DQ-143: phone must not contain known placeholder/dummy values
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN phone = '12345' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN phone = '12345' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN phone = '12345' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp


-- ------------------------------------------------------------
-- status
-- DQ-014: status must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN status IS NULL OR TRIM(status) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN status IS NULL  OR TRIM(status) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN status IS NULL OR TRIM(status) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp


-- ============================================================
-- 02. raw_customer_accounts
-- ============================================================

-- ------------------------------------------------------------
-- account_id
-- DQ-015: account_id must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN account_id IS NULL OR TRIM(account_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN account_id IS NULL  OR TRIM(account_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN account_id IS NULL OR TRIM(account_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_customer_accounts


-- ------------------------------------------------------------
-- account_name
-- DQ-017: account_name must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN account_name IS NULL OR TRIM(account_name) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN account_name IS NULL  OR TRIM(account_name) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN account_name IS NULL OR TRIM(account_name) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_customer_accounts


-- ------------------------------------------------------------
-- account_type
-- DQ-020: account_type must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN account_type IS NULL OR TRIM(account_type) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN account_type IS NULL  OR TRIM(account_type) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN account_type IS NULL OR TRIM(account_type) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_customer_accounts


-- ------------------------------------------------------------
-- city
-- DQ-021: city must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN city IS NULL OR TRIM(city) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN city IS NULL  OR TRIM(city) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN city IS NULL OR TRIM(city) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_customer_accounts


-- ------------------------------------------------------------
-- territory
-- DQ-022: territory must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN territory IS NULL OR TRIM(territory) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN territory IS NULL  OR TRIM(territory) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN territory IS NULL OR TRIM(territory) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_customer_accounts


-- ------------------------------------------------------------
-- tax_id
-- DQ-023: tax_id must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN tax_id IS NULL OR TRIM(tax_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN tax_id IS NULL  OR TRIM(tax_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN tax_id IS NULL OR TRIM(tax_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_customer_accounts


-- ------------------------------------------------------------
-- phone
-- DQ-024: phone must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN phone IS NULL OR TRIM(phone) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN phone IS NULL  OR TRIM(phone) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN phone IS NULL OR TRIM(phone) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_customer_accounts


-- ------------------------------------------------------------
-- status
-- DQ-026: status must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN status IS NULL OR TRIM(status) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN status IS NULL  OR TRIM(status) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN status IS NULL OR TRIM(status) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_customer_accounts


-- ============================================================
-- 03. hcp_account_affiliations
-- ============================================================

-- ------------------------------------------------------------
-- affiliation_id
-- DQ-027: affiliation_id must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN affiliation_id IS NULL OR TRIM(affiliation_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN affiliation_id IS NULL  OR TRIM(affiliation_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN affiliation_id IS NULL OR TRIM(affiliation_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp_account_affiliations


-- ------------------------------------------------------------
-- hcp_id
-- DQ-030: hcp_id must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN hcp_id IS NULL OR TRIM(hcp_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN hcp_id IS NULL  OR TRIM(hcp_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN hcp_id IS NULL OR TRIM(hcp_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp_account_affiliations


-- ------------------------------------------------------------
-- account_id
-- DQ-031: account_id must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN account_id IS NULL OR TRIM(account_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN account_id IS NULL  OR TRIM(account_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN account_id IS NULL OR TRIM(account_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp_account_affiliations


-- ------------------------------------------------------------
-- role
-- DQ-032: role must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN role IS NULL OR TRIM(role) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN role IS NULL  OR TRIM(role) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN role IS NULL OR TRIM(role) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp_account_affiliations


-- ------------------------------------------------------------
-- primary_affiliation
-- DQ-033: primary_affiliation must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN primary_affiliation IS NULL OR TRIM(primary_affiliation) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN primary_affiliation IS NULL  OR TRIM(primary_affiliation) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN primary_affiliation IS NULL OR TRIM(primary_affiliation) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp_account_affiliations


-- ------------------------------------------------------------
-- start_date
-- DQ-034: start_date must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN start_date IS NULL OR TRIM(start_date) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN start_date IS NULL  OR TRIM(start_date) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN start_date IS NULL OR TRIM(start_date) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp_account_affiliations


-- ------------------------------------------------------------
-- end_date
-- DQ-036: end_date must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN end_date IS NULL OR TRIM(end_date) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN end_date IS NULL  OR TRIM(end_date) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN end_date IS NULL OR TRIM(end_date) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp_account_affiliations


-- ------------------------------------------------------------
-- status
-- DQ-038: status must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN status IS NULL OR TRIM(status) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN status IS NULL  OR TRIM(status) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN status IS NULL OR TRIM(status) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp_account_affiliations


-- ============================================================
-- 04. raw_products
-- ============================================================

-- ------------------------------------------------------------
-- product_id
-- DQ-039: product_id must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN product_id IS NULL OR TRIM(product_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN product_id IS NULL  OR TRIM(product_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN product_id IS NULL OR TRIM(product_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS product_id
FROM raw.raw_products


-- ------------------------------------------------------------
-- product_name
-- DQ-041: product_name must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN product_name IS NULL OR TRIM(product_name) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN product_name IS NULL  OR TRIM(product_name) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN product_name IS NULL OR TRIM(product_name) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS product_name
FROM raw.raw_products


-- ------------------------------------------------------------
-- therapeutic_area
-- DQ-044: therapeutic_area must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN therapeutic_area IS NULL OR TRIM(therapeutic_area) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN therapeutic_area IS NULL  OR TRIM(therapeutic_area) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN therapeutic_area IS NULL OR TRIM(therapeutic_area) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS therapeutic_area
FROM raw.raw_products


-- ------------------------------------------------------------
-- product_type
-- DQ-045: product_type must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN product_type IS NULL OR TRIM(product_type) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN product_type IS NULL  OR TRIM(product_type) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN product_type IS NULL OR TRIM(product_type) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS product_type
FROM raw.raw_products


-- ------------------------------------------------------------
-- priority_flag
-- DQ-046: priority_flag must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN priority_flag IS NULL OR TRIM(priority_flag) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN priority_flag IS NULL  OR TRIM(priority_flag) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN priority_flag IS NULL OR TRIM(priority_flag) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS priority_flag
FROM raw.raw_products


-- ------------------------------------------------------------
-- launch_date
-- DQ-047: launch_date must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN launch_date IS NULL OR TRIM(launch_date) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN launch_date IS NULL  OR TRIM(launch_date) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN launch_date IS NULL OR TRIM(launch_date) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS launch_date
FROM raw.raw_products


-- ------------------------------------------------------------
-- status
-- DQ-049: status must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN status IS NULL OR TRIM(status) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN status IS NULL  OR TRIM(status) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN status IS NULL OR TRIM(status) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_products


-- ============================================================
-- 05. raw_field_reps
-- ============================================================

-- ------------------------------------------------------------
-- rep_id
-- DQ-050: rep_id must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN rep_id IS NULL OR TRIM(rep_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN rep_id IS NULL  OR TRIM(rep_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN rep_id IS NULL OR TRIM(rep_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_field_reps


-- ------------------------------------------------------------
-- rep_name
-- DQ-052: rep_name must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN rep_name IS NULL OR TRIM(rep_name) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN rep_name IS NULL  OR TRIM(rep_name) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN rep_name IS NULL OR TRIM(rep_name) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_field_reps


-- ------------------------------------------------------------
-- territory
-- DQ-055: territory must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN territory IS NULL OR TRIM(territory) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN territory IS NULL  OR TRIM(territory) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN territory IS NULL OR TRIM(territory) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_field_reps


-- ------------------------------------------------------------
-- base_city
-- DQ-056: base_city must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN base_city IS NULL OR TRIM(base_city) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN base_city IS NULL  OR TRIM(base_city) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN base_city IS NULL OR TRIM(base_city) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_field_reps


-- ------------------------------------------------------------
-- hire_date
-- DQ-057: hire_date must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN hire_date IS NULL OR TRIM(hire_date) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN hire_date IS NULL  OR TRIM(hire_date) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN hire_date IS NULL OR TRIM(hire_date) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS hire_date
FROM raw.raw_field_reps


-- ------------------------------------------------------------
-- status
-- DQ-059: status must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN status IS NULL OR TRIM(status) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN status IS NULL  OR TRIM(status) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN status IS NULL OR TRIM(status) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_field_reps


-- ------------------------------------------------------------
-- specialization
-- DQ-060: specialization must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN specialization IS NULL OR TRIM(specialization) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN specialization IS NULL  OR TRIM(specialization) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN specialization IS NULL OR TRIM(specialization) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_field_reps


-- ============================================================
-- 06. raw_interactions
-- ============================================================

-- ------------------------------------------------------------
-- interaction_id
-- DQ-061: interaction_id must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN interaction_id IS NULL OR TRIM(interaction_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN interaction_id IS NULL  OR TRIM(interaction_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN interaction_id IS NULL OR TRIM(interaction_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_interactions


-- ------------------------------------------------------------
-- interaction_datetime
-- DQ-064: interaction_datetime must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN interaction_datetime IS NULL OR TRIM(interaction_datetime) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN interaction_datetime IS NULL  OR TRIM(interaction_datetime) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN interaction_datetime IS NULL OR TRIM(interaction_datetime) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_interactions


-- ------------------------------------------------------------
-- hcp_id
-- DQ-066: hcp_id must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN hcp_id IS NULL OR TRIM(hcp_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN hcp_id IS NULL  OR TRIM(hcp_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN hcp_id IS NULL OR TRIM(hcp_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_interactions


-- ------------------------------------------------------------
-- account_id
-- DQ-067: account_id must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN account_id IS NULL OR TRIM(account_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN account_id IS NULL  OR TRIM(account_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN account_id IS NULL OR TRIM(account_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_interactions


-- ------------------------------------------------------------
-- rep_id
-- DQ-068: rep_id must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN rep_id IS NULL OR TRIM(rep_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN rep_id IS NULL  OR TRIM(rep_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN rep_id IS NULL OR TRIM(rep_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_interactions


-- ------------------------------------------------------------
-- product_id
-- DQ-069: product_id must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN product_id IS NULL OR TRIM(product_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN product_id IS NULL  OR TRIM(product_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN product_id IS NULL OR TRIM(product_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_interactions


-- ------------------------------------------------------------
-- interaction_type
-- DQ-070: interaction_type must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN interaction_type IS NULL OR TRIM(interaction_type) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN interaction_type IS NULL  OR TRIM(interaction_type) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN interaction_type IS NULL OR TRIM(interaction_type) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_interactions


-- ------------------------------------------------------------
-- channel
-- DQ-071: channel must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN channel IS NULL OR TRIM(channel) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN channel IS NULL  OR TRIM(channel) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN channel IS NULL OR TRIM(channel) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_interactions


-- ------------------------------------------------------------
-- duration_minutes
-- DQ-072: duration_minutes must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN duration_minutes IS NULL OR TRIM(duration_minutes) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN duration_minutes IS NULL  OR TRIM(duration_minutes) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN duration_minutes IS NULL OR TRIM(duration_minutes) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_interactions


-- ------------------------------------------------------------
-- outcome
-- DQ-074: outcome must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN outcome IS NULL OR TRIM(outcome) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN outcome IS NULL  OR TRIM(outcome) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN outcome IS NULL OR TRIM(outcome) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_interactions


-- ------------------------------------------------------------
-- engagement_score
-- DQ-075: engagement_score must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN engagement_score IS NULL OR TRIM(engagement_score) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN engagement_score IS NULL  OR TRIM(engagement_score) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN engagement_score IS NULL OR TRIM(engagement_score) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_interactions


-- ============================================================
-- 07. raw_events
-- ============================================================

-- ------------------------------------------------------------
-- event_id
-- DQ-077: event_id must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN event_id IS NULL OR TRIM(event_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN event_id IS NULL  OR TRIM(event_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN event_id IS NULL OR TRIM(event_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_events


-- ------------------------------------------------------------
-- event_name
-- DQ-080: event_name must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN event_name IS NULL OR TRIM(event_name) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN event_name IS NULL  OR TRIM(event_name) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN event_name IS NULL OR TRIM(event_name) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_events


-- ------------------------------------------------------------
-- event_type
-- DQ-083: event_type must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN event_type IS NULL OR TRIM(event_type) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN event_type IS NULL  OR TRIM(event_type) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN event_type IS NULL OR TRIM(event_type) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_events


-- ------------------------------------------------------------
-- start_date
-- DQ-084: start_date must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN start_date IS NULL OR TRIM(start_date) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN start_date IS NULL  OR TRIM(start_date) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN start_date IS NULL OR TRIM(start_date) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_events


-- ------------------------------------------------------------
-- end_date
-- DQ-086: end_date must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN end_date IS NULL OR TRIM(end_date) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN end_date IS NULL  OR TRIM(end_date) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN end_date IS NULL OR TRIM(end_date) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_events


-- ------------------------------------------------------------
-- city
-- DQ-088: city must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN city IS NULL OR TRIM(city) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN city IS NULL  OR TRIM(city) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN city IS NULL OR TRIM(city) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_events


-- ------------------------------------------------------------
-- territory
-- DQ-089: territory must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN territory IS NULL OR TRIM(territory) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN territory IS NULL  OR TRIM(territory) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN territory IS NULL OR TRIM(territory) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_events


-- ------------------------------------------------------------
-- product_id
-- DQ-090: product_id must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN product_id IS NULL OR TRIM(product_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN product_id IS NULL  OR TRIM(product_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN product_id IS NULL OR TRIM(product_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_events


-- ------------------------------------------------------------
-- budget
-- DQ-091: budget must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN budget IS NULL OR TRIM(budget) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN budget IS NULL  OR TRIM(budget) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN budget IS NULL OR TRIM(budget) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_events


-- ------------------------------------------------------------
-- status
-- DQ-093: status must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN status IS NULL OR TRIM(status) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN status IS NULL  OR TRIM(status) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN status IS NULL OR TRIM(status) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_events


-- ============================================================
-- 08. raw_event_registrations
-- ============================================================

-- ------------------------------------------------------------
-- registration_id
-- DQ-094: registration_id must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN registration_id IS NULL OR TRIM(registration_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN registration_id IS NULL  OR TRIM(registration_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN registration_id IS NULL OR TRIM(registration_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_event_registrations


-- ------------------------------------------------------------
-- event_id
-- DQ-097: event_id must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN event_id IS NULL OR TRIM(event_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN event_id IS NULL  OR TRIM(event_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN event_id IS NULL OR TRIM(event_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_event_registrations


-- ------------------------------------------------------------
-- hcp_id
-- DQ-098: hcp_id must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN hcp_id IS NULL OR TRIM(hcp_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN hcp_id IS NULL  OR TRIM(hcp_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN hcp_id IS NULL OR TRIM(hcp_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_event_registrations


-- ------------------------------------------------------------
-- registration_date
-- DQ-099: registration_date must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN registration_date IS NULL OR TRIM(registration_date) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN registration_date IS NULL  OR TRIM(registration_date) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN registration_date IS NULL OR TRIM(registration_date) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_event_registrations


-- ------------------------------------------------------------
-- attendance_status
-- DQ-101: attendance_status must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN attendance_status IS NULL OR TRIM(attendance_status) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN attendance_status IS NULL  OR TRIM(attendance_status) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN attendance_status IS NULL OR TRIM(attendance_status) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_event_registrations


-- ------------------------------------------------------------
-- follow_up_required
-- DQ-102: follow_up_required must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN follow_up_required IS NULL OR TRIM(follow_up_required) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN follow_up_required IS NULL  OR TRIM(follow_up_required) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN follow_up_required IS NULL OR TRIM(follow_up_required) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_event_registrations


-- ------------------------------------------------------------
-- follow_up_status
-- DQ-103: follow_up_status must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN follow_up_status IS NULL OR TRIM(follow_up_status) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN follow_up_status IS NULL  OR TRIM(follow_up_status) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN follow_up_status IS NULL OR TRIM(follow_up_status) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_event_registrations


-- ------------------------------------------------------------
-- source
-- DQ-104: source must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN source IS NULL OR TRIM(source) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN source IS NULL  OR TRIM(source) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN source IS NULL OR TRIM(source) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_event_registrations


-- ============================================================
-- 09. raw_sales
-- ============================================================

-- ------------------------------------------------------------
-- sales_id
-- DQ-105: sales_id must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN sales_id IS NULL OR TRIM(sales_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN sales_id IS NULL  OR TRIM(sales_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN sales_id IS NULL OR TRIM(sales_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_sales


-- ------------------------------------------------------------
-- sales_date
-- DQ-108: sales_date must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN sales_date IS NULL OR TRIM(sales_date) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN sales_date IS NULL  OR TRIM(sales_date) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN sales_date IS NULL OR TRIM(sales_date) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_sales


-- ------------------------------------------------------------
-- account_id
-- DQ-110: account_id must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN account_id IS NULL OR TRIM(account_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN account_id IS NULL  OR TRIM(account_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN account_id IS NULL OR TRIM(account_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_sales


-- ------------------------------------------------------------
-- product_id
-- DQ-111: product_id must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN product_id IS NULL OR TRIM(product_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN product_id IS NULL  OR TRIM(product_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN product_id IS NULL OR TRIM(product_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_sales


-- ------------------------------------------------------------
-- territory
-- DQ-112: territory must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN territory IS NULL OR TRIM(territory) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN territory IS NULL  OR TRIM(territory) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN territory IS NULL OR TRIM(territory) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_sales


-- ------------------------------------------------------------
-- sales_channel
-- DQ-113: sales_channel must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN sales_channel IS NULL OR TRIM(sales_channel) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN sales_channel IS NULL  OR TRIM(sales_channel) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN sales_channel IS NULL OR TRIM(sales_channel) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_sales


-- ------------------------------------------------------------
-- order_type
-- DQ-114: order_type must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN order_type IS NULL OR TRIM(order_type) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN order_type IS NULL  OR TRIM(order_type) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN order_type IS NULL OR TRIM(order_type) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_sales


-- ------------------------------------------------------------
-- invoice_number
-- DQ-115: invoice_number must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN invoice_number IS NULL OR TRIM(invoice_number) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN invoice_number IS NULL  OR TRIM(invoice_number) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN invoice_number IS NULL OR TRIM(invoice_number) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_sales


-- ------------------------------------------------------------
-- quantity
-- DQ-117: quantity must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN quantity IS NULL OR TRIM(quantity) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN quantity IS NULL  OR TRIM(quantity) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN quantity IS NULL OR TRIM(quantity) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_sales


-- ------------------------------------------------------------
-- unit_price
-- DQ-119: unit_price must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN unit_price IS NULL OR TRIM(unit_price) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN unit_price IS NULL  OR TRIM(unit_price) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN unit_price IS NULL OR TRIM(unit_price) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_sales


-- ------------------------------------------------------------
-- sales_amount
-- DQ-121: sales_amount must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN sales_amount IS NULL OR TRIM(sales_amount) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN sales_amount IS NULL  OR TRIM(sales_amount) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN sales_amount IS NULL OR TRIM(sales_amount) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_sales

-- ============================================================
-- 10. raw_campaigns
-- ============================================================

-- ------------------------------------------------------------
-- campaign_id
-- DQ-123: campaign_id must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN campaign_id IS NULL OR TRIM(campaign_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN campaign_id IS NULL  OR TRIM(campaign_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN campaign_id IS NULL OR TRIM(campaign_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_campaigns


-- ------------------------------------------------------------
-- campaign_name
-- DQ-126: campaign_name must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN campaign_name IS NULL OR TRIM(campaign_name) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN campaign_name IS NULL  OR TRIM(campaign_name) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN campaign_name IS NULL OR TRIM(campaign_name) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_campaigns


-- ------------------------------------------------------------
-- campaign_type
-- DQ-129: campaign_type must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN campaign_type IS NULL OR TRIM(campaign_type) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN campaign_type IS NULL  OR TRIM(campaign_type) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN campaign_type IS NULL OR TRIM(campaign_type) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_campaigns


-- ------------------------------------------------------------
-- product_id
-- DQ-130: product_id must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN product_id IS NULL OR TRIM(product_id) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN product_id IS NULL  OR TRIM(product_id) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN product_id IS NULL OR TRIM(product_id) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_campaigns


-- ------------------------------------------------------------
-- start_date
-- DQ-131: start_date must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN start_date IS NULL OR TRIM(start_date) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN start_date IS NULL  OR TRIM(start_date) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN start_date IS NULL OR TRIM(start_date) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_campaigns


-- ------------------------------------------------------------
-- end_date
-- DQ-133: end_date must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN end_date IS NULL OR TRIM(end_date) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN end_date IS NULL  OR TRIM(end_date) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN end_date IS NULL OR TRIM(end_date) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_campaigns


-- ------------------------------------------------------------
-- target_hcp_count
-- DQ-135: target_hcp_count must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN target_hcp_count IS NULL OR TRIM(target_hcp_count) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN target_hcp_count IS NULL  OR TRIM(target_hcp_count) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN target_hcp_count IS NULL OR TRIM(target_hcp_count) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_campaigns


-- ------------------------------------------------------------
-- budget
-- DQ-137: budget must be populated for optional / source-dependent fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN budget IS NULL OR TRIM(budget) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN budget IS NULL  OR TRIM(budget) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN budget IS NULL OR TRIM(budget) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_campaigns


-- ------------------------------------------------------------
-- status
-- DQ-139: status must be populated for required fields
-- ------------------------------------------------------------
SELECT
	SUM(CASE WHEN status IS NULL OR TRIM(status) = '' THEN 1 ELSE 0 END) AS violation_count,
	CONCAT(
		CAST(ROUND(SUM(CASE WHEN status IS NULL  OR TRIM(status) = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE
		WHEN SUM(CASE WHEN status IS NULL OR TRIM(status) = '' THEN 1 ELSE 0 END) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_campaigns
 
