# Kerangka Slide Presentasi — SehatKu (Kelompok 4)

Panduan isi untuk 8–10 slide presentasi (PowerPoint / Google Slides / Canva):

---

### Slide 1 — Judul
- **Judul:** **SehatKu**: Aplikasi Pendaftaran Antrean & Rekam Medis Klinik
- **Subjudul:** UAS Project-Based Learning (PBL) — Pengembangan Aplikasi Perangkat Bergerak (A)
- **Tim Kelompok 4:** M. Arifqu Wa Liin (Lead Dev), M. Fadjri Akbar (UI/UX & Data), Evan (QA & Dokumentasi)

### Slide 2 — Masalah di Klinik Pratama
1. Antrean kertas konvensional memicu penumpukan pasien di pagi hari.
2. Jadwal praktik dokter tidak terpantau secara real-time oleh pasien.
3. Catatan resep dan riwayat kontrol pasien mudah hilang atau tercecer.

### Slide 3 — Solusi & Alur Aplikasi SehatKu
- Direktori 12 dokter lintas 6 poliklinik dengan pencarian & filter dinamis.
- Booking online dengan pilihan penjamin (BPJS / Umum) + **Tiket QR Antrean**.
- Rekam medis *offline-first* (SQLite + Hive) dilengkapi lampiran foto dokumen & notifikasi pengingat.

### Slide 4 — Desain UI/UX & Arsitektur Data
- Tampilkan gambar **Wireframe 3 Layar** (`docs/wireframes/wireframe_3_layar_utama_sehatku.svg`).
- Tampilkan **Diagram ERD** (`docs/erd/erd_sehatku_database.svg`).
- Sorot arsitektur dua lapis: MySQL (`sehatku_db` + PHP PDO `bcrypt`) dan Lokal (`sqflite`, `hive`, `shared_preferences`).

### Slide 5 — Mengapa Flutter? & Manajemen State
- Single codebase Android APK + Flutter Web, Material 3 (Light & Dark Mode), responsif Mobile (`ListView`) & Tablet (`GridView`).
- `setState` untuk state lokal (`ClinicPrepChecklistWidget`) vs `MultiProvider` (`AuthProvider`, `ClinicDataProvider`) untuk sinkronisasi lintas halaman.

### Slide 6 — Demo Fitur Utama & Fitur Inovatif
- Cuplikan screenshot: Login/Demo Mode → Beranda → Jadwal Dokter → **Tiket QR Antrean** (dengan zona tenang putih di Mode Gelap) → Rekam Medis CRUD + Foto → Tab Profil & Grafik Poli.

### Slide 7 — Hasil Testing, TDD & Bug Fixing (QA)
- 13 automated tests (`widget_test.dart`, `arif_features_test.dart`, `evan_validation_tdd_test.dart`) + siklus TDD `formatQueueNumber` (Red → Green → Refactor).
- 2 bug integrasi yang berhasil diselesaikan:
  1. Overflow 390px di Login/Profil & pending timer di Async Demo (`5f8250e`).
  2. Konflik AGP 9.1.0 vs `compileSdk 36` → upgrade AGP 9.1.1 & `compileSdk 37` (`7a63b96`).

### Slide 8 — Analisis Bisnis & Nilai Kewirausahaan
- Pemanfaatan `visitCountByPoli` untuk penjadwalan dokter & kuota berbasis data.
- Efisiensi biaya kertas & percepatan check-in melalui Tiket QR Antrean.
- Peluang model SaaS klinik pratama (Freemium → Klinik Pro).

### Slide 9 — Rencana Pengembangan Selanjutnya
1. Sinkronisasi dua arah MySQL ↔ SQLite untuk akses multi-perangkat.
2. Fitur pemindai QR di aplikasi petugas resepsionis klinik.
3. Pengujian `integration_test` end-to-end pada perangkat Android nyata.

### Slide 10 — Penutup
- Tautan GitHub Repository & Rilis APK `v1.0.0`.
- Terima kasih & sesi tanya jawab.
