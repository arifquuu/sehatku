import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/doctor_model.dart';
import '../models/health_article_model.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Layanan konsumsi REST API Publik (Tugas 9 - Sub-CPMK0538)
/// Menggunakan package `http` untuk mengambil JSON dari DummyJSON REST API
/// dan mem-parsing ke dalam model class `Doctor` serta `HealthArticle`.
class ApiService {
  static const String doctorsEndpoint =
      'https://dummyjson.com/users?limit=12&select=id,firstName,lastName,age,image,university';
  static const String articlesEndpoint =
      'https://dummyjson.com/posts?limit=6&select=id,title,body,tags,views';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Doctor>> fetchDoctorsFromApi() async {
    try {
      final response = await _client
          .get(
            Uri.parse(doctorsEndpoint),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw ApiException(
          'Gagal memuat data dokter API (HTTP ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['users'] is! List) {
        throw const ApiException('Format respons JSON dokter tidak valid.');
      }

      final usersList = decoded['users'] as List;
      return List<Doctor>.generate(
        usersList.length,
        (index) => Doctor.fromApiJson(
          Map<String, dynamic>.from(usersList[index] as Map),
          index: index,
        ),
      );
    } on TimeoutException {
      throw const ApiException(
        'Koneksi ke server API melebihi batas waktu (timeout). Periksa jaringan Anda.',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Tidak dapat terhubung ke REST API (mode offline): $e',
      );
    }
  }

  Future<List<HealthArticle>> fetchHealthArticles() async {
    try {
      final response = await _client
          .get(
            Uri.parse(articlesEndpoint),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw ApiException(
          'Gagal memuat artikel kesehatan (HTTP ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['posts'] is! List) {
        throw const ApiException('Format respons JSON artikel tidak valid.');
      }

      final postsList = decoded['posts'] as List;
      return List<HealthArticle>.generate(
        postsList.length,
        (index) => HealthArticle.fromApiJson(
          Map<String, dynamic>.from(postsList[index] as Map),
          index: index,
        ),
      );
    } on TimeoutException {
      throw const ApiException('Timeout saat memuat info kesehatan dari API.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Gagal mengambil info kesehatan API: $e');
    }
  }
}
