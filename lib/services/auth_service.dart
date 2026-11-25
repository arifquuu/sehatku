import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';

class AuthException implements Exception {
  final String message;
  final bool isNetworkError;

  const AuthException(this.message, {this.isNetworkError = false});

  @override
  String toString() => message;
}

class AuthResult {
  final AppUser user;
  final String token;

  const AuthResult({
    required this.user,
    required this.token,
  });
}

class AuthService {
  static String get defaultBaseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator accesses host machine localhost via 10.0.2.2.
      return 'http://10.0.2.2:8080';
    }
    return 'http://127.0.0.1:8080';
  }

  final http.Client _client;
  final Duration _timeout;

  AuthService({
    http.Client? client,
    Duration timeout = const Duration(seconds: 8),
  }) : _client = client ?? http.Client(),
       _timeout = timeout;

  String _normalizeBaseUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return defaultBaseUrl;
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  Map<String, dynamic> _decodeJsonObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const AuthException('Format respons server autentikasi tidak valid.');
  }

  Future<bool> checkHealth(String baseUrl) async {
    final uri = Uri.parse('${_normalizeBaseUrl(baseUrl)}/api/health');
    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(_timeout);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<AuthResult> login({
    required String baseUrl,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${_normalizeBaseUrl(baseUrl)}/api/login');
    try {
      final response = await _client
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email.trim(),
              'password': password,
            }),
          )
          .timeout(_timeout);

      final data = _decodeJsonObject(response.body);
      if (response.statusCode != 200 || data['success'] != true) {
        final msg =
            data['message']?.toString() ??
            'Email atau kata sandi tidak sesuai.';
        throw AuthException(msg);
      }

      final payload = Map<String, dynamic>.from(data['data'] as Map);
      final userMap = Map<String, dynamic>.from(payload['user'] as Map);
      final token = (payload['token'] ?? '').toString();
      if (token.isEmpty) {
        throw const AuthException('Token sesi dari server kosong.');
      }

      return AuthResult(user: AppUser.fromJson(userMap), token: token);
    } on TimeoutException {
      throw const AuthException(
        'Server autentikasi tidak merespons (timeout). Pastikan backend PHP dan MySQL aktif.',
        isNetworkError: true,
      );
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(
        'Tidak dapat terhubung ke server MySQL. Periksa URL server atau gunakan mode demo lokal.',
        isNetworkError: true,
      );
    }
  }

  Future<AuthResult> register({
    required String baseUrl,
    required String fullName,
    required String email,
    required String password,
    required String nik,
    String phone = '',
    String bloodType = 'O+',
    String bpjsNumber = '',
  }) async {
    final uri = Uri.parse('${_normalizeBaseUrl(baseUrl)}/api/register');
    try {
      final response = await _client
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'full_name': fullName.trim(),
              'email': email.trim(),
              'password': password,
              'nik': nik.trim(),
              'phone': phone.trim(),
              'blood_type': bloodType.trim(),
              'bpjs_number': bpjsNumber.trim(),
            }),
          )
          .timeout(_timeout);

      final data = _decodeJsonObject(response.body);
      if ((response.statusCode != 200 && response.statusCode != 201) ||
          data['success'] != true) {
        final msg =
            data['message']?.toString() ?? 'Pendaftaran akun gagal diproses.';
        throw AuthException(msg);
      }

      final payload = Map<String, dynamic>.from(data['data'] as Map);
      final userMap = Map<String, dynamic>.from(payload['user'] as Map);
      final token = (payload['token'] ?? '').toString();
      return AuthResult(user: AppUser.fromJson(userMap), token: token);
    } on TimeoutException {
      throw const AuthException(
        'Koneksi ke server pendaftaran timeout. Pastikan backend PHP aktif.',
        isNetworkError: true,
      );
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(
        'Gagal menghubungi server pendaftaran MySQL. Cek jaringan atau URL server.',
        isNetworkError: true,
      );
    }
  }

  Future<AppUser> fetchCurrentUser({
    required String baseUrl,
    required String token,
  }) async {
    final uri = Uri.parse('${_normalizeBaseUrl(baseUrl)}/api/me');
    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      final data = _decodeJsonObject(response.body);
      if (response.statusCode != 200 || data['success'] != true) {
        throw const AuthException('Sesi login telah berakhir.');
      }

      final payload = Map<String, dynamic>.from(data['data'] as Map);
      return AppUser.fromJson(Map<String, dynamic>.from(payload['user'] as Map));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(
        'Gagal memuat profil sesi dari server.',
        isNetworkError: true,
      );
    }
  }

  Future<void> logout({
    required String baseUrl,
    required String token,
  }) async {
    final uri = Uri.parse('${_normalizeBaseUrl(baseUrl)}/api/logout');
    try {
      await _client
          .post(
            uri,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      // Clear local session even when server cannot be reached.
    }
  }
}
