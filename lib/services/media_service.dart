import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'media_storage_stub.dart'
    if (dart.library.io) 'media_storage_io.dart';

class MediaPickResult {
  final String? savedPath;
  final bool cancelled;
  final bool permissionDenied;
  final bool permanentlyDenied;
  final String message;

  const MediaPickResult({
    this.savedPath,
    this.cancelled = false,
    this.permissionDenied = false,
    this.permanentlyDenied = false,
    required this.message,
  });
}

class MediaService {
  final ImagePicker _picker;

  MediaService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  Future<MediaPickResult> pickMedicalDocument(ImageSource source) async {
    final permCheck = await _ensurePermission(source);
    if (permCheck != null) return permCheck;

    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 82,
      );
      if (picked == null) {
        return const MediaPickResult(
          cancelled: true,
          message: 'Pemilihan foto dibatalkan.',
        );
      }

      final bytes = await picked.readAsBytes();
      final savedPath = await persistMedicalPhotoBytes(
        bytes: bytes,
        fileName: picked.name,
      );
      return MediaPickResult(
        savedPath: savedPath,
        message: 'Foto dokumen medis berhasil dilampirkan.',
      );
    } on PlatformException catch (e) {
      return MediaPickResult(
        permissionDenied: e.code.contains('access_denied'),
        message: 'Gagal mengakses media perangkat: ${e.message ?? e.code}',
      );
    } catch (e) {
      return MediaPickResult(
        message: 'Tidak dapat memuat foto dokumen: $e',
      );
    }
  }

  Future<MediaPickResult?> _ensurePermission(ImageSource source) async {
    if (kIsWeb) return null;
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return null;
    }

    try {
      if (source == ImageSource.camera) {
        var status = await Permission.camera.status;
        if (!status.isGranted) {
          status = await Permission.camera.request();
        }
        if (!status.isGranted) {
          return MediaPickResult(
            permissionDenied: true,
            permanentlyDenied: status.isPermanentlyDenied,
            message: status.isPermanentlyDenied
                ? 'Izin kamera ditolak permanen. Aktifkan di Pengaturan Aplikasi.'
                : 'Izin kamera diperlukan untuk memotret dokumen medis.',
          );
        }
        return null;
      }

      // Android 13+ uses READ_MEDIA_IMAGES (photos), older versions use storage.
      var photosStatus = await Permission.photos.status;
      if (photosStatus.isGranted || photosStatus.isLimited) return null;
      photosStatus = await Permission.photos.request();
      if (photosStatus.isGranted || photosStatus.isLimited) return null;

      var storageStatus = await Permission.storage.status;
      if (storageStatus.isGranted) return null;
      storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) return null;

      final permanent =
          photosStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied;
      return MediaPickResult(
        permissionDenied: true,
        permanentlyDenied: permanent,
        message: permanent
            ? 'Izin galeri ditolak permanen. Buka Pengaturan Aplikasi untuk mengaktifkannya.'
            : 'Izin akses galeri diperlukan untuk memilih foto resep atau hasil lab.',
      );
    } on MissingPluginException {
      return null;
    }
  }
}
