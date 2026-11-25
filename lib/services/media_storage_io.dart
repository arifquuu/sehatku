import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> persistMedicalPhotoBytes({
  required Uint8List bytes,
  required String fileName,
}) async {
  final docsDir = await getApplicationDocumentsDirectory();
  final folder = Directory(p.join(docsDir.path, 'medical_docs'));
  if (!await folder.exists()) {
    await folder.create(recursive: true);
  }
  final ext = p.extension(fileName).isNotEmpty ? p.extension(fileName) : '.jpg';
  final targetName = 'doc_${DateTime.now().millisecondsSinceEpoch}$ext';
  final targetFile = File(p.join(folder.path, targetName));
  await targetFile.writeAsBytes(bytes, flush: true);
  return targetFile.path;
}
