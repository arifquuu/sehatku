// Tugas 2 (a) — Pemrograman Dart Dasar: Class & Inheritance
// Tema: Layanan Klinik SehatKu (LayananKlinik -> LayananPoli & LayananLaboratorium)

import 'dart:io';

class LayananKlinik {
  final String kode;
  final String nama;
  final int tarifDasar;

  const LayananKlinik({
    required this.kode,
    required this.nama,
    required this.tarifDasar,
  });

  String deskripsiSingkat() {
    return '[$kode] $nama — Tarif Dasar: Rp$tarifDasar';
  }

  int hitungBiaya({bool pakaiBpjs = false}) {
    return pakaiBpjs ? 0 : tarifDasar;
  }
}

class LayananPoli extends LayananKlinik {
  final String namaDokter;
  final String ruangan;
  final int kuotaHarian;

  const LayananPoli({
    required super.kode,
    required super.nama,
    required super.tarifDasar,
    required this.namaDokter,
    required this.ruangan,
    required this.kuotaHarian,
  });

  @override
  String deskripsiSingkat() {
    return '${super.deskripsiSingkat()} | Dokter: $namaDokter ($ruangan, Kuota: $kuotaHarian)';
  }
}

class LayananLaboratorium extends LayananKlinik {
  final int estimasiMenitHasil;
  final bool butuhPuasa;

  const LayananLaboratorium({
    required super.kode,
    required super.nama,
    required super.tarifDasar,
    required this.estimasiMenitHasil,
    this.butuhPuasa = false,
  });

  @override
  String deskripsiSingkat() {
    final syarat = butuhPuasa ? 'Wajib Puasa 8 Jam' : 'Tanpa Puasa';
    return '${super.deskripsiSingkat()} | Hasil: $estimasiMenitHasil menit ($syarat)';
  }
}

void main() {
  const poliUmum = LayananPoli(
    kode: 'A',
    nama: 'Poli Umum',
    tarifDasar: 50000,
    namaDokter: 'dr. Andi Pratama',
    ruangan: 'Ruang 101',
    kuotaHarian: 30,
  );

  const poliGigi = LayananPoli(
    kode: 'B',
    nama: 'Poli Gigi & Mulut',
    tarifDasar: 120000,
    namaDokter: 'drg. Ratna Sari',
    ruangan: 'Ruang 104',
    kuotaHarian: 20,
  );

  const cekDarah = LayananLaboratorium(
    kode: 'LAB-01',
    nama: 'Cek Gula Darah & Kolesterol',
    tarifDasar: 95000,
    estimasiMenitHasil: 45,
    butuhPuasa: true,
  );

  final daftarLayanan = <LayananKlinik>[poliUmum, poliGigi, cekDarah];

  stdout.writeln('=== DAFTAR LAYANAN KLINIK SEHATKU ===');
  for (final layanan in daftarLayanan) {
    stdout.writeln('- ${layanan.deskripsiSingkat()}');
    stdout.writeln(
      '  Biaya Umum: Rp${layanan.hitungBiaya()} | Biaya BPJS: Rp${layanan.hitungBiaya(pakaiBpjs: true)}',
    );
  }
}
