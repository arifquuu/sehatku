<?php
declare(strict_types=1);

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth_token.php';

setApiHeaders();

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') !== 'GET') {
    jsonError('Metode request harus GET.', 405);
}

$token = extractBearerToken();
if ($token === null) {
    jsonError('Token autentikasi tidak ditemukan.', 401);
}

$claims = verifyAuthToken($token);
if ($claims === null) {
    jsonError('Token autentikasi tidak valid atau sudah kedaluwarsa.', 401);
}

try {
    $pdo = getDatabaseConnection();
    $stmt = $pdo->prepare('SELECT * FROM users WHERE id = :id LIMIT 1');
    $stmt->execute(['id' => (int) $claims['sub']]);
    $userRow = $stmt->fetch();

    if (!$userRow) {
        jsonError('Akun pengguna tidak ditemukan.', 404);
    }

    jsonSuccess([
        'user' => sanitizeUserRow($userRow),
    ], 'Profil pengguna berhasil dimuat.');
} catch (Throwable $e) {
    jsonError('Gagal mengambil data pengguna: ' . $e->getMessage(), 500);
}
