import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';
import '../services/image_storage.dart';
import '../services/user_cloud.dart';

/// Receitas da conta conectada, sincronizadas com a nuvem ([UserCloud]).
class RecipeStore extends ChangeNotifier {
  /// Onde as versões antigas (sem conta) guardavam as receitas.
  static const _legacyKey = 'recipes';
  static const _legacyBackupKey = 'recipes_backup_local';

  /// Limite de uma foto (o documento do Firestore aceita até 1 MB).
  static const maxPhotoBytes = 700 * 1024;

  final List<Recipe> _recipes = [];
  UserCloud? _cloud;
  StreamSubscription<List<Recipe>>? _sub;
  bool _loaded = false;
  final _photoFutures = <String, Future<File?>>{};

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

  /// Conecta à conta: passa a receber as receitas dela.
  Future<void> attach(UserCloud cloud) async {
    await detach();
    _cloud = cloud;
    await _migrateLegacy(cloud);
    _sub = cloud.recipes().listen((list) {
      _recipes
        ..clear()
        ..addAll(list);
      _loaded = true;
      notifyListeners();
    });
  }

  /// Desconecta (ao sair da conta).
  Future<void> detach() async {
    await _sub?.cancel();
    _sub = null;
    _cloud = null;
    _recipes.clear();
    _photoFutures.clear();
    _loaded = false;
    notifyListeners();
  }

  UserCloud get _c {
    final c = _cloud;
    if (c == null) throw StateError('RecipeStore sem conta conectada');
    return c;
  }

  Future<void> upsert(Recipe recipe) async {
    final old = byId(recipe.id);
    final i = _recipes.indexWhere((r) => r.id == recipe.id);
    if (i >= 0) {
      _recipes[i] = recipe;
    } else {
      _recipes.add(recipe);
    }
    notifyListeners();
    _fireAndForget(_c.saveRecipe(recipe));
    if (old?.photoId != null && old!.photoId != recipe.photoId) {
      _removePhoto(old.photoId!);
    }
  }

  Future<void> delete(String id) async {
    final r = byId(id);
    _recipes.removeWhere((r) => r.id == id);
    notifyListeners();
    _fireAndForget(_c.deleteRecipe(id));
    if (r?.photoId != null) _removePhoto(r!.photoId!);
  }

  Future<void> toggleFavorite(String id) async {
    final r = byId(id);
    if (r == null) return;
    await upsert(r.copyWith(favorite: !r.favorite));
  }

  /// Guarda uma foto nova (no aparelho e na nuvem) e devolve o id dela.
  Future<String> savePhoto(Uint8List bytes) async {
    if (bytes.length > maxPhotoBytes) throw const PhotoTooLargeException();
    final id = newId();
    final f = await ImageStorage.write(id, bytes);
    if (f != null) _photoFutures[id] = Future.value(f);
    _fireAndForget(_c.savePhoto(id, base64Encode(bytes)));
    return id;
  }

  /// Arquivo local da foto; baixa da nuvem na primeira vez.
  Future<File?> photoFile(String photoId) =>
      _photoFutures[photoId] ??= _loadPhoto(photoId);

  Future<File?> _loadPhoto(String photoId) async {
    final cached = await ImageStorage.cached(photoId);
    if (cached != null) return cached;
    final cloud = _cloud;
    if (cloud == null) return null;
    try {
      final data = await cloud.photo(photoId);
      if (data == null) return null;
      return ImageStorage.write(photoId, base64Decode(data));
    } catch (_) {
      _photoFutures.remove(photoId); // tenta de novo depois (ex.: sem internet)
      return null;
    }
  }

  void _removePhoto(String photoId) {
    _photoFutures.remove(photoId);
    ImageStorage.delete(photoId);
    _fireAndForget(_c.deletePhoto(photoId));
  }

  /// Sobe para a conta as receitas salvas só no aparelho (versões antigas).
  Future<void> _migrateLegacy(UserCloud cloud) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_legacyKey);
    if (raw == null) return;
    final list = [
      for (final e in jsonDecode(raw) as List)
        Recipe.fromJson(e as Map<String, dynamic>),
    ];
    for (var r in list) {
      final path = r.legacyImagePath;
      if (path != null) {
        final bytes = await ImageStorage.readPath(path);
        if (bytes != null && bytes.length <= maxPhotoBytes) {
          final id = newId();
          await ImageStorage.write(id, bytes);
          _fireAndForget(cloud.savePhoto(id, base64Encode(bytes)));
          r = r.copyWith(photoId: id);
        }
      }
      _fireAndForget(cloud.saveRecipe(r));
    }
    // Guarda uma cópia de segurança e não migra de novo.
    await prefs.setString(_legacyBackupKey, raw);
    await prefs.remove(_legacyKey);
  }

  static void _fireAndForget(Future<void> f) =>
      f.catchError((Object e) => debugPrint('Falha ao sincronizar: $e'));

  static int _seq = 0;

  /// Id único (tempo + contador, para ids criados no mesmo instante).
  static String newId() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(36) +
      (_seq++ % 1296).toRadixString(36).padLeft(2, '0');
}

class PhotoTooLargeException implements Exception {
  const PhotoTooLargeException();
}
