import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/dummy_clinic_data.dart';
import '../models/booking_model.dart';
import '../models/doctor_model.dart';
import '../providers/clinic_data_provider.dart';
import '../routing/app_router.dart';
import '../theme/sehatku_theme.dart';
import '../widgets/doctor_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToSchedule;
  final VoidCallback onNavigateToRecords;
  final void Function(Doctor doctor) onOpenBooking;

  const HomeScreen({
    super.key,
    required this.onNavigateToSchedule,
    required this.onNavigateToRecords,
    required this.onOpenBooking,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

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
    final featuredDoctors = provider.filteredDoctors.take(isWide ? 6 : 4).toList();

    return RefreshIndicator(
      onRefresh: () => provider.fetchApiData(),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontalPad,
              16,
              horizontalPad,
              24,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Hero Stack Banner Klinik & Tiket Antrean Aktif (Tugas 3: Stack, Container, Image, Row, Column)
                _buildHeroBanner(context, provider, isWide),
                const SizedBox(height: 16),

                // 2. Baris Statistik Cepat Klinik (Responsif Row / Wrap)
                _buildQuickMetricsRow(context, provider, isWide),
                const SizedBox(height: 18),

                // 3. Kolom Pencarian Cepat (Tugas 3: TextField)
                TextField(
                  key: const Key('home_search_textfield'),
                  controller: _searchController,
                  onChanged: provider.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Cari nama dokter, spesialis, atau ruangan poli...',
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
                const SizedBox(height: 12),

                // 4. Filter Kategori Poli Dinamis (Tugas 4)
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
                const SizedBox(height: 20),

                // 5. Header Dokter Praktik Pilihan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dokter Praktik Tersedia',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Menampilkan ${featuredDoctors.length} dari ${provider.filteredDoctors.length} dokter (${provider.selectedPoli})',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: widget.onNavigateToSchedule,
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('Lihat Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 6. List / Grid Responsif Dokter (Tugas 3 & Tugas 4: Uji 2 Ukuran Layar)
                if (featuredDoctors.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 40,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tidak ada dokter yang cocok dengan kata kunci/poli tersebut.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearchQuery('');
                              provider.setSelectedPoli('Semua');
                            },
                            child: const Text('Reset Pencarian'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (isWide)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: featuredDoctors.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: SehatKuResponsive.gridColumns(
                        screenWidth,
                      ),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      mainAxisExtent: provider.compactCards ? 148 : 196,
                    ),
                    itemBuilder: (context, index) {
                      final doc = featuredDoctors[index];
                      return DoctorCard(
                        doctor: doc,
                        compact: provider.compactCards,
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
                    itemCount: featuredDoctors.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = featuredDoctors[index];
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

                const SizedBox(height: 24),

                // 7. Edukasi & Informasi Klinik dari REST API Publik (Tugas 9)
                _buildHealthApiSection(context, provider),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(
    BuildContext context,
    ClinicDataProvider provider,
    bool isWide,
  ) {
    final activeBooking = provider.activeBooking;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/clinic_hero.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SehatKuColors.primaryDark.withValues(alpha: 0.92),
                  SehatKuColors.secondary.withValues(alpha: 0.78),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(isWide ? 24 : 18),
            child: isWide
                ? Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildHeroGreetingText(provider),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: _buildActiveQueueCard(activeBooking),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroGreetingText(provider),
                      const SizedBox(height: 14),
                      _buildActiveQueueCard(activeBooking),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroGreetingText(ClinicDataProvider provider) {
    final name = provider.patientProfile['name'] ?? 'Pasien SehatKu';
    final rmNo = provider.patientProfile['rmNumber'] ?? 'RM-2026-0104';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'No. Rekam Medis: $rmNo',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selamat Datang, $name',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Daftar antrean poli secara online dari rumah tanpa harus datang pagi dan pantau riwayat rekam medis Anda.',
          style: TextStyle(
            color: Color(0xFFE0F2FE),
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveQueueCard(BookingAppointment? activeBooking) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
      ),
      child: activeBooking == null
          ? Row(
              children: [
                const Icon(
                  Icons.event_available,
                  color: SehatKuColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Belum ada jadwal antrean aktif. Pilih dokter untuk booking online.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: SehatKuColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'ANTREAN',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: SehatKuColors.primaryDark,
                        ),
                      ),
                      Text(
                        activeBooking.queueNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: SehatKuColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeBooking.doctorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${activeBooking.poli} • ${activeBooking.room}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: SehatKuColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${activeBooking.visitDate} (${activeBooking.sessionTime})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                IconButton.filledTonal(
                  key: const Key('home_open_qr_button'),
                  tooltip: 'Buka Tiket QR Antrean',
                  style: IconButton.styleFrom(
                    backgroundColor: SehatKuColors.primarySoft,
                    foregroundColor: SehatKuColors.primaryDark,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.qrTicket,
                      arguments: activeBooking,
                    );
                  },
                  icon: const Icon(Icons.qr_code_2_rounded, size: 22),
                ),
              ],
            ),
    );
  }

  Widget _buildQuickMetricsRow(
    BuildContext context,
    ClinicDataProvider provider,
    bool isWide,
  ) {
    final metrics = [
      (
        icon: Icons.medical_services_outlined,
        label: 'Dokter Aktif',
        value: '${provider.activeDoctors.length}',
        color: SehatKuColors.primary,
        onTap: widget.onNavigateToSchedule,
      ),
      (
        icon: Icons.local_hospital_outlined,
        label: 'Layanan Poli',
        value: '${DummyClinicData.poliCategories.length - 1} Poli',
        color: SehatKuColors.secondary,
        onTap: widget.onNavigateToSchedule,
      ),
      (
        icon: Icons.assignment_outlined,
        label: 'Rekam Medis',
        value: '${provider.medicalRecords.length} Data',
        color: const Color(0xFF7C3AED),
        onTap: widget.onNavigateToRecords,
      ),
      (
        icon: Icons.favorite_border_rounded,
        label: 'Favorit Saya',
        value: '${provider.favoriteDoctorIds.length} Dokter',
        color: const Color(0xFFE11D48),
        onTap: widget.onNavigateToSchedule,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 4 : 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 68,
      ),
      itemBuilder: (context, i) {
        final item = metrics[i];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: item.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthApiSection(
    BuildContext context,
    ClinicDataProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.cloud_done_outlined,
              size: 18,
              color: SehatKuColors.secondary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Edukasi Kesehatan (REST API Publik)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Muat ulang data REST API',
              onPressed: provider.isLoadingApi
                  ? null
                  : () => provider.fetchApiData(),
              icon: const Icon(Icons.refresh, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (provider.isLoadingApi)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  SizedBox(width: 12),
                  Text('Mengambil data JSON dari REST API publik...'),
                ],
              ),
            ),
          )
        else if (provider.apiErrorMessage != null &&
            provider.healthArticles.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    color: SehatKuColors.accentAmber,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Info API belum dimuat (mode offline). Data jadwal & rekam medis lokal tetap aktif.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  TextButton(
                    onPressed: () => provider.fetchApiData(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: provider.healthArticles.take(3).map((article) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                article.tags.first,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0369A1),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '👁 ${article.views} pembaca',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          article.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          article.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
