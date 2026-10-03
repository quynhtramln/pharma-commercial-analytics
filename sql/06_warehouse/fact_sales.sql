/* =============================================================================
   06_warehouse / fact_sales.sql
   Purpose : Fact
   Target  : warehouse.fact_sales
   Grain   : 1 sales transaction
   -------------------------------------------------------------------------
   Keys
     FK date_key, account_key, product_key
   Note
     account level - no HCP (D-06)
   ============================================================================= */


DROP TABLE IF EXISTS warehouse.fact_sales;


CREATE TABLE warehouse.fact_sales (
	sales_key                    INT PRIMARY KEY,
	date_key                     INT REFERENCES warehouse.dim_date(date_key),
	account_key                  INT REFERENCES warehouse.dim_account(account_key),
	product_key                  INT REFERENCES warehouse.dim_product(product_key),
	sales_id                     VARCHAR(20)   NOT NULL UNIQUE,
	territory                    VARCHAR(50)   NULL,
	sales_channel                VARCHAR(50)   NULL,
	order_type                   VARCHAR(50)   NULL,
	invoice_number               VARCHAR(20)   NULL,
	quantity                     INT           NULL,
	unit_price                   DECIMAL(10,2) NULL,
	sales_amount                 DECIMAL(12,2) NULL,
	pre_launch_sales_flag        BIT NOT NULL DEFAULT 0,
	negative_quantity_flag       BIT NOT NULL DEFAULT 0,
	non_positive_price_flag      BIT NOT NULL DEFAULT 0,
	missing_sales_channel_flag   BIT NOT NULL DEFAULT 0,
	missing_invoice_number_flag  BIT NOT NULL DEFAULT 0,
	amount_mismatch_flag         BIT NOT NULL DEFAULT 0
);


INSERT INTO warehouse.fact_sales
SELECT
	s.sales_key,
	YEAR(s.sales_date)*10000 + MONTH(s.sales_date)*100 + DAY(s.sales_date),
	a.account_key, p.product_key,
	s.sales_id, s.territory, s.sales_channel, s.order_type, s.invoice_number,
	s.quantity, s.unit_price, s.sales_amount,
	s.pre_launch_sales_flag, s.negative_quantity_flag, s.non_positive_price_flag,
	s.missing_sales_channel_flag, s.missing_invoice_number_flag, s.amount_mismatch_flag
FROM master.master_sales AS s
JOIN master.master_customer_accounts AS a ON s.account_id = a.account_id
JOIN master.master_products AS p ON s.product_id = p.product_id;
