import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dados do perfil, buscas recentes e lista de compras.
class UserData extends ChangeNotifier {
  static const _nameKey = 'profile_name';
  static const _emailKey = 'profile_email';
  static const _searchKey = 'recent_searches';
  static const _shoppingKey = 'shopping_list';
  static const _shoppingDoneKey = 'shopping_list_done';
  static const _maxRecent = 8;

  String _name = '';
  String _email = '';
  List<String> _recentSearches = [];
  List<String> _shopping = [];
  Set<String> _shoppingDone = {};

  String get name => _name;
  String get email => _email;
  String get firstName => _name.trim().split(' ').first;
  List<String> get recentSearches => List.unmodifiable(_recentSearches);
  List<String> get shopping => List.unmodifiable(_shopping);
  bool isBought(String item) => _shoppingDone.contains(item);

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _name = p.getString(_nameKey) ?? '';
    _email = p.getString(_emailKey) ?? '';
    _recentSearches = p.getStringList(_searchKey) ?? [];
    _shopping = p.getStringList(_shoppingKey) ?? [];
    _shoppingDone = (p.getStringList(_shoppingDoneKey) ?? []).toSet();
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

  /// Adiciona itens à lista de compras (ignora os que já estão lá).
  Future<int> addToShopping(Iterable<String> items) async {
    var added = 0;
    for (final item in items.map((e) => e.trim())) {
      if (item.isEmpty || _shopping.contains(item)) continue;
      _shopping.add(item);
      added++;
    }
    await _saveShopping();
    return added;
  }

  Future<void> toggleBought(String item) async {
    if (!_shoppingDone.remove(item)) _shoppingDone.add(item);
    await _saveShopping();
  }

  Future<void> removeShopping(String item) async {
    _shopping.remove(item);
    _shoppingDone.remove(item);
    await _saveShopping();
  }

  Future<void> clearBought() async {
    _shopping.removeWhere(_shoppingDone.contains);
    _shoppingDone.clear();
    await _saveShopping();
  }

  Future<void> _saveShopping() async {
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_shoppingKey, _shopping);
    await p.setStringList(_shoppingDoneKey, _shoppingDone.toList());
  }
}
