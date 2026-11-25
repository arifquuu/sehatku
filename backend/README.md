# Backend Autentikasi SehatKu (PHP PDO + MySQL)

Backend ini menangani proses registrasi pasien, login dengan verifikasi hash bcrypt (`password_hash` dan `password_verify`), pengambilan profil sesi, dan logout memakai database `sehatku_db` dari `database/mysql_sehatku_schema.sql`.

## 1. Import Skema MySQL

Import file `database/mysql_sehatku_schema.sql` lewat phpMyAdmin atau perintah CLI MySQL:

```bash
mysql -u root < database/mysql_sehatku_schema.sql
```

Akun awal yang tersedia dari seed data:
- Pasien: `fadjri@sehatku.id` / kata sandi `password`
- Admin: `admin@sehatku.id` / kata sandi `password`

## 2. Jalankan Server PHP Lokal

Dari folder root proyek `sehatku`:

```bash
php -S 0.0.0.0:8080 -t backend backend/index.php
```

Konfigurasi database dapat diubah lewat environment variable opsional `SEHATKU_DB_HOST`, `SEHATKU_DB_PORT`, `SEHATKU_DB_NAME`, `SEHATKU_DB_USER`, `SEHATKU_DB_PASS`, dan `SEHATKU_TOKEN_SECRET`.

## 3. Daftar Endpoint

| Metode | Path | Keterangan |
| :--- | :--- | :--- |
| `GET` | `/api/health` | Cek koneksi PHP dan database `sehatku_db` |
| `POST` | `/api/register` | Daftar pasien baru (NIK 16 digit, email unik, hash bcrypt) |
| `POST` | `/api/login` | Verifikasi email dan kata sandi, mengembalikan Bearer token |
| `GET` | `/api/me` | Ambil data user aktif (header `Authorization: Bearer <token>`) |
| `POST` | `/api/logout` | Akhiri sesi autentikasi |

Pada emulator Android, gunakan URL server `http://10.0.2.2:8080`. Pada Flutter Web atau Windows desktop, gunakan `http://127.0.0.1:8080`.
