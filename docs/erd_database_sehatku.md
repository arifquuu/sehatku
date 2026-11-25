# Desain Basis Data & Diagram ERD — Sistem Klinik SehatKu

**Kelompok 4 — SehatKu**  
**Mata Kuliah:** Pengembangan Aplikasi Perangkat Bergerak (A) — Semester Ganjil 2026/2027  
**Penanggung Jawab Desain Basis Data:** M. Fadjri Akbar (Jalur UI/UX & Data — Langkah 7)  
**Indikator Capaian:** Sub-CPMK0539 (Tugas 10 — Penyimpanan Data Lokal SQLite/Hive/Prefs) & Sub-CPMK05310 (Tugas 11 — Desain Basis Data & ERD MySQL)

---

## 1. Arsitektur Penyimpanan Hibrida (Server MySQL + Lokal Offline-First)

Aplikasi **SehatKu** dirancang dengan arsitektur penyimpanan dua lapis agar pasien tetap dapat membuka jadwal kontrol dan rekam medis meskipun koneksi internet klinik sedang terganggu:

1. **Basis Data Terpusat MySQL (`sehatku_db`):** Digunakan oleh layanan backend autentikasi (Register/Login dengan *hash password* `bcrypt`), manajemen master poli, jadwal praktik dokter, dan rekap kunjungan klinik lintas poli. Skrip SQL siap impor tersedia pada [`database/mysql_sehatku_schema.sql`](../database/mysql_sehatku_schema.sql).
2. **Basis Data Lokal Perangkat (`SQLite` + `Hive` + `SharedPreferences`):**
   - **SQLite (`sehatku_clinic.db`):** Menyimpan operasi **CRUD Rekam Medis Ringkas** (`medical_records`) dan **Riwayat Booking Antrean** (`bookings`). Skrip skema tersedia pada [`database/sqlite_local_schema.sql`](../database/sqlite_local_schema.sql) dan diimplementasikan di [`lib/services/database_helper.dart`](../lib/services/database_helper.dart).
   - **Hive (`sehatku_favorites_box` & `sehatku_profile_box`):** Menyimpan daftar **Dokter Favorit** dan **Profil Identitas Medis Pasien** secara persisten.
   - **SharedPreferences:** Menyimpan preferensi pengguna (*Mode Gelap*, *Pengingat Kontrol H-1*, *Tampilan Kartu Ringkas*, serta *Filter Poli Terakhir*).

---

## 2. Diagram Visual ERD (MySQL & Penyimpanan Lokal)

![Diagram ERD Basis Data SehatKu](erd/erd_sehatku_database.svg)

---

## 3. Diagram Relasi Entitas (Mermaid `erDiagram`)

```mermaid
erDiagram
    USERS ||--o{ APPOINTMENTS : "melakukan booking"
    USERS ||--o{ MEDICAL_RECORDS : "memiliki riwayat"
    POLYCLINICS ||--|{ DOCTORS : "menaungi"
    DOCTORS ||--|{ DOCTOR_SCHEDULES : "memiliki jadwal"
    DOCTORS ||--o{ APPOINTMENTS : "melayani"
    DOCTORS ||--o{ MEDICAL_RECORDS : "memeriksa"
    APPOINTMENTS ||--o| MEDICAL_RECORDS : "menghasilkan"

    USERS {
        int id PK
        varchar rm_number UK "Nomor Rekam Medis"
        char nik UK "16 Digit NIK Pasien"
        varchar full_name
        varchar email UK
        varchar password_hash "Bcrypt Password Hash"
        varchar phone
        varchar blood_type
        varchar allergies
        varchar bpjs_number
        enum role "pasien | admin"
        timestamp created_at
    }

    POLYCLINICS {
        int id PK
        varchar code UK
        varchar name
        varchar floor_location
        char queue_prefix "A s.d. F"
    }

    DOCTORS {
        int id PK
        int polyclinic_id FK
        varchar doctor_code UK
        varchar full_name
        varchar specialist_title
        varchar str_number
        varchar room_number
        int consultation_fee
        int daily_quota
        decimal rating
    }

    DOCTOR_SCHEDULES {
        int id PK
        int doctor_id FK
        varchar day_of_week
        varchar session_range
        int quota_per_session
    }

    APPOINTMENTS {
        int id PK
        varchar queue_number
        int user_id FK
        int doctor_id FK
        date visit_date
        varchar session_time
        enum payment_type "BPJS Kesehatan | Pasien Umum"
        text complaint
        enum status "Terjadwal | Diproses | Selesai | Dibatalkan"
    }

    MEDICAL_RECORDS {
        int id PK
        int appointment_id FK
        int user_id FK
        int doctor_id FK
        date visit_date
        varchar diagnosis
        text symptoms
        text treatment_prescription
        varchar blood_pressure
        decimal body_weight_kg
        date next_control_date
        varchar document_photo_path
    }
```

