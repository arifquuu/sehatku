-- ============================================================================
-- SKEMA BASIS DATA MYSQL — APLIKASI KLINIK SEHATKU (KELOMPOK 4)
-- Mata Kuliah : Pengembangan Aplikasi Perangkat Bergerak (A) — UAS PBL
-- Tugas 11    : Autentikasi Pengguna & Skema Relasional Klinik (MySQL)
-- Penyusun    : M. Fadjri Akbar (UI/UX & Data Developer)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS sehatku_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE sehatku_db;

-- 1. Tabel Master Poliklinik (polyclinics)
CREATE TABLE IF NOT EXISTS polyclinics (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(15) NOT NULL UNIQUE,
  name VARCHAR(80) NOT NULL,
  floor_location VARCHAR(50) NOT NULL,
  queue_prefix CHAR(1) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Tabel Pengguna / Pasien & Admin dengan Hash Password (users)
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  rm_number VARCHAR(20) NOT NULL UNIQUE,
  nik CHAR(16) NOT NULL UNIQUE,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL COMMENT 'Bcrypt/Argon2 password hash',
  phone VARCHAR(20) DEFAULT NULL,
  blood_type VARCHAR(5) DEFAULT 'O+',
  allergies VARCHAR(255) DEFAULT 'Tidak ada alergi obat',
  bpjs_number VARCHAR(20) DEFAULT NULL,
  role ENUM('pasien', 'admin') NOT NULL DEFAULT 'pasien',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 3. Tabel Dokter Klinik (doctors)
CREATE TABLE IF NOT EXISTS doctors (
  id INT AUTO_INCREMENT PRIMARY KEY,
  polyclinic_id INT NOT NULL,
  doctor_code VARCHAR(20) NOT NULL UNIQUE,
  full_name VARCHAR(120) NOT NULL,
  specialist_title VARCHAR(100) NOT NULL,
  str_number VARCHAR(40) NOT NULL,
  room_number VARCHAR(25) NOT NULL,
  consultation_fee INT NOT NULL DEFAULT 50000,
  experience_years INT NOT NULL DEFAULT 5,
  daily_quota INT NOT NULL DEFAULT 10,
  rating DECIMAL(2,1) NOT NULL DEFAULT 4.8,
  alumni_university VARCHAR(100) DEFAULT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  CONSTRAINT fk_doctors_polyclinic
    FOREIGN KEY (polyclinic_id) REFERENCES polyclinics(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 4. Tabel Jadwal Praktik Dokter (doctor_schedules)
CREATE TABLE IF NOT EXISTS doctor_schedules (
  id INT AUTO_INCREMENT PRIMARY KEY,
  doctor_id INT NOT NULL,
  day_of_week VARCHAR(40) NOT NULL,
  session_range VARCHAR(30) NOT NULL,
  quota_per_session INT NOT NULL DEFAULT 5,
  CONSTRAINT fk_schedules_doctor
    FOREIGN KEY (doctor_id) REFERENCES doctors(id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 5. Tabel Pendaftaran Antrean / Booking Kunjungan (appointments)
CREATE TABLE IF NOT EXISTS appointments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  queue_number VARCHAR(12) NOT NULL,
  user_id INT NOT NULL,
  doctor_id INT NOT NULL,
  visit_date DATE NOT NULL,
  session_time VARCHAR(30) NOT NULL,
  payment_type ENUM('BPJS Kesehatan', 'Pasien Umum') NOT NULL DEFAULT 'BPJS Kesehatan',
  complaint TEXT NOT NULL,
  status ENUM('Terjadwal', 'Diproses', 'Selesai', 'Dibatalkan') NOT NULL DEFAULT 'Terjadwal',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_appointments_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_appointments_doctor
    FOREIGN KEY (doctor_id) REFERENCES doctors(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 6. Tabel Rekam Medis Pasien (medical_records)
CREATE TABLE IF NOT EXISTS medical_records (
  id INT AUTO_INCREMENT PRIMARY KEY,
  appointment_id INT DEFAULT NULL,
  user_id INT NOT NULL,
  doctor_id INT NOT NULL,
  visit_date DATE NOT NULL,
  diagnosis VARCHAR(180) NOT NULL,
  symptoms TEXT NOT NULL,
  treatment_prescription TEXT NOT NULL,
  blood_pressure VARCHAR(20) DEFAULT '120/80 mmHg',
  body_weight_kg DECIMAL(5,2) DEFAULT 60.00,
  next_control_date DATE DEFAULT NULL,
  doctor_notes TEXT DEFAULT NULL,
  document_photo_path VARCHAR(255) DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_mr_appointment
    FOREIGN KEY (appointment_id) REFERENCES appointments(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_mr_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_mr_doctor
    FOREIGN KEY (doctor_id) REFERENCES doctors(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ============================================================================
-- DATA AWAL (SEED DATA) UNTUK PENGUJIAN BACKEND & PHPMYADMIN
-- ============================================================================

INSERT INTO polyclinics (code, name, floor_location, queue_prefix) VALUES
  ('POLI-UMUM', 'Poli Umum', 'Lantai 1 - Sayap Barat', 'A'),
  ('POLI-GIGI', 'Poli Gigi & Mulut', 'Lantai 1 - Sayap Timur', 'B'),
  ('POLI-ANAK', 'Poli Anak', 'Lantai 1 - Ruang Ramah Anak', 'C'),
  ('POLI-PD',   'Poli Penyakit Dalam', 'Lantai 2 - Sayap Barat', 'D'),
  ('POLI-KIA',  'Poli KIA & Kandungan', 'Lantai 2 - Ruang Ibu & Anak', 'E'),
  ('POLI-THT',  'Poli Mata & THT', 'Lantai 2 - Sayap Timur', 'F');

-- Contoh akun pasien & admin (password_hash menggunakan format bcrypt standar)
INSERT INTO users (rm_number, nik, full_name, email, password_hash, phone, blood_type, bpjs_number, role) VALUES
  ('RM-2026-0104', '6171032405040002', 'M. Fadjri Akbar', 'fadjri@sehatku.id', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081256789044', 'O+', '0001849201142', 'pasien'),
  ('RM-2026-0001', '6171010101000001', 'Admin Klinik SehatKu', 'admin@sehatku.id', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0561577963', 'A+', NULL, 'admin');

INSERT INTO doctors (polyclinic_id, doctor_code, full_name, specialist_title, str_number, room_number, consultation_fee, experience_years, daily_quota, rating, alumni_university) VALUES
  (1, 'dok-01', 'dr. Andi Pratama, M.Kes', 'Dokter Umum & Kesehatan Keluarga', '31.1.1.100.2.21.014521', 'Ruang R-101', 50000, 8, 12, 4.9, 'FK Universitas Tanjungpura'),
  (2, 'dok-03', 'drg. Budi Santoso, Sp.KG', 'Spesialis Konservasi Gigi', '31.2.2.200.3.20.009841', 'Ruang R-104', 90000, 11, 7, 4.9, 'FKG Universitas Airlangga'),
  (3, 'dok-05', 'dr. Siti Rahmawati, Sp.A', 'Spesialis Kesehatan Anak', '31.2.1.401.3.19.007210', 'Ruang R-102', 100000, 9, 9, 5.0, 'FK Universitas Indonesia'),
  (4, 'dok-07', 'dr. Hendra Wijaya, Sp.PD', 'Spesialis Penyakit Dalam', '31.2.1.301.3.18.005419', 'Ruang R-201', 120000, 13, 10, 4.9, 'FK Universitas Indonesia'),
  (5, 'dok-09', 'dr. Maya Kusuma, Sp.OG', 'Spesialis Obstetri & Ginekologi', '31.2.1.501.3.19.006332', 'Ruang R-203', 125000, 11, 8, 4.9, 'FK Universitas Gadjah Mada'),
  (6, 'dok-11', 'dr. Dimas Prasetyo, Sp.M', 'Spesialis Kesehatan Mata', '31.2.1.601.3.20.009115', 'Ruang R-205', 105000, 9, 9, 4.8, 'FK Universitas Padjadjaran');
