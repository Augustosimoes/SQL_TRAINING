-- Set default search_path for all connections (must run outside a transaction)
ALTER DATABASE retail_dw SET search_path TO retail, public;
