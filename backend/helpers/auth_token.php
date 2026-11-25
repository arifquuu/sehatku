<?php
declare(strict_types=1);

function base64UrlEncode(string $data): string
{
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

function base64UrlDecode(string $data): string
{
    $remainder = strlen($data) % 4;
    if ($remainder > 0) {
        $data .= str_repeat('=', 4 - $remainder);
    }
    $decoded = base64_decode(strtr($data, '-_', '+/'), true);
    return $decoded === false ? '' : $decoded;
}

function getTokenSecret(): string
{
    return getenv('SEHATKU_TOKEN_SECRET') ?: 'sehatku_untan_pbl_2026_secret_key';
}

function createAuthToken(int $userId, string $email, string $role): string
{
    $header = base64UrlEncode(json_encode(['alg' => 'HS256', 'typ' => 'JWT']));
    $payload = base64UrlEncode(json_encode([
        'sub' => $userId,
        'email' => $email,
        'role' => $role,
        'iat' => time(),
        'exp' => time() + (60 * 60 * 24 * 7),
    ]));
    $signature = base64UrlEncode(
        hash_hmac('sha256', $header . '.' . $payload, getTokenSecret(), true)
    );
    return $header . '.' . $payload . '.' . $signature;
}

function verifyAuthToken(string $token): ?array
{
    $parts = explode('.', $token);
    if (count($parts) !== 3) {
        return null;
    }

    [$header, $payload, $signature] = $parts;
    $expected = base64UrlEncode(
        hash_hmac('sha256', $header . '.' . $payload, getTokenSecret(), true)
    );
    if (!hash_equals($expected, $signature)) {
        return null;
    }

    $decoded = json_decode(base64UrlDecode($payload), true);
    if (!is_array($decoded) || !isset($decoded['sub'], $decoded['exp'])) {
        return null;
    }
    if ((int) $decoded['exp'] < time()) {
        return null;
    }

    return $decoded;
}

function extractBearerToken(): ?string
{
    $header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
    if ($header === '' && function_exists('apache_request_headers')) {
        $headers = apache_request_headers();
        foreach ($headers as $key => $value) {
            if (strtolower((string) $key) === 'authorization') {
                $header = (string) $value;
                break;
            }
        }
    }

    if (preg_match('/^Bearer\s+(\S+)$/i', trim($header), $matches) === 1) {
        return $matches[1];
    }
    return null;
}
