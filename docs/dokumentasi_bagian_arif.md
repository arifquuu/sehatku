# Dokumentasi Pengerjaan Jalur Lead Developer - M. Arifqu Wa Liin

Kelompok 4: SehatKu (Aplikasi Pendaftaran dan Rekam Medis Klinik)
Peran: Lead Developer
Cakupan Tugas Proyek: Tugas 1 (Setup Repo & Arsitektur), Tugas 5 (Routing & Proteksi Rute), Tugas 7 (State Management Global), Tugas 8 (Pemrograman Asinkron & Event Loop), Tugas 11 (Backend PHP MySQL & Autentikasi), Tugas 12 (Notifikasi Lokal & Galeri Dokumen Medis), Tugas 14 (Fitur Inovatif QR Antrean & Build Rilis).

## Ringkasan Penyelesaian Langkah 1 sampai 7

| Langkah | Tugas UAS PBL | Berkas Implementasi Utama | Status |
| :---: | :--- | :--- | :---: |
| 1 | Tugas 1: Setup Repo & Arsitektur | `docs/arsitektur_dan_setup_arif.md`, struktur folder `lib/` & `backend/` | Selesai |
| 2 | Tugas 5: Routing Terpusat & Argumen | `lib/routing/app_router.dart`, `lib/main.dart` | Selesai |
| 3 | Tugas 7: State Management Lanjutan (`MultiProvider`) | `lib/models/user_model.dart`, `lib/providers/auth_provider.dart`, sinkronisasi `ClinicDataProvider` | Selesai |
| 4 | Tugas 8: Pemrograman Asinkron & Event Loop | `lib/services/async_demo_service.dart`, `lib/screens/async_comparison_screen.dart`, `tool/sync_vs_async_demo.dart` | Selesai |
| 5 | Tugas 11: Backend PHP MySQL & Halaman Login/Register | `backend/` (PDO + `password_hash` bcrypt), `lib/services/auth_service.dart`, `lib/screens/login_screen.dart`, `lib/screens/register_screen.dart` | Selesai |
| 6 | Tugas 12: Notifikasi Lokal & Galeri Dokumen Medis | `lib/services/notification_service.dart`, `lib/services/media_service.dart`, `lib/widgets/medical_document_preview.dart`, migrasi SQLite v2 (`document_photo_path`), `AndroidManifest.xml`, `build.gradle.kts` | Selesai |
| 7 | Tugas 14: QR Antrean & Build APK/Web | `lib/screens/qr_queue_ticket_screen.dart`, integrasi pada Home, Jadwal, dan Dialog Booking, build APK release & Flutter Web | Selesai |

## Cara Verifikasi Tiap Fitur

### 1. Autentikasi PHP + MySQL (Tugas 11)
1. Import `database/mysql_sehatku_schema.sql` ke MySQL (Laragon/phpMyAdmin).
2. Jalankan server API PHP dari root proyek:
   ```bash
   php -S 0.0.0.0:8080 -t backend backend/index.php
   ```
3. Buka aplikasi SehatKu, gunakan akun seed (`fadjri@sehatku.id` / `password`) atau buat akun baru lewat halaman **Daftar Sekarang**. Password disimpan sebagai hash bcrypt (`$2y$10$...`) di tabel `users`.
4. Bila menjalankan aplikasi tanpa server lokal aktif, tersedia tombol **Masuk Mode Demo Lokal (Tanpa Server)** di bawah form login.

### 2. Perbandingan Sinkron vs Asinkron (Tugas 8)
- Melalui konsol Dart:
  ```bash
  dart run tool/sync_vs_async_demo.dart
  ```
- Melalui aplikasi: buka **Drawer > Lab Asinkron & Event Loop**, lalu uji tombol **Jalankan Sinkron**, **Jalankan Asinkron (Event Loop)**, serta tiga skenario jaringan (**Koneksi Normal**, **Simulasi Timeout**, **Simulasi Offline**).

### 3. Notifikasi Lokal & Lampiran Galeri Medis (Tugas 12)
- Buka menu **Profil > Preferensi Aplikasi**: aktifkan pengingat kontrol H-1 dan klik **Kirim** pada baris **Uji Notifikasi Pengingat Kontrol**.
- Buka menu **Rekam Medis > + Tambah Catatan**: pilih foto resep atau hasil lab melalui tombol **Galeri** atau **Kamera**, simpan ke SQLite, lalu klik **Lihat Foto Dokumen** pada kartu catatan.

### 4. Tiket QR Antrean (Tugas 14)
- Pada **Beranda** (kartu antrean aktif), **Jadwal > Antrean Saya**, atau dialog setelah konfirmasi booking, tekan tombol **QR Antrean** untuk menampilkan tiket QR check-in klinik.
