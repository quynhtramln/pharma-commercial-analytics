/* =============================================================================
   09_validation / validation.sql
   Purpose : Prove the build before any number is published
   Source  : raw.*, stg.*, master.*, warehouse.*, mart.*
   -------------------------------------------------------------------------
   Sections
     1. Row-count lineage    raw -> staging (+ quarantine) -> master -> warehouse
     2. Model integrity      surrogate keys unique, no NULL / orphan foreign keys
     3. KPI reconciliation   SQL value = Power BI card value (tolerance 0)
     4. Business sanity      values that must be impossible
     5. Performance          indexes on fact foreign keys + timing
   Every check returns a status column: PASS / FAIL (or WARN for known, documented items).
   As-of date for all time logic: 2026-06-29 (decision D-09).
   ============================================================================= */
-- How to run
--   SSMS    : F5 runs everything.
--   DBeaver : pick database New_Project_Healthcare_Pharma_Commercial in the toolbar,
--             then Execute SQL Script (Alt+X). Each check opens its own result tab.
-- No variables and no GO separators are used, so every statement runs on its own.
USE New_Project_Healthcare_Pharma_Commercial;

-- =============================================================================
-- 1. ROW-COUNT LINEAGE
--    Master and warehouse must keep exactly the staging row count (they only add
--    keys, corrections and flags). Staging = raw - quarantine - exact duplicates.
-- =============================================================================
WITH lineage AS (
    SELECT 'hcp' AS entity,
           (SELECT COUNT(*) FROM raw.raw_hcp)                       AS raw_rows,
           0                                                        AS quarantined,
           (SELECT COUNT(*) FROM stg.stg_hcp)                       AS stg_rows,
           (SELECT COUNT(*) FROM master.master_hcp)                 AS master_rows,
           (SELECT COUNT(*) FROM warehouse.dim_hcp)                 AS warehouse_rows,
           5200                                                     AS expected_rows
    UNION ALL SELECT 'customer_accounts',
           (SELECT COUNT(*) FROM raw.raw_customer_accounts), 0,
           (SELECT COUNT(*) FROM stg.stg_customer_accounts),
           (SELECT COUNT(*) FROM master.master_customer_accounts),
           (SELECT COUNT(*) FROM warehouse.dim_account), 1100
    UNION ALL SELECT 'hcp_account_affiliations',
           (SELECT COUNT(*) FROM raw.raw_hcp_account_affiliations),
           (SELECT COUNT(*) FROM stg.quarantine_hcp_account_affiliations),
           (SELECT COUNT(*) FROM stg.stg_hcp_account_affiliations),
           (SELECT COUNT(*) FROM master.master_hcp_account_affiliations),
           (SELECT COUNT(*) FROM warehouse.fact_hcp_account_affiliation), 12360
    UNION ALL SELECT 'products',
           (SELECT COUNT(*) FROM raw.raw_products), 0,
           (SELECT COUNT(*) FROM stg.stg_products),
           (SELECT COUNT(*) FROM master.master_products),
           (SELECT COUNT(*) FROM warehouse.dim_product), 40
    UNION ALL SELECT 'field_reps',
           (SELECT COUNT(*) FROM raw.raw_field_reps), 0,
           (SELECT COUNT(*) FROM stg.stg_field_reps),
           (SELECT COUNT(*) FROM master.master_field_reps),
           (SELECT COUNT(*) FROM warehouse.dim_field_rep), 220
    UNION ALL SELECT 'interactions',
           (SELECT COUNT(*) FROM raw.raw_interactions),
           (SELECT COUNT(*) FROM stg.quarantine_interactions),
           (SELECT COUNT(*) FROM stg.stg_interactions),
           (SELECT COUNT(*) FROM master.master_interactions),
           (SELECT COUNT(*) FROM warehouse.fact_interactions), 319570
    UNION ALL SELECT 'events',
           (SELECT COUNT(*) FROM raw.raw_events), 0,
           (SELECT COUNT(*) FROM stg.stg_events),
           (SELECT COUNT(*) FROM master.master_events),
           (SELECT COUNT(*) FROM warehouse.dim_event), 550
    UNION ALL SELECT 'event_registrations',
           (SELECT COUNT(*) FROM raw.raw_event_registrations),
           (SELECT COUNT(*) FROM stg.quarantine_event_registrations),
           (SELECT COUNT(*) FROM stg.stg_event_registrations),
           (SELECT COUNT(*) FROM master.master_event_registrations),
           (SELECT COUNT(*) FROM warehouse.fact_event_registrations), 649300
    UNION ALL SELECT 'sales',
           (SELECT COUNT(*) FROM raw.raw_sales),
           (SELECT COUNT(*) FROM stg.quarantine_sales),
           (SELECT COUNT(*) FROM stg.stg_sales),
           (SELECT COUNT(*) FROM master.master_sales),
           (SELECT COUNT(*) FROM warehouse.fact_sales), 1048300
    UNION ALL SELECT 'campaigns',
           (SELECT COUNT(*) FROM raw.raw_campaigns),
           (SELECT COUNT(*) FROM stg.quarantine_campaigns),
           (SELECT COUNT(*) FROM stg.stg_campaigns),
           (SELECT COUNT(*) FROM master.master_campaigns),
           (SELECT COUNT(*) FROM warehouse.fact_campaign), 69
)
SELECT entity, raw_rows, quarantined,
       raw_rows - quarantined - stg_rows AS duplicates_removed,
       stg_rows, master_rows, warehouse_rows, expected_rows,
       CASE WHEN stg_rows = master_rows AND master_rows = warehouse_rows AND warehouse_rows = expected_rows
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM lineage
ORDER BY entity;
-- Expected: every row PASS. duplicates_removed should match the issue register
-- (hcp 20 · accounts 6 · affiliations 50 · reps 1 · interactions 640 · events 2 ·
--  registrations 975 · sales 1,050 · campaigns 2).


