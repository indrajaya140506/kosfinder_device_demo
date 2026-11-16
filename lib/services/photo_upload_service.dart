import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../cloud_config.dart';

class PhotoUploadResult {
  const PhotoUploadResult(this.storagePath, this.publicUrl);

  final String storagePath;
  final String publicUrl;
}

/// Layanan upload foto ke Supabase Storage.
class PhotoUploadService {
  Future<PhotoUploadResult> upload(Uint8List photo, String fileName) async {
    if (!CloudConfig.enabled) {
      throw StateError(
        'Supabase belum dikonfigurasi. Gunakan Simpan Draft Lokal.',
      );
    }

    final client = Supabase.instance.client;

    // Membuat sesi anonymous jika belum ada.
    if (client.auth.currentUser == null) {
      await client.auth.signInAnonymously();
    }

    final userId = client.auth.currentUser?.id;

    if (userId == null) {
      throw StateError('Sesi anonymous Supabase tidak berhasil dibuat.');
    }

    final ext = fileName.split('.').last.toLowerCase();

    if (!{'jpg', 'jpeg', 'png'}.contains(ext)) {
      throw const FormatException('Format foto tidak didukung.');
    }

    if (photo.length > 5 * 1024 * 1024) {
      throw const FormatException('Ukuran foto maksimal 5 MB.');
    }

    // Upload hanya ke folder milik pengguna sendiri.
    final objectPath = '$userId/${DateTime.now().microsecondsSinceEpoch}.$ext';

    final returnedPath = await client.storage
        .from('kosfinder-demo')
        .uploadBinary(
          objectPath,
          photo,
          fileOptions: FileOptions(
            upsert: false,
            contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
          ),
        );

    final publicUrl = client.storage
        .from('kosfinder-demo')
        .getPublicUrl(returnedPath);

    return PhotoUploadResult(returnedPath, publicUrl);
  }
}
