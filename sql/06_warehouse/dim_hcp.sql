/* =============================================================================
   06_warehouse / dim_hcp.sql
   Purpose : Dimension
   Target  : warehouse.dim_hcp
   -------------------------------------------------------------------------
   Keys
     PK hcp_key (surrogate, reused from master)
     Business key hcp_id
   Note
     PII removed: hcp_name, email, phone
   ============================================================================= */


DROP TABLE IF EXISTS warehouse.dim_hcp;


CREATE TABLE warehouse.dim_hcp (
	hcp_key    INT PRIMARY KEY,
	hcp_id     VARCHAR(20)  NOT NULL UNIQUE,
	hcp_type   VARCHAR(50)  NULL,
	specialty  VARCHAR(100) NULL,
	city       VARCHAR(100) NULL,
	territory  VARCHAR(50)  NULL,
	status     VARCHAR(20)  NULL
);


INSERT INTO warehouse.dim_hcp
SELECT hcp_key, hcp_id, hcp_type, specialty, city, territory, status
FROM master.master_hcp;
