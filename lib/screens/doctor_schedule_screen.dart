import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/dummy_clinic_data.dart';
import '../models/doctor_model.dart';
import '../providers/clinic_data_provider.dart';
import '../routing/app_router.dart';
import '../theme/sehatku_theme.dart';
import '../widgets/doctor_card.dart';

class DoctorScheduleScreen extends StatefulWidget {
  final void Function(Doctor doctor) onOpenBooking;

  const DoctorScheduleScreen({
    super.key,
    required this.onOpenBooking,
  });

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _forceGridOnMobile = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClinicDataProvider>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPad = SehatKuResponsive.horizontalPadding(screenWidth);
    final isWide = screenWidth >= SehatKuResponsive.tabletBreakpoint;
    final doctors = provider.filteredDoctors;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).cardTheme.color,
            child: TabBar(
              labelColor: SehatKuColors.primary,
              indicatorColor: SehatKuColors.primary,
              tabs: [
                Tab(
                  text: 'Daftar Dokter (${doctors.length})',
                  icon: const Icon(Icons.people_alt_outlined, size: 18),
                ),
                Tab(
                  text: 'Antrean Saya (${provider.bookings.length})',
                  icon: const Icon(Icons.confirmation_number_outlined, size: 18),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildDoctorDirectoryTab(
                  context,
                  provider,
                  doctors,
                  screenWidth,
                  horizontalPad,
                  isWide,
                ),
                _buildMyBookingsTab(context, provider, horizontalPad),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorDirectoryTab(
    BuildContext context,
    ClinicDataProvider provider,
    List<Doctor> doctors,
    double screenWidth,
    double horizontalPad,
    bool isWide,
  ) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontalPad, 14, horizontalPad, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Sumber Data Toggle: Lokal (12 Dokter) vs REST API Publik (Tugas 9)
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        provider.useApiDoctors
                            ? Icons.public
                            : Icons.storage_rounded,
                        color: SehatKuColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.useApiDoctors
                                  ? 'Sumber Data: REST API Publik (DummyJSON)'
                                  : 'Sumber Data: Direktori Klinik SehatKu (12 Dokter)',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              provider.useApiDoctors
                                  ? 'JSON di-parsing langsung ke model class Doctor'
                                  : 'Aktifkan switch untuk memuat daftar dokter mitra dari API',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (provider.isLoadingApi)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      Switch(
                        key: const Key('switch_api_source'),
                        value: provider.useApiDoctors,
                        activeThumbColor: SehatKuColors.primary,
                        onChanged: (val) =>
                            provider.toggleDoctorDataSource(val),
                      ),
                    ],
                  ),
                ),
              ),
              if (provider.useApiDoctors &&
                  provider.apiErrorMessage != null &&
                  provider.apiDoctors.isEmpty) ...[
                const SizedBox(height: 10),
                Card(
                  color: const Color(0xFFFEF3C7),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFB45309),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Gagal terhubung ke API (${provider.apiErrorMessage}). Menampilkan data cadangan lokal agar layanan tetap berjalan.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              provider.fetchApiData(activateApiDoctors: true),
                          child: const Text('Muat Ulang'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Pencarian & Toggle List/Grid
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('schedule_search_textfield'),
                      controller: _searchController,
                      onChanged: provider.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Cari dokter, poli, atau hari praktik...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: SehatKuColors.primary,
                        ),
                        suffixIcon: provider.searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  provider.setSearchQuery('');
                                },
                                icon: const Icon(Icons.clear, size: 18),
                              )
                            : null,
                      ),
                    ),
                  ),
                  if (!isWide) ...[
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: _forceGridOnMobile
                          ? 'Tampilan ListView'
                          : 'Tampilan GridView',
                      onPressed: () {
                        setState(() {
                          _forceGridOnMobile = !_forceGridOnMobile;
                        });
                      },
                      icon: Icon(
                        _forceGridOnMobile
                            ? Icons.view_list_rounded
                            : Icons.grid_view_rounded,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Filter Poli Dinamis (Tugas 4)
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: DummyClinicData.poliCategories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final poli = DummyClinicData.poliCategories[index];
                    final selected = provider.selectedPoli == poli;
                    return ChoiceChip(
                      label: Text(poli),
                      selected: selected,
                      selectedColor: SehatKuColors.primary,
                      labelStyle: TextStyle(
                        fontSize: 12.5,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected ? Colors.white : null,
                      ),
                      onSelected: (_) => provider.setSelectedPoli(poli),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // List Dinamis / GridView Dokter (Minimal 10 Data - Tugas 4)
              if (doctors.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Text('Tidak ditemukan jadwal dokter yang sesuai.'),
                  ),
                )
              else if (isWide || _forceGridOnMobile)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: doctors.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide
                        ? SehatKuResponsive.gridColumns(screenWidth)
                        : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: (provider.compactCards || _forceGridOnMobile)
                        ? 172
                        : 198,
                  ),
                  itemBuilder: (context, index) {
                    final doc = doctors[index];
                    return DoctorCard(
                      doctor: doc,
                      compact: provider.compactCards || _forceGridOnMobile,
                      isFavorite: provider.isDoctorFavorite(doc.id),
                      onTapBooking: () => widget.onOpenBooking(doc),
                      onToggleFavorite: () =>
                          provider.toggleFavoriteDoctor(doc.id),
                    );
                  },
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: doctors.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = doctors[index];
                    return DoctorCard(
                      doctor: doc,
                      compact: provider.compactCards,
                      isFavorite: provider.isDoctorFavorite(doc.id),
                      onTapBooking: () => widget.onOpenBooking(doc),
                      onToggleFavorite: () =>
                          provider.toggleFavoriteDoctor(doc.id),
                    );
                  },
                ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildMyBookingsTab(
    BuildContext context,
    ClinicDataProvider provider,
    double horizontalPad,
  ) {
    final bookings = provider.bookings;
    if (bookings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Belum ada pendaftaran antrean. Silakan pilih dokter pada tab Daftar Dokter.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(horizontalPad, 16, horizontalPad, 24),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = bookings[index];
        final isScheduled = item.status == 'Terjadwal';
        final statusColor = switch (item.status) {
          'Selesai' => SehatKuColors.success,
          'Dibatalkan' => SehatKuColors.danger,
          _ => SehatKuColors.primary,
        };

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: SehatKuColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Antrean ${item.queueNumber}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: SehatKuColors.primaryDark,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.status,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.paymentType,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.doctorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.poli} • ${item.room}',
                  style: const TextStyle(
                    color: SehatKuColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '📅 Tanggal: ${item.visitDate} • Sesi: ${item.sessionTime}',
                  style: const TextStyle(fontSize: 12.5),
                ),
                Text(
                  '👤 Pasien: ${item.patientName} (NIK: ${item.patientNik})',
                  style: const TextStyle(fontSize: 12.5),
                ),
                const SizedBox(height: 4),
                Text(
                  '📝 Keluhan: ${item.complaint}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Divider(height: 20),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.qrTicket,
                          arguments: item,
                        );
                      },
                      icon: const Icon(
                        Icons.qr_code_2_rounded,
                        size: 17,
                        color: SehatKuColors.primary,
                      ),
                      label: const Text('QR Antrean'),
                    ),
                    if (isScheduled && item.id != null) ...[
                      TextButton.icon(
                        onPressed: () => provider.updateBookingStatus(
                          item.id!,
                          'Selesai',
                        ),
                        icon: const Icon(
                          Icons.check_circle_outline,
                          size: 17,
                          color: SehatKuColors.success,
                        ),
                        label: const Text('Tandai Selesai'),
                      ),
                      TextButton.icon(
                        onPressed: () => provider.updateBookingStatus(
                          item.id!,
                          'Dibatalkan',
                        ),
                        icon: const Icon(
                          Icons.cancel_outlined,
                          size: 17,
                          color: SehatKuColors.danger,
                        ),
                        label: const Text('Batalkan'),
                      ),
                    ],
                    if (item.id != null)
                      IconButton(
                        tooltip: 'Hapus riwayat antrean',
                        onPressed: () => provider.deleteBooking(item.id!),
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 19,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
