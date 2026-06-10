USE sneakimy_care_db;

-- Jalankan sekali saja di phpMyAdmin kalau muncul error:
-- Unknown column 'customer_name' in 'field list'
ALTER TABLE orders ADD COLUMN customer_name VARCHAR(120) NULL AFTER status;
ALTER TABLE orders ADD COLUMN customer_email VARCHAR(160) NULL AFTER customer_name;
ALTER TABLE orders ADD COLUMN estimasi_biaya INT DEFAULT 0 AFTER customer_email;
