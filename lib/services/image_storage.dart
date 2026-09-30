import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Guarda fotos (receitas, perfil) na pasta de documentos do app.
abstract final class ImageStorage {
  /// Copia a foto escolhida para a pasta do app e devolve o novo caminho.
  static Future<String> save(
    XFile file, {
    String folder = 'recipe_images',
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final sep = Platform.pathSeparator;
    final target = Directory('${dir.path}$sep$folder');
    await target.create(recursive: true);
    final ext = file.path.contains('.') ? file.path.split('.').last : 'jpg';
    final name = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final path = '${target.path}$sep$name.$ext';
    await file.saveTo(path);
    return path;
  }

  static Future<void> delete(String? path) async {
    if (path == null || kIsWeb) return;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}
