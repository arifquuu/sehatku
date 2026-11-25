<?php
declare(strict_types=1);

function setApiHeaders(): void
{
    header('Content-Type: application/json; charset=utf-8');
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept');

    if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'OPTIONS') {
        http_response_code(204);
        exit;
    }
}

function jsonSuccess(array $data = [], string $message = 'OK', int $statusCode = 200): never
{
    http_response_code($statusCode);
    echo json_encode([
        'success' => true,
        'message' => $message,
        'data' => $data,
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

function jsonError(string $message, int $statusCode = 400, array $errors = []): never
{
    http_response_code($statusCode);
    $payload = [
        'success' => false,
        'message' => $message,
    ];
    if ($errors !== []) {
        $payload['errors'] = $errors;
    }
    echo json_encode($payload, JSON_UNESCAPED_UNICODE);
    exit;
}

function readJsonInput(): array
{
    $raw = file_get_contents('php://input');
    if ($raw === false || trim($raw) === '') {
        return $_POST;
    }
    $decoded = json_decode($raw, true);
    if (!is_array($decoded)) {
        jsonError('Body request harus berupa JSON yang valid.', 400);
    }
    return $decoded;
}

function sanitizeUserRow(array $row): array
{
    return [
        'id' => (int) $row['id'],
        'rm_number' => (string) $row['rm_number'],
        'nik' => (string) $row['nik'],
        'full_name' => (string) $row['full_name'],
        'email' => (string) $row['email'],
        'phone' => (string) ($row['phone'] ?? ''),
        'blood_type' => (string) ($row['blood_type'] ?? 'O+'),
        'allergies' => (string) ($row['allergies'] ?? 'Tidak ada alergi obat'),
        'bpjs_number' => (string) ($row['bpjs_number'] ?? ''),
        'role' => (string) ($row['role'] ?? 'pasien'),
    ];
}
