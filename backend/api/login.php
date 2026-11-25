<?php
declare(strict_types=1);

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth_token.php';

setApiHeaders();

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') !== 'POST') {
    jsonError('Metode request harus POST.', 405);
}

$input = readJsonInput();
$email = strtolower(trim((string) ($input['email'] ?? '')));
$password = (string) ($input['password'] ?? '');

if (!filter_var($email, FILTER_VALIDATE_EMAIL) || $password === '') {
    jsonError('Masukkan email dan kata sandi yang valid.', 422);
}

try {
    $pdo = getDatabaseConnection();
    $stmt = $pdo->prepare('SELECT * FROM users WHERE email = :email LIMIT 1');
    $stmt->execute(['email' => $email]);
    $userRow = $stmt->fetch();

    if (!$userRow || !password_verify($password, (string) $userRow['password_hash'])) {
        jsonError('Email atau kata sandi salah.', 401);
    }

    $token = createAuthToken((int) $userRow['id'], (string) $userRow['email'], (string) $userRow['role']);

    jsonSuccess([
        'token' => $token,
        'user' => sanitizeUserRow($userRow),
    ], 'Login berhasil.');
} catch (Throwable $e) {
    jsonError('Terjadi kesalahan server saat login: ' . $e->getMessage(), 500);
}