-- =============================================================================
-- 2. MODEL INTEGRITY
-- =============================================================================

-- 2a. Surrogate keys are unique in every dimension
SELECT 'dim_hcp' AS tbl, COUNT(*) - COUNT(DISTINCT hcp_key) AS duplicate_keys FROM warehouse.dim_hcp
UNION ALL SELECT 'dim_account',   COUNT(*) - COUNT(DISTINCT account_key) FROM warehouse.dim_account
UNION ALL SELECT 'dim_product',   COUNT(*) - COUNT(DISTINCT product_key) FROM warehouse.dim_product
UNION ALL SELECT 'dim_field_rep', COUNT(*) - COUNT(DISTINCT rep_key)     FROM warehouse.dim_field_rep
UNION ALL SELECT 'dim_event',     COUNT(*) - COUNT(DISTINCT event_key)   FROM warehouse.dim_event
UNION ALL SELECT 'dim_date',      COUNT(*) - COUNT(DISTINCT date_key)    FROM warehouse.dim_date;
-- Expected: 0 for every table

-- 2b. Every fact foreign key is populated and finds its dimension row
WITH fk_checks AS (
    SELECT 'fact_sales.account_key' AS fk, COUNT(*) AS bad_rows
    FROM warehouse.fact_sales f LEFT JOIN warehouse.dim_account d ON f.account_key = d.account_key
    WHERE d.account_key IS NULL
    UNION ALL
    SELECT 'fact_sales.product_key', COUNT(*)
    FROM warehouse.fact_sales f LEFT JOIN warehouse.dim_product d ON f.product_key = d.product_key
    WHERE d.product_key IS NULL
    UNION ALL
    SELECT 'fact_sales.date_key', COUNT(*)
    FROM warehouse.fact_sales f LEFT JOIN warehouse.dim_date d ON f.date_key = d.date_key
    WHERE d.date_key IS NULL
    UNION ALL
    SELECT 'fact_interactions.hcp_key', COUNT(*)
    FROM warehouse.fact_interactions f LEFT JOIN warehouse.dim_hcp d ON f.hcp_key = d.hcp_key
    WHERE d.hcp_key IS NULL
    UNION ALL
    SELECT 'fact_interactions.account_key', COUNT(*)
    FROM warehouse.fact_interactions f LEFT JOIN warehouse.dim_account d ON f.account_key = d.account_key
    WHERE d.account_key IS NULL
    UNION ALL
    SELECT 'fact_interactions.rep_key', COUNT(*)
    FROM warehouse.fact_interactions f LEFT JOIN warehouse.dim_field_rep d ON f.rep_key = d.rep_key
    WHERE d.rep_key IS NULL
    UNION ALL
    SELECT 'fact_interactions.product_key', COUNT(*)
    FROM warehouse.fact_interactions f LEFT JOIN warehouse.dim_product d ON f.product_key = d.product_key
    WHERE d.product_key IS NULL
    UNION ALL
    SELECT 'fact_interactions.date_key', COUNT(*)
    FROM warehouse.fact_interactions f LEFT JOIN warehouse.dim_date d ON f.date_key = d.date_key
    WHERE d.date_key IS NULL
    UNION ALL
    SELECT 'fact_event_registrations.event_key', COUNT(*)
    FROM warehouse.fact_event_registrations f LEFT JOIN warehouse.dim_event d ON f.event_key = d.event_key
    WHERE d.event_key IS NULL
    UNION ALL
    SELECT 'fact_event_registrations.hcp_key', COUNT(*)
    FROM warehouse.fact_event_registrations f LEFT JOIN warehouse.dim_hcp d ON f.hcp_key = d.hcp_key
    WHERE d.hcp_key IS NULL
    UNION ALL
    SELECT 'fact_hcp_account_affiliation.hcp_key', COUNT(*)
    FROM warehouse.fact_hcp_account_affiliation f LEFT JOIN warehouse.dim_hcp d ON f.hcp_key = d.hcp_key
    WHERE d.hcp_key IS NULL
    UNION ALL
    SELECT 'fact_hcp_account_affiliation.account_key', COUNT(*)
    FROM warehouse.fact_hcp_account_affiliation f LEFT JOIN warehouse.dim_account d ON f.account_key = d.account_key
    WHERE d.account_key IS NULL
    UNION ALL
    SELECT 'fact_campaign.product_key', COUNT(*)
    FROM warehouse.fact_campaign f LEFT JOIN warehouse.dim_product d ON f.product_key = d.product_key
    WHERE d.product_key IS NULL
    UNION ALL
    SELECT 'dim_event.product_key', COUNT(*)
    FROM warehouse.dim_event e LEFT JOIN warehouse.dim_product d ON e.product_key = d.product_key
    WHERE d.product_key IS NULL
)
SELECT fk, bad_rows, CASE WHEN bad_rows = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM fk_checks;
-- Expected: every row PASS (orphans were quarantined in staging, decision D-05)

