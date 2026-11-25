<?php
declare(strict_types=1);

require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth_token.php';

setApiHeaders();

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') !== 'POST') {
    jsonError('Metode request harus POST.', 405);
}

$token = extractBearerToken();
if ($token !== null) {
    verifyAuthToken($token);
}

jsonSuccess([
    'logged_out' => true,
], 'Sesi login berhasil diakhiri.');
