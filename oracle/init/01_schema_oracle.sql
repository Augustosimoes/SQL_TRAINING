-- DEPRECATED / superseded by 01_schema.sql in this same directory.
--
-- This file used to contain a "schema sketch" with no bulk data. It has been
-- replaced by the full schema (01_schema.sql), dimensions (02_dimensions.sql),
-- and data-quality fixtures (03_data_quality.sql), loaded together with the
-- full bulk dataset via oracle/seed/load_oracle.py.
--
-- Kept as an empty no-op (rather than deleted) because it's still referenced
-- by the container's alphabetical init-script scan; it intentionally does
-- nothing so it can't collide with 01_schema.sql's CREATE TABLE statements.
-- Safe to delete manually if your filesystem allows it.

WHENEVER SQLERROR CONTINUE
SELECT 1 FROM DUAL;
EXIT;
