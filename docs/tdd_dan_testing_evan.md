# Dokumentasi QA, Unit/Widget Testing, TDD & Bug Log — SehatKu (Tugas 13)

**Disusun oleh:** Evan (QA, Dokumentasi & Fitur Dasar — Kelompok 4)  

---

## 1. Ringkasan Cakupan Pengujian Otomatis

Seluruh pengujian otomatis berada di folder `test/` menggunakan `flutter_test`:

| Berkas Pengujian | Fokus Pengujian | Jumlah Kasus Uji |
| :--- | :--- | :---: |
| [`test/widget_test.dart`](../test/widget_test.dart) | Dataset dokter (Tugas 4), REST API MockClient (Tugas 9), CRUD SQLite & persistensi Hive/SharedPreferences (Tugas 10), Widget UI responsif mobile & tablet (Tugas 3 & 5) | 4 test |
| [`test/arif_features_test.dart`](../test/arif_features_test.dart) | `AuthProvider` login/register/logout/restore sesi (Tugas 7 & 11), `AuthGate` proteksi rute (Tugas 5), `AsyncDemoService` (Tugas 8), `MediaService` (Tugas 12), `QrQueueTicketScreen` (Tugas 14) | 4 test |
| [`test/evan_validation_tdd_test.dart`](../test/evan_validation_tdd_test.dart) | Validasi NIK & nama pasien, estimasi biaya BPJS/Umum & waktu tunggu, ketersediaan kuota jadwal, fungsi TDD `formatQueueNumber`, serta widget test `ClinicPrepChecklistWidget` (`setState`) | 5 test |

**Total keseluruhan:** 13 skenario pengujian otomatis (`flutter test`).

---

## 2. Catatan Siklus TDD (Test-Driven Development)

Sesuai instruksi Tugas 13, siklus TDD (**Red → Green → Refactor**) diterapkan pada fungsi `PatientValidator.formatQueueNumber` di `lib/utils/patient_validator.dart`:

### Tahap 1 — RED (Tulis Test Terlebih Dahulu)
Menulis ekspektasi pada `test/evan_validation_tdd_test.dart` sebelum fungsi `formatQueueNumber` dibuat:
- Input `poliCode: 'a', sequenceNumber: 7` harus menghasilkan `'A-007'`.
- Input `poliCode: ' c ', sequenceNumber: 25` harus menghasilkan `'C-025'`.
- Input `poliCode: ''` atau `sequenceNumber: 0` harus melempar `ArgumentError`.

Saat dijalankan sebelum implementasi, test gagal (*compile error* / *Undefined method 'formatQueueNumber'*):
```text
Error: Member not found: 'PatientValidator.formatQueueNumber'.
```

### Tahap 2 — GREEN (Implementasi Kode Minimal agar Lulus)
Mengimplementasikan `formatQueueNumber` di `lib/utils/patient_validator.dart`:
```dart
static String formatQueueNumber({
  required String poliCode,
  required int sequenceNumber,
}) {
  final cleanCode = poliCode.trim().toUpperCase();
  if (cleanCode.isEmpty) {
    throw ArgumentError('Kode poli tidak boleh kosong.');
  }
  if (sequenceNumber < 1) {
    throw ArgumentError('Nomor urut antrean minimal 1.');
  }
  final padded = sequenceNumber.toString().padLeft(3, '0');
  return '$cleanCode-$padded';
}
```
Setelah implementasi, test pada grup `TDD Test: formatQueueNumber` lulus.

### Tahap 3 — REFACTOR
Merapikan docstring serta menyatukan konvensi `ArgumentError` bersama fungsi validasi lain di `PatientValidator` tanpa mengubah perilaku yang sudah lulus uji.

---

## 3. Catatan 2 Bug Nyata yang Ditemukan Tim Saat Integrasi & Solusinya

