import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/image_storage.dart';
import '../services/user_cloud.dart';

/// Perfil (nome e foto, salvos na conta) e buscas recentes (só no aparelho).
class UserData extends ChangeNotifier {
  // Versões antigas guardavam o perfil só no aparelho.
  static const _legacyNameKey = 'profile_name';
  static const _legacyPhotoKey = 'profile_photo';
  static const _searchKey = 'recent_searches';
  static const _maxRecent = 8;

  /// Foto de perfil: pequena, cabe no documento do usuário.
  static const maxPhotoBytes = 300 * 1024;

  String _name = '';
  String _email = '';
  Uint8List? _photo;
  List<String> _recentSearches = [];
  UserCloud? _cloud;
  StreamSubscription<Map<String, dynamic>>? _sub;

  String get name => _name;
  String get email => _email;
  Uint8List? get photo => _photo;
  String get firstName => _name.trim().split(' ').first;
  List<String> get recentSearches => List.unmodifiable(_recentSearches);

  /// Carrega o que é só do aparelho (buscas recentes).
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _recentSearches = p.getStringList(_searchKey) ?? [];
    // Limpa dados da antiga lista de compras (removida na versão 1.0.2).
    await p.remove('shopping_list');
    await p.remove('shopping_list_done');
    notifyListeners();
  }

  /// Conecta à conta. [displayName] vem do login (ex.: nome da conta Google).
  Future<void> attach(
    UserCloud cloud, {
    required String email,
    String? displayName,
  }) async {
    await detach();
    _cloud = cloud;
    _email = email;
    _name = displayName ?? '';
    var first = true;
    _sub = cloud.profile().listen((data) {
      final name = data['name'] as String?;
      if (name != null && name.isNotEmpty) _name = name;
      final photo = data['photo'] as String?;
      _photo = photo == null ? null : base64Decode(photo);
      notifyListeners();
      if (first) {
        first = false;
        _migrateLegacy(data, displayName);
      }
    });
  }

  Future<void> detach() async {
    await _sub?.cancel();
    _sub = null;
    _cloud = null;
    _name = '';
    _email = '';
    _photo = null;
    notifyListeners();
  }

  /// Na primeira vez: leva o nome/foto do perfil local antigo para a conta.
  Future<void> _migrateLegacy(
    Map<String, dynamic> data,
    String? fallback,
  ) async {
    final p = await SharedPreferences.getInstance();
    final update = <String, dynamic>{};
    if ((data['name'] as String?)?.isNotEmpty != true) {
      final legacy = p.getString(_legacyNameKey);
      final name = (legacy?.isNotEmpty == true ? legacy : fallback) ?? '';
      if (name.isNotEmpty) update['name'] = name;
    }
    final legacyPhoto = p.getString(_legacyPhotoKey);
    if (data['photo'] == null && legacyPhoto != null) {
      final bytes = await ImageStorage.readPath(legacyPhoto);
      if (bytes != null && bytes.length <= maxPhotoBytes) {
        update['photo'] = base64Encode(bytes);
      }
    }
    if (update.isNotEmpty) await setProfileData(update);
    await p.remove(_legacyNameKey);
    await p.remove(_legacyPhotoKey);
    await p.remove('profile_email');
  }

  Future<void> setName(String name) => setProfileData({'name': name.trim()});

  /// Troca a foto de perfil ([bytes] null remove a foto).
  Future<void> setPhoto(Uint8List? bytes) {
    if (bytes != null && bytes.length > maxPhotoBytes) {
      throw const FormatException('Foto muito grande');
    }
    return setProfileData({
      'photo': bytes == null ? null : base64Encode(bytes),
    });
  }

  Future<void> setProfileData(Map<String, dynamic> data) async {
    if (data.containsKey('name')) _name = data['name'] as String;
    if (data.containsKey('photo')) {
      final photo = data['photo'] as String?;
      _photo = photo == null ? null : base64Decode(photo);
    }
    notifyListeners();
    final cloud = _cloud;
    if (cloud == null) return;
    cloud
        .saveProfile(data)
        .catchError((Object e) => debugPrint('Falha ao salvar perfil: $e'));
  }

  Future<void> addSearch(String term) async {
    final t = term.trim();
    if (t.isEmpty) return;
    _recentSearches
      ..removeWhere((s) => s.toLowerCase() == t.toLowerCase())
      ..insert(0, t);
    if (_recentSearches.length > _maxRecent) {
      _recentSearches = _recentSearches.sublist(0, _maxRecent);
    }
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_searchKey, _recentSearches);
  }

  Future<void> clearSearches() async {
    _recentSearches = [];
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.remove(_searchKey);
  }
}
