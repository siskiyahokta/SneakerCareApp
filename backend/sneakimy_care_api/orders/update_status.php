<?php
require_once __DIR__ . '/../config/response.php';
require_once __DIR__ . '/../config/database.php';

try {
    $data = get_json_input();

    $id = read_field($data, ['id']);
    $status = read_field($data, ['status']);

    $allowed = ['Menunggu Kurir', 'Dijemput Kurir', 'Cleaning', 'Drying', 'Packing', 'Selesai'];

    if ($id === '' || $status === '') {
        send_json(false, 'ID dan status wajib diisi.', null, 422);
    }

    if (!in_array($status, $allowed, true)) {
        send_json(false, 'Status tidak valid.', null, 422);
    }

    $check = $pdo->prepare('SELECT id FROM orders WHERE id = :id');
    $check->execute(['id' => $id]);

    if (!$check->fetch()) {
        send_json(false, 'Pesanan tidak ditemukan.', null, 404);
    }

    $stmt = $pdo->prepare('UPDATE orders SET status = :status WHERE id = :id');
    $stmt->execute(['id' => $id, 'status' => $status]);

    $find = $pdo->prepare('SELECT * FROM orders WHERE id = :id');
    $find->execute(['id' => $id]);

    send_json(true, 'Status pesanan berhasil diperbarui.', $find->fetch());
} catch (Exception $e) {
    send_json(false, 'Gagal memperbarui status: ' . $e->getMessage(), null, 500);
}
