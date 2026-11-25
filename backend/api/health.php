<?php
declare(strict_types=1);

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

setApiHeaders();

try {
    $pdo = getDatabaseConnection();
    $count = (int) $pdo->query('SELECT COUNT(*) FROM users')->fetchColumn();
    jsonSuccess([
        'service' => 'SehatKu Auth API (PHP + MySQL)',
        'database' => 'sehatku_db',
        'users_count' => $count,
        'server_time' => date('Y-m-d H:i:s'),
    ], 'Backend PHP dan MySQL sehatku_db aktif.');
} catch (Throwable $e) {
    jsonError('Koneksi database MySQL gagal: ' . $e->getMessage(), 500);
}
