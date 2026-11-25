import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/booking_model.dart';

class NotificationActionResult {
  final bool granted;
  final bool permanentlyDenied;
  final String message;

  const NotificationActionResult({
    required this.granted,
    required this.message,
    this.permanentlyDenied = false,
  });
}

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  static const String _channelId = 'sehatku_reminders';
  static const String _channelName = 'Pengingat Kontrol & Antrean SehatKu';
  static const String _channelDescription =
      'Notifikasi nomor antrean poli dan pengingat jadwal kontrol ulang pasien.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _timeZoneReady = false;

  Future<void> initialize() async {
    if (_initialized) return;

    if (!_timeZoneReady) {
      tz_data.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Pontianak'));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
      _timeZoneReady = true;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const webSettings = WebInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      web: webSettings,
    );

    try {
      await _plugin.initialize(settings: initSettings);
      _initialized = true;
    } on MissingPluginException {
      // Skip native setup when running inside headless unit/widget tests.
      _initialized = false;
    } catch (_) {
      _initialized = false;
    }
  }

  Future<NotificationActionResult> requestPermission() async {
    await initialize();

    if (kIsWeb) {
      try {
        final webPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              WebFlutterLocalNotificationsPlugin
            >();
        if (webPlugin == null) {
          return const NotificationActionResult(
            granted: false,
            message: 'Browser ini belum mendukung notifikasi lokal.',
          );
        }
        final ok = (await webPlugin.requestNotificationsPermission()) ?? false;
        return NotificationActionResult(
          granted: ok,
          message: ok
              ? 'Izin notifikasi browser diberikan.'
              : 'Izin notifikasi ditolak di pengaturan browser.',
        );
      } catch (_) {
        return const NotificationActionResult(
          granted: false,
          message: 'Tidak dapat meminta izin notifikasi pada browser ini.',
        );
      }
    }

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        var status = await Permission.notification.status;
        if (!status.isGranted) {
          status = await Permission.notification.request();
        }
        if (status.isGranted) {
          return const NotificationActionResult(
            granted: true,
            message: 'Izin notifikasi aktif.',
          );
        }
        if (status.isPermanentlyDenied) {
          return const NotificationActionResult(
            granted: false,
            permanentlyDenied: true,
            message:
                'Izin notifikasi ditolak permanen. Aktifkan melalui Pengaturan Aplikasi.',
          );
        }
        return const NotificationActionResult(
          granted: false,
          message:
              'Izin notifikasi belum diberikan. Pengingat jadwal kontrol tidak akan muncul.',
        );
      } on MissingPluginException {
        return const NotificationActionResult(
          granted: true,
          message: 'Simulasi izin notifikasi (lingkungan uji).',
        );
      }
    }

    return const NotificationActionResult(
      granted: true,
      message: 'Notifikasi lokal aktif untuk perangkat ini.',
    );
  }

  NotificationDetails _defaultDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<NotificationActionResult> showBookingNotification(
    BookingAppointment booking,
  ) async {
    final perm = await requestPermission();
    if (!perm.granted) return perm;

    final notifId = (booking.id ?? DateTime.now().millisecondsSinceEpoch) %
        100000;
    try {
      await _plugin.show(
        id: notifId,
        title: 'Antrean ${booking.queueNumber} Terdaftar',
        body:
            '${booking.doctorName} (${booking.poli}) pada ${booking.visitDate}, sesi ${booking.sessionTime}.',
        notificationDetails: _defaultDetails(),
        payload: booking.queueNumber,
      );
      return const NotificationActionResult(
        granted: true,
        message: 'Notifikasi tiket antrean dikirim.',
      );
    } on MissingPluginException {
      return const NotificationActionResult(
        granted: true,
        message: 'Notifikasi tercatat (mode uji tanpa plugin native).',
      );
    } catch (e) {
      return NotificationActionResult(
        granted: false,
        message: 'Gagal menampilkan notifikasi: $e',
      );
    }
  }

  Future<NotificationActionResult> scheduleControlReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    final perm = await requestPermission();
    if (!perm.granted) return perm;

    try {
      if (kIsWeb ||
          (defaultTargetPlatform != TargetPlatform.android &&
              defaultTargetPlatform != TargetPlatform.iOS)) {
        await _plugin.show(
          id: id,
          title: title,
          body: body,
          notificationDetails: _defaultDetails(),
        );
        return const NotificationActionResult(
          granted: true,
          message: 'Notifikasi pengingat kontrol langsung ditampilkan.',
        );
      }

      final targetTime = scheduledAt.isAfter(DateTime.now())
          ? scheduledAt
          : DateTime.now().add(const Duration(seconds: 5));
      final tzTime = tz.TZDateTime.from(targetTime, tz.local);

      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzTime,
        notificationDetails: _defaultDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      return const NotificationActionResult(
        granted: true,
        message: 'Pengingat jadwal kontrol berhasil dijadwalkan.',
      );
    } on MissingPluginException {
      return const NotificationActionResult(
        granted: true,
        message: 'Pengingat dijadwalkan (mode uji).',
      );
    } catch (e) {
      return NotificationActionResult(
        granted: false,
        message: 'Gagal menjadwalkan notifikasi: $e',
      );
    }
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {
      // Ignore cleanup errors on unsupported platforms.
    }
  }
}
