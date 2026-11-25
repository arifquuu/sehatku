import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../models/doctor_model.dart';
import '../providers/auth_provider.dart';
import '../providers/clinic_data_provider.dart';
import '../routing/app_router.dart';
import '../services/notification_service.dart';
import '../theme/sehatku_theme.dart';

class ProfileScreen extends StatelessWidget {
  final void Function(Doctor doctor) onOpenBooking;

  const ProfileScreen({
    super.key,
    required this.onOpenBooking,
  });

  Future<void> _showEditProfileDialog(BuildContext context) async {
    final provider = context.read<ClinicDataProvider>();
    final current = provider.patientProfile;

    final nameCtrl = TextEditingController(text: current['name']);
    final nikCtrl = TextEditingController(text: current['nik']);
    final bloodCtrl = TextEditingController(text: current['bloodType']);
    final allergyCtrl = TextEditingController(text: current['allergies']);
    final bpjsCtrl = TextEditingController(text: current['bpjsNumber']);
    final phoneCtrl = TextEditingController(text: current['phone']);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profil Pasien (Hive)'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nikCtrl,
                  decoration: const InputDecoration(labelText: 'NIK Pasien'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: bloodCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Golongan Darah',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: phoneCtrl,
                        decoration: const InputDecoration(
                          labelText: 'No. Telepon',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: bpjsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Kartu BPJS',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: allergyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Riwayat Alergi Obat / Makanan',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updated = {
                ...current,
                'name': nameCtrl.text.trim(),
                'nik': nikCtrl.text.trim(),
                'bloodType': bloodCtrl.text.trim(),
                'allergies': allergyCtrl.text.trim(),
                'bpjsNumber': bpjsCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
              };
              await provider.updatePatientProfile(updated);
              if (context.mounted) {
                context.read<AuthProvider?>()?.syncLocalProfileChanges(updated);
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profil pasien disimpan ke Hive Box.'),
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClinicDataProvider>();
    final auth = context.watch<AuthProvider?>();
    final profile = provider.patientProfile;
    final favDoctors = provider.favoriteDoctors;
    final poliCounts = provider.visitCountByPoli;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPad = SehatKuResponsive.horizontalPadding(screenWidth);

    return ListView(
      padding: EdgeInsets.fromLTRB(horizontalPad, 16, horizontalPad, 32),
      children: [
        // 1. Kartu Identitas Pasien (Tersimpan di Hive)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: SehatKuColors.primarySoft,
                      child: Text(
                        (profile['name'] ?? 'P').substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: SehatKuColors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile['name'] ?? 'Pasien SehatKu',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'No. RM: ${profile['rmNumber']} • Gol. Darah: ${profile['bloodType']}',
                            style: const TextStyle(
                              color: SehatKuColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                          Text(
                            'NIK: ${profile['nik']}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showEditProfileDialog(context),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit'),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  children: [
                    _profileMeta(
                      Icons.health_and_safety_outlined,
                      'BPJS: ${profile['bpjsNumber']}',
                    ),
                    _profileMeta(
                      Icons.phone_outlined,
                      'Telp: ${profile['phone']}',
                    ),
                    _profileMeta(
                      Icons.warning_amber_rounded,
                      'Alergi: ${profile['allergies']}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // 2. Dokter Favorit Saya (Tersimpan di Hive)
        Text(
          'Dokter Favorit Saya (Hive Storage)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        if (favDoctors.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'Belum ada dokter favorit. Ketuk ikon hati (♥) pada daftar dokter untuk menyimpan ke Hive.',
              ),
            ),
          )
        else
          ...favDoctors.map(
            (doc) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: SehatKuColors.primarySoft,
                    child: Icon(
                      Icons.medical_services_outlined,
                      color: SehatKuColors.primaryDark,
                    ),
                  ),
                  title: Text(
                    doc.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text('${doc.poli} • ${doc.scheduleDays}'),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      TextButton(
                        onPressed: () => onOpenBooking(doc),
                        child: const Text('Booking'),
                      ),
                      IconButton(
                        tooltip: 'Hapus dari favorit',
                        onPressed: () => provider.toggleFavoriteDoctor(doc.id),
                        icon: const Icon(
                          Icons.favorite,
                          color: Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),

        // 3. Pengaturan Aplikasi (Tersimpan di SharedPreferences)
        Text(
          'Preferensi Aplikasi (SharedPreferences)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                key: const Key('switch_dark_mode'),
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Mode Gelap (Dark Mode)'),
                subtitle: const Text(
                  'Menyimpan tema aplikasi ke SharedPreferences',
                ),
                value: provider.isDarkMode,
                onChanged: provider.toggleDarkMode,
              ),
              const Divider(height: 1),
              SwitchListTile(
                key: const Key('switch_reminder'),
                secondary: const Icon(Icons.notifications_active_outlined),
                title: const Text('Pengingat Jadwal Kontrol H-1'),
                subtitle: const Text(
                  'Aktifkan pengingat otomatis sebelum tanggal kontrol ulang',
                ),
                value: provider.reminderEnabled,
                onChanged: (val) async {
                  if (val) {
                    final perm = await NotificationService.instance
                        .requestPermission();
                    if (!context.mounted) return;
                    if (!perm.granted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(perm.message),
                          action: perm.permanentlyDenied
                              ? const SnackBarAction(
                                  label: 'Pengaturan',
                                  onPressed: openAppSettings,
                                )
                              : null,
                        ),
                      );
                      return;
                    }
                  } else {
                    await NotificationService.instance.cancelAll();
                  }
                  await provider.toggleReminder(val);
                },
              ),
              const Divider(height: 1),
              ListTile(
                key: const Key('test_notification_tile'),
                leading: const Icon(Icons.notification_add_outlined),
                title: const Text('Uji Notifikasi Pengingat Kontrol'),
                subtitle: const Text(
                  'Kirim pengingat lokal jadwal kontrol terdekat sekarang',
                ),
                trailing: TextButton(
                  onPressed: () async {
                    final nextControl = provider.medicalRecords.isNotEmpty
                        ? provider.medicalRecords.first.nextControlDate
                        : 'sesuai jadwal klinik';
                    final res = await NotificationService.instance
                        .scheduleControlReminder(
                          id: 901,
                          title: 'Pengingat Kontrol SehatKu',
                          body:
                              'Halo ${profile['name'] ?? 'Pasien'}, jadwal kontrol ulang terdekat Anda: $nextControl.',
                          scheduledAt: DateTime.now().add(
                            const Duration(seconds: 5),
                          ),
                        );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(res.message),
                        action: res.permanentlyDenied
                            ? const SnackBarAction(
                                label: 'Pengaturan',
                                onPressed: openAppSettings,
                              )
                            : null,
                      ),
                    );
                  },
                  child: const Text('Kirim'),
                ),
              ),
              const Divider(height: 1),
              SwitchListTile(
                key: const Key('switch_compact_cards'),
                secondary: const Icon(Icons.view_compact_alt_outlined),
                title: const Text('Tampilan Kartu Dokter Ringkas'),
                subtitle: const Text(
                  'Tampilkan lebih banyak jadwal dokter dalam satu layar',
                ),
                value: provider.compactCards,
                onChanged: provider.toggleCompactCards,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 4. Rekap Kunjungan per Poli (Mendukung Analisis Bisnis Kelompok 4)
        Text(
          'Rekap Kunjungan per Poli (Analitik Klinik)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: poliCounts.isEmpty
                ? const Text('Belum ada data kunjungan poli tercatat.')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: poliCounts.entries.map((entry) {
                      final total = poliCounts.values.fold<int>(
                        0,
                        (a, b) => a + b,
                      );
                      final ratio = total > 0 ? entry.value / total : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${entry.value} kunjungan',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: SehatKuColors.primary,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: ratio,
                                minHeight: 8,
                                backgroundColor: const Color(0xFFE2E8F0),
                                color: SehatKuColors.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ),
        const SizedBox(height: 20),

        if (auth != null && auth.isAuthenticated) ...[
          Text(
            'Sesi Akun & Keamanan',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                auth.isOfflineSession
                    ? Icons.offline_bolt_outlined
                    : Icons.verified_user_outlined,
                color: auth.isOfflineSession
                    ? SehatKuColors.accentAmber
                    : SehatKuColors.success,
              ),
              title: Text(
                auth.currentUser?.email ?? '-',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                auth.isOfflineSession
                    ? 'Aktif pada mode demo lokal (tanpa koneksi MySQL)'
                    : 'Terverifikasi melalui server PHP + MySQL (${auth.serverBaseUrl})',
              ),
              trailing: TextButton.icon(
                key: const Key('profile_logout_button'),
                onPressed: () async {
                  await auth.logout();
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRouter.login,
                    (_) => false,
                  );
                },
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 18,
                  color: SehatKuColors.danger,
                ),
                label: const Text(
                  'Keluar',
                  style: TextStyle(color: SehatKuColors.danger),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _profileMeta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: SehatKuColors.primary),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: const TextStyle(fontSize: 12.5))),
      ],
    );
  }
}
