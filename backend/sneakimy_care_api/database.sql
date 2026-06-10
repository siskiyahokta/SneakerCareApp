CREATE DATABASE IF NOT EXISTS sneakimy_care_db;
USE sneakimy_care_db;

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS services;

CREATE TABLE services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    price INT NOT NULL,
    duration VARCHAR(50) NOT NULL,
    icon_key VARCHAR(50),
    color_hex VARCHAR(20),
    is_active TINYINT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    layanan VARCHAR(100) NOT NULL,
    merk_sepatu VARCHAR(120) NOT NULL,
    bahan_sepatu VARCHAR(80) NOT NULL,
    alamat_pickup TEXT NOT NULL,
    catatan TEXT,
    status VARCHAR(50) DEFAULT 'Menunggu Kurir',
    customer_name VARCHAR(120),
    customer_email VARCHAR(160),
    estimasi_biaya INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO services (name, description, price, duration, icon_key, color_hex) VALUES
('Deep Cleaning', 'Cuci detail luar dalam untuk sneaker harian.', 35000, '2-3 hari', 'cleaning', '#2563EB'),
('Unyellowing', 'Perawatan midsole yang menguning agar terlihat lebih fresh.', 50000, '3-4 hari', 'sunny', '#F59E0B'),
('Repaint', 'Cat ulang bagian sepatu yang mulai pudar.', 75000, '4-5 hari', 'paint', '#9333EA'),
('Custom Art', 'Desain custom sneaker sesuai konsep pengguna.', 90000, '5-7 hari', 'brush', '#059669');
