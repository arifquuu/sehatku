# SehatKu — Aplikasi Pendaftaran & Rekam Medis Klinik

**Kelompok 4 — Proyek UAS Project-Based Learning (PBL)**  
**Mata Kuliah:** Pengembangan Aplikasi Perangkat Bergerak (A) — Semester Ganjil 2026/2027  
**Program Studi:** Sistem Informasi, FMIPA Universitas Tanjungpura  
**Dosen Pengampu:** Syahru Rahmayuda, S.Kom., M.Kom.

---

## Anggota Kelompok 4

| No | Nama Anggota | Peran | Fokus Cakupan Tugas |
| :---: | :--- | :--- | :--- |
| 1 | **M. Arifqu Wa Liin (Arif)** | Lead Developer | Arsitektur, Routing, Provider Global, Async, Auth MySQL, Notifikasi & Galeri, Build APK |
| 2 | **M. Fadjri Akbar (Fajri)** | UI/UX & Data Developer | Wireframe 3 Layar, Tema & Layout Responsif, List Dinamis Dokter, 4 Halaman UI, REST API JSON, SQLite/Hive/SharedPrefs, ERD DB |
| 3 | **Evan** | QA & Dokumentasi | Program Dasar Dart, Analisis Ekosistem & Bisnis, Widget `setState`, Unit/Widget Test & TDD, Laporan & Video Demo |

---

## Fitur Utama SehatKu

1. **Beranda & Tiket Antrean Online:** Pantau nomor antrean aktif per kode poli (`A` s.d. `F`), ringkasan layanan klinik, dan edukasi kesehatan dari REST API publik.
2. **Direktori 12 Dokter & Filter Poli Dinamis:** Pencarian *real-time* dan filter 6 poliklinik (*Poli Umum, Poli Gigi & Mulut, Poli Anak, Poli KIA & Kandungan, Poli Penyakit Dalam, Poli Mata & THT*) dalam tampilan `ListView` (mobile) maupun `GridView` (tablet/lebar), dilengkapi mode sumber data **REST API Publik (`DummyJSON`)**.
3. **Detail Dokter & Pendaftaran Antrean Online:** Pengantaran objek model `Doctor` antar halaman, pemilihan tanggal & sesi jam praktik, penjamin *BPJS Kesehatan* / *Pasien Umum*, dan penerbitan nomor antrean otomatis ke penyimpanan lokal.
4. **Rekam Medis Ringkas (SQLite CRUD):** Tambah, lihat, ubah, filter, dan hapus catatan riwayat diagnosis, tanda vital (tekanan darah & berat badan), resep obat, serta jadwal kontrol ulang secara *offline-first*.
5. **Profil Medis, Dokter Favorit & Preferensi (Hive + SharedPreferences):** Penyimpanan identitas medis pasien & daftar dokter favorit di **Hive**, pengaturan *Mode Gelap*, pengingat kontrol H-1, dan tampilan kartu ringkas di **SharedPreferences**, serta grafik rekap kunjungan per poli.

---

## Dokumentasi Desain & Basis Data

- **Wireframe 3 Layar Utama & Sistem Desain UI/UX:** [`docs/wireframe_dan_desain_ui.md`](docs/wireframe_dan_desain_ui.md)
- **Diagram ERD & Kamus Data (MySQL + SQLite/Hive/Prefs):** [`docs/erd_database_sehatku.md`](docs/erd_database_sehatku.md)
- **Skema SQL MySQL (Siap Import phpMyAdmin):** [`database/mysql_sehatku_schema.sql`](database/mysql_sehatku_schema.sql)
- **Skema SQL SQLite Lokal:** [`database/sqlite_local_schema.sql`](database/sqlite_local_schema.sql)
- **Ringkasan Pengerjaan Bagian UI/UX & Data (Fajri):** [`docs/dokumentasi_bagian_fajri.md`](docs/dokumentasi_bagian_fajri.md)

### Pratinjau Wireframe 3 Layar Utama
![Wireframe SehatKu](docs/wireframes/wireframe_3_layar_utama_sehatku.svg)

### Pratinjau Diagram ERD Sistem Klinik SehatKu
![ERD SehatKu](docs/erd/erd_sehatku_database.svg)

---

## Struktur Direktori Proyek

```text
sehatku/
├── assets/images/               # Aset gambar lokal banner klinik & avatar dokter
├── database/                    # Skema SQL MySQL (backend auth) & SQLite lokal
├── docs/                        # Dokumentasi wireframe SVG, ERD SVG, dan panduan desain
├── lib/
│   ├── data/                    # Dataset lokal 12 dokter klinik lintas 6 poli & seed data
│   ├── models/                  # Model class (Doctor, BookingAppointment, MedicalRecord, HealthArticle)
│   ├── providers/               # State & koordinasi data (ClinicDataProvider)
│   ├── screens/                 # Halaman UI (Home, DoctorSchedule, BookingDetail, MedicalRecord, Profile)
│   ├── services/                # ApiService (http), DatabaseHelper (SQLite), LocalStorageService (Hive/Prefs)
│   ├── theme/                   # SehatKuTheme (Light/Dark Material 3) & helper responsif
│   ├── widgets/                 # Reusable widget DoctorCard
│   └── main.dart                # Entry point MaterialApp, MultiProvider & Named Routes
└── test/                        # Pengujian unit API, SQLite CRUD, Hive/Prefs & widget responsif
```

---

## Cara Instalasi & Menjalankan Aplikasi

1. Pastikan **Flutter SDK** telah terpasang (`flutter --version`).
2. Unduh dependensi paket proyek:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi di emulator Android, perangkat fisik, atau browser Chrome:
   ```bash
   flutter run -d chrome
   # atau pada perangkat/emulator Android:
   flutter run
   ```
4. Jalankan analisis kode & seluruh pengujian otomatis:
   ```bash
   flutter analyze
   flutter test
   ```
