import 'package:flutter/material.dart';

import '../services/async_demo_service.dart';
import '../theme/sehatku_theme.dart';

class AsyncComparisonScreen extends StatefulWidget {
  const AsyncComparisonScreen({super.key});

  @override
  State<AsyncComparisonScreen> createState() => _AsyncComparisonScreenState();
}

class _AsyncComparisonScreenState extends State<AsyncComparisonScreen> {
  final AsyncDemoService _service = AsyncDemoService();

  AsyncComparisonReport? _lastReport;
  bool _isRunningEventLoop = false;

  NetworkSimScenario _selectedScenario = NetworkSimScenario.success;
  bool _isLoadingNetwork = false;
  Map<String, dynamic>? _networkResult;
  String? _networkError;

  void _runSyncDemo() {
    final report = _service.runSynchronousDemo(workDurationMs: 180);
    setState(() {
      _lastReport = report;
    });
  }

  Future<void> _runAsyncDemo() async {
    setState(() => _isRunningEventLoop = true);
    final report = await _service.runAsynchronousEventLoopDemo(
      taskDelayMs: 160,
    );
    if (!mounted) return;
    setState(() {
      _lastReport = report;
      _isRunningEventLoop = false;
    });
  }

  Future<void> _runNetworkScenario() async {
    setState(() {
      _isLoadingNetwork = true;
      _networkError = null;
      _networkResult = null;
    });

    try {
      final result = await _service.simulateClinicSync(
        _selectedScenario,
        delay: const Duration(milliseconds: 450),
        timeout: const Duration(milliseconds: 220),
      );
      if (!mounted) return;
      setState(() {
        _networkResult = result;
        _isLoadingNetwork = false;
      });
    } on NetworkSimException catch (e) {
      if (!mounted) return;
      setState(() {
        _networkError = e.message;
        _isLoadingNetwork = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _networkError = 'Kesalahan tidak terduga: $e';
        _isLoadingNetwork = false;
      });
    }
  }

  Color _queueBgColor(String queue, bool isDark) {
    if (isDark) {
      return switch (queue) {
        'Sync' => const Color(0xFF451A03),
        'Microtask' => const Color(0xFF134E4A),
        'Event Queue' => const Color(0xFF0C4A6E),
        'Timer' => const Color(0xFF312E81),
        _ => const Color(0xFF1E293B),
      };
    }
    return switch (queue) {
      'Sync' => const Color(0xFFFEF3C7),
      'Microtask' => SehatKuColors.primarySoft,
      'Event Queue' => const Color(0xFFE0F2FE),
      'Timer' => const Color(0xFFE0E7FF),
      _ => const Color(0xFFF1F5F9),
    };
  }

