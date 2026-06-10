<?php
require_once __DIR__ . '/../config/response.php';
require_once __DIR__ . '/../config/database.php';

try {
    $stmt = $pdo->query('SELECT * FROM services WHERE is_active = 1 ORDER BY id ASC');
    $services = $stmt->fetchAll();

    send_json(true, 'Data layanan berhasil diambil.', $services);
} catch (Exception $e) {
    send_json(false, 'Gagal mengambil layanan: ' . $e->getMessage(), null, 500);
}
