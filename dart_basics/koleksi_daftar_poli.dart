// Tugas 2 (b) — Pemrograman Dart Dasar: Koleksi List & Map
// Tema: Daftar Poliklinik, Kode Antrean, Kuota Harian, dan Rekap Kunjungan SehatKu

import 'dart:io';

void main() {
  // List berisi Map data 6 poliklinik utama Klinik SehatKu
  final List<Map<String, dynamic>> daftarPoli = [
    {
      'kode': 'A',
      'nama': 'Poli Umum',
      'kuota': 30,
      'terisi': 24,
      'tarif': 50000,
    },
    {
      'kode': 'B',
      'nama': 'Poli Gigi & Mulut',
      'kuota': 20,
      'terisi': 15,
      'tarif': 120000,
    },
    {
      'kode': 'C',
      'nama': 'Poli Anak',
      'kuota': 25,
      'terisi': 21,
      'tarif': 85000,
    },
    {
      'kode': 'D',
      'nama': 'Poli KIA & Kandungan',
      'kuota': 18,
      'terisi': 12,
      'tarif': 110000,
    },
    {
      'kode': 'E',
      'nama': 'Poli Penyakit Dalam',
      'kuota': 16,
      'terisi': 14,
      'tarif': 130000,
    },
    {
      'kode': 'F',
      'nama': 'Poli Mata & THT',
      'kuota': 15,
      'terisi': 9,
      'tarif': 115000,
    },
  ];

  // Map untuk merekap sisa kuota per kode poli
  final Map<String, int> sisaKuotaPerPoli = {};

  stdout.writeln('=== DAFTAR POLIKLINIK SEHATKU ===');
  for (final poli in daftarPoli) {
    final kode = poli['kode'] as String;
    final nama = poli['nama'] as String;
    final kuota = poli['kuota'] as int;
    final terisi = poli['terisi'] as int;
    final tarif = poli['tarif'] as int;
    final sisa = kuota - terisi;

    sisaKuotaPerPoli[nama] = sisa;
    stdout.writeln('[$kode] $nama | Terisi: $terisi/$kuota (Sisa: $sisa) | Rp$tarif');
  }

  // Filter poli yang masih memiliki sisa kuota >= 5
  final poliLega = daftarPoli.where((p) {
    final sisa = (p['kuota'] as int) - (p['terisi'] as int);
    return sisa >= 5;
  }).toList();

  stdout.writeln('\nPoli dengan sisa kuota >= 5 pasien:');
  for (final p in poliLega) {
    stdout.writeln('- ${p['nama']} (Kode ${p['kode']})');
  }

  stdout.writeln('\nRekap Map Sisa Kuota: $sisaKuotaPerPoli');
}
