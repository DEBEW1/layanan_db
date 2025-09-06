import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UniversalImage extends StatelessWidget {
  final dynamic imageSource; // bisa File (mobile) atau Uint8List (web)
  final double? width;
  final double? height;
  final BoxFit fit;

  const UniversalImage({
    super.key,
    required this.imageSource,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Untuk Flutter Web - gunakan Image.memory
      if (imageSource is Uint8List) {
        return Image.memory(
          imageSource,
          width: width,
          height: height,
          fit: fit,
        );
      } else {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.image, size: 50, color: Colors.grey),
          ),
        );
      }
    } else {
      // Untuk Android/iOS - gunakan Image.file
      if (imageSource is File) {
        return Image.file(
          imageSource,
          width: width,
          height: height,
          fit: fit,
        );
      } else {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.image, size: 50, color: Colors.grey),
          ),
        );
      }
    }
  }
}