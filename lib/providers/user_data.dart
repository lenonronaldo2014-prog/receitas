import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/image_storage.dart';

/// Dados do perfil e buscas recentes.
class UserData extends ChangeNotifier {
  static const _nameKey = 'profile_name';
  static const _emailKey = 'profile_email';
  static const _photoKey = 'profile_photo';
  static const _searchKey = 'recent_searches';
  static const _maxRecent = 8;

  String _name = '';
  String _email = '';
  String? _photoPath;
  List<String> _recentSearches = [];

  String get name => _name;
  String get email => _email;
  String? get photoPath => _photoPath;
  String get firstName => _name.trim().split(' ').first;
  List<String> get recentSearches => List.unmodifiable(_recentSearches);

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _name = p.getString(_nameKey) ?? '';
    _email = p.getString(_emailKey) ?? '';
    _photoPath = p.getString(_photoKey);
    _recentSearches = p.getStringList(_searchKey) ?? [];
    // Limpa dados da antiga lista de compras (removida na versão 1.0.2).
    await p.remove('shopping_list');
    await p.remove('shopping_list_done');
    notifyListeners();
  }

  Future<void> setProfile(String name, String email) async {
    _name = name.trim();
    _email = email.trim();
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_nameKey, _name);
    await p.setString(_emailKey, _email);
  }

  /// Troca a foto de perfil ([file] null remove a foto).
  Future<void> setPhoto(XFile? file) async {
    final newPath = file == null
        ? null
        : await ImageStorage.save(file, folder: 'profile');
    await ImageStorage.delete(_photoPath);
    _photoPath = newPath;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    if (newPath == null) {
      await p.remove(_photoKey);
    } else {
      await p.setString(_photoKey, newPath);
    }
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
