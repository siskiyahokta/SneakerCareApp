<?php
require_once __DIR__ . '/../config/response.php';
require_once __DIR__ . '/../config/database.php';

try {
    $customerEmail = isset($_GET['customer_email']) ? trim($_GET['customer_email']) : '';

    if ($customerEmail !== '') {
        $stmt = $pdo->prepare('SELECT * FROM orders WHERE customer_email = :customer_email ORDER BY id DESC');
        $stmt->execute(['customer_email' => $customerEmail]);
    } else {
        $stmt = $pdo->query('SELECT * FROM orders ORDER BY id DESC');
    }

    $orders = $stmt->fetchAll();
    send_json(true, 'Data pesanan berhasil diambil.', $orders);
} catch (Exception $e) {
    send_json(false, 'Gagal mengambil data pesanan: ' . $e->getMessage(), null, 500);
}
