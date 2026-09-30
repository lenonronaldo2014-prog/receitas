import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Cópia local das fotos das receitas (`<documentos>/photos/<photoId>.jpg`),
/// para não baixar da nuvem toda vez.
abstract final class ImageStorage {
  static Future<File> file(String photoId) async {
    final dir = await getApplicationDocumentsDirectory();
    final sep = Platform.pathSeparator;
    return File('${dir.path}${sep}photos$sep$photoId.jpg');
  }

  static Future<File?> cached(String photoId) async {
    if (kIsWeb) return null;
    final f = await file(photoId);
    return await f.exists() ? f : null;
  }

  static Future<File?> write(String photoId, Uint8List bytes) async {
    if (kIsWeb) return null;
    final f = await file(photoId);
    await f.parent.create(recursive: true);
    return f.writeAsBytes(bytes, flush: true);
  }

  static Future<void> delete(String photoId) async {
    if (kIsWeb) return;
    await deletePath((await file(photoId)).path);
  }

  static Future<void> deletePath(String? path) async {
    if (path == null || kIsWeb) return;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  /// Lê uma foto das versões antigas (caminho local).
  static Future<Uint8List?> readPath(String path) async {
    if (kIsWeb) return null;
    try {
      final f = File(path);
      return await f.exists() ? await f.readAsBytes() : null;
    } catch (_) {
      return null;
    }
  }
}
