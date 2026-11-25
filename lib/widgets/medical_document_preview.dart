import 'dart:convert';

import 'package:flutter/material.dart';

import 'document_image_stub.dart'
    if (dart.library.io) 'document_image_io.dart';

class MedicalDocumentPreview extends StatelessWidget {
  final String photoPath;
  final double height;
  final BoxFit fit;

  const MedicalDocumentPreview({
    super.key,
    required this.photoPath,
    this.height = 140,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (photoPath.startsWith('data:image')) {
      final commaIndex = photoPath.indexOf(',');
      if (commaIndex > 0) {
        try {
          final bytes = base64Decode(photoPath.substring(commaIndex + 1));
          return Image.memory(
            bytes,
            height: height,
            width: double.infinity,
            fit: fit,
            errorBuilder: (_, _, _) => _brokenPlaceholder(context),
          );
        } catch (_) {
          return _brokenPlaceholder(context);
        }
      }
    }

    return buildPlatformDocumentImage(
      photoPath: photoPath,
      height: height,
      fit: fit,
      fallback: _brokenPlaceholder(context),
    );
  }

  Widget _brokenPlaceholder(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFFF1F5F9),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_outlined, color: Color(0xFF64748B)),
          SizedBox(height: 4),
          Text(
            'Pratinjau foto tidak tersedia',
            style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }
}
