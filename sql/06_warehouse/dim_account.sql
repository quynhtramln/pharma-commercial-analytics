/* =============================================================================
   06_warehouse / dim_account.sql
   Purpose : Dimension
   Target  : warehouse.dim_account
   -------------------------------------------------------------------------
   Keys
     PK account_key (surrogate, reused from master)
     Business key account_id
   Note
     PII removed: tax_id, phone; account_name kept (organisation)
   ============================================================================= */


DROP TABLE IF EXISTS warehouse.dim_account;


CREATE TABLE warehouse.dim_account (
	account_key        INT PRIMARY KEY,
	account_id         VARCHAR(20)    NOT NULL UNIQUE,
	account_name       NVARCHAR(150)  NOT NULL,
	account_type       VARCHAR(50)    NULL,
	city               NVARCHAR(100)  NULL,
	territory          VARCHAR(50)    NULL,
	status             VARCHAR(20)    NULL,
	parent_account_id  VARCHAR(20)    NULL
);


INSERT INTO warehouse.dim_account
SELECT account_key, account_id, account_name, account_type, city, territory, status, parent_account_id
FROM master.master_customer_accounts;
