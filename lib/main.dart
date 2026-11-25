import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/dummy_clinic_data.dart';
import 'models/doctor_model.dart';
import 'providers/clinic_data_provider.dart';
import 'screens/booking_detail_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'theme/sehatku_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ClinicDataProvider()..initializeAll(),
        ),
      ],
      child: const SehatKuApp(),
    ),
  );
}

class SehatKuApp extends StatelessWidget {
  const SehatKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.select<ClinicDataProvider, bool>(
      (p) => p.isDarkMode,
    );

    return MaterialApp(
      title: 'SehatKu — Pendaftaran & Rekam Medis Klinik',
      debugShowCheckedModeBanner: false,
      theme: SehatKuTheme.lightTheme,
      darkTheme: SehatKuTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (_) => const MainNavigationScreen(initialIndex: 0),
        '/jadwal': (_) => const MainNavigationScreen(initialIndex: 1),
        '/rekam-medis': (_) => const MainNavigationScreen(initialIndex: 2),
        '/profil': (_) => const MainNavigationScreen(initialIndex: 3),
      },
      onGenerateRoute: (settings) {
        if (settings.name == BookingDetailScreen.routeName) {
          final arg = settings.arguments;
          final doctor = arg is Doctor
              ? arg
              : DummyClinicData.localDoctors.first;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => BookingDetailScreen(doctor: doctor),
          );
        }
        return null;
      },
    );
  }
}
