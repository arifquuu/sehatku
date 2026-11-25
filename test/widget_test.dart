import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:sehatku/data/dummy_clinic_data.dart';
import 'package:sehatku/main.dart';
import 'package:sehatku/models/medical_record_model.dart';
import 'package:sehatku/providers/clinic_data_provider.dart';
import 'package:sehatku/services/api_service.dart';
import 'package:sehatku/services/database_helper.dart';
import 'package:sehatku/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sehatku_test_');
    SharedPreferences.setMockInitialValues({});
    DatabaseHelper.instance.configureTestDatabasePath(
      p.join(tempDir.path, 'test_sehatku.db'),
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
    'Tugas 4 & Tugas 9: Koleksi minimal 10 dokter lokal & parsing JSON REST API ke model Doctor',
    () async {
      expect(DummyClinicData.localDoctors.length, greaterThanOrEqualTo(10));

      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/users')) {
          return http.Response(
            jsonEncode({
              'users': [
                {
                  'id': 1,
                  'firstName': 'Aulia',
                  'lastName': 'Rahman',
                  'age': 38,
                  'image': '',
                  'university': 'FK Universitas Tanjungpura',
                },
                {
                  'id': 2,
                  'firstName': 'Sinta',
                  'lastName': 'Dewi',
                  'age': 34,
                  'image': '',
                  'university': 'FK Universitas Indonesia',
                },
              ],
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'posts': [
              {
                'id': 10,
                'title': 'Health Info',
                'body': 'Minum air putih minimal 8 gelas sehari.',
                'tags': ['health'],
                'views': 250,
              },
            ],
          }),
          200,
        );
      });

      final api = ApiService(client: mockClient);
      final doctors = await api.fetchDoctorsFromApi();
      final articles = await api.fetchHealthArticles();

      expect(doctors.length, 2);
      expect(doctors.first.isFromApi, isTrue);
      expect(doctors.first.name, contains('Aulia Rahman'));
      expect(articles.length, 1);
      expect(articles.first.views, 250);
    },
  );

  test(
    'Tugas 10: SQLite CRUD rekam medis & booking tetap tersimpan setelah DB ditutup dan dibuka kembali',
    () async {
      final dbHelper = DatabaseHelper.instance;

      // Seed awal otomatis tersedia
      final initial = await dbHelper.getAllMedicalRecords();
      expect(initial.length, greaterThanOrEqualTo(3));

      // Create
      final newId = await dbHelper.insertMedicalRecord(
        const MedicalRecord(
          patientName: 'M. Fadjri Akbar',
          medicalRecordNumber: 'RM-2026-0104',
          visitDate: '25 November 2026',
          poli: 'Poli Mata & THT',
          doctorName: 'dr. Dimas Prasetyo, Sp.M',
          diagnosis: 'Asthenopia (Kelelahan Mata Digital)',
          symptoms: 'Mata kering setelah menatap layar laptop',
          treatmentAndPrescription: 'Artificial Tears 4x1 tetes mata',
          bloodPressure: '118/78 mmHg',
          bodyWeightKg: 64.5,
          nextControlDate: '15 Desember 2026',
          notes: 'Terapkan aturan 20-20-20 saat bekerja di depan layar.',
        ),
      );
      expect(newId, greaterThan(0));

      // Simulasi aplikasi ditutup lalu dibuka kembali
      await dbHelper.closeDatabase();
      final afterReopen = await dbHelper.getAllMedicalRecords();
      final inserted = afterReopen.firstWhere((r) => r.id == newId);
      expect(inserted.diagnosis, 'Asthenopia (Kelelahan Mata Digital)');

      // Update
      await dbHelper.updateMedicalRecord(
        inserted.copyWith(diagnosis: 'Asthenopia Terkontrol'),
      );
      final updatedList = await dbHelper.getAllMedicalRecords();
      expect(
        updatedList.firstWhere((r) => r.id == newId).diagnosis,
        'Asthenopia Terkontrol',
      );

      // Delete
      await dbHelper.deleteMedicalRecord(newId);
      final afterDelete = await dbHelper.getAllMedicalRecords();
      expect(afterDelete.any((r) => r.id == newId), isFalse);
    },
  );

  test(
    'Tugas 10: Hive (dokter favorit & profil) serta SharedPreferences (tema & pengingat) persisten',
    () async {
      final storage = LocalStorageService();
      await storage.init(customHivePath: p.join(tempDir.path, 'hive_boxes'));

      // Toggle dokter favorit di Hive
      final favsAfterAdd = await storage.toggleFavoriteDoctor('dok-03');
      expect(favsAfterAdd, contains('dok-03'));

      // Simpan profil pasien di Hive
      await storage.savePatientProfile({
        'name': 'Fadjri Akbar',
        'nik': '6171032405040002',
        'rmNumber': 'RM-2026-0104',
        'bloodType': 'O+',
        'allergies': 'Debu dingin',
        'bpjsNumber': '0001849201142',
        'phone': '081256789044',
      });
      expect(storage.getPatientProfile()['allergies'], 'Debu dingin');

      // Simpan preferensi di SharedPreferences
      await storage.setDarkMode(true);
      await storage.setCompactCards(true);
      final prefs = await storage.loadPreferences();
      expect(prefs['isDarkMode'], isTrue);
      expect(prefs['compactCards'], isTrue);
    },
  );

  testWidgets(
    'Tugas 3, 4 & 5: Uji layout responsif di 2 ukuran layar (Mobile & Tablet) + pencarian + navigasi 4 halaman',
    (WidgetTester tester) async {
      final mockClient = MockClient(
        (_) async => http.Response(
          jsonEncode({'users': [], 'posts': []}),
          200,
        ),
      );

      late ClinicDataProvider provider;
      await tester.runAsync(() async {
        final storage = LocalStorageService();
        await storage.init(customHivePath: p.join(tempDir.path, 'hive_widget'));
        provider = ClinicDataProvider(
          apiService: ApiService(client: mockClient),
          databaseHelper: DatabaseHelper.instance,
          localStorageService: storage,
        );
        await provider.initializeAll(fetchNetworkOnStart: false);
      });

      // Ukuran Layar 1: Smartphone Mobile (390 x 844)
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const SehatKuApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SehatKu Klinik'), findsOneWidget);
      expect(find.byKey(const Key('home_search_textfield')), findsOneWidget);

      // Uji pencarian dinamis dokter
      await tester.enterText(
        find.byKey(const Key('home_search_textfield')),
        'Siti Rahmawati',
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining('dr. Siti Rahmawati'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('dr. Siti Rahmawati'), findsWidgets);

      // Reset pencarian lalu uji Ukuran Layar 2: Tablet / Lebar (1024 x 768)
      provider.setSearchQuery('');
      tester.view.physicalSize = const Size(1024, 768);
      await tester.pumpAndSettle();
      expect(find.text('Dokter Praktik Tersedia'), findsOneWidget);

      // Navigasi antar 4 halaman BottomNavigationBar (Beranda -> Jadwal -> Rekam Medis -> Profil)
      final bottomNav = find.byType(BottomNavigationBar);
      await tester.tap(
        find.descendant(of: bottomNav, matching: find.text('Jadwal')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Jadwal Dokter & Booking'), findsOneWidget);

      await tester.tap(
        find.descendant(of: bottomNav, matching: find.text('Rekam Medis')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Rekam Medis Pasien'), findsOneWidget);

      await tester.tap(
        find.descendant(of: bottomNav, matching: find.text('Profil')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Profil & Preferensi'), findsOneWidget);

      // Kembali ke Jadwal & buka halaman Detail/Form Booking via Navigator.pushNamed
      await tester.tap(
        find.descendant(of: bottomNav, matching: find.text('Jadwal')),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Booking').first);
      await tester.tap(find.text('Booking').first);
      await tester.pumpAndSettle();
      expect(find.text('Detail Dokter & Booking'), findsOneWidget);
    },
  );
}
