import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  static const String _prefTokenKey = 'sehatku_auth_token';
  static const String _prefUserKey = 'sehatku_auth_user_json';
  static const String _prefServerUrlKey = 'sehatku_auth_server_url';
  static const String _prefOfflineSessionKey = 'sehatku_auth_offline_session';

  final AuthService _authService;

  AppUser? _currentUser;
  String? _token;
  String _serverBaseUrl;
  bool _isInitializing = true;
  bool _isLoading = false;
  bool _isOfflineSession = false;
  String? _errorMessage;

  AuthProvider({
    AuthService? authService,
    AppUser? initialUser,
    String? initialToken,
    bool initialOfflineSession = false,
    String? initialServerBaseUrl,
  }) : _authService = authService ?? AuthService(),
       _currentUser = initialUser,
       _token = initialToken,
       _isOfflineSession = initialOfflineSession,
       _serverBaseUrl = initialServerBaseUrl ?? AuthService.defaultBaseUrl,
       _isInitializing = initialUser == null;

  AppUser? get currentUser => _currentUser;
  String? get token => _token;
  String get serverBaseUrl => _serverBaseUrl;
  bool get isInitializing => _isInitializing;
  bool get isLoading => _isLoading;
  bool get isOfflineSession => _isOfflineSession;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated =>
      _currentUser != null && _token != null && _token!.isNotEmpty;

  Future<void> restoreSession() async {
    _isInitializing = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString(_prefServerUrlKey);
      if (savedUrl != null && savedUrl.trim().isNotEmpty) {
        _serverBaseUrl = savedUrl.trim();
      }

      final savedToken = prefs.getString(_prefTokenKey);
      final savedUserJson = prefs.getString(_prefUserKey);
      final savedOffline = prefs.getBool(_prefOfflineSessionKey) ?? false;

      if (savedToken != null &&
          savedToken.isNotEmpty &&
          savedUserJson != null &&
          savedUserJson.isNotEmpty) {
        final decoded = jsonDecode(savedUserJson);
        if (decoded is Map<String, dynamic>) {
          _currentUser = AppUser.fromJson(decoded);
          _token = savedToken;
          _isOfflineSession = savedOffline;
        }
      }
    } catch (_) {
      _currentUser = null;
      _token = null;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> _persistSession({
    required AppUser user,
    required String token,
    required bool offline,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefTokenKey, token);
    await prefs.setString(_prefUserKey, jsonEncode(user.toJson()));
    await prefs.setBool(_prefOfflineSessionKey, offline);
  }

  Future<void> updateServerBaseUrl(String newUrl) async {
    final cleaned = newUrl.trim();
    if (cleaned.isEmpty) return;
    _serverBaseUrl = cleaned;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefServerUrlKey, _serverBaseUrl);
    notifyListeners();
  }

  Future<bool> checkBackendConnection() async {
    return _authService.checkHealth(_serverBaseUrl);
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        baseUrl: _serverBaseUrl,
        email: email,
        password: password,
      );
      _currentUser = result.user;
      _token = result.token;
      _isOfflineSession = false;
      await _persistSession(
        user: result.user,
        token: result.token,
        offline: false,
      );
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String nik,
    String phone = '',
    String bloodType = 'O+',
    String bpjsNumber = '',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        baseUrl: _serverBaseUrl,
        fullName: fullName,
        email: email,
        password: password,
        nik: nik,
        phone: phone,
        bloodType: bloodType,
        bpjsNumber: bpjsNumber,
      );
      _currentUser = result.user;
      _token = result.token;
      _isOfflineSession = false;
      await _persistSession(
        user: result.user,
        token: result.token,
        offline: false,
      );
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fallback session when the local PHP + MySQL backend is not running.
  Future<void> enterOfflineDemoSession() async {
    const demoUser = AppUser(
      id: 0,
      rmNumber: 'RM-2026-0101',
      nik: '6171031504040001',
      fullName: 'M. Arifqu Wa Liin',
      email: 'arif@sehatku.id',
      phone: '0812-5501-4401',
      bloodType: 'O+',
      allergies: 'Tidak ada alergi obat',
      bpjsNumber: '0001849201101',
      role: 'pasien',
    );
    const demoToken = 'local-demo-session';
    _currentUser = demoUser;
    _token = demoToken;
    _isOfflineSession = true;
    _errorMessage = null;
    await _persistSession(user: demoUser, token: demoToken, offline: true);
    notifyListeners();
  }

  Future<void> refreshProfileFromServer() async {
    if (!isAuthenticated || _isOfflineSession || _token == null) return;
    try {
      final refreshed = await _authService.fetchCurrentUser(
        baseUrl: _serverBaseUrl,
        token: _token!,
      );
      _currentUser = refreshed;
      await _persistSession(user: refreshed, token: _token!, offline: false);
      notifyListeners();
    } catch (_) {
      // Keep cached session when refresh fails offline.
    }
  }

  void syncLocalProfileChanges(Map<String, String> profile) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      fullName: profile['name'] ?? _currentUser!.fullName,
      nik: profile['nik'] ?? _currentUser!.nik,
      rmNumber: profile['rmNumber'] ?? _currentUser!.rmNumber,
      bloodType: profile['bloodType'] ?? _currentUser!.bloodType,
      allergies: profile['allergies'] ?? _currentUser!.allergies,
      bpjsNumber: profile['bpjsNumber'] ?? _currentUser!.bpjsNumber,
      phone: profile['phone'] ?? _currentUser!.phone,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    if (!_isOfflineSession && _token != null) {
      await _authService.logout(baseUrl: _serverBaseUrl, token: _token!);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefTokenKey);
    await prefs.remove(_prefUserKey);
    await prefs.remove(_prefOfflineSessionKey);

    _currentUser = null;
    _token = null;
    _isOfflineSession = false;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
}
