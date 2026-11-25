import 'dart:async';
import 'dart:io';

Future<void> main() async {
  stdout.writeln('=== PERBANDINGAN SINKRON VS ASINKRON (DART EVENT LOOP) ===\n');

  stdout.writeln('1. EKSEKUSI SINKRON (BLOCKING)');
  final syncWatch = Stopwatch()..start();
  stdout.writeln('[Sync] Mulai memuat jadwal dokter...');
  _blockingWork(350);
  stdout.writeln(
    '[Sync] Jadwal dokter selesai (${syncWatch.elapsedMilliseconds} ms)',
  );
  stdout.writeln('[Sync] Mulai memuat rekam medis...');
  _blockingWork(350);
  stdout.writeln(
    '[Sync] Rekam medis selesai (${syncWatch.elapsedMilliseconds} ms)',
  );
  syncWatch.stop();
  stdout.writeln(
    '[Sync] Total waktu blocking: ${syncWatch.elapsedMilliseconds} ms\n',
  );

  stdout.writeln('2. URUTAN DART EVENT LOOP (SYNC -> MICROTASK -> EVENT QUEUE)');
  final order = <String>[];
  order.add('1. Kode sinkron (awal)');

  Future(() => order.add('4. Future Event Queue (default)'));
  Future.delayed(
    const Duration(milliseconds: 20),
    () => order.add('5. Future.delayed (timer 20 ms)'),
  );
  Future.microtask(() => order.add('3. Future.microtask (prioritas tinggi)'));

  order.add('2. Kode sinkron (akhir)');
  await Future<void>.delayed(const Duration(milliseconds: 50));
  for (final step in order) {
    stdout.writeln('  $step');
  }

  stdout.writeln('\n3. ASYNC/AWAIT SEKUENSIAL VS PARALEL (Future.wait)');
  final seqWatch = Stopwatch()..start();
  await _fetchSimulated('Jadwal Dokter', 250);
  await _fetchSimulated('Rekam Medis', 250);
  seqWatch.stop();
  stdout.writeln(
    '[Async Sekuensial] Total waktu: ${seqWatch.elapsedMilliseconds} ms',
  );

  final parWatch = Stopwatch()..start();
  await Future.wait([
    _fetchSimulated('Jadwal Dokter', 250),
    _fetchSimulated('Rekam Medis', 250),
  ]);
  parWatch.stop();
  stdout.writeln(
    '[Async Paralel Future.wait] Total waktu: ${parWatch.elapsedMilliseconds} ms',
  );

  stdout.writeln('\n4. PENANGANAN ERROR TRY-CATCH DAN TIMEOUT');
  try {
    await Future<String>.delayed(
      const Duration(milliseconds: 400),
      () => 'Respons lambat',
    ).timeout(const Duration(milliseconds: 150));
  } on TimeoutException {
    stdout.writeln(
      '[Error State] TimeoutException tertangkap aman oleh try-catch.',
    );
  }
}

void _blockingWork(int milliseconds) {
  final end = DateTime.now().add(Duration(milliseconds: milliseconds));
  while (DateTime.now().isBefore(end)) {
    // Busy-wait simulates synchronous work blocking the main isolate.
  }
}

Future<String> _fetchSimulated(String label, int milliseconds) async {
  await Future<void>.delayed(Duration(milliseconds: milliseconds));
  return '$label siap';
}