---

## 4. Kamus Data Penyimpanan Lokal Flutter (Tugas 10)

### A. Tabel SQLite `medical_records`
| Nama Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| `id` | `INTEGER PRIMARY KEY AUTOINCREMENT` | Kunci utama otomatis setiap catatan rekam medis. |
| `patient_name` | `TEXT NOT NULL` | Nama lengkap pasien. |
| `medical_record_number` | `TEXT NOT NULL` | Nomor Rekam Medis klinik (mis. `RM-2026-0104`). |
| `visit_date` | `TEXT NOT NULL` | Tanggal pemeriksaan kunjungan klinik. |
| `poli` | `TEXT NOT NULL` | Nama poliklinik tujuan (mendukung agregasi analitik kunjungan per poli). |
| `doctor_name` | `TEXT NOT NULL` | Nama dokter pemeriksa beserta gelar. |
| `diagnosis` | `TEXT NOT NULL` | Diagnosis medis hasil pemeriksaan dokter. |
| `symptoms` | `TEXT NOT NULL` | Keluhan/gejala awal pasien. |
| `treatment_prescription` | `TEXT NOT NULL` | Tindakan medis & rincian resep obat. |
| `blood_pressure` | `TEXT NOT NULL` | Tekanan darah pasien (mis. `120/80 mmHg`). |
| `body_weight_kg` | `REAL NOT NULL` | Berat badan pasien dalam kilogram. |
| `next_control_date` | `TEXT NOT NULL` | Jadwal kontrol ulang berikutnya. |
| `notes` | `TEXT NOT NULL` | Catatan edukasi tambahan dokter. |

### B. Tabel SQLite `bookings`
| Nama Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| `id` | `INTEGER PRIMARY KEY AUTOINCREMENT` | Kunci utama antrean lokal. |
| `queue_number` | `TEXT NOT NULL` | Nomor tiket antrean per kode poli (`A-012`, `B-013`, dst.). |
| `doctor_id`, `doctor_name` | `TEXT NOT NULL` | Identitas dokter tujuan booking. |
| `poli`, `room` | `TEXT NOT NULL` | Nama poli dan ruangan praktik. |
| `patient_name`, `patient_nik` | `TEXT NOT NULL` | Identitas pendaftar kunjungan. |
| `visit_date`, `session_time` | `TEXT NOT NULL` | Tanggal dan jam sesi praktik yang dipilih. |
| `payment_type`, `complaint` | `TEXT NOT NULL` | Jenis penjamin (`BPJS Kesehatan`/`Pasien Umum`) & keluhan. |
| `status`, `created_at` | `TEXT NOT NULL` | Status jadwal (`Terjadwal`/`Selesai`/`Dibatalkan`) & waktu buat. |

---

## 5. Cara Import Skema MySQL di phpMyAdmin / Laragon / XAMPP

1. Buka **phpMyAdmin** (`http://localhost/phpmyadmin`) atau terminal MySQL.
2. Pilih menu **Import** → pilih file [`database/mysql_sehatku_schema.sql`](../database/mysql_sehatku_schema.sql) → klik **Go / Kirim**.
3. Database `sehatku_db` beserta 6 tabel berelasi (`polyclinics`, `users`, `doctors`, `doctor_schedules`, `appointments`, `medical_records`) dan data awal (*seed*) akan otomatis terbentuk.
