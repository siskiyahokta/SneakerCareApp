<?php
require_once __DIR__ . '/../config/response.php';
require_once __DIR__ . '/../config/database.php';

try {
    $data = get_json_input();

    $layanan = read_field($data, ['layanan', 'service']);
    $merkSepatu = read_field($data, ['merkSepatu', 'merk_sepatu']);
    $bahanSepatu = read_field($data, ['bahanSepatu', 'bahan_sepatu']);
    $alamatPickup = read_field($data, ['alamatPickup', 'alamat_pickup']);
    $catatan = read_field($data, ['catatan', 'note']);
    $customerName = read_field($data, ['customerName', 'customer_name'], 'Customer Sneakimy');
    $customerEmail = read_field($data, ['customerEmail', 'customer_email'], 'customer@sneakimycare.com');

    if ($layanan === '' || $merkSepatu === '' || $bahanSepatu === '' || $alamatPickup === '') {
        send_json(false, 'Layanan, merk sepatu, bahan sepatu, dan alamat pickup wajib diisi.', null, 422);
    }

    $estimasiBiaya = estimate_price($layanan);

    $stmt = $pdo->prepare(
        'INSERT INTO orders (layanan, merk_sepatu, bahan_sepatu, alamat_pickup, catatan, status, customer_name, customer_email, estimasi_biaya)
         VALUES (:layanan, :merk_sepatu, :bahan_sepatu, :alamat_pickup, :catatan, :status, :customer_name, :customer_email, :estimasi_biaya)'
    );

    $stmt->execute([
        'layanan' => $layanan,
        'merk_sepatu' => $merkSepatu,
        'bahan_sepatu' => $bahanSepatu,
        'alamat_pickup' => $alamatPickup,
        'catatan' => $catatan,
        'status' => 'Menunggu Kurir',
        'customer_name' => $customerName,
        'customer_email' => $customerEmail,
        'estimasi_biaya' => $estimasiBiaya,
    ]);

    $id = $pdo->lastInsertId();
    $find = $pdo->prepare('SELECT * FROM orders WHERE id = :id');
    $find->execute(['id' => $id]);

    send_json(true, 'Pesanan berhasil dibuat.', $find->fetch(), 201);
} catch (Exception $e) {
    send_json(false, 'Gagal membuat pesanan: ' . $e->getMessage(), null, 500);
}
