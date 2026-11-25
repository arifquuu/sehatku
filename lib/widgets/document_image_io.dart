import 'dart:io';

import 'package:flutter/material.dart';

Widget buildPlatformDocumentImage({
  required String photoPath,
  required double height,
  required BoxFit fit,
  required Widget fallback,
}) {
  final file = File(photoPath);
  if (!file.existsSync()) {
    return fallback;
  }
  return Image.file(
    file,
    height: height,
    width: double.infinity,
    fit: fit,
    errorBuilder: (_, _, _) => fallback,
  );
}
