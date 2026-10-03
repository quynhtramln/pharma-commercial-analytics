/* =============================================================================
   06_warehouse / dim_date.sql
   Purpose : Dimension
   Target  : warehouse.dim_date
   -------------------------------------------------------------------------
   Keys
     PK date_key (surrogate, reused from master)
     Business key -
   Note
     1 row = 1 calendar day; marked as date table in Power BI
   ============================================================================= */


DROP TABLE IF EXISTS warehouse.dim_date;


CREATE TABLE warehouse.dim_date (
	date_key      INT PRIMARY KEY,
	full_date     DATE NOT NULL UNIQUE,
	year          INT NOT NULL,
	quarter       INT NOT NULL,
	month         INT NOT NULL,
	month_name    VARCHAR(20) NOT NULL,
	day           INT NOT NULL,
	day_of_week   INT NOT NULL,
	day_name      VARCHAR(20) NOT NULL,
	is_weekend    BIT NOT NULL
);


WITH n AS (
	SELECT TOP (3000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS rn
	FROM sys.all_objects a CROSS JOIN sys.all_objects b
),
d AS (
	SELECT DATEADD(DAY, rn, '2019-01-01') AS full_date
	FROM n
	WHERE DATEADD(DAY, rn, '2019-01-01') <= '2026-12-31'
)
INSERT INTO warehouse.dim_date
SELECT
	YEAR(full_date)*10000 + MONTH(full_date)*100 + DAY(full_date),
	full_date,
	YEAR(full_date), DATEPART(QUARTER, full_date), MONTH(full_date), DATENAME(MONTH, full_date),
	DAY(full_date), DATEPART(WEEKDAY, full_date), DATENAME(WEEKDAY, full_date),
	CASE WHEN DATEPART(WEEKDAY, full_date) IN (1,7) THEN 1 ELSE 0 END
FROM d;
