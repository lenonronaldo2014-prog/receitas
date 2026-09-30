import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// Consulta a última versão publicada nas Releases do GitHub.
abstract final class UpdateService {
  static const repo = 'lenonronaldo2014-prog/receitas';
  static const repoUrl = 'https://github.com/$repo';

  static Future<String> currentVersion() async =>
      (await PackageInfo.fromPlatform()).version;

  /// Retorna a atualização disponível, ou null se o app já está na última.
  /// Lança [UpdateException] se não conseguir consultar.
  static Future<AppUpdate?> check() async {
    final http.Response res;
    try {
      res = await http
          .get(
            Uri.parse('https://api.github.com/repos/$repo/releases/latest'),
            headers: {'Accept': 'application/vnd.github+json'},
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw const UpdateException('Sem conexão com a internet.');
    }
    if (res.statusCode == 404) return null; // nenhuma versão publicada ainda
    if (res.statusCode != 200) {
      throw UpdateException('GitHub respondeu ${res.statusCode}.');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final latest = (data['tag_name'] as String? ?? '').replaceFirst(
      RegExp('^v'),
      '',
    );
    final current = await currentVersion();
    if (!isNewer(latest, current)) return null;

    String? apkUrl;
    for (final a in (data['assets'] as List? ?? const [])) {
      final name = (a['name'] as String? ?? '').toLowerCase();
      if (name.endsWith('.apk')) {
        apkUrl = a['browser_download_url'] as String?;
        break;
      }
    }
    final isAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

    return AppUpdate(
      version: latest,
      notes: (data['body'] as String? ?? '').trim(),
      downloadUrl: (isAndroid ? apkUrl : null) ?? data['html_url'] as String,
    );
  }

  /// Compara versões no formato 1.2.3.
  static bool isNewer(String latest, String current) {
    List<int> parts(String v) =>
        v.split('+').first.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final a = parts(latest), b = parts(current);
    for (var i = 0; i < 3; i++) {
      final x = i < a.length ? a[i] : 0;
      final y = i < b.length ? b[i] : 0;
      if (x != y) return x > y;
    }
    return false;
  }
}

class AppUpdate {
  const AppUpdate({
    required this.version,
    required this.notes,
    required this.downloadUrl,
  });

  final String version;
  final String notes;
  final String downloadUrl;
}

class UpdateException implements Exception {
  const UpdateException(this.message);

  final String message;
}
