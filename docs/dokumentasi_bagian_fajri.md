# Dokumentasi Pengerjaan Jalur UI/UX & Data — M. Fadjri Akbar

**Kelompok 4 — SehatKu (Aplikasi Pendaftaran & Rekam Medis Klinik)**  
**Peran:** UI/UX & Data Developer  
**Cakupan Tugas Proyek:** Tugas 1 (Wireframe), Tugas 3, Tugas 4, Tugas 5 (Halaman UI), Tugas 9, Tugas 10, Tugas 11 (ERD DB)

---

## Ringkasan Penyelesaian Langkah 1 s.d. 7

| Langkah | Tugas UAS PBL | Berkas Implementasi Utama | Status |
| :---: | :--- | :--- | :---: |
| **1** | **Tugas 1 — Wireframe 3 Layar Utama** | [`docs/wireframes/wireframe_3_layar_utama_sehatku.svg`](wireframes/wireframe_3_layar_utama_sehatku.svg)<br>[`docs/wireframe_dan_desain_ui.md`](wireframe_dan_desain_ui.md) | Selesai |
| **2** | **Tugas 3 — Layout Utama, Tema & Responsif 2 Layar** | [`lib/theme/sehatku_theme.dart`](../lib/theme/sehatku_theme.dart)<br>[`lib/screens/home_screen.dart`](../lib/screens/home_screen.dart)<br>[`assets/images/`](../assets/images/) | Selesai |
| **3** | **Tugas 4 — Model Class & List Dinamis 12 Dokter + Filter Poli** | [`lib/models/doctor_model.dart`](../lib/models/doctor_model.dart)<br>[`lib/data/dummy_clinic_data.dart`](../lib/data/dummy_clinic_data.dart)<br>[`lib/widgets/doctor_card.dart`](../lib/widgets/doctor_card.dart) | Selesai |
| **4** | **Tugas 5 — 4+ Halaman UI, BottomNavigationBar, Drawer & Detail Booking** | [`lib/screens/main_navigation_screen.dart`](../lib/screens/main_navigation_screen.dart)<br>[`lib/screens/doctor_schedule_screen.dart`](../lib/screens/doctor_schedule_screen.dart)<br>[`lib/screens/booking_detail_screen.dart`](../lib/screens/booking_detail_screen.dart)<br>[`lib/screens/medical_record_screen.dart`](../lib/screens/medical_record_screen.dart)<br>[`lib/screens/profile_screen.dart`](../lib/screens/profile_screen.dart) | Selesai |
| **5** | **Tugas 9 — Akses REST API Publik (`http`) & Parsing JSON** | [`lib/services/api_service.dart`](../lib/services/api_service.dart)<br>[`lib/models/health_article_model.dart`](../lib/models/health_article_model.dart) | Selesai |
| **6** | **Tugas 10 — Penyimpanan Lokal (`SQLite` CRUD + `Hive` + `SharedPreferences`)** | [`lib/services/database_helper.dart`](../lib/services/database_helper.dart)<br>[`lib/services/local_storage_service.dart`](../lib/services/local_storage_service.dart)<br>[`lib/providers/clinic_data_provider.dart`](../lib/providers/clinic_data_provider.dart) | Selesai |
| **7** | **Tugas 11 — Diagram ERD & Skema SQL MySQL + SQLite** | [`docs/erd/erd_sehatku_database.svg`](erd/erd_sehatku_database.svg)<br>[`docs/erd_database_sehatku.md`](erd_database_sehatku.md)<br>[`database/mysql_sehatku_schema.sql`](../database/mysql_sehatku_schema.sql)<br>[`database/sqlite_local_schema.sql`](../database/sqlite_local_schema.sql) | Selesai |

---

## Panduan Singkat Bukti Video Penyimpanan Lokal (Tugas 10)

Untuk merekam bukti video bahwa data lokal tetap tersimpan setelah aplikasi ditutup dan dibuka kembali:

1. Jalankan aplikasi (`flutter run -d chrome` atau pada emulator/perangkat Android).
2. Buka menu **Jadwal** → pilih salah satu dokter → klik **Booking** → isi keluhan & klik **Konfirmasi Booking & Ambil Nomor Antrean** (tersimpan di tabel `bookings` SQLite).
3. Buka menu **Rekam Medis** → klik tombol **+ Tambah Catatan** → isi diagnosis & resep → klik **Simpan SQLite** (tersimpan di tabel `medical_records` SQLite).
4. Buka menu **Profil** → aktifkan **Mode Gelap** (`SharedPreferences`) dan tandai ikon hati (**♥**) pada salah satu dokter untuk menyimpannya ke **Dokter Favorit** (`Hive`).
5. Tutup aplikasi sepenuhnya (atau muat ulang browser/restart aplikasi), lalu buka kembali aplikasi **SehatKu** — seluruh nomor antrean booking, catatan rekam medis, dokter favorit, serta preferensi Mode Gelap tetap tersimpan utuh.

---

## Catatan Titik Integrasi untuk Anggota Tim

- **Untuk Arif (Lead Developer):**
  - Struktur folder [`lib/models/`](../lib/models/), [`lib/services/`](../lib/services/), [`lib/providers/`](../lib/providers/), dan [`lib/screens/`](../lib/screens/) sudah selaras dengan arsitektur kelompok.
  - `MultiProvider` dan *named routes* (`'/'`, `'/jadwal'`, `'/booking'`, `'/rekam-medis'`, `'/profil'`) pada [`lib/main.dart`](../lib/main.dart) siap dihubungkan langsung dengan `AuthProvider` MySQL (proteksi halaman login) serta `flutter_local_notifications` & `image_picker`.
  - Skema tabel MySQL lengkap beserta `password_hash` dan *seed data* tersedia di [`database/mysql_sehatku_schema.sql`](../database/mysql_sehatku_schema.sql).
- **Untuk Evan (QA & Dokumentasi):**
  - Gambar **Wireframe 3 Layar Utama** dan **Diagram ERD** berformat SVG vektor tajam tersedia di folder [`docs/wireframes/`](wireframes/) dan [`docs/erd/`](erd/) untuk langsung disematkan ke Laporan Proyek & Slide Presentasi.
  - Rekap analitik kunjungan per poli telah tersedia melalui getter `visitCountByPoli` pada `ClinicDataProvider` dan divisualisasikan pada halaman **Profil**.
