import 'package:flutter/material.dart';

enum RecipeCategory {
  carne('Carnes', Icons.kebab_dining_rounded),
  ave('Aves', Icons.egg_alt_rounded),
  peixe('Peixes', Icons.set_meal_rounded),
  vegetariana('Vegetarianas', Icons.eco_rounded),
  massa('Massas', Icons.dinner_dining_rounded),
  salada('Saladas', Icons.grass_rounded),
  sopa('Sopas', Icons.soup_kitchen_rounded),
  sobremesa('Sobremesas', Icons.icecream_rounded),
  bolo('Bolos', Icons.cake_rounded),
  salgado('Salgados', Icons.bakery_dining_rounded),
  lanche('Lanches', Icons.lunch_dining_rounded),
  bebida('Bebidas', Icons.local_bar_rounded),
  cafeDaManha('Café da manhã', Icons.free_breakfast_rounded),
  outro('Outros', Icons.restaurant_rounded);

  const RecipeCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  /// Nomes antigos (versão anterior do app) são convertidos aqui.
  static const _legacy = {'doce': sobremesa, 'prato': outro};

  static RecipeCategory fromName(String? name) =>
      _legacy[name] ??
      RecipeCategory.values.firstWhere(
        (c) => c.name == name,
        orElse: () => RecipeCategory.outro,
      );
}

enum Difficulty {
  facil('Fácil'),
  medio('Médio'),
  dificil('Difícil');

  const Difficulty(this.label);

  final String label;

  static Difficulty fromName(String? name) => Difficulty.values.firstWhere(
    (d) => d.name == name,
    orElse: () => Difficulty.facil,
  );
}

class Recipe {
  Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.ingredients,
    required this.steps,
    this.difficulty = Difficulty.facil,
    this.prepMinutes,
    this.servings,
    this.notes = '',
    this.photoId,
    this.legacyImagePath,
    this.favorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final RecipeCategory category;
  final List<String> ingredients;
  final List<String> steps;
  final Difficulty difficulty;
  final int? prepMinutes;
  final int? servings;
  final String notes;

  /// Foto salva na nuvem (users/{uid}/photos/{photoId}); null = sem foto.
  final String? photoId;

  /// Caminho da foto local das versões antigas (só para migrar).
  final String? legacyImagePath;
  final bool favorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Ex: "30 min • Fácil"
  String get summary => [
    if (prepMinutes != null) '$prepMinutes min',
    difficulty.label,
  ].join(' • ');

  Recipe copyWith({bool? favorite, String? photoId}) {
    return Recipe(
      id: id,
      title: title,
      category: category,
      ingredients: ingredients,
      steps: steps,
      difficulty: difficulty,
      prepMinutes: prepMinutes,
      servings: servings,
      notes: notes,
      photoId: photoId ?? this.photoId,
      favorite: favorite ?? this.favorite,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Verifica se a receita corresponde ao termo de busca
  /// (título, ingredientes, observações ou categoria).
  bool matches(String query) {
    final q = normalizeText(query);
    if (q.isEmpty) return true;
    return normalizeText(title).contains(q) ||
        normalizeText(category.label).contains(q) ||
        normalizeText(notes).contains(q) ||
        ingredients.any((i) => normalizeText(i).contains(q));
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category.name,
    'ingredients': ingredients,
    'steps': steps,
    'difficulty': difficulty.name,
    'prepMinutes': prepMinutes,
    'servings': servings,
    'notes': notes,
    'photoId': photoId,
    'favorite': favorite,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    category: RecipeCategory.fromName(json['category'] as String?),
    ingredients: List<String>.from(json['ingredients'] as List? ?? []),
    steps: List<String>.from(json['steps'] as List? ?? []),
    difficulty: Difficulty.fromName(json['difficulty'] as String?),
    prepMinutes: json['prepMinutes'] as int?,
    servings: json['servings'] as int?,
    notes: json['notes'] as String? ?? '',
    photoId: json['photoId'] as String?,
    legacyImagePath: json['imagePath'] as String?,
    favorite: json['favorite'] as bool? ?? false,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

/// Remove acentos e deixa minúsculo para a busca ignorar "é", "ç" etc.
String normalizeText(String s) {
  const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const to = 'aaaaaeeeeiiiiooooouuuucn';
  final lower = s.toLowerCase().trim();
  final buffer = StringBuffer();
  for (final ch in lower.split('')) {
    final i = from.indexOf(ch);
    buffer.write(i >= 0 ? to[i] : ch);
  }
  return buffer.toString();
}
