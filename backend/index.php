<?php
declare(strict_types=1);

$uriPath = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
$normalized = rtrim($uriPath, '/');

$routes = [
    '/api/health' => __DIR__ . '/api/health.php',
    '/api/register' => __DIR__ . '/api/register.php',
    '/api/login' => __DIR__ . '/api/login.php',
    '/api/me' => __DIR__ . '/api/me.php',
    '/api/logout' => __DIR__ . '/api/logout.php',
];

if (isset($routes[$normalized])) {
    require $routes[$normalized];
    exit;
}

if ($normalized === '' || $normalized === '/index.php') {
    require __DIR__ . '/api/health.php';
    exit;
}

require_once __DIR__ . '/helpers/response.php';
setApiHeaders();
jsonError('Endpoint tidak ditemukan: ' . $uriPath, 404);
