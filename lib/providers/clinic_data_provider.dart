import 'package:flutter/foundation.dart';

import '../data/dummy_clinic_data.dart';
import '../models/booking_model.dart';
import '../models/doctor_model.dart';
import '../models/health_article_model.dart';
import '../models/medical_record_model.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';
import '../services/local_storage_service.dart';

class ClinicDataProvider extends ChangeNotifier {
  final ApiService _apiService;
  final DatabaseHelper _databaseHelper;
  final LocalStorageService _localStorageService;

  ClinicDataProvider({
    ApiService? apiService,
    DatabaseHelper? databaseHelper,
    LocalStorageService? localStorageService,
  }) : _apiService = apiService ?? ApiService(),
       _databaseHelper = databaseHelper ?? DatabaseHelper.instance,
       _localStorageService = localStorageService ?? LocalStorageService();

  // Daftar dokter lokal & REST API
  final List<Doctor> _localDoctors = DummyClinicData.localDoctors;
  List<Doctor> _apiDoctors = const [];
  List<HealthArticle> _healthArticles = const [];

  bool _useApiDoctors = false;
  bool _isLoadingApi = false;
  String? _apiErrorMessage;

  // Filter & Pencarian Dinamis (Tugas 4)
  String _searchQuery = '';
  String _selectedPoli = 'Semua';

  // SQLite Data (Tugas 10)
  List<MedicalRecord> _medicalRecords = const [];
  List<BookingAppointment> _bookings = const [];
  bool _isLoadingLocalDb = false;

  // Hive & SharedPreferences Data (Tugas 10)
  List<String> _favoriteDoctorIds = const [];
  Map<String, String> _patientProfile = {
    'name': 'M. Fadjri Akbar',
    'nik': '6171032405040002',
    'rmNumber': 'RM-2026-0104',
    'bloodType': 'O+',
    'allergies': 'Tidak ada alergi obat',
    'bpjsNumber': '0001849201142',
    'phone': '0812-5678-9044',
  };
  bool _isDarkMode = false;
  bool _reminderEnabled = true;
  bool _compactCards = false;

  // Getters
  List<Doctor> get activeDoctors =>
      (_useApiDoctors && _apiDoctors.isNotEmpty) ? _apiDoctors : _localDoctors;
  List<Doctor> get apiDoctors => _apiDoctors;
  List<HealthArticle> get healthArticles => _healthArticles;
  bool get useApiDoctors => _useApiDoctors;
  bool get isLoadingApi => _isLoadingApi;
  String? get apiErrorMessage => _apiErrorMessage;

  String get searchQuery => _searchQuery;
  String get selectedPoli => _selectedPoli;

  List<MedicalRecord> get medicalRecords => _medicalRecords;
  List<BookingAppointment> get bookings => _bookings;
  bool get isLoadingLocalDb => _isLoadingLocalDb;

  List<String> get favoriteDoctorIds => _favoriteDoctorIds;
  Map<String, String> get patientProfile => _patientProfile;
  bool get isDarkMode => _isDarkMode;
  bool get reminderEnabled => _reminderEnabled;
  bool get compactCards => _compactCards;

  List<Doctor> get favoriteDoctors {
    final combined = <String, Doctor>{
      for (final d in _localDoctors) d.id: d,
      for (final d in _apiDoctors) d.id: d,
    };
    return _favoriteDoctorIds
        .where(combined.containsKey)
        .map((id) => combined[id]!)
        .toList();
  }

  BookingAppointment? get activeBooking {
    for (final b in _bookings) {
      if (b.status == 'Terjadwal') return b;
    }
    return _bookings.isNotEmpty ? _bookings.first : null;
  }

  /// Filter & pencarian dokter secara dinamis berdasarkan nama, spesialis, poli, atau hari
  List<Doctor> get filteredDoctors {
    final q = _searchQuery.trim().toLowerCase();
    return activeDoctors.where((doc) {
      final matchesPoli =
          _selectedPoli == 'Semua' || doc.poli == _selectedPoli;
      if (!matchesPoli) return false;
      if (q.isEmpty) return true;
      return doc.name.toLowerCase().contains(q) ||
          doc.poli.toLowerCase().contains(q) ||
          doc.specialistTitle.toLowerCase().contains(q) ||
          doc.scheduleDays.toLowerCase().contains(q) ||
          doc.room.toLowerCase().contains(q);
    }).toList();
  }

