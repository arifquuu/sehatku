/// Kumpulan fungsi validasi dan kalkulasi pasien SehatKu (Tugas 13 — Evan).
class PatientValidator {
  const PatientValidator._();

  /// Memvalidasi NIK 16 digit angka. Mengembalikan `null` jika valid.
  static String? validateNik(String? nik) {
    final value = nik?.trim() ?? '';
    if (value.isEmpty) {
      return 'NIK wajib diisi.';
    }
    if (!RegExp(r'^\d{16}$').hasMatch(value)) {
      return 'NIK harus terdiri dari tepat 16 digit angka.';
    }
    return null;
  }

  /// Memvalidasi nama lengkap pasien (minimal 3 karakter).
  static String? validatePatientName(String? name) {
    final value = name?.trim() ?? '';
    if (value.isEmpty) {
      return 'Nama pasien wajib diisi.';
    }
    if (value.length < 3) {
      return 'Nama pasien minimal 3 karakter.';
    }
    return null;
  }

  /// Menghitung estimasi total biaya konsultasi klinik (BPJS = Rp0).
  static int calculateConsultationEstimate({
    required int baseFee,
    required bool isBpjs,
    int adminFee = 10000,
  }) {
    if (baseFee < 0 || adminFee < 0) {
      throw ArgumentError('Tarif dan biaya admin tidak boleh negatif.');
    }
    if (isBpjs) return 0;
    return baseFee + adminFee;
  }

  /// Menghitung estimasi waktu tunggu antrean dalam menit.
  static int estimateQueueWaitMinutes({
    required int queuesAhead,
    int minutesPerPatient = 10,
  }) {
    if (queuesAhead <= 0 || minutesPerPatient <= 0) return 0;
    return queuesAhead * minutesPerPatient;
  }

  /// Mengecek apakah jadwal dokter masih bisa dibooking pasien.
  static bool isScheduleSlotAvailable({
    required int remainingQuota,
    required bool isDoctorAvailable,
  }) {
    return isDoctorAvailable && remainingQuota > 0;
  }

  /// Memformat nomor antrean poli (hasil implementasi siklus TDD).
  /// Contoh: kode `'a'`, urut `7` -> `'A-007'`.
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
}
