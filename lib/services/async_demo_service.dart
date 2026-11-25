import 'dart:async';

enum NetworkSimScenario { success, timeout, offline }

class AsyncLogEntry {
  final int elapsedMs;
  final String queueLabel;
  final String detail;

  const AsyncLogEntry({
    required this.elapsedMs,
    required this.queueLabel,
    required this.detail,
  });
}

class AsyncComparisonReport {
  final String modeTitle;
  final int totalElapsedMs;
  final int? parallelElapsedMs;
  final bool blockedMainThread;
  final List<AsyncLogEntry> entries;

  const AsyncComparisonReport({
    required this.modeTitle,
    required this.totalElapsedMs,
    this.parallelElapsedMs,
    required this.blockedMainThread,
    required this.entries,
  });
}

class NetworkSimException implements Exception {
  final String message;
  final bool isTimeout;

  const NetworkSimException(this.message, {this.isTimeout = false});

  @override
  String toString() => message;
}

class AsyncDemoService {
  AsyncComparisonReport runSynchronousDemo({int workDurationMs = 180}) {
    final watch = Stopwatch()..start();
    final entries = <AsyncLogEntry>[
      const AsyncLogEntry(
        elapsedMs: 0,
        queueLabel: 'Sync',
        detail: 'Memulai pemrosesan sinkron di main isolate',
      ),
    ];

    _busyWait(workDurationMs);
    entries.add(
      AsyncLogEntry(
        elapsedMs: watch.elapsedMilliseconds,
        queueLabel: 'Sync',
        detail: 'Tugas 1 (validasi jadwal dokter) selesai secara blocking',
      ),
    );

    _busyWait(workDurationMs);
    entries.add(
      AsyncLogEntry(
        elapsedMs: watch.elapsedMilliseconds,
        queueLabel: 'Sync',
        detail: 'Tugas 2 (rekap antrean poli) selesai secara blocking',
      ),
    );

    watch.stop();
    return AsyncComparisonReport(
      modeTitle: 'Sinkron (Blocking)',
      totalElapsedMs: watch.elapsedMilliseconds,
      blockedMainThread: true,
      entries: entries,
    );
  }

  Future<AsyncComparisonReport> runAsynchronousEventLoopDemo({
    int taskDelayMs = 160,
  }) async {
    final watch = Stopwatch()..start();
    final entries = <AsyncLogEntry>[];

    entries.add(
      AsyncLogEntry(
        elapsedMs: watch.elapsedMilliseconds,
        queueLabel: 'Sync',
        detail: '1. Baris kode sinkron pertama dieksekusi langsung',
      ),
    );

    final eventDone = Future<void>(() {
      entries.add(
        AsyncLogEntry(
          elapsedMs: watch.elapsedMilliseconds,
          queueLabel: 'Event Queue',
          detail: '4. Future() dijalankan setelah seluruh microtask selesai',
        ),
      );
    });

    final timerDone = Future<void>.delayed(
      const Duration(milliseconds: 25),
      () {
        entries.add(
          AsyncLogEntry(
            elapsedMs: watch.elapsedMilliseconds,
            queueLabel: 'Timer',
            detail: '5. Future.delayed(25ms) dieksekusi oleh timer event loop',
          ),
        );
      },
    );

    final microtaskDone = Future<void>.microtask(() {
      entries.add(
        AsyncLogEntry(
          elapsedMs: watch.elapsedMilliseconds,
          queueLabel: 'Microtask',
          detail: '3. Future.microtask() diprioritaskan sebelum Event Queue',
        ),
      );
    });

    entries.add(
      AsyncLogEntry(
        elapsedMs: watch.elapsedMilliseconds,
        queueLabel: 'Sync',
        detail: '2. Baris kode sinkron kedua selesai sebelum antrean async',
      ),
    );

    await Future.wait([microtaskDone, eventDone, timerDone]);

    final seqWatch = Stopwatch()..start();
    await _delayedTask('Ambil jadwal dokter', taskDelayMs);
    await _delayedTask('Ambil rekam medis', taskDelayMs);
    seqWatch.stop();
    entries.add(
      AsyncLogEntry(
        elapsedMs: watch.elapsedMilliseconds,
        queueLabel: 'Async',
        detail:
            '6. Dua await sekuensial selesai dalam ${seqWatch.elapsedMilliseconds} ms',
      ),
    );

    final parWatch = Stopwatch()..start();
    await Future.wait([
      _delayedTask('Ambil jadwal dokter', taskDelayMs),
      _delayedTask('Ambil rekam medis', taskDelayMs),
    ]);
    parWatch.stop();
    entries.add(
      AsyncLogEntry(
        elapsedMs: watch.elapsedMilliseconds,
        queueLabel: 'Async',
        detail:
            '7. Future.wait paralel selesai dalam ${parWatch.elapsedMilliseconds} ms (tanpa memblokir UI)',
      ),
    );

    watch.stop();
    return AsyncComparisonReport(
      modeTitle: 'Asinkron (Event Loop Non-Blocking)',
      totalElapsedMs: seqWatch.elapsedMilliseconds,
      parallelElapsedMs: parWatch.elapsedMilliseconds,
      blockedMainThread: false,
      entries: entries,
    );
  }

  Future<Map<String, dynamic>> simulateClinicSync(
    NetworkSimScenario scenario, {
    Duration delay = const Duration(milliseconds: 500),
    Duration timeout = const Duration(milliseconds: 250),
  }) async {
    final watch = Stopwatch()..start();
    try {
      switch (scenario) {
        case NetworkSimScenario.success:
          await Future<void>.delayed(delay);
          watch.stop();
          return {
            'status': 'Sinkronisasi berhasil',
            'activePoli': 6,
            'availableDoctors': 12,
            'latencyMs': watch.elapsedMilliseconds,
          };
        case NetworkSimScenario.timeout:
          final completer = Completer<String>();
          final timer = Timer(delay + timeout, () {
            if (!completer.isCompleted) completer.complete('late-response');
          });
          try {
            await completer.future.timeout(timeout);
          } finally {
            timer.cancel();
          }
          return const {};
        case NetworkSimScenario.offline:
          await Future<void>.delayed(const Duration(milliseconds: 220));
          throw const NetworkSimException(
            'Perangkat dalam kondisi offline. Data klinik tetap tersedia dari penyimpanan SQLite lokal.',
          );
      }
    } on TimeoutException {
      throw const NetworkSimException(
        'Permintaan ke server melebihi batas waktu (timeout). Tekan Coba Lagi saat jaringan stabil.',
        isTimeout: true,
      );
    }
  }

  void _busyWait(int milliseconds) {
    final end = DateTime.now().add(Duration(milliseconds: milliseconds));
    while (DateTime.now().isBefore(end)) {
      // Intentional busy-wait for educational sync vs async comparison.
    }
  }

  Future<String> _delayedTask(String name, int milliseconds) async {
    await Future<void>.delayed(Duration(milliseconds: milliseconds));
    return name;
  }
}
