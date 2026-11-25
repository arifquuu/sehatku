<?php
declare(strict_types=1);

function getDatabaseConnection(): PDO
{
    static $pdo = null;
    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $host = getenv('SEHATKU_DB_HOST') ?: '127.0.0.1';
    $port = getenv('SEHATKU_DB_PORT') ?: '3306';
    $dbName = getenv('SEHATKU_DB_NAME') ?: 'sehatku_db';
    $user = getenv('SEHATKU_DB_USER') ?: 'root';
    $pass = getenv('SEHATKU_DB_PASS');
    if ($pass === false) {
        $pass = '';
    }

    $dsn = sprintf('mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4', $host, $port, $dbName);

    $pdo = new PDO($dsn, $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);

    return $pdo;
}
