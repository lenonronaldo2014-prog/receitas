import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';
import '../services/image_storage.dart';

/// Guarda as receitas localmente no aparelho (shared_preferences, em JSON).
/// As fotos ficam como arquivos na pasta de documentos do app.
class RecipeStore extends ChangeNotifier {
  static const _key = 'recipes';

  final List<Recipe> _recipes = [];
  bool _loaded = false;

  bool get loaded => _loaded;

  /// Favoritas primeiro, depois as mais recentes.
  List<Recipe> get recipes {
    final list = [..._recipes];
    list.sort((a, b) {
      if (a.favorite != b.favorite) return a.favorite ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return list;
  }

  List<Recipe> get recent =>
      [..._recipes]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<Recipe> get favorites => recent.where((r) => r.favorite).toList();

  /// Receita em destaque: a favorita mais recente ou, se não houver, a última.
  Recipe? get featured {
    if (_recipes.isEmpty) return null;
    final favs = favorites;
    return favs.isNotEmpty ? favs.first : recent.first;
  }

  int countIn(RecipeCategory c) =>
      _recipes.where((r) => r.category == c).length;

  Recipe? byId(String id) {
    for (final r in _recipes) {
      if (r.id == id) return r;
    }
    return null;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    _recipes.clear();
    if (raw != null) {
      final data = jsonDecode(raw) as List;
      _recipes.addAll(
        data.map((e) => Recipe.fromJson(e as Map<String, dynamic>)),
      );
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_recipes.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> upsert(Recipe recipe) async {
    final i = _recipes.indexWhere((r) => r.id == recipe.id);
    if (i >= 0) {
      final old = _recipes[i].imagePath;
      if (old != recipe.imagePath) await ImageStorage.delete(old);
      _recipes[i] = recipe;
    } else {
      _recipes.add(recipe);
    }
    notifyListeners();
    await _save();
  }

  Future<void> delete(String id) async {
    final r = byId(id);
    await ImageStorage.delete(r?.imagePath);
    _recipes.removeWhere((r) => r.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> toggleFavorite(String id) async {
    final i = _recipes.indexWhere((r) => r.id == id);
    if (i < 0) return;
    _recipes[i] = _recipes[i].copyWith(favorite: !_recipes[i].favorite);
    notifyListeners();
    await _save();
  }

  static String newId() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(36);
}
