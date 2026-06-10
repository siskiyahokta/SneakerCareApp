<?php
require_once __DIR__ . '/../config/response.php';
require_once __DIR__ . '/../config/database.php';

try {
    $data = get_json_input();

    $id = read_field($data, ['id']);
    $merkSepatu = read_field($data, ['merkSepatu', 'merk_sepatu']);
    $bahanSepatu = read_field($data, ['bahanSepatu', 'bahan_sepatu']);
    $alamatPickup = read_field($data, ['alamatPickup', 'alamat_pickup']);
    $catatan = read_field($data, ['catatan', 'note']);

    if ($id === '' || $merkSepatu === '' || $bahanSepatu === '' || $alamatPickup === '') {
        send_json(false, 'ID, merk sepatu, bahan sepatu, dan alamat pickup wajib diisi.', null, 422);
    }

    $check = $pdo->prepare('SELECT * FROM orders WHERE id = :id');
    $check->execute(['id' => $id]);
    $order = $check->fetch();

    if (!$order) {
        send_json(false, 'Pesanan tidak ditemukan.', null, 404);
    }

    if (strtolower($order['status']) !== strtolower('Menunggu Kurir')) {
        send_json(false, 'Pesanan tidak bisa diubah karena sudah diproses.', null, 403);
    }

    $stmt = $pdo->prepare(
        'UPDATE orders
         SET merk_sepatu = :merk_sepatu,
             bahan_sepatu = :bahan_sepatu,
             alamat_pickup = :alamat_pickup,
             catatan = :catatan
         WHERE id = :id'
    );

    $stmt->execute([
        'id' => $id,
        'merk_sepatu' => $merkSepatu,
        'bahan_sepatu' => $bahanSepatu,
        'alamat_pickup' => $alamatPickup,
        'catatan' => $catatan,
    ]);

    $find = $pdo->prepare('SELECT * FROM orders WHERE id = :id');
    $find->execute(['id' => $id]);

    send_json(true, 'Pesanan berhasil diperbarui.', $find->fetch());
} catch (Exception $e) {
    send_json(false, 'Gagal mengubah pesanan: ' . $e->getMessage(), null, 500);
}
