# Analisis Bisnis & Kewirausahaan Digital — SehatKu (Tugas 14)

**Disusun oleh:** Evan (QA, Dokumentasi & Fitur Dasar — Kelompok 4)  
**Studi Kasus:** Aplikasi Pendaftaran Antrean & Rekam Medis Klinik Pratama **SehatKu**  

---

## 1. Analisis Data Operasional Klinik: Rekap Kunjungan per Poli (`visitCountByPoli`)

Aplikasi SehatKu menyediakan getter `visitCountByPoli` pada `ClinicDataProvider` (`lib/providers/clinic_data_provider.dart`) yang menggabungkan data riwayat `medical_records` dan `bookings` dari penyimpanan SQLite lokal, lalu menampilkannya sebagai grafik batang horizontal pada halaman **Profil** (`lib/screens/profile_screen.dart`).

Berdasarkan data seed awal dan simulasi operasional 6 poliklinik (Poli Umum, Poli Gigi & Mulut, Poli Anak, Poli KIA & Kandungan, Poli Penyakit Dalam, serta Poli Mata & THT), pola kunjungan pasien memberikan rekomendasi manajerial berikut:

| Kategori Poli | Indikasi Beban Kunjungan | Rekomendasi Penjadwalan Dokter & Operasional |
| :--- | :--- | :--- |
| **Poli Umum (Kode A)** & **Poli Anak (Kode C)** | Volume kunjungan tertinggi (keluhan harian & kontrol rutin anak) | Alokasikan **minimal 2 dokter praktik per hari** (shift pagi dan sore) dengan kuota harian lebih besar (25–30 pasien/hari) agar penumpukan antrean tidak terjadi di jam 08.00–10.00. |
| **Poli Gigi & Mulut (Kode B)** & **Poli KIA & Kandungan (Kode D)** | Kunjungan menengah dengan durasi tindakan lebih lama | Terapkan sistem **slot sesi jam praktik** (misal sesi 09.00–11.00 dan 13.00–15.00) dengan estimasi 15–20 menit per pasien agar waktu tunggu lebih terprediksi. |
| **Poli Penyakit Dalam (Kode E)** & **Poli Mata & THT (Kode F)** | Kunjungan spesialis terjadwal & kontrol berkala | Aktifkan **pengingat kontrol H-1 (`flutter_local_notifications`)** agar pasien penyakit kronis/kontrol tidak melewatkan jadwal dan kuota dokter spesialis termanfaatkan optimal. |

**Dampak Bisnis:** Dengan memantau `visitCountByPoli` secara berkala, manajemen klinik dapat menyusun jadwal dokter berbasis data (*data-driven scheduling*), menghindari kekosongan ruang praktik, dan menekan angka pembatalan pasien akibat antrean terlalu lama.

---

## 2. Nilai Bisnis & Kewirausahaan Digital Fitur Inovatif SehatKu

### A. Tiket Antrean QR (`QrQueueTicketScreen`)
- **Masalah yang Diselesaikan:** Antrean kertas konvensional membutuhkan biaya cetak terus-menerus, mudah hilang, dan memperlambat proses verifikasi di meja registrasi klinik.
- **Nilai Bisnis & Efisiensi:**
  1. **Paperless & Hemat Biaya Operasional:** Klinik menghemat pengadaan kertas nomor antrean dan formulir pendaftaran manual.
  2. **Check-in Lebih Cepat:** Petugas cukup memindai kode QR pasien yang memuat nomor antrean, nama poli, dan tanggal kunjungan.
  3. **Keandalan Pemindaian:** Tiket QR didesain dengan *quiet zone* berwarna putih tetap meskipun aplikasi berada pada Mode Gelap, sehingga pemindai kamera/barcode tetap akurat di berbagai kondisi pencahayaan.

### B. Mode Gelap (`SehatKuTheme.darkTheme`) & Pengalaman Pasien
- Pasien yang melakukan pendaftaran di malam hari atau sedang kurang sehat membutuhkan tampilan layar yang nyaman di mata (*low eye strain*).
- Preferensi tema disimpan permanen di `SharedPreferences`, meningkatkan kenyamanan dan retensi penggunaan aplikasi oleh pasien.

### C. Arsitektur *Offline-First* (SQLite + Hive + SharedPreferences)
- Di banyak klinik daerah atau fasilitas kesehatan tingkat pertama, koneksi internet tidak selalu stabil.
- Dengan menyimpan rekam medis ringkas, riwayat booking, daftar dokter favorit, dan lampiran foto resep secara lokal (*offline-first*), pasien tetap dapat menunjukkan riwayat obat atau alergi kepada dokter kapan saja tanpa bergantung penuh pada koneksi server.

---

## 3. Model Keberlanjutan & Peluang Pengembangan Usaha (B2B SaaS Klinik)

SehatKu memiliki potensi dikembangkan menjadi produk **SaaS (Software as a Service)** untuk klinik pratama dan praktik dokter bersama:
1. **Paket Dasar (Gratis / Freemium):** Direktori jadwal dokter, booking antrean daring, dan tiket QR untuk klinik kecil (maksimal 2 poli).
2. **Paket Klinik Pro (Berlangganan Bulanan):** Dashboard analitik `visitCountByPoli` berbasis server MySQL/cloud, notifikasi pengingat kontrol otomatis, dan integrasi rekam medis elektronik multi-cabang.
3. **Diferensiasi Kompetitif:** Ringan dijalankan di perangkat Android spesifikasi menengah ke bawah serta dapat langsung diakses lewat peramban Web.
