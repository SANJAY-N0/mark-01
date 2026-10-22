import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Shows a circular photo, or initials if no photo is available or it fails to load.
class ContactAvatar extends StatelessWidget {
  final String name;
  final String? photoPath;
  final Uint8List? photoBytes;
  final double size;

  const ContactAvatar({
    super.key,
    required this.name,
    this.photoPath,
    this.photoBytes,
    required this.size,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: scheme.secondaryContainer,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.bold,
          color: scheme.onSecondaryContainer,
        ),
      ),
    );

    Widget child = fallback;
    if (photoBytes != null) {
      child = Image.memory(
        photoBytes!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => fallback,
      );
    } else if (photoPath != null && File(photoPath!).existsSync()) {
      child = Image.file(
        File(photoPath!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return ClipOval(child: child);
  }
}
