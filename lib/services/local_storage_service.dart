import 'dart:typed_data';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Layanan Penyimpanan Lokal Hive & SharedPreferences (Tugas 10 - Sub-CPMK0539)
/// 1. Hive: Menyimpan daftar ID dokter favorit & profil medis ringkas pasien.
/// 2. SharedPreferences: Menyimpan preferensi aplikasi (mode gelap, pengingat kontrol,
///    mode tampilan daftar kompak, dan filter poli terakhir).
class LocalStorageService {
  static const String favoritesBoxName = 'sehatku_favorites_box';
  static const String profileBoxName = 'sehatku_profile_box';

  static const String keyFavoriteIds = 'favorite_doctor_ids';
  static const String prefDarkMode = 'pref_dark_mode';
  static const String prefReminderEnabled = 'pref_reminder_enabled';
  static const String prefCompactCards = 'pref_compact_cards';
  static const String prefLastPoli = 'pref_last_selected_poli';

  bool _initialized = false;

  Future<void> init({String? customHivePath, bool inMemory = false}) async {
    if (_initialized) return;
    if (inMemory) {
      await Hive.openBox(favoritesBoxName, bytes: Uint8List(0));
      await Hive.openBox(profileBoxName, bytes: Uint8List(0));
      _initialized = true;
      return;
    }
    if (customHivePath != null) {
      Hive.init(customHivePath);
    } else {
      await Hive.initFlutter();
    }
    await Hive.openBox(favoritesBoxName);
    await Hive.openBox(profileBoxName);
    _initialized = true;
  }

  // =========================================================================
  // HIVE: DOKTER FAVORIT PASIEN
  // =========================================================================

  List<String> getFavoriteDoctorIds() {
    final box = Hive.box(favoritesBoxName);
    final raw = box.get(keyFavoriteIds, defaultValue: <String>['dok-05']);
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return <String>[];
  }

  Future<List<String>> toggleFavoriteDoctor(String doctorId) async {
    final box = Hive.box(favoritesBoxName);
    final current = getFavoriteDoctorIds();
    if (current.contains(doctorId)) {
      current.remove(doctorId);
    } else {
      current.add(doctorId);
    }
    await box.put(keyFavoriteIds, current);
    return current;
  }

  // =========================================================================
  // HIVE: PROFIL MEDIS PASIEN
  // =========================================================================

  Map<String, String> getPatientProfile() {
    final box = Hive.box(profileBoxName);
    return {
      'name': box
          .get('name', defaultValue: 'M. Fadjri Akbar')
          .toString(),
      'nik': box
          .get('nik', defaultValue: '6171032405040002')
          .toString(),
      'rmNumber': box
          .get('rmNumber', defaultValue: 'RM-2026-0104')
          .toString(),
      'bloodType': box.get('bloodType', defaultValue: 'O+').toString(),
      'allergies': box
          .get('allergies', defaultValue: 'Tidak ada alergi obat')
          .toString(),
      'bpjsNumber': box
          .get('bpjsNumber', defaultValue: '0001849201142')
          .toString(),
      'phone': box
          .get('phone', defaultValue: '0812-5678-9044')
          .toString(),
    };
  }

  Future<void> savePatientProfile(Map<String, String> profile) async {
    final box = Hive.box(profileBoxName);
    await box.putAll(profile);
  }

  // =========================================================================
  // SHARED PREFERENCES: PREFERENSI PENGGUNA & PENGATURAN APLIKASI
  // =========================================================================

  Future<Map<String, dynamic>> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isDarkMode': prefs.getBool(prefDarkMode) ?? false,
      'reminderEnabled': prefs.getBool(prefReminderEnabled) ?? true,
      'compactCards': prefs.getBool(prefCompactCards) ?? false,
      'lastPoli': prefs.getString(prefLastPoli) ?? 'Semua',
    };
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefDarkMode, value);
  }

  Future<void> setReminderEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefReminderEnabled, value);
  }

  Future<void> setCompactCards(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefCompactCards, value);
  }

  Future<void> setLastSelectedPoli(String poli) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefLastPoli, poli);
  }
}
