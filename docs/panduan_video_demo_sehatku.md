# Panduan & Naskah Video Demo Aplikasi SehatKu (Durasi 3–5 Menit)

Gunakan panduan ini saat merekam layar (OBS Studio / Xbox Game Bar / Screen Recorder Android) untuk **Langkah 7 Evan**:

---

## Persiapan Sebelum Rekam
1. Pasang APK rilis `v1.0.0` di HP/Emulator Android (atau jalankan `flutter run -d chrome`).
2. *(Opsional untuk demo MySQL)*: Jalankan server PHP (`php -S 0.0.0.0:8080 -t backend backend/index.php`) dan pastikan MySQL aktif dengan akun `fadjri@sehatku.id` / `password`. Jika tidak menyalakan server, gunakan tombol **Masuk Mode Demo Lokal (Tanpa Server)**.

---

## Alur Rekaman (Target: 4 Menit)

### 1. Pembukaan & Halaman Masuk (00:00 – 00:35)
- Perkenalkan diri (Evan, Kelompok 4) dan tujuan aplikasi SehatKu.
- Tunjukkan halaman `/login` (proteksi rute `AuthGate`), lalu masuk menggunakan akun MySQL atau klik **Masuk Mode Demo Lokal**.

### 2. Beranda & Widget `setState` (00:35 – 01:20)
- Tunjukkan kartu identitas pasien, kolom pencarian dokter, filter chip poli, dan **Widget Persiapan Kunjungan Klinik (`ClinicPrepChecklistWidget`)**.
- Centang salah satu item checklist dan klik tombol `+` pada estimasi antrean untuk menunjukkan perubahan state lokal secara langsung.

### 3. Jadwal Dokter, REST API & Booking Online + QR Antrean (01:20 – 02:25)
- Buka tab **Jadwal**, ubah tampilan Daftar ↔ Grid (atau perbesar jendela jika di Web/Tablet untuk menunjukkan responsivitas).
- Pilih salah satu dokter → masuk ke halaman **Booking Detail** → pilih tanggal, sesi jam, penjamin (BPJS/Umum), isi keluhan → konfirmasi.
- Buka **Tiket QR Antrean** dan tunjukkan nomor antrean serta kode QR siap pindai.

### 4. Rekam Medis Offline-First & Lampiran Foto (02:25 – 03:10)
- Buka tab **Rekam Medis**, tambahkan atau edit satu catatan rekam medis, dan tunjukkan fitur pilih foto dokumen medis (galeri/kamera).
- Jelaskan bahwa data tersimpan persisten di SQLite lokal.

### 5. Profil, Mode Gelap, Grafik Kunjungan Poli & Lab Asinkron (03:10 – 04:00)
- Buka tab **Profil**: tunjukkan daftar dokter favorit (Hive), aktifkan **Mode Gelap**, uji tombol **Kirim Notifikasi Pengingat**, dan tunjukkan **Grafik Rekap Kunjungan per Poli (`visitCountByPoli`)**.
- *(Opsional singkat)* Buka Drawer → **Lab Asinkron** untuk menunjukkan demo perbandingan sync vs async.
- Tutup presentasi dengan menyebut tautan GitHub & rilis APK `v1.0.0`.
