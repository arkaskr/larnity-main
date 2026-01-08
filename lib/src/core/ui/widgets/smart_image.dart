import 'dart:io';
import 'package:flutter/material.dart';

class SmartImage extends StatelessWidget {
  final String? path;
  final BoxFit fit;
  final double? width;
  final double? height;

  const SmartImage(
    this.path, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return const SizedBox.shrink();
    }

    if (path!.startsWith('http://') || path!.startsWith('https://')) {
      return Image.network(
        path!,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, color: Colors.grey),
      );
    }

    return Image.file(
      File(path!),
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}
