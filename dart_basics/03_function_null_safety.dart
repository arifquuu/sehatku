/// Tugas 2 (c) — Pemrograman Dart Dasar: Function & Null Safety
/// Tema: Validasi Data Pasien, Format Antrean, & Estimasi Biaya Kunjungan SehatKu

String formatNomorAntrean({
  required String kodePoli,
  required int nomorUrut,
}) {
  final kodeBersih = kodePoli.trim().toUpperCase();
  final padded = nomorUrut.toString().padLeft(3, '0');
  return '$kodeBersih-$padded';
}

bool isNikValid(String? nik) {
  if (nik == null) return false;
  final bersih = nik.trim();
  return RegExp(r'^\d{16}$').hasMatch(bersih);
}

String ringkasanPenjamin({
  required String namaPasien,
  String? nomorBpjs,
  String? keluhanUtama,
}) {
  final statusBpjs = (nomorBpjs != null && nomorBpjs.trim().isNotEmpty)
      ? 'BPJS (${nomorBpjs.trim()})'
      : 'Pasien Umum';
  final catatanKeluhan = keluhanUtama?.trim().isNotEmpty == true
      ? keluhanUtama!.trim()
      : 'Belum diisi';

  return 'Pasien: $namaPasien | Penjamin: $statusBpjs | Keluhan: $catatanKeluhan';
}

int hitungEstimasiBiaya({
  required int tarifKonsultasi,
  required bool pakaiBpjs,
  int biayaAdmin = 10000,
}) {
  if (pakaiBpjs) return 0;
  return tarifKonsultasi + biayaAdmin;
}

void main() {
  print('=== SIMULASI FUNCTION & NULL SAFETY SEHATKU ===');

  const nikValid = '6171031504040001';
  const String? nikKosong = null;

  print('Cek NIK "$nikValid": ${isNikValid(nikValid) ? "Valid" : "Tidak Valid"}');
  print('Cek NIK null: ${isNikValid(nikKosong) ? "Valid" : "Tidak Valid"}');

  final nomorAntrean = formatNomorAntrean(kodePoli: 'a', nomorUrut: 7);
  print('Nomor Antrean Terbit: $nomorAntrean');

  print(
    ringkasanPenjamin(
      namaPasien: 'Evan',
      nomorBpjs: '0001849201102',
      keluhanUtama: 'Demam ringan sejak kemarin malam',
    ),
  );
  print(
    ringkasanPenjamin(
      namaPasien: 'Pasien Tamu',
      nomorBpjs: null,
      keluhanUtama: null,
    ),
  );

  final totalUmum = hitungEstimasiBiaya(
    tarifKonsultasi: 85000,
    pakaiBpjs: false,
  );
  final totalBpjs = hitungEstimasiBiaya(
    tarifKonsultasi: 85000,
    pakaiBpjs: true,
  );
  print('Estimasi Biaya Umum: Rp$totalUmum | Estimasi Biaya BPJS: Rp$totalBpjs');
}
