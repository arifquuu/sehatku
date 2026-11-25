import 'package:flutter/material.dart';

import '../theme/sehatku_theme.dart';

/// Widget mandiri berbasis [StatefulWidget] dan [setState] (Tugas 6 — Evan).
///
/// Mengelola state lokal sementara (ephemeral state) berupa:
/// 1. Checklist kelengkapan berkas pasien sebelum ke klinik.
/// 2. Simulasi jumlah antrean di depan untuk menghitung estimasi waktu tunggu.
class ClinicPrepChecklistWidget extends StatefulWidget {
  const ClinicPrepChecklistWidget({super.key});

  @override
  State<ClinicPrepChecklistWidget> createState() =>
      _ClinicPrepChecklistWidgetState();
}

class _ClinicPrepChecklistWidgetState extends State<ClinicPrepChecklistWidget> {
  final Map<String, bool> _checklist = {
    'KTP / Identitas Pasien': true,
    'Kartu BPJS / Rujukan (jika peserta JKN)': false,
    'Daftar Obat yang Sedang Dikonsumsi': false,
  };

  int _queuesAhead = 3;
  bool _expanded = true;

  int get _completedCount =>
      _checklist.values.where((checked) => checked).length;

  int get _estimatedWaitMinutes => _queuesAhead * 10;

  void _toggleItem(String key, bool? value) {
    setState(() {
      _checklist[key] = value ?? false;
    });
  }

  void _incrementQueue() {
    if (_queuesAhead >= 30) return;
    setState(() {
      _queuesAhead++;
    });
  }

  void _decrementQueue() {
    if (_queuesAhead <= 0) return;
    setState(() {
      _queuesAhead--;
    });
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = _checklist.length;
    final allReady = _completedCount == totalItems;

    return Card(
      key: const Key('evan_clinic_prep_card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: SehatKuColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.fact_check_outlined,
                    color: SehatKuColors.primaryDark,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Persiapan Kunjungan Klinik',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Kelengkapan berkas & estimasi tunggu',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  key: const Key('evan_prep_badge'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: allReady
                        ? SehatKuColors.success.withValues(alpha: 0.14)
                        : SehatKuColors.accentAmber.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_completedCount/$totalItems siap',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: allReady
                          ? SehatKuColors.success
                          : const Color(0xFFB45309),
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('evan_prep_expand_btn'),
                  onPressed: _toggleExpanded,
                  icon: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  tooltip: _expanded ? 'Tutup detail' : 'Buka detail',
                ),
              ],
            ),
            if (_expanded) ...[
              const Divider(height: 20),
              ..._checklist.entries.map(
                (entry) => CheckboxListTile(
                  key: Key('evan_check_${entry.key}'),
                  value: entry.value,
                  onChanged: (val) => _toggleItem(entry.key, val),
                  title: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 13.5),
                  ),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: SehatKuColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 18,
                      color: SehatKuColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Antrean di depan: $_queuesAhead • Est. $_estimatedWaitMinutes menit',
                        key: const Key('evan_wait_estimate_text'),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      key: const Key('evan_queue_minus_btn'),
                      onPressed: _decrementQueue,
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Kurangi antrean',
                    ),
                    IconButton(
                      key: const Key('evan_queue_plus_btn'),
                      onPressed: _incrementQueue,
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Tambah antrean',
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