  /// Rekap jumlah kunjungan per poli (mendukung analisis bisnis klinik SehatKu)
  Map<String, int> get visitCountByPoli {
    final counts = <String, int>{};
    for (final rec in _medicalRecords) {
      counts[rec.poli] = (counts[rec.poli] ?? 0) + 1;
    }
    for (final book in _bookings) {
      counts[book.poli] = (counts[book.poli] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> initializeAll({bool fetchNetworkOnStart = true}) async {
    _isLoadingLocalDb = true;
    notifyListeners();

    await _localStorageService.init();
    _favoriteDoctorIds = _localStorageService.getFavoriteDoctorIds();
    _patientProfile = _localStorageService.getPatientProfile();

    final prefs = await _localStorageService.loadPreferences();
    _isDarkMode = prefs['isDarkMode'] as bool;
    _reminderEnabled = prefs['reminderEnabled'] as bool;
    _compactCards = prefs['compactCards'] as bool;
    final savedPoli = prefs['lastPoli'] as String;
    if (DummyClinicData.poliCategories.contains(savedPoli)) {
      _selectedPoli = savedPoli;
    }

    _medicalRecords = await _databaseHelper.getAllMedicalRecords();
    _bookings = await _databaseHelper.getAllBookings();
    _isLoadingLocalDb = false;
    notifyListeners();

    if (fetchNetworkOnStart) {
      await fetchApiData();
    }
  }

  // =========================================================================
  // FILTER & PENCARIAN
  // =========================================================================

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> setSelectedPoli(String poli) async {
    _selectedPoli = poli;
    notifyListeners();
    await _localStorageService.setLastSelectedPoli(poli);
  }

  // =========================================================================
  // AKSES REST API PUBLIK (TUGAS 9)
  // =========================================================================

  Future<void> fetchApiData({bool activateApiDoctors = false}) async {
    _isLoadingApi = true;
    _apiErrorMessage = null;
    if (activateApiDoctors) {
      _useApiDoctors = true;
    }
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.fetchDoctorsFromApi(),
        _apiService.fetchHealthArticles(),
      ]);
      _apiDoctors = results[0] as List<Doctor>;
      _healthArticles = results[1] as List<HealthArticle>;
      _apiErrorMessage = null;
    } catch (e) {
      _apiErrorMessage = e.toString();
    } finally {
      _isLoadingApi = false;
      notifyListeners();
    }
  }

  Future<void> toggleDoctorDataSource(bool useApi) async {
    _useApiDoctors = useApi;
    notifyListeners();
    if (useApi && _apiDoctors.isEmpty && !_isLoadingApi) {
      await fetchApiData(activateApiDoctors: true);
    }
  }

  // =========================================================================
  // SQLITE CRUD: BOOKING & REKAM MEDIS (TUGAS 10)
  // =========================================================================

  String generateNextQueueNumber(String poli) {
    final prefix = switch (poli) {
      'Poli Umum' => 'A',
      'Poli Gigi & Mulut' => 'B',
      'Poli Anak' => 'C',
      'Poli Penyakit Dalam' => 'D',
      'Poli KIA & Kandungan' => 'E',
      _ => 'F',
    };
    final nextNum = _bookings.length + 12;
    return '$prefix-${nextNum.toString().padLeft(3, '0')}';
  }

  Future<BookingAppointment> createBooking({
    required Doctor doctor,
    required String patientName,
    required String patientNik,
    required String visitDate,
    required String sessionTime,
    required String paymentType,
    required String complaint,
  }) async {
    final queueNo = generateNextQueueNumber(doctor.poli);
    final nowStr = DateTime.now().toIso8601String().substring(0, 16).replaceAll('T', ' ');
    final booking = BookingAppointment(
      queueNumber: queueNo,
      doctorId: doctor.id,
      doctorName: doctor.name,
      poli: doctor.poli,
      room: doctor.room,
      patientName: patientName,
      patientNik: patientNik,
      visitDate: visitDate,
      sessionTime: sessionTime,
      paymentType: paymentType,
      complaint: complaint,
      status: 'Terjadwal',
      createdAt: nowStr,
    );

    final id = await _databaseHelper.insertBooking(booking);
    _bookings = await _databaseHelper.getAllBookings();
    notifyListeners();
    return booking.copyWith(id: id);
  }

  Future<void> updateBookingStatus(int id, String status) async {
    await _databaseHelper.updateBookingStatus(id, status);
    _bookings = await _databaseHelper.getAllBookings();
    notifyListeners();
  }

  Future<void> deleteBooking(int id) async {
    await _databaseHelper.deleteBooking(id);
    _bookings = await _databaseHelper.getAllBookings();
    notifyListeners();
  }

  Future<void> addMedicalRecord(MedicalRecord record) async {
    await _databaseHelper.insertMedicalRecord(record);
    _medicalRecords = await _databaseHelper.getAllMedicalRecords();
    notifyListeners();
  }

  Future<void> updateMedicalRecord(MedicalRecord record) async {
    await _databaseHelper.updateMedicalRecord(record);
    _medicalRecords = await _databaseHelper.getAllMedicalRecords();
    notifyListeners();
  }

  Future<void> deleteMedicalRecord(int id) async {
    await _databaseHelper.deleteMedicalRecord(id);
    _medicalRecords = await _databaseHelper.getAllMedicalRecords();
    notifyListeners();
  }

  // =========================================================================
  // HIVE & SHARED PREFERENCES (TUGAS 10)
  // =========================================================================

  bool isDoctorFavorite(String doctorId) =>
      _favoriteDoctorIds.contains(doctorId);

  Future<void> toggleFavoriteDoctor(String doctorId) async {
    _favoriteDoctorIds = await _localStorageService.toggleFavoriteDoctor(
      doctorId,
    );
    notifyListeners();
  }

  Future<void> updatePatientProfile(Map<String, String> updated) async {
    _patientProfile = Map<String, String>.from(updated);
    await _localStorageService.savePatientProfile(_patientProfile);
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    await _localStorageService.setDarkMode(value);
  }

  Future<void> toggleReminder(bool value) async {
    _reminderEnabled = value;
    notifyListeners();
    await _localStorageService.setReminderEnabled(value);
  }

  Future<void> toggleCompactCards(bool value) async {
    _compactCards = value;
    notifyListeners();
    await _localStorageService.setCompactCards(value);
  }
}
