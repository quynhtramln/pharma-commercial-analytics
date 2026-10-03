/* =============================================================================
   06_warehouse / dim_event.sql
   Purpose : Dimension
   Target  : warehouse.dim_event
   -------------------------------------------------------------------------
   Keys
     PK event_key (surrogate, reused from master)
     Business key event_id
   Note
     snowflake: product_key -> dim_product; pre_launch_event_flag exposed
   ============================================================================= */


DROP TABLE IF EXISTS warehouse.dim_event;


CREATE TABLE warehouse.dim_event (
	event_key    INT PRIMARY KEY,
	event_id     VARCHAR(20)    NOT NULL UNIQUE,
	event_name   NVARCHAR(200)  NOT NULL,
	event_type   VARCHAR(50)    NULL,
	start_date   DATE           NOT NULL,
	end_date     DATE           NULL,
	city         NVARCHAR(100)  NULL,
	territory    VARCHAR(50)    NULL,
	product_key  INT            NOT NULL REFERENCES warehouse.dim_product(product_key),
	budget       DECIMAL(12,2)  NULL,
	status       VARCHAR(20)    NULL,
	pre_launch_event_flag BIT   NOT NULL DEFAULT 0
);


INSERT INTO warehouse.dim_event
SELECT
	e.event_key, e.event_id, e.event_name, e.event_type, e.start_date, e.end_date,
	e.city, e.territory, p.product_key, e.budget, e.status, e.pre_launch_event_flag
FROM master.master_events AS e
JOIN master.master_products AS p ON e.product_id = p.product_id;
