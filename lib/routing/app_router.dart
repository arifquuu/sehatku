import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/dummy_clinic_data.dart';
import '../models/booking_model.dart';
import '../models/doctor_model.dart';
import '../providers/auth_provider.dart';
import '../screens/async_comparison_screen.dart';
import '../screens/booking_detail_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/qr_queue_ticket_screen.dart';
import '../screens/register_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';
  static const String schedule = '/jadwal';
  static const String records = '/rekam-medis';
  static const String profile = '/profil';
  static const String booking = BookingDetailScreen.routeName;
  static const String asyncLab = '/async-lab';
  static const String qrTicket = '/qr-ticket';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case register:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RegisterScreen(),
        );
      case schedule:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AuthGate(
            child: MainNavigationScreen(initialIndex: 1),
          ),
        );
      case records:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AuthGate(
            child: MainNavigationScreen(initialIndex: 2),
          ),
        );
      case profile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AuthGate(
            child: MainNavigationScreen(initialIndex: 3),
          ),
        );
      case booking:
        final arg = settings.arguments;
        final doctor = arg is Doctor ? arg : DummyClinicData.localDoctors.first;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AuthGate(
            child: BookingDetailScreen(doctor: doctor),
          ),
        );
      case asyncLab:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AuthGate(
            child: AsyncComparisonScreen(),
          ),
        );
      case qrTicket:
        final arg = settings.arguments;
        final ticket = arg is BookingAppointment
            ? arg
            : DummyClinicData.initialBookings.first;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AuthGate(
            child: QrQueueTicketScreen(booking: ticket),
          ),
        );
      case home:
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AuthGate(
            child: MainNavigationScreen(initialIndex: 0),
          ),
        );
    }
  }
}

class AuthGate extends StatelessWidget {
  final Widget child;

  const AuthGate({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Support widget tests that mount SehatKuApp without an AuthProvider.
    final auth = context.read<AuthProvider?>();
    if (auth == null) {
      return child;
    }

    return Selector<AuthProvider, ({bool isInit, bool isAuth})>(
      selector: (_, p) => (isInit: p.isInitializing, isAuth: p.isAuthenticated),
      builder: (_, state, _) {
        if (state.isInit) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Memeriksa sesi akun pasien...'),
                ],
              ),
            ),
          );
        }

        if (!state.isAuth) {
          return const LoginScreen();
        }

        return child;
      },
    );
  }
}
