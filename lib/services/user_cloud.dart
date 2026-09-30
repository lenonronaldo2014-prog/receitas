import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/recipe.dart';

/// Onde ficam os dados de uma conta: receitas, fotos e perfil.
///
/// As gravações não são aguardadas pela interface: sem internet o Firestore
/// guarda no aparelho e envia quando a conexão voltar.
abstract class UserCloud {
  Stream<List<Recipe>> recipes();
  Future<void> saveRecipe(Recipe recipe);
  Future<void> deleteRecipe(String id);

  /// Foto em base64 (fotos pequenas cabem num documento do Firestore).
  Future<String?> photo(String photoId);
  Future<void> savePhoto(String photoId, String base64);
  Future<void> deletePhoto(String photoId);

  Stream<Map<String, dynamic>> profile();
  Future<void> saveProfile(Map<String, dynamic> data);
}

/// Dados na nuvem: `users/{uid}/recipes`, `users/{uid}/photos` e `users/{uid}`.
class FirestoreUserCloud implements UserCloud {
  FirestoreUserCloud(this.uid, {FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  final String uid;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> get _user =>
      _db.collection('users').doc(uid);
  CollectionReference<Map<String, dynamic>> get _recipes =>
      _user.collection('recipes');
  CollectionReference<Map<String, dynamic>> get _photos =>
      _user.collection('photos');

  @override
  Stream<List<Recipe>> recipes() => _recipes.snapshots().map(
    (s) => [
      for (final d in s.docs) Recipe.fromJson({...d.data(), 'id': d.id}),
    ],
  );

  @override
  Future<void> saveRecipe(Recipe recipe) =>
      _recipes.doc(recipe.id).set(recipe.toJson());

  @override
  Future<void> deleteRecipe(String id) => _recipes.doc(id).delete();

  @override
  Future<String?> photo(String photoId) async {
    final doc = await _photos.doc(photoId).get();
    return doc.data()?['data'] as String?;
  }

  @override
  Future<void> savePhoto(String photoId, String base64) =>
      _photos.doc(photoId).set({'data': base64});

  @override
  Future<void> deletePhoto(String photoId) => _photos.doc(photoId).delete();

  @override
  Stream<Map<String, dynamic>> profile() =>
      _user.snapshots().map((d) => d.data() ?? const {});

  @override
  Future<void> saveProfile(Map<String, dynamic> data) =>
      _user.set(data, SetOptions(merge: true));
}

/// Versão em memória (testes).
class MemoryUserCloud implements UserCloud {
  final _recipes = <String, Recipe>{};
  final _photos = <String, String>{};
  final _profile = <String, dynamic>{};
  final _recipesCtrl = StreamController<List<Recipe>>.broadcast();
  final _profileCtrl = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<List<Recipe>> recipes() async* {
    yield _recipes.values.toList();
    yield* _recipesCtrl.stream;
  }

  void _emit() => _recipesCtrl.add(_recipes.values.toList());

  @override
  Future<void> saveRecipe(Recipe recipe) async {
    _recipes[recipe.id] = recipe;
    _emit();
  }

  @override
  Future<void> deleteRecipe(String id) async {
    _recipes.remove(id);
    _emit();
  }

  @override
  Future<String?> photo(String photoId) async => _photos[photoId];

  @override
  Future<void> savePhoto(String photoId, String base64) async =>
      _photos[photoId] = base64;

  @override
  Future<void> deletePhoto(String photoId) async => _photos.remove(photoId);

  @override
  Stream<Map<String, dynamic>> profile() async* {
    yield Map.of(_profile);
    yield* _profileCtrl.stream;
  }

  @override
  Future<void> saveProfile(Map<String, dynamic> data) async {
    data.forEach((k, v) => v == null ? _profile.remove(k) : _profile[k] = v);
    _profileCtrl.add(Map.of(_profile));
  }

  @visibleForTesting
  Map<String, String> get photos => _photos;
}
