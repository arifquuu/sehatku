import 'dart:convert';
import 'dart:typed_data';

Future<String> persistMedicalPhotoBytes({
  required Uint8List bytes,
  required String fileName,
}) async {
  final lower = fileName.toLowerCase();
  final mime = lower.endsWith('.png') ? 'image/png' : 'image/jpeg';
  return 'data:$mime;base64,${base64Encode(bytes)}';
}
