/* =============================================================================
   05_master / master_sales.sql
   Purpose : Trusted entity: surrogate key, confirmed business fixes with audit, DQ flags
   Source  : stg.stg_sales
   Target  : master.master_sales
   -------------------------------------------------------------------------
   1. DETECT - decisions
     ISS-039 sale before launch · ISS-041 negative quantity · ISS-042 price <= 0
     ISS-043 channel NULL · ISS-044 invoice NULL · ISS-045 amount <> qty x price
     -> one *_flag column per issue; Total Sales excludes ISS-041 and ISS-042 rows
   2. RULES
     join stg_products.launch_date for ISS-039
     no value recomputed
   ============================================================================= */

-- ============================================================
-- 3. TRANSFORM
-- ============================================================
DROP TABLE IF EXISTS master.master_sales;


CREATE TABLE master.master_sales (
	sales_key                    INT IDENTITY(1,1) PRIMARY KEY,
	sales_id                     VARCHAR(20)    NOT NULL UNIQUE,
	sales_date                   DATE           NOT NULL,
	account_id                   VARCHAR(20)    NOT NULL,
	product_id                   VARCHAR(20)    NOT NULL,
	territory                    VARCHAR(50)    NULL,
	sales_channel                VARCHAR(50)    NULL,
	order_type                   VARCHAR(50)    NULL,
	invoice_number               VARCHAR(20)    NULL,
	quantity                     INT            NULL,
	unit_price                   DECIMAL(10,2)  NULL,
	sales_amount                 DECIMAL(12,2)  NULL,
	pre_launch_sales_flag        BIT            NOT NULL DEFAULT 0,   -- ISS-039
	negative_quantity_flag       BIT            NOT NULL DEFAULT 0,   -- ISS-041
	non_positive_price_flag      BIT            NOT NULL DEFAULT 0,   -- ISS-042
	missing_sales_channel_flag   BIT            NOT NULL DEFAULT 0,   -- ISS-043
	missing_invoice_number_flag  BIT            NOT NULL DEFAULT 0,   -- ISS-044
	amount_mismatch_flag         BIT            NOT NULL DEFAULT 0,   -- ISS-045
	master_load_date             DATETIME       NOT NULL DEFAULT GETDATE()
);


INSERT INTO master.master_sales (
	sales_id, sales_date, account_id, product_id, territory, sales_channel, order_type, invoice_number,
	quantity, unit_price, sales_amount,
	pre_launch_sales_flag, negative_quantity_flag, non_positive_price_flag,
	missing_sales_channel_flag, missing_invoice_number_flag, amount_mismatch_flag
)
SELECT
	s.sales_id, s.sales_date, s.account_id, s.product_id, s.territory, s.sales_channel, s.order_type, s.invoice_number,
	s.quantity, s.unit_price, s.sales_amount,
	CASE WHEN p.launch_date IS NOT NULL AND s.sales_date < p.launch_date THEN 1 ELSE 0 END,
	CASE WHEN s.quantity < 0 THEN 1 ELSE 0 END,
	CASE WHEN s.unit_price <= 0 THEN 1 ELSE 0 END,
	CASE WHEN s.sales_channel IS NULL THEN 1 ELSE 0 END,
	CASE WHEN s.invoice_number IS NULL THEN 1 ELSE 0 END,
	CASE
		WHEN s.quantity IS NOT NULL AND s.unit_price IS NOT NULL AND s.sales_amount IS NOT NULL
			AND ABS(s.sales_amount - (s.quantity * s.unit_price)) > 0.01
		THEN 1 ELSE 0
	END
FROM stg.stg_sales AS s
LEFT JOIN stg.stg_products AS p ON s.product_id = p.product_id;

-- ============================================================
-- 4. TEST - case level
-- ============================================================
SELECT
	(SELECT COUNT(*) FROM master.master_sales WHERE pre_launch_sales_flag = 1) AS pre_launch,
	(SELECT COUNT(*) FROM master.master_sales WHERE negative_quantity_flag = 1) AS neg_qty,
	(SELECT COUNT(*) FROM master.master_sales WHERE non_positive_price_flag = 1) AS non_pos_price,
	(SELECT COUNT(*) FROM master.master_sales WHERE missing_sales_channel_flag = 1) AS missing_channel,
	(SELECT COUNT(*) FROM master.master_sales WHERE missing_invoice_number_flag = 1) AS missing_invoice,
	(SELECT COUNT(*) FROM master.master_sales WHERE amount_mismatch_flag = 1) AS amount_mismatch;

-- ============================================================
-- 5. VALIDATE - table level
-- ============================================================
SELECT
	(SELECT COUNT(*) FROM stg.stg_sales) AS stg_count,
	(SELECT COUNT(*) FROM master.master_sales) AS master_count;
-- Expected: 1,048,300 = 1,048,300
