import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/favourite.dart';

/// Stores EasyDial's own configuration on the device. Nothing is uploaded.
class FavouritesRepository {
  static const int maxFavourites = 6;

  static const _listKey = 'easydial.favourites.v1';
  static const _seededKey = 'easydial.samples_seeded.v1';

  Future<List<Favourite>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_listKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final items = decoded
          .map((e) => Favourite.fromJson(e as Map<String, dynamic>))
          .take(maxFavourites)
          .toList();

      // If the system removed a photo file, fall back to the initials avatar.
      return items.map((f) {
        final path = f.photoPath;
        if (path != null && !File(path).existsSync()) {
          return f.copyWith(clearPhoto: true);
        }
        return f;
      }).toList();
    } catch (_) {
      // Corrupt data should never crash the app.
      return [];
    }
  }

  Future<void> save(List<Favourite> items) async {
    final prefs = await SharedPreferences.getInstance();
    final data = items.take(maxFavourites).map((f) => f.toJson()).toList();
    await prefs.setString(_listKey, jsonEncode(data));
  }

  /// On first launch only, adds three clearly-labelled sample contacts so the
  /// home screen can be previewed. They can be removed from Edit Contacts.
  Future<void> seedSamplesIfFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_seededKey) ?? false) return;
    await prefs.setBool(_seededKey, true);
    if (prefs.containsKey(_listKey)) return;

    await save(const [
      Favourite(id: 'sample-1', name: 'Anne (Sample)', phone: '+1 555 010 0101', isSample: true),
      Favourite(id: 'sample-2', name: 'Tom (Sample)', phone: '+1 555 010 0102', isSample: true),
      Favourite(id: 'sample-3', name: 'Doctor (Sample)', phone: '+1 555 010 0103', isSample: true),
    ]);
  }

  /// Writes photo bytes into the app's private documents folder.
  /// A fresh file name is used each time so the image cache never shows stale photos.
  Future<String> savePhoto(Uint8List bytes) async {
    final dir = await _photosDir();
    final file = File(p.join(dir.path, 'photo_${DateTime.now().microsecondsSinceEpoch}.jpg'));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<void> deletePhoto(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Directory> _photosDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'photos'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
