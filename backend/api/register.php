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
$fullName = trim((string) ($input['full_name'] ?? ''));
$email = strtolower(trim((string) ($input['email'] ?? '')));
$password = (string) ($input['password'] ?? '');
$nik = preg_replace('/\D+/', '', (string) ($input['nik'] ?? '')) ?? '';
$phone = trim((string) ($input['phone'] ?? ''));
$bloodType = trim((string) ($input['blood_type'] ?? 'O+')) ?: 'O+';
$bpjsNumber = trim((string) ($input['bpjs_number'] ?? ''));

if (mb_strlen($fullName) < 3) {
    jsonError('Nama lengkap minimal 3 karakter.', 422);
}
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    jsonError('Format email tidak valid.', 422);
}
if (strlen($password) < 6) {
    jsonError('Kata sandi minimal 6 karakter.', 422);
}
if (strlen($nik) !== 16) {
    jsonError('NIK pasien wajib terdiri dari 16 digit angka.', 422);
}

try {
    $pdo = getDatabaseConnection();

    $checkStmt = $pdo->prepare('SELECT id, email, nik FROM users WHERE email = :email OR nik = :nik LIMIT 1');
    $checkStmt->execute(['email' => $email, 'nik' => $nik]);
    $existing = $checkStmt->fetch();
    if ($existing) {
        if (strtolower((string) $existing['email']) === $email) {
            jsonError('Email sudah terdaftar. Silakan masuk dengan akun Anda.', 409);
        }
        jsonError('NIK sudah terdaftar pada akun lain.', 409);
    }

    $nextSeq = (int) $pdo->query('SELECT COALESCE(MAX(id), 0) + 101 FROM users')->fetchColumn();
    $rmNumber = sprintf('RM-%s-%04d', date('Y'), $nextSeq);
    $passwordHash = password_hash($password, PASSWORD_BCRYPT);

    $insertStmt = $pdo->prepare(
        'INSERT INTO users (rm_number, nik, full_name, email, password_hash, phone, blood_type, allergies, bpjs_number, role)
         VALUES (:rm_number, :nik, :full_name, :email, :password_hash, :phone, :blood_type, :allergies, :bpjs_number, :role)'
    );
    $insertStmt->execute([
        'rm_number' => $rmNumber,
        'nik' => $nik,
        'full_name' => $fullName,
        'email' => $email,
        'password_hash' => $passwordHash,
        'phone' => $phone !== '' ? $phone : null,
        'blood_type' => $bloodType,
        'allergies' => 'Tidak ada alergi obat',
        'bpjs_number' => $bpjsNumber !== '' ? $bpjsNumber : null,
        'role' => 'pasien',
    ]);

    $userId = (int) $pdo->lastInsertId();
    $fetchStmt = $pdo->prepare('SELECT * FROM users WHERE id = :id LIMIT 1');
    $fetchStmt->execute(['id' => $userId]);
    $userRow = $fetchStmt->fetch();

    $token = createAuthToken($userId, $email, 'pasien');

    jsonSuccess([
        'token' => $token,
        'user' => sanitizeUserRow($userRow),
    ], 'Registrasi akun pasien berhasil.', 201);
} catch (Throwable $e) {
    jsonError('Terjadi kesalahan server saat registrasi: ' . $e->getMessage(), 500);
}
