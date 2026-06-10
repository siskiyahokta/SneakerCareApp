<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

function send_json($success, $message, $data = null, $statusCode = 200) {
    http_response_code($statusCode);
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data,
    ]);
    exit;
}

function get_json_input() {
    $raw = file_get_contents('php://input');
    if (!$raw) {
        return [];
    }

    $data = json_decode($raw, true);
    if (!is_array($data)) {
        return [];
    }

    return $data;
}

function read_field($data, $keys, $default = '') {
    foreach ($keys as $key) {
        if (isset($data[$key])) {
            return trim((string) $data[$key]);
        }
    }
    return $default;
}

function estimate_price($service) {
    $prices = [
        'Deep Cleaning' => 35000,
        'Unyellowing' => 50000,
        'Repaint' => 75000,
        'Custom Art' => 90000,
    ];

    return $prices[$service] ?? 35000;
}
