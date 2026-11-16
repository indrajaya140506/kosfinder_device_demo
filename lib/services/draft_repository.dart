import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan satu draft lokal pada perangkat atau browser.
class DraftRepository {
  static const _draftKey = 'kosfinder_device_demo_draft_v1';

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  Future<Map<String, dynamic>> load() async {
    final raw = await _prefs.getString(_draftKey);

    if (raw == null) return {};

    final decoded = jsonDecode(raw);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {};
  }

  Future<void> save(Map<String, dynamic> draft) async {
    await _prefs.setString(_draftKey, jsonEncode(draft));
  }

  /// Membaca foto sebagai Base64 agar dapat digunakan di Web dan Android.
  Future<String> savePermanentPhoto(XFile selected) async {
    final ext = selected.name.split('.').last.toLowerCase();

    if (!{'jpg', 'jpeg', 'png'}.contains(ext)) {
      throw const FormatException('Foto harus berupa JPG/JPEG/PNG.');
    }

    final bytes = await selected.readAsBytes();

    if (bytes.length > 5 * 1024 * 1024) {
      throw const FormatException('Ukuran foto maksimal 5 MB.');
    }

    return base64Encode(bytes);
  }
}
