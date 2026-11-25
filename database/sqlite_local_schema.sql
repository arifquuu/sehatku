-- ============================================================================
-- SKEMA BASIS DATA LOKAL SQLITE — APLIKASI FLUTTER SEHATKU (`sehatku_clinic.db`)
-- Tugas 10 : Penyimpanan Data Lokal (CRUD Rekam Medis & Riwayat Booking)
-- File Implementasi Dart: lib/services/database_helper.dart
-- ============================================================================

-- 1. Tabel Rekam Medis Ringkas Pasien (medical_records)
CREATE TABLE IF NOT EXISTS medical_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  patient_name TEXT NOT NULL,
  medical_record_number TEXT NOT NULL,
  visit_date TEXT NOT NULL,
  poli TEXT NOT NULL,
  doctor_name TEXT NOT NULL,
  diagnosis TEXT NOT NULL,
  symptoms TEXT NOT NULL,
  treatment_prescription TEXT NOT NULL,
  blood_pressure TEXT NOT NULL,
  body_weight_kg REAL NOT NULL,
  next_control_date TEXT NOT NULL,
  notes TEXT NOT NULL,
  document_photo_path TEXT
);

-- 2. Tabel Riwayat Pendaftaran & Nomor Antrean Lokal (bookings)
CREATE TABLE IF NOT EXISTS bookings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  queue_number TEXT NOT NULL,
  doctor_id TEXT NOT NULL,
  doctor_name TEXT NOT NULL,
  poli TEXT NOT NULL,
  room TEXT NOT NULL,
  patient_name TEXT NOT NULL,
  patient_nik TEXT NOT NULL,
  visit_date TEXT NOT NULL,
  session_time TEXT NOT NULL,
  payment_type TEXT NOT NULL,
  complaint TEXT NOT NULL,
  status TEXT NOT NULL,
  created_at TEXT NOT NULL
);
