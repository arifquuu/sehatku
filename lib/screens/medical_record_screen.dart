import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/dummy_clinic_data.dart';
import '../models/medical_record_model.dart';
import '../providers/clinic_data_provider.dart';
import '../theme/sehatku_theme.dart';

class MedicalRecordScreen extends StatefulWidget {
  const MedicalRecordScreen({super.key});

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _poliFilter = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MedicalRecord> _filterRecords(List<MedicalRecord> records) {
    final q = _searchController.text.trim().toLowerCase();
    return records.where((rec) {
      final matchesPoli = _poliFilter == 'Semua' || rec.poli == _poliFilter;
      if (!matchesPoli) return false;
      if (q.isEmpty) return true;
      return rec.diagnosis.toLowerCase().contains(q) ||
          rec.doctorName.toLowerCase().contains(q) ||
          rec.poli.toLowerCase().contains(q) ||
          rec.treatmentAndPrescription.toLowerCase().contains(q) ||
          rec.visitDate.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _showRecordFormDialog({MedicalRecord? existing}) async {
    final provider = context.read<ClinicDataProvider>();
    final profile = provider.patientProfile;

    final visitDateCtrl = TextEditingController(
      text: existing?.visitDate ?? '25 November 2026',
    );
    final doctorCtrl = TextEditingController(
      text: existing?.doctorName ?? DummyClinicData.localDoctors.first.name,
    );
    final diagnosisCtrl = TextEditingController(
      text: existing?.diagnosis ?? '',
    );
    final symptomsCtrl = TextEditingController(text: existing?.symptoms ?? '');
    final prescriptionCtrl = TextEditingController(
      text: existing?.treatmentAndPrescription ?? '',
    );
    final bpCtrl = TextEditingController(
      text: existing?.bloodPressure ?? '120/80 mmHg',
    );
    final weightCtrl = TextEditingController(
      text: (existing?.bodyWeightKg ?? 64.0).toString(),
    );
    final nextControlCtrl = TextEditingController(
      text: existing?.nextControlDate ?? '10 Desember 2026',
    );
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    String selectedPoli = existing?.poli ?? 'Poli Umum';

    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            existing == null
                ? 'Tambah Catatan Rekam Medis'
                : 'Edit Rekam Medis',
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedPoli,
                      decoration: const InputDecoration(
                        labelText: 'Poli Layanan',
                      ),
                      items: DummyClinicData.poliCategories
                          .where((p) => p != 'Semua')
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedPoli = val);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      key: const Key('mr_visit_date_field'),
                      controller: visitDateCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Kunjungan',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      key: const Key('mr_doctor_field'),
                      controller: doctorCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Dokter Pemeriksa',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      key: const Key('mr_diagnosis_field'),
                      controller: diagnosisCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Diagnosis Medis',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Diagnosis wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      key: const Key('mr_symptoms_field'),
                      controller: symptomsCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Gejala / Keluhan Pasien',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      key: const Key('mr_prescription_field'),
                      controller: prescriptionCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Tindakan & Resep Obat',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Resep/tindakan wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: bpCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Tekanan Darah',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: weightCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Berat Badan (kg)',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: nextControlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Jadwal Kontrol Ulang',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: notesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Catatan Tambahan Dokter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              key: const Key('save_mr_button'),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final record = MedicalRecord(
                  id: existing?.id,
                  patientName: profile['name'] ?? 'M. Fadjri Akbar',
                  medicalRecordNumber: profile['rmNumber'] ?? 'RM-2026-0104',
                  visitDate: visitDateCtrl.text.trim(),
                  poli: selectedPoli,
                  doctorName: doctorCtrl.text.trim(),
                  diagnosis: diagnosisCtrl.text.trim(),
                  symptoms: symptomsCtrl.text.trim().isEmpty
                      ? 'Pemeriksaan rawat jalan'
                      : symptomsCtrl.text.trim(),
                  treatmentAndPrescription: prescriptionCtrl.text.trim(),
                  bloodPressure: bpCtrl.text.trim(),
                  bodyWeightKg:
                      double.tryParse(weightCtrl.text.trim()) ?? 64.0,
                  nextControlDate: nextControlCtrl.text.trim(),
                  notes: notesCtrl.text.trim(),
                );

                if (existing == null) {
                  await provider.addMedicalRecord(record);
                } else {
                  await provider.updateMedicalRecord(record);
                }

                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        existing == null
                            ? 'Rekam medis baru disimpan ke SQLite.'
                            : 'Rekam medis berhasil diperbarui di SQLite.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Simpan SQLite'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(MedicalRecord record) async {
    if (record.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Rekam Medis?'),
        content: Text(
          'Catatan "${record.diagnosis}" tanggal ${record.visitDate} akan dihapus dari penyimpanan lokal SQLite.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SehatKuColors.danger,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<ClinicDataProvider>().deleteMedicalRecord(record.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan rekam medis dihapus.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClinicDataProvider>();
    final allRecords = provider.medicalRecords;
    final filtered = _filterRecords(allRecords);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPad = SehatKuResponsive.horizontalPadding(screenWidth);
    final isWide = screenWidth >= SehatKuResponsive.tabletBreakpoint;

    final uniquePoliCount = allRecords.map((e) => e.poli).toSet().length;
    final nextControl = allRecords.isNotEmpty
        ? allRecords.first.nextControlDate
        : '-';

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('fab_add_medical_record'),
        backgroundColor: SehatKuColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showRecordFormDialog(),
        icon: const Icon(Icons.note_add_outlined),
        label: const Text('Tambah Catatan'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontalPad,
              16,
              horizontalPad,
              88,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Ringkasan Statistik Rekam Medis Pasien
                Row(
                  children: [
                    Expanded(
                      child: _summaryStatCard(
                        title: 'Total Kunjungan',
                        value: '${allRecords.length}',
                        icon: Icons.folder_shared_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _summaryStatCard(
                        title: 'Poli Dikunjungi',
                        value: '$uniquePoliCount Poli',
                        icon: Icons.local_hospital_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _summaryStatCard(
                        title: 'Kontrol Terdekat',
                        value: nextControl,
                        icon: Icons.event_repeat_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Pencarian Rekam Medis
                TextField(
                  key: const Key('mr_search_textfield'),
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari diagnosis, nama dokter, atau resep obat...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: SehatKuColors.primary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear, size: 18),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Poli
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: DummyClinicData.poliCategories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final poli = DummyClinicData.poliCategories[index];
                      final selected = _poliFilter == poli;
                      return ChoiceChip(
                        label: Text(poli),
                        selected: selected,
                        selectedColor: SehatKuColors.primary,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: selected ? Colors.white : null,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        onSelected: (_) => setState(() => _poliFilter = poli),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                if (filtered.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(
                        child: Text(
                          'Belum ada catatan rekam medis yang sesuai filter.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                else if (isWide)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 252,
                        ),
                    itemBuilder: (context, index) =>
                        _buildRecordCard(context, filtered[index]),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildRecordCard(context, filtered[index]),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: SehatKuColors.primary),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, MedicalRecord rec) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    rec.visitDate,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rec.poli,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: SehatKuColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Edit catatan',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _showRecordFormDialog(existing: rec),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                ),
                IconButton(
                  tooltip: 'Hapus catatan',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _confirmDelete(rec),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: SehatKuColors.danger,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              rec.diagnosis,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 3),
            Text(
              'Dokter: ${rec.doctorName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              '💊 Resep/Tindakan: ${rec.treatmentAndPrescription}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            const Divider(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'TD: ${rec.bloodPressure} • BB: ${rec.bodyWeightKg} kg',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                Text(
                  'Kontrol: ${rec.nextControlDate}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: SehatKuColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
