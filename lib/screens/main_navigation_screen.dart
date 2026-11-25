import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/doctor_model.dart';
import '../providers/auth_provider.dart';
import '../providers/clinic_data_provider.dart';
import '../routing/app_router.dart';
import '../theme/sehatku_theme.dart';
import 'booking_detail_screen.dart';
import 'doctor_schedule_screen.dart';
import 'home_screen.dart';
import 'medical_record_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  static const List<String> _pageTitles = [
    'SehatKu Klinik',
    'Jadwal Dokter & Booking',
    'Rekam Medis Pasien',
    'Profil & Preferensi',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _openDoctorBooking(Doctor doctor) {
    Navigator.pushNamed(
      context,
      BookingDetailScreen.routeName,
      arguments: doctor,
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final auth = context.read<AuthProvider?>();
    if (auth == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari SehatKu?'),
        content: const Text(
          'Sesi login Anda akan diakhiri dan Anda akan diarahkan kembali ke halaman Masuk.',
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
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await auth.logout();
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.login,
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClinicDataProvider>();
    final auth = context.watch<AuthProvider?>();

    final pages = [
      HomeScreen(
        onNavigateToSchedule: () => setState(() => _currentIndex = 1),
        onNavigateToRecords: () => setState(() => _currentIndex = 2),
        onOpenBooking: _openDoctorBooking,
      ),
      DoctorScheduleScreen(
        onOpenBooking: _openDoctorBooking,
      ),
      const MedicalRecordScreen(),
      ProfileScreen(
        onOpenBooking: _openDoctorBooking,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_currentIndex]),
        actions: [
          IconButton(
            tooltip: provider.isDarkMode ? 'Mode Terang' : 'Mode Gelap',
            onPressed: () => provider.toggleDarkMode(!provider.isDarkMode),
            icon: Icon(
              provider.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                color: SehatKuColors.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.local_hospital_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'SehatKu Klinik Pratama',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      provider.patientProfile['name'] ?? 'Pasien SehatKu',
                      style: const TextStyle(
                        color: Color(0xFFCCFBF1),
                        fontSize: 13,
                      ),
                    ),
                    if (auth?.currentUser != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        auth!.isOfflineSession
                            ? '${auth.currentUser!.email} (Mode Lokal)'
                            : auth.currentUser!.email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Beranda Klinik'),
                selected: _currentIndex == 0,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month_outlined),
                title: const Text('Jadwal & Booking Online'),
                selected: _currentIndex == 1,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment_outlined),
                title: const Text('Rekam Medis (SQLite)'),
                selected: _currentIndex == 2,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 2);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profil & Favorit (Hive/Prefs)'),
                selected: _currentIndex == 3,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 3);
                },
              ),
              const Divider(height: 1),
              ListTile(
                key: const Key('drawer_async_lab_tile'),
                leading: const Icon(Icons.bolt_outlined),
                title: const Text('Lab Asinkron & Event Loop'),
                subtitle: const Text('Demo sync vs async & error state'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRouter.asyncLab);
                },
              ),
              const Spacer(),
              if (auth != null && auth.isAuthenticated) ...[
                const Divider(height: 1),
                ListTile(
                  key: const Key('drawer_logout_tile'),
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: SehatKuColors.danger,
                  ),
                  title: const Text(
                    'Keluar Akun',
                    style: TextStyle(
                      color: SehatKuColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmLogout(context);
                  },
                ),
              ],
              const Divider(height: 1),
              const Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'Kelompok 4 - SehatKu\nProdi Sistem Informasi FMIPA UNTAN',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month_rounded),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment_rounded),
            label: 'Rekam Medis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
