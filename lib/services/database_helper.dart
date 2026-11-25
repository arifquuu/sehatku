import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../data/dummy_clinic_data.dart';
import '../models/booking_model.dart';
import '../models/medical_record_model.dart';
import 'sqlite_init_stub.dart'
    if (dart.library.io) 'sqlite_init_io.dart';

/// Helper Penyimpanan Lokal SQLite (Tugas 10 - Sub-CPMK0539)
/// Mengelola operasi CRUD tabel `medical_records` (rekam medis ringkas)
/// dan tabel `bookings` (riwayat pendaftaran/antrean kunjungan klinik).
/// Mendukung Android/iOS (`sqflite`), Desktop/Testing (`sqflite_common_ffi`),
/// serta fallback IndexedDB persisten saat dijalankan di browser Web (`kIsWeb`).
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static const String _dbName = 'sehatku_clinic.db';
  static const int _dbVersion = 2;

  static const String tableMedicalRecords = 'medical_records';
  static const String tableBookings = 'bookings';

  static const String _webRecordsBoxName = 'sehatku_web_medical_records';
  static const String _webBookingsBoxName = 'sehatku_web_bookings';

  Database? _database;
  String? _overrideDbPath;

  /// Digunakan khusus pada pengujian unit/integrasi agar memakai file DB terisolasi
  void configureTestDatabasePath(String? customPath) {
    _overrideDbPath = customPath;
  }

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    ensureDesktopSqliteInitialized();
    final dbPath = _overrideDbPath ??
        p.join(await getDatabasesPath(), _dbName);

    _database = await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _database!;
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $tableMedicalRecords ADD COLUMN document_photo_path TEXT',
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableMedicalRecords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_name TEXT NOT NULL,
        medical_record_number TEXT NOT NULL,
        visit_date TEXT NOT NULL,
        poli TEXT NOT NULL,
        doctor_name TEXT NOT NULL,
        diagnosis TEXT NOT NULL,
        symptoms TEXT NOT NULL,
        treatment_prescription TEXT NOT NULL,
        blood_pressure TEXT NOT NULL,
        body_weight_kg REAL NOT NULL,
        next_control_date TEXT NOT NULL,
        notes TEXT NOT NULL,
        document_photo_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableBookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        queue_number TEXT NOT NULL,
        doctor_id TEXT NOT NULL,
        doctor_name TEXT NOT NULL,
        poli TEXT NOT NULL,
        room TEXT NOT NULL,
        patient_name TEXT NOT NULL,
        patient_nik TEXT NOT NULL,
        visit_date TEXT NOT NULL,
        session_time TEXT NOT NULL,
        payment_type TEXT NOT NULL,
        complaint TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Seed data awal agar riwayat kunjungan klinik langsung tersedia saat pertama kali dijalankan
    for (final record in DummyClinicData.initialMedicalRecords) {
      await db.insert(tableMedicalRecords, record.toMap());
    }
    for (final booking in DummyClinicData.initialBookings) {
      await db.insert(tableBookings, booking.toMap());
    }
  }

  Future<void> _ensureWebBoxesSeeded() async {
    final recBox = await Hive.openBox<Map>(_webRecordsBoxName);
    if (recBox.isEmpty) {
      int id = 1;
      for (final record in DummyClinicData.initialMedicalRecords) {
        final map = record.copyWith(id: id).toMap();
        await recBox.put(id, map);
        id++;
      }
    }
    final bookBox = await Hive.openBox<Map>(_webBookingsBoxName);
    if (bookBox.isEmpty) {
      int id = 1;
      for (final booking in DummyClinicData.initialBookings) {
        final map = booking.copyWith(id: id).toMap();
        await bookBox.put(id, map);
        id++;
      }
    }
  }

  // =========================================================================
  // CRUD REKAM MEDIS RINGKAS (medical_records)
  // =========================================================================

  Future<List<MedicalRecord>> getAllMedicalRecords() async {
    if (kIsWeb) {
      await _ensureWebBoxesSeeded();
      final box = await Hive.openBox<Map>(_webRecordsBoxName);
      final items = box.values
          .map((e) => MedicalRecord.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      items.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
      return items;
    }

    final db = await database;
    final rows = await db.query(tableMedicalRecords, orderBy: 'id DESC');
    return rows.map(MedicalRecord.fromMap).toList();
  }

  Future<int> insertMedicalRecord(MedicalRecord record) async {
    if (kIsWeb) {
      await _ensureWebBoxesSeeded();
      final box = await Hive.openBox<Map>(_webRecordsBoxName);
      final nextId = box.keys.isEmpty
          ? 1
          : (box.keys.cast<int>().reduce((a, b) => a > b ? a : b) + 1);
      final map = record.copyWith(id: nextId).toMap();
      await box.put(nextId, map);
      return nextId;
    }

    final db = await database;
    final map = record.toMap()..remove('id');
    return db.insert(tableMedicalRecords, map);
  }

  Future<int> updateMedicalRecord(MedicalRecord record) async {
    if (record.id == null) return 0;

    if (kIsWeb) {
      final box = await Hive.openBox<Map>(_webRecordsBoxName);
      await box.put(record.id!, record.toMap());
      return 1;
    }

    final db = await database;
    return db.update(
      tableMedicalRecords,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteMedicalRecord(int id) async {
    if (kIsWeb) {
      final box = await Hive.openBox<Map>(_webRecordsBoxName);
      await box.delete(id);
      return 1;
    }

    final db = await database;
    return db.delete(
      tableMedicalRecords,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================================================================
  // CRUD RIWAYAT BOOKING / PENDAFTARAN KUNJUNGAN (bookings)
  // =========================================================================

  Future<List<BookingAppointment>> getAllBookings() async {
    if (kIsWeb) {
      await _ensureWebBoxesSeeded();
      final box = await Hive.openBox<Map>(_webBookingsBoxName);
      final items = box.values
          .map((e) => BookingAppointment.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      items.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
      return items;
    }

    final db = await database;
    final rows = await db.query(tableBookings, orderBy: 'id DESC');
    return rows.map(BookingAppointment.fromMap).toList();
  }

  Future<int> insertBooking(BookingAppointment booking) async {
    if (kIsWeb) {
      await _ensureWebBoxesSeeded();
      final box = await Hive.openBox<Map>(_webBookingsBoxName);
      final nextId = box.keys.isEmpty
          ? 1
          : (box.keys.cast<int>().reduce((a, b) => a > b ? a : b) + 1);
      final map = booking.copyWith(id: nextId).toMap();
      await box.put(nextId, map);
      return nextId;
    }

    final db = await database;
    final map = booking.toMap()..remove('id');
    return db.insert(tableBookings, map);
  }

  Future<int> updateBookingStatus(int id, String newStatus) async {
    if (kIsWeb) {
      final box = await Hive.openBox<Map>(_webBookingsBoxName);
      final existing = box.get(id);
      if (existing == null) return 0;
      final updated = BookingAppointment.fromMap(
        Map<String, dynamic>.from(existing),
      ).copyWith(status: newStatus);
      await box.put(id, updated.toMap());
      return 1;
    }

    final db = await database;
    return db.update(
      tableBookings,
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteBooking(int id) async {
    if (kIsWeb) {
      final box = await Hive.openBox<Map>(_webBookingsBoxName);
      await box.delete(id);
      return 1;
    }

    final db = await database;
    return db.delete(
      tableBookings,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}
