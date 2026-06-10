<?php
require_once __DIR__ . '/../config/response.php';
require_once __DIR__ . '/../config/database.php';

try {
    $data = get_json_input();
    $id = read_field($data, ['id']);

    if ($id === '') {
        send_json(false, 'ID pesanan wajib diisi.', null, 422);
    }

    $check = $pdo->prepare('SELECT * FROM orders WHERE id = :id');
    $check->execute(['id' => $id]);
    $order = $check->fetch();

    if (!$order) {
        send_json(false, 'Pesanan tidak ditemukan.', null, 404);
    }

    $stmt = $pdo->prepare('DELETE FROM orders WHERE id = :id');
    $stmt->execute(['id' => $id]);

    send_json(true, 'Pesanan berhasil dihapus.', ['id' => $id]);
} catch (Exception $e) {
    send_json(false, 'Gagal menghapus pesanan: ' . $e->getMessage(), null, 500);
}