  Color _queueTextColor(String queue, bool isDark) {
    if (isDark) {
      return switch (queue) {
        'Sync' => const Color(0xFFFDE68A),
        'Microtask' => const Color(0xFF5EEAD4),
        'Event Queue' => const Color(0xFF7DD3FC),
        'Timer' => const Color(0xFFC7D2FE),
        _ => const Color(0xFFE2E8F0),
      };
    }
    return switch (queue) {
      'Sync' => const Color(0xFF92400E),
      'Microtask' => SehatKuColors.primaryDark,
      'Event Queue' => const Color(0xFF075985),
      'Timer' => const Color(0xFF3730A3),
      _ => const Color(0xFF334155),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPad = SehatKuResponsive.horizontalPadding(width);
    final subtleColor = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF475569);

    return Scaffold(
      appBar: AppBar(title: const Text('Lab Asinkron & Event Loop')),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(horizontalPad, 16, horizontalPad, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '1. Perbandingan Sinkron vs Asinkron (Event Loop)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bandingkan pemrosesan sinkron yang memblokir thread utama dengan eksekusi asinkron Dart (Microtask, Event Queue, dan Future.wait).',
                  style: TextStyle(fontSize: 13, color: subtleColor),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            SizedBox(
                              height: 44,
                              child: OutlinedButton.icon(
                                key: const Key('run_sync_demo_button'),
                                onPressed: _isRunningEventLoop
                                    ? null
                                    : _runSyncDemo,
                                icon: const Icon(Icons.pause_circle_outline),
                                label: const Text('Jalankan Sinkron'),
                              ),
                            ),
                            SizedBox(
                              height: 44,
                              child: ElevatedButton.icon(
                                key: const Key('run_async_demo_button'),
                                onPressed: _isRunningEventLoop
                                    ? null
                                    : _runAsyncDemo,
                                icon: const Icon(Icons.bolt_outlined),
                                label: Text(
                                  _isRunningEventLoop
                                      ? 'Menjalankan Event Loop...'
                                      : 'Jalankan Asinkron (Event Loop)',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_isRunningEventLoop)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Menjalankan antrean Microtask & Future...'),
                              ],
                            ),
                          )
                        else if (_lastReport == null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Belum ada hasil pengujian. Pilih salah satu tombol di atas untuk melihat urutan eksekusi Event Loop dan waktu proses.',
                              style: TextStyle(
                                fontSize: 13,
                                color: subtleColor,
                              ),
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 10,
                                runSpacing: 8,
                                children: [
                                  _metricBadge(
                                    label: 'Mode',
                                    value: _lastReport!.modeTitle,
                                    isDark: isDark,
                                  ),
                                  _metricBadge(
                                    label: _lastReport!.blockedMainThread
                                        ? 'Total Blocking'
                                        : 'Await Sekuensial',
                                    value: '${_lastReport!.totalElapsedMs} ms',
                                    isDark: isDark,
                                  ),
                                  if (_lastReport!.parallelElapsedMs != null)
                                    _metricBadge(
                                      label: 'Future.wait Paralel',
                                      value:
                                          '${_lastReport!.parallelElapsedMs} ms',
                                      isDark: isDark,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Log Urutan Eksekusi:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ..._lastReport!.entries.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _queueBgColor(
                                            entry.queueLabel,
                                            isDark,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          entry.queueLabel,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: _queueTextColor(
                                              entry.queueLabel,
                                              isDark,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          entry.detail,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '+${entry.elapsedMs} ms',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: subtleColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '2. Simulasi Future, Try-Catch, Loading & Error State',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Uji penanganan jaringan klinik pada tiga skenario nyata: respons sukses, batas waktu habis (timeout), dan kondisi offline.',
                  style: TextStyle(fontSize: 13, color: subtleColor),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              key: const Key('scenario_success_chip'),
                              label: const Text('Koneksi Normal'),
                              selected:
                                  _selectedScenario ==
                                  NetworkSimScenario.success,
                              selectedColor: SehatKuColors.primaryDark,
                              labelStyle: TextStyle(
                                color:
                                    _selectedScenario ==
                                        NetworkSimScenario.success
                                    ? Colors.white
                                    : null,
                                fontWeight: FontWeight.w600,
                              ),
                              onSelected: (_) => setState(
                                () => _selectedScenario =
                                    NetworkSimScenario.success,
                              ),
                            ),
                            ChoiceChip(
                              key: const Key('scenario_timeout_chip'),
                              label: const Text('Simulasi Timeout'),
                              selected:
                                  _selectedScenario ==
                                  NetworkSimScenario.timeout,
                              selectedColor: SehatKuColors.primaryDark,
                              labelStyle: TextStyle(
                                color:
                                    _selectedScenario ==
                                        NetworkSimScenario.timeout
                                    ? Colors.white
                                    : null,
                                fontWeight: FontWeight.w600,
                              ),
                              onSelected: (_) => setState(
                                () => _selectedScenario =
                                    NetworkSimScenario.timeout,
                              ),
                            ),
                            ChoiceChip(
                              key: const Key('scenario_offline_chip'),
                              label: const Text('Simulasi Offline'),
                              selected:
                                  _selectedScenario ==
                                  NetworkSimScenario.offline,
                              selectedColor: SehatKuColors.primaryDark,
                              labelStyle: TextStyle(
                                color:
                                    _selectedScenario ==
                                        NetworkSimScenario.offline
                                    ? Colors.white
                                    : null,
                                fontWeight: FontWeight.w600,
                              ),
                              onSelected: (_) => setState(
                                () => _selectedScenario =
                                    NetworkSimScenario.offline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 46,
                          child: ElevatedButton.icon(
                            key: const Key('run_network_sim_button'),
                            onPressed: _isLoadingNetwork
                                ? null
                                : _runNetworkScenario,
                            icon: const Icon(Icons.sync_rounded),
                            label: const Text('Uji Permintaan Asinkron'),
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (_isLoadingNetwork)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Memuat data sinkronisasi klinik...'),
                              ],
                            ),
                          )
                        else if (_networkError != null)
                          Container(
                            key: const Key('network_error_state'),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF450A0A)
                                  : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFFB91C1C)
                                    : const Color(0xFFFECACA),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.wifi_off_rounded,
                                      size: 20,
                                      color: isDark
                                          ? const Color(0xFFFCA5A5)
                                          : const Color(0xFF991B1B),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Kegagalan Koneksi Tertangani',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? const Color(0xFFFECACA)
                                              : const Color(0xFF991B1B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _networkError!,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: isDark
                                        ? const Color(0xFFFECACA)
                                        : const Color(0xFF7F1D1D),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed: _runNetworkScenario,
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          )
                        else if (_networkResult != null)
                          Container(
                            key: const Key('network_success_state'),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF052E16)
                                  : const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF15803D)
                                    : const Color(0xFFBBF7D0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: isDark
                                      ? const Color(0xFF86EFAC)
                                      : const Color(0xFF166534),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${_networkResult!['status']}: ${_networkResult!['availableDoctors']} dokter pada ${_networkResult!['activePoli']} poli dimuat dalam ${_networkResult!['latencyMs']} ms.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? const Color(0xFFDCFCE7)
                                          : const Color(0xFF166534),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Text(
                            'Pilih skenario lalu tekan "Uji Permintaan Asinkron" untuk melihat transisi loading dan error handling.',
                            style: TextStyle(fontSize: 13, color: subtleColor),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricBadge({
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF475569),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
