Kalau muncul error:
SQLSTATE[42S22]: Column not found: 1054 Unknown column 'customer_name' in 'field list'

Jalankan query ini di phpMyAdmin:

USE sneakimy_care_db;
ALTER TABLE orders ADD COLUMN customer_name VARCHAR(120) NULL AFTER status;
ALTER TABLE orders ADD COLUMN customer_email VARCHAR(160) NULL AFTER customer_name;
ALTER TABLE orders ADD COLUMN estimasi_biaya INT DEFAULT 0 AFTER customer_email;

Catatan:
- Jalankan migration ini sekali saja.
- Kalau duplicate column, berarti kolom sudah ada dan bisa diabaikan.
