import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sehatku/data/dummy_clinic_data.dart';
import 'package:sehatku/main.dart';
import 'package:sehatku/models/medical_record_model.dart';
import 'package:sehatku/providers/auth_provider.dart';
import 'package:sehatku/providers/clinic_data_provider.dart';
import 'package:sehatku/screens/profile_screen.dart';
import 'package:sehatku/screens/qr_queue_ticket_screen.dart';
import 'package:sehatku/services/api_service.dart';
import 'package:sehatku/services/async_demo_service.dart';
import 'package:sehatku/services/auth_service.dart';
import 'package:sehatku/services/database_helper.dart';
import 'package:sehatku/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sehatku_arif_test_');
    SharedPreferences.setMockInitialValues({});
    DatabaseHelper.instance.configureTestDatabasePath(
      p.join(tempDir.path, 'test_sehatku_arif.db'),
    );
  });

  tearDown(() async {
    await DatabaseHelper.instance.closeDatabase();
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'Tugas 7 & 11: AuthProvider login, register, persistensi sesi, dan logout memakai AuthService',
    () async {
      final mockClient = MockClient((request) async {
        final body = request.body.isNotEmpty
            ? Map<String, dynamic>.from(jsonDecode(request.body) as Map)
            : <String, dynamic>{};

        if (request.url.path.endsWith('/api/login')) {
          if (body['email'] == 'arif@sehatku.id' &&
              body['password'] == 'password123') {
            return http.Response(
              jsonEncode({
                'success': true,
                'message': 'Login berhasil.',
                'data': {
                  'token': 'jwt-mock-token-001',
                  'user': {
                    'id': 3,
                    'rm_number': 'RM-2026-0103',
                    'nik': '6171031504040001',
                    'full_name': 'M. Arifqu Wa Liin',
                    'email': 'arif@sehatku.id',
                    'phone': '081255014401',
                    'blood_type': 'O+',
                    'allergies': 'Tidak ada alergi obat',
                    'bpjs_number': '0001849201101',
                    'role': 'pasien',
                  },
                },
              }),
              200,
            );
          }
          return http.Response(
            jsonEncode({
              'success': false,
              'message': 'Email atau kata sandi salah.',
            }),
            401,
          );
        }

        if (request.url.path.endsWith('/api/register')) {
          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'Registrasi berhasil.',
              'data': {
                'token': 'jwt-mock-token-reg',
                'user': {
                  'id': 4,
                  'rm_number': 'RM-2026-0105',
                  'nik': body['nik'],
                  'full_name': body['full_name'],
                  'email': body['email'],
                  'phone': body['phone'] ?? '',
                  'blood_type': body['blood_type'] ?? 'O+',
                  'allergies': 'Tidak ada alergi obat',
                  'bpjs_number': body['bpjs_number'] ?? '',
                  'role': 'pasien',
                },
              },
            }),
            201,
          );
        }

        if (request.url.path.endsWith('/api/logout')) {
          return http.Response(
            jsonEncode({'success': true, 'data': {'logged_out': true}}),
            200,
          );
        }

        return http.Response(jsonEncode({'success': false}), 404);
      });

      final authService = AuthService(client: mockClient);
      final auth = AuthProvider(
        authService: authService,
        initialServerBaseUrl: 'http://127.0.0.1:8080',
      );
      await auth.restoreSession();
      expect(auth.isAuthenticated, isFalse);

      // Login gagal dengan kata sandi salah
      final failed = await auth.login(
        email: 'arif@sehatku.id',
        password: 'wrong',
      );
      expect(failed, isFalse);
      expect(auth.errorMessage, contains('salah'));
      expect(auth.isAuthenticated, isFalse);

      // Login berhasil dan sesi tersimpan ke SharedPreferences
      final ok = await auth.login(
        email: 'arif@sehatku.id',
        password: 'password123',
      );
      expect(ok, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser?.fullName, 'M. Arifqu Wa Liin');

      // Simulasi restart aplikasi: provider baru memulihkan sesi tersimpan
      final restored = AuthProvider(authService: authService);
      await restored.restoreSession();
      expect(restored.isAuthenticated, isTrue);
      expect(restored.currentUser?.email, 'arif@sehatku.id');

      // Logout menghapus sesi lokal
      await restored.logout();
      expect(restored.isAuthenticated, isFalse);
      expect(restored.currentUser, isNull);

      // Registrasi akun baru
      final regOk = await auth.register(
        fullName: 'Evan QA',
        email: 'evan@sehatku.id',
        password: 'password123',
        nik: '6171031102040009',
      );
      expect(regOk, isTrue);
      expect(auth.currentUser?.rmNumber, 'RM-2026-0105');
    },
  );

  test(
    'Tugas 8: AsyncDemoService memverifikasi urutan Event Loop, paralel Future.wait, serta error timeout/offline',
    () async {
      final service = AsyncDemoService();

      final syncReport = service.runSynchronousDemo(workDurationMs: 25);
      expect(syncReport.blockedMainThread, isTrue);
      expect(syncReport.entries.length, 3);

      final asyncReport = await service.runAsynchronousEventLoopDemo(
        taskDelayMs: 60,
      );
      expect(asyncReport.blockedMainThread, isFalse);
      final queues = asyncReport.entries.map((e) => e.queueLabel).toList();
      expect(
        queues.take(5).toList(),
        equals(['Sync', 'Sync', 'Microtask', 'Event Queue', 'Timer']),
      );
      expect(asyncReport.parallelElapsedMs, isNotNull);
      expect(
        asyncReport.parallelElapsedMs!,
        lessThan(asyncReport.totalElapsedMs),
      );

      final successRes = await service.simulateClinicSync(
        NetworkSimScenario.success,
        delay: const Duration(milliseconds: 20),
      );
      expect(successRes['availableDoctors'], 12);

      await expectLater(
        service.simulateClinicSync(
          NetworkSimScenario.timeout,
          delay: const Duration(milliseconds: 80),
          timeout: const Duration(milliseconds: 25),
        ),
        throwsA(
          isA<NetworkSimException>().having((e) => e.isTimeout, 'isTimeout', true),
        ),
      );

      await expectLater(
        service.simulateClinicSync(
          NetworkSimScenario.offline,
          delay: const Duration(milliseconds: 20),
        ),
        throwsA(
          isA<NetworkSimException>().having((e) => e.isTimeout, 'isTimeout', false),
        ),
      );
    },
  );

  test(
    'Tugas 12 & 14: SQLite menyimpan document_photo_path dan QR payload berisi JSON antrean valid',
    () async {
      final db = DatabaseHelper.instance;
      final insertedId = await db.insertMedicalRecord(
        const MedicalRecord(
          patientName: 'M. Arifqu Wa Liin',
          medicalRecordNumber: 'RM-2026-0103',
          visitDate: '25 November 2026',
          poli: 'Poli Umum',
          doctorName: 'dr. Andi Pratama, M.Kes',
          diagnosis: 'Kontrol Tekanan Darah',
          symptoms: 'Pemeriksaan berkala',
          treatmentAndPrescription: 'Edukasi diet rendah garam',
          bloodPressure: '120/80 mmHg',
          bodyWeightKg: 65.0,
          nextControlDate: '25 Desember 2026',
          notes: 'Lampirkan hasil cek laboratorium.',
          documentPhotoPath: 'data:image/png;base64,iVBORw0KGgo=',
        ),
      );

      await db.closeDatabase();
      final records = await db.getAllMedicalRecords();
      final saved = records.firstWhere((r) => r.id == insertedId);
      expect(saved.documentPhotoPath, 'data:image/png;base64,iVBORw0KGgo=');

      final qrJson = QrQueueTicketScreen.buildQrPayload(
        DummyClinicData.initialBookings.first,
        rmNumber: 'RM-2026-0103',
      );
      final decoded = jsonDecode(qrJson) as Map<String, dynamic>;
      expect(decoded['app'], 'SehatKu');
      expect(decoded['queue'], 'A-012');
      expect(decoded['rm'], 'RM-2026-0103');
      expect(decoded['poli'], 'Poli Penyakit Dalam');
    },
  );

  testWidgets(
    'Tugas 5, 7, 8, 11 & 14: Proteksi rute Login, masuk aplikasi, buka QR Antrean, Lab Asinkron, dan Logout',
    (WidgetTester tester) async {
      final mockClient = MockClient(
        (_) async => http.Response(jsonEncode({'users': [], 'posts': []}), 200),
      );

      late ClinicDataProvider clinicProvider;
      late AuthProvider authProvider;

      await tester.runAsync(() async {
        final storage = LocalStorageService();
        await storage.init(inMemory: true);
        clinicProvider = ClinicDataProvider(
          apiService: ApiService(client: mockClient),
          databaseHelper: DatabaseHelper.instance,
          localStorageService: storage,
        );
        await clinicProvider.initializeAll(fetchNetworkOnStart: false);

        authProvider = AuthProvider(
          authService: AuthService(client: mockClient),
        );
        await authProvider.restoreSession();
      });

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<ClinicDataProvider>.value(
              value: clinicProvider,
            ),
          ],
          child: const SehatKuApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Belum login: AuthGate wajib mengarahkan ke halaman Masuk
      expect(find.text('Masuk Akun Pasien'), findsOneWidget);

      // Buka halaman Register via named route lalu kembali
      await tester.ensureVisible(find.byKey(const Key('goto_register_button')));
      await tester.tap(find.byKey(const Key('goto_register_button')));
      await tester.pumpAndSettle();
      expect(find.text('Buat Akun Klinik SehatKu'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Masuk Akun Pasien'), findsOneWidget);

      // Masuk melalui Mode Demo Lokal untuk menguji proteksi rute terbuka
      await tester.ensureVisible(
        find.byKey(const Key('login_offline_demo_button')),
      );
      await tester.tap(find.byKey(const Key('login_offline_demo_button')));
      await tester.pumpAndSettle();
      expect(find.text('SehatKu Klinik'), findsOneWidget);

      // Buka Tiket QR Antrean dari kartu antrean aktif di Beranda
      await tester.tap(find.byKey(const Key('home_open_qr_button')));
      await tester.pumpAndSettle();
      expect(find.text('Tiket QR Antrean Klinik'), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.byKey(const Key('qr_queue_number_text')), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Buka Drawer -> Lab Asinkron & Event Loop
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('drawer_async_lab_tile')));
      await tester.pumpAndSettle();
      expect(find.text('Lab Asinkron & Event Loop'), findsOneWidget);

      // Uji tombol Sinkron & Error Timeout
      await tester.tap(find.byKey(const Key('run_sync_demo_button')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Sinkron (Blocking)'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('scenario_timeout_chip')));
      await tester.tap(find.byKey(const Key('scenario_timeout_chip')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('run_network_sim_button')));
      await tester.tap(find.byKey(const Key('run_network_sim_button')));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('network_error_state')), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Buka tab Profil dan uji Logout kembali ke LoginScreen
      final bottomNav = find.byType(BottomNavigationBar);
      await tester.tap(
        find.descendant(of: bottomNav, matching: find.text('Profil')),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('profile_logout_button')),
        200,
        scrollable: find.descendant(
          of: find.byType(ProfileScreen),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(find.byKey(const Key('profile_logout_button')));
      await tester.pumpAndSettle();
      expect(find.text('Masuk Akun Pasien'), findsOneWidget);
    },
  );
}
