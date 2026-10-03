/* =============================================================================
   06_warehouse / dim_field_rep.sql
   Purpose : Dimension
   Target  : warehouse.dim_field_rep
   -------------------------------------------------------------------------
   Keys
     PK rep_key (surrogate, reused from master)
     Business key rep_id
   Note
     rep_name kept, intended for row-level security
   ============================================================================= */


DROP TABLE IF EXISTS warehouse.dim_field_rep;


CREATE TABLE warehouse.dim_field_rep (
	rep_key         INT PRIMARY KEY,
	rep_id          VARCHAR(20)   NOT NULL UNIQUE,
	rep_name        NVARCHAR(100) NOT NULL,   -- row-level security applied in Power BI
	territory       VARCHAR(50)   NULL,
	base_city       NVARCHAR(100) NULL,
	status          VARCHAR(20)   NULL,
	specialization  NVARCHAR(100) NULL
);


INSERT INTO warehouse.dim_field_rep
SELECT rep_key, rep_id, rep_name, territory, base_city, status, specialization
FROM master.master_field_reps;
