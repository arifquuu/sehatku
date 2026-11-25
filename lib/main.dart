import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/clinic_data_provider.dart';
import 'routing/app_router.dart';
import 'theme/sehatku_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  final clinicProvider = ClinicDataProvider();

  authProvider.addListener(() {
    final user = authProvider.currentUser;
    if (user != null) {
      clinicProvider.applyAuthenticatedUser(user);
    }
  });

  authProvider.restoreSession();
  clinicProvider.initializeAll();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<ClinicDataProvider>.value(value: clinicProvider),
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
      title: 'SehatKu - Pendaftaran dan Rekam Medis Klinik',
      debugShowCheckedModeBanner: false,
      theme: SehatKuTheme.lightTheme,
      darkTheme: SehatKuTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
