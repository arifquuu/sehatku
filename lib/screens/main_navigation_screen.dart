import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/doctor_model.dart';
import '../providers/clinic_data_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClinicDataProvider>();

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
              const Spacer(),
              const Divider(height: 1),
              const Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'Kelompok 4 — SehatKu\nProdi Sistem Informasi FMIPA UNTAN',
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
