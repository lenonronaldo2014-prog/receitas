import 'dart:convert';

import 'package:archive/archive.dart';

import '../models/recipe.dart';
import '../providers/recipe_store.dart';

/// Converte uma receita em um código de texto (e vice-versa) para
/// compartilhar entre aparelhos sem precisar de servidor.
///
/// Formato: `RDA1-` + base64url(gzip(json)). A foto não vai no código.
abstract final class RecipeShare {
  static const _prefix = 'RDA1-';
  static final _codePattern = RegExp(r'RDA1-[A-Za-z0-9_\-]+');

  static String encode(Recipe r) {
    final data = <String, Object?>{
      't': r.title,
      'c': r.category.name,
      'd': r.difficulty.name,
      'p': r.prepMinutes,
      's': r.servings,
      'i': r.ingredients,
      'm': r.steps,
      if (r.notes.isNotEmpty) 'n': r.notes,
    }..removeWhere((_, v) => v == null);
    final zipped = GZipEncoder().encodeBytes(utf8.encode(jsonEncode(data)));
    return _prefix + base64Url.encode(zipped).replaceAll('=', '');
  }

  /// Mensagem pronta para enviar pelo WhatsApp etc.
  static String message(Recipe r) =>
      '🍽️ Receita "${r.title}" — Receitas da Anna\n\n'
      'Para adicionar: abra o app, toque em + → "Adicionar por código" '
      'e cole esta mensagem.\n\n${encode(r)}';

  /// Lê o código (pode ser a mensagem inteira colada). Retorna null se inválido.
  static Recipe? decode(String input) {
    final match = _codePattern.firstMatch(input.replaceAll(RegExp(r'\s'), ''));
    if (match == null) return null;
    try {
      var b64 = match.group(0)!.substring(_prefix.length);
      b64 = b64.padRight((b64.length + 3) ~/ 4 * 4, '=');
      final json = utf8.decode(
        GZipDecoder().decodeBytes(base64Url.decode(b64)),
      );
      final d = jsonDecode(json) as Map<String, dynamic>;
      final title = (d['t'] as String? ?? '').trim();
      if (title.isEmpty) return null;
      final now = DateTime.now();
      return Recipe(
        id: RecipeStore.newId(),
        title: title,
        category: RecipeCategory.fromName(d['c'] as String?),
        difficulty: Difficulty.fromName(d['d'] as String?),
        prepMinutes: d['p'] as int?,
        servings: d['s'] as int?,
        ingredients: List<String>.from(d['i'] as List? ?? []),
        steps: List<String>.from(d['m'] as List? ?? []),
        notes: d['n'] as String? ?? '',
        createdAt: now,
        updatedAt: now,
      );
    } catch (_) {
      return null;
    }
  }
}
