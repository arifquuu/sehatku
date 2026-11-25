import 'package:flutter/material.dart';

Widget buildPlatformDocumentImage({
  required String photoPath,
  required double height,
  required BoxFit fit,
  required Widget fallback,
}) {
  return Image.network(
    photoPath,
    height: height,
    width: double.infinity,
    fit: fit,
    errorBuilder: (_, _, _) => fallback,
  );
}
