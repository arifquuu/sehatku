# Setup Proyek dan Arsitektur Teknis SehatKu

Penanggung jawab: M. Arifqu Wa Liin (Lead Developer, Kelompok 4)
Mata kuliah: Pengembangan Aplikasi Perangkat Bergerak (A), Sistem Informasi FMIPA UNTAN
Cakupan: Tugas 1 (setup repo dan arsitektur), Tugas 5 (routing), Tugas 7 (state management global), Tugas 8 (pemrograman asinkron), Tugas 11 (backend autentikasi MySQL), Tugas 12 (notifikasi lokal dan galeri), Tugas 14 (fitur QR antrean dan build rilis).

## 1. Lingkungan Pengembangan

Proyek dibangun menggunakan Flutter SDK versi stabil pada perangkat lokal bersama Android Studio dan Laragon untuk layanan PHP + MySQL lokal.

- Repository GitHub: `https://github.com/arifquuu/sehatku`
- Cabang integrasi: `main` (pengembangan fitur per anggota di branch `arif`, `fajri`, dan cabang anggota lain)
- Target build: Android APK (debug dan release) serta Flutter Web
- Backend lokal: PHP 8.3 (PDO) dan MySQL 8.0 (`sehatku_db`)

## 2. Struktur Folder Arsitektur

Pemisahan kode mengikuti pola berlapis agar tim UI/UX, data, backend, dan QA dapat bekerja paralel tanpa konflik:

```text
sehatku/
├── backend/                     # REST API autentikasi PHP + MySQL (register, login, me, logout)
├── database/                    # Skema SQL MySQL (sehatku_db) dan SQLite lokal
├── docs/                        # Wireframe, ERD, catatan arsitektur, panduan pengerjaan
├── lib/
│   ├── data/                    # Dataset klinik lokal (12 dokter dan seed rekam medis)
│   ├── models/                  # Model data (AppUser, Doctor, BookingAppointment, MedicalRecord, HealthArticle)
│   ├── providers/               # State global (AuthProvider, ClinicDataProvider) via MultiProvider
│   ├── routing/                 # AppRouter terpusat, named routes, dan proteksi rute autentikasi
│   ├── screens/                 # Halaman aplikasi (Login, Register, Home, Jadwal, Booking, Rekam Medis, Profil, Async Lab, QR Antrean)
│   ├── services/                # ApiService, AuthService, DatabaseHelper, LocalStorageService, NotificationService, MediaService, AsyncDemoService
│   ├── theme/                   # SehatKuTheme (Light/Dark Material 3) dan breakpoint responsif
│   ├── widgets/                 # Komponen UI pakai ulang (DoctorCard, dll.)
│   └── main.dart                # Entry point MultiProvider dan konfigurasi MaterialApp
├── tool/                        # Skrip Dart konsol untuk demo perbandingan sinkron vs asinkron
└── test/                        # Pengujian unit dan widget (flutter_test)
```

## 3. Alur State dan Navigasi

1. `MultiProvider` di `lib/main.dart` menyediakan dua `ChangeNotifier` utama:
   - `AuthProvider`: mengelola status login, token sesi di `SharedPreferences`, URL server backend PHP, serta profil akun aktif.
   - `ClinicDataProvider`: mengelola data dokter lokal dan REST API, antrean booking SQLite, rekam medis SQLite (termasuk path lampiran foto), dokter favorit Hive, serta preferensi aplikasi.
2. `AppRouter` di `lib/routing/app_router.dart` mendaftarkan named routes (`/login`, `/register`, `/`, `/jadwal`, `/rekam-medis`, `/profil`, `/booking`, `/async-lab`, `/qr-ticket`) dan menjaga seluruh rute terproteksi agar otomatis mengarahkan pengguna yang belum login ke `/login`.
3. Pengantaran data antar halaman dilakukan lewat argumen `Navigator.pushNamed` (`Doctor` untuk `/booking` dan `BookingAppointment` untuk `/qr-ticket`).
