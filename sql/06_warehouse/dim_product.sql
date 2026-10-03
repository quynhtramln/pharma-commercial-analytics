/* =============================================================================
   06_warehouse / dim_product.sql
   Purpose : Dimension
   Target  : warehouse.dim_product
   -------------------------------------------------------------------------
   Keys
     PK product_key (surrogate, reused from master)
     Business key product_id
   ============================================================================= */


DROP TABLE IF EXISTS warehouse.dim_product;


CREATE TABLE warehouse.dim_product (
	product_key       INT PRIMARY KEY,
	product_id        VARCHAR(20)    NOT NULL UNIQUE,
	product_name      NVARCHAR(150)  NOT NULL,
	therapeutic_area  NVARCHAR(100)  NULL,
	product_type      VARCHAR(50)    NULL,
	priority_flag     BIT            NULL,
	launch_date       DATE           NULL,
	status            VARCHAR(20)    NULL
);


INSERT INTO warehouse.dim_product
SELECT product_key, product_id, product_name, therapeutic_area, product_type, priority_flag, launch_date, status
FROM master.master_products;