### Bug 1 — Overflow UI Layar Mobile 390px & Timer Timeout Menggantung di Async Demo
- **Gejala:**
  1. Pada pengujian layar ponsel sempit (`390 px`), `Row` pada `LoginScreen` dan `ProfileScreen` mengalami *RenderFlex overflow* di sisi kanan teks/tombol.
  2. Saat pengujian unit/widget pada `AsyncDemoService`, `Timer` simulasi timeout sempat menggantung (*pending timer*) setelah test selesai.
  *(Catatan tambahan dari pengujian awal UI: pada `MedicalRecordScreen` mode mobile `ListView`, pemakaian `Spacer()` di dalam item `ListView` juga sempat memicu error `RenderFlex` unbounded height).*
- **Akar Penyebab:**
  - `Row` tidak membungkus teks panjang dengan `Expanded`/`Flexible` atau beralih ke `Wrap` pada layar sempit.
  - Timer simulasi timeout di `AsyncDemoService` belum dibatalkan secara eksplisit ketika operasi selesai lebih cepat atau saat teardown.
- **Solusi (Commit `5f8250e`):**
  - Menyesuaikan tata letak `Row` menjadi `Expanded`/`Wrap` agar responsif di lebar `390 px` tanpa overflow.
  - Menambahkan pembatalan (`timer.cancel()`) pada timer timeout di `AsyncDemoService` sehingga tidak ada *pending timer* yang menggantung saat testing.

### Bug 2 — Konflik Versi AGP 9.1.0 dan `compileSdk 36` Saat Build APK Release
- **Gejala:** Proses `flutter build apk --release` gagal karena konflik versi Android Gradle Plugin (AGP `9.1.0`) dengan `compileSdk 36`, sementara plugin `flutter_local_notifications` dan `permission_handler` menuntut `compileSdk 37`.
- **Akar Penyebab:** Konfigurasi `android/app/build.gradle.kts` dan versi AGP belum selaras dengan kebutuhan SDK minimum plugin notifikasi dan izin Android terbaru, serta plugin registrants perlu disinkronkan untuk build rilis.
- **Solusi (Commit `7a63b96`):** Memperbarui konfigurasi build Android ke **AGP 9.1.1**, menaikkan **`compileSdk 37`**, dan memastikan plugin registrants terkonfigurasi dengan benar hingga APK release berhasil dibangun dan diunggah ke GitHub Releases `v1.0.0`.

---

## 4. Penilaian Sistem Terhadap Alur Bisnis Klinik & Rekomendasi

### Penilaian Alur Bisnis Klinik
1. **Alur Pendaftaran & Check-in:** Sudah berjalan utuh mulai dari autentikasi pasien (`AuthGate`), pencarian dokter/poli, pemilihan jadwal & penjamin (BPJS/Umum), penerbitan tiket QR antrean, hingga notifikasi lokal.
2. **Alur Rekam Medis Offline-First:** Catatan diagnosis, resep, tanda vital, dan lampiran foto dokumen medis tersimpan persisten di SQLite & Hive sehingga tetap dapat diakses saat klinik mengalami gangguan internet.
3. **Kesiapan Analitik:** Rekap `visitCountByPoli` di tab Profil sudah memberi gambaran beban kunjungan per poli.

### Rekomendasi Perbaikan ke Depan
1. **Sinkronisasi Dua Arah (MySQL ↔ SQLite):** Saat ini booking dan rekam medis masih tersimpan lokal di SQLite; ke depan perlu endpoint sinkronisasi agar riwayat pasien dapat dibuka di perangkat berbeda.
2. **Pemindai QR Sisi Petugas:** Menambahkan halaman khusus admin/resepsionis untuk memindai QR antrean pasien (`QrQueueTicketScreen`) dan mengubah status antrean secara otomatis menjadi `Selesai`.
3. **Pengujian Integrasi End-to-End:** Menambahkan `integration_test` untuk menguji alur penuh dari Login → Booking → QR Antrean → Rekam Medis pada emulator Android nyata.