-- 2c. Each mart table has exactly one row per dimension row (one-to-one in Power BI)
SELECT 'tbl_account_growth' AS mart_table, (SELECT COUNT(*) FROM mart.tbl_account_growth) AS mart_rows, (SELECT COUNT(*) FROM warehouse.dim_account) AS dim_rows
UNION ALL SELECT 'tbl_account_opportunity', (SELECT COUNT(*) FROM mart.tbl_account_opportunity), (SELECT COUNT(*) FROM warehouse.dim_account)
UNION ALL SELECT 'tbl_hcp_opportunity',     (SELECT COUNT(*) FROM mart.tbl_hcp_opportunity),     (SELECT COUNT(*) FROM warehouse.dim_hcp)
UNION ALL SELECT 'tbl_product_momentum',    (SELECT COUNT(*) FROM mart.tbl_product_momentum),    (SELECT COUNT(*) FROM warehouse.dim_product)
UNION ALL SELECT 'tbl_rep_coverage',        (SELECT COUNT(*) FROM mart.tbl_rep_coverage),        (SELECT COUNT(*) FROM warehouse.dim_field_rep);
-- Expected: mart_rows = dim_rows on every line


-- =============================================================================
-- 3. KPI RECONCILIATION (SQL = Power BI)
--    Same definitions as the DAX measures, period = all data up to the as-of date
--    (the report-level filter in Power BI). Compare with the cards on the Overview
--    page after setting the date slicer to 01-Jan-2023 .. 29-Jun-2026.
-- =============================================================================
WITH kpi AS (
    -- Total Sales: excludes negative quantity and non-positive price (Business Rule 6)
    SELECT 'Total Sales' AS kpi,
           CAST(SUM(f.sales_amount) AS DECIMAL(18,2)) AS sql_value,
           CAST(482177312.05 AS DECIMAL(18,2))         AS powerbi_value
    FROM warehouse.fact_sales f
    JOIN warehouse.dim_date d ON f.date_key = d.date_key
    WHERE f.negative_quantity_flag = 0 AND f.non_positive_price_flag = 0 AND d.full_date <= '2026-06-29'

    UNION ALL
    -- YoY Growth %: H1 2026 (01-Jan .. 29-Jun) vs the same days of 2025
    SELECT 'YoY Growth % (H1 2026 vs H1 2025)',
           CAST(100.0 * (SUM(CASE WHEN d.full_date BETWEEN '2026-01-01' AND '2026-06-29' THEN f.sales_amount END)
                       / SUM(CASE WHEN d.full_date BETWEEN '2025-01-01' AND '2025-06-29' THEN f.sales_amount END) - 1) AS DECIMAL(18,2)),
           CAST(0.59 AS DECIMAL(18,2))
    FROM warehouse.fact_sales f
    JOIN warehouse.dim_date d ON f.date_key = d.date_key
    WHERE f.negative_quantity_flag = 0 AND f.non_positive_price_flag = 0

    UNION ALL
    -- Total Engagement: all interaction rows
    SELECT 'Total Engagement', COUNT(*), 298769
    FROM warehouse.fact_interactions f
    JOIN warehouse.dim_date d ON f.date_key = d.date_key
    WHERE d.full_date <= '2026-06-29'

    UNION ALL
    -- Coverage Rate %: active HCPs with >= 1 interaction / all active HCPs
    SELECT 'Coverage Rate %',
           CAST(100.0 * COUNT(DISTINCT CASE WHEN d.full_date <= '2026-06-29' THEN f.hcp_key END)
                / (SELECT COUNT(*) FROM warehouse.dim_hcp WHERE status = 'Active') AS DECIMAL(18,2)),
           CAST(100.00 AS DECIMAL(18,2))
    FROM warehouse.fact_interactions f
    JOIN warehouse.dim_hcp h  ON f.hcp_key = h.hcp_key AND h.status = 'Active'
    JOIN warehouse.dim_date d ON f.date_key = d.date_key

    UNION ALL
    -- Attendance Rate %: attended / registrations for events that started by the as-of date
    SELECT 'Attendance Rate %',
           CAST(100.0 * SUM(CASE WHEN r.attendance_status = 'Attended' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(18,2)),
           CAST(24.61 AS DECIMAL(18,2))
    FROM warehouse.fact_event_registrations r
    JOIN warehouse.dim_event e ON r.event_key = e.event_key
    JOIN warehouse.dim_date d  ON r.date_key = d.date_key
    WHERE e.start_date <= '2026-06-29' AND d.full_date <= '2026-06-29'

    UNION ALL
    -- Follow-up Completion %: completed / registrations that require follow-up
    SELECT 'Follow-up Completion %',
           CAST(100.0 * SUM(CASE WHEN r.follow_up_status = 'Completed' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(18,2)),
           CAST(33.44 AS DECIMAL(18,2))
    FROM warehouse.fact_event_registrations r
    JOIN warehouse.dim_date d ON r.date_key = d.date_key
    WHERE r.follow_up_required = 1 AND d.full_date <= '2026-06-29'
)
SELECT kpi, sql_value, powerbi_value,
       CASE WHEN ABS(sql_value - powerbi_value) < 0.01 THEN 'PASS' ELSE 'FAIL' END AS status
FROM kpi;
-- powerbi_value = value shown by the report for 01-Jan-2023 .. 29-Jun-2026.
-- If a line fails: check the as-of filter first, then the DQ exclusions.


-- =============================================================================
-- 4. BUSINESS SANITY
-- =============================================================================
SELECT 'Negative or zero-price rows inside Total Sales' AS check_name,
       COUNT(*) AS rows_found,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM warehouse.fact_sales
WHERE (quantity < 0 OR unit_price <= 0)
  AND negative_quantity_flag = 0 AND non_positive_price_flag = 0       -- every bad row must carry its flag

UNION ALL
SELECT 'Affiliations with start_date > end_date after the swap',
       COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM warehouse.fact_hcp_account_affiliation
WHERE end_date IS NOT NULL AND start_date > end_date

UNION ALL
SELECT 'Engagement score outside 1-10',
       COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM warehouse.fact_interactions
WHERE engagement_score NOT BETWEEN 1 AND 10

UNION ALL
-- Known item ISS-066: attendance already recorded for events that start after the as-of date.
-- Attendance Rate % excludes future events, so the KPI is not affected -> WARN.
SELECT 'Attended registrations for events not yet started (ISS-066)',
       COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'WARN' END
FROM warehouse.fact_event_registrations r
JOIN warehouse.dim_event e ON r.event_key = e.event_key
WHERE r.attendance_status = 'Attended' AND e.start_date > '2026-06-29'

UNION ALL
-- Known item ISS-065: transactions dated after the as-of date exist in the source.
-- They are excluded by the report-level filter (Date <= 29-Jun-2026), so WARN, not FAIL.
SELECT 'Sales dated after the as-of date (ISS-065, excluded by report filter)',
       COUNT(*), CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'WARN' END
FROM warehouse.fact_sales f
JOIN warehouse.dim_date d ON f.date_key = d.date_key
WHERE d.full_date > '2026-06-29';
-- Expected: PASS on the first three, WARN on ISS-066 (4,687 rows) and ISS-065 (48,065 rows).


-- =============================================================================
-- 5. PERFORMANCE
--    Facts are joined to dimensions on every query, so index the foreign keys.
-- =============================================================================
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_fact_sales_date_account_product')
    CREATE NONCLUSTERED INDEX IX_fact_sales_date_account_product
        ON warehouse.fact_sales (date_key, account_key, product_key) INCLUDE (sales_amount);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_fact_interactions_date_hcp')
    CREATE NONCLUSTERED INDEX IX_fact_interactions_date_hcp
        ON warehouse.fact_interactions (date_key, hcp_key) INCLUDE (account_key, rep_key, product_key, engagement_score);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_fact_event_registrations_event')
    CREATE NONCLUSTERED INDEX IX_fact_event_registrations_event
        ON warehouse.fact_event_registrations (event_key, date_key) INCLUDE (hcp_key, attendance_status);

-- Timing of the heaviest query used by the report (monthly sales by territory).
-- Read the execution time in SSMS (Messages tab) or DBeaver (Statistics tab).
SELECT d.year, d.month, a.territory, SUM(f.sales_amount) AS sales
FROM warehouse.fact_sales f
JOIN warehouse.dim_date d    ON f.date_key = d.date_key
JOIN warehouse.dim_account a ON f.account_key = a.account_key
WHERE f.negative_quantity_flag = 0 AND f.non_positive_price_flag = 0
GROUP BY d.year, d.month, a.territory;
-- Record the elapsed time in docs/07 (target: under 2 seconds on a laptop)
