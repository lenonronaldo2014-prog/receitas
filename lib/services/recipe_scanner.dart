import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../models/recipe.dart';
import '../providers/recipe_store.dart';

/// Lê fotos de uma receita (livro, caderno, print...) e devolve os campos
/// separados. A receita volta como rascunho: a pessoa confere antes de salvar.
abstract class RecipeScanner {
  Future<Recipe> scan(List<Uint8List> images);
}

class ScanException implements Exception {
  const ScanException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Usa o Gemini pelo Firebase AI Logic (sem chave de API dentro do app).
class GeminiRecipeScanner implements RecipeScanner {
  static const _modelName = 'gemini-3.5-flash';

  static final _schema = Schema.object(
    properties: {
      'encontrou': Schema.boolean(
        description: 'false se as fotos não mostram uma receita culinária',
      ),
      'titulo': Schema.string(description: 'Nome da receita'),
      'categoria': Schema.enumString(
        enumValues: [for (final c in RecipeCategory.values) c.name],
        description: _categoryHelp,
      ),
      'dificuldade': Schema.enumString(
        enumValues: [for (final d in Difficulty.values) d.name],
      ),
      'tempoMinutos': Schema.integer(
        nullable: true,
        description: 'Tempo total de preparo em minutos, se informado',
      ),
      'porcoes': Schema.integer(
        nullable: true,
        description: 'Quantas porções/pessoas rende, se informado',
      ),
      'ingredientes': Schema.array(
        items: Schema.string(),
        description: 'Um ingrediente por item, com a quantidade',
      ),
      'passos': Schema.array(
        items: Schema.string(),
        description: 'Modo de preparo: um passo por item, sem numeração',
      ),
      'observacoes': Schema.string(
        description: 'Dicas, variações ou observações; vazio se não houver',
      ),
    },
    optionalProperties: ['tempoMinutos', 'porcoes'],
  );

  static final _categoryHelp = [
    for (final c in RecipeCategory.values) '${c.name} = ${c.label}',
  ].join(', ');

  static const _instructions = '''
Você recebe uma ou mais fotos de UMA receita culinária (página de livro,
caderno escrito à mão, print de site ou rede social). Extraia a receita em
português do Brasil.

Regras:
- Transcreva fielmente; não invente ingredientes nem passos.
- Mantenha as quantidades como escritas (ex.: "2 xícaras de farinha de trigo").
- Se houver mais de uma foto, são partes da mesma receita: junte na ordem.
- Corrija só erros óbvios de leitura e de digitação.
- Se a receita tiver partes (massa, recheio, cobertura), mantenha a parte no
  início do item, ex.: "Recheio: 1 lata de leite condensado".
- Escolha a categoria e a dificuldade que melhor combinam com a receita.
- Tempo e porções: apenas se estiverem na receita; caso contrário, omita.
- Se as fotos não mostram uma receita, responda encontrou = false.''';

  late final _gemini = FirebaseAI.googleAI().generativeModel(
    model: _modelName,
    systemInstruction: Content.system(_instructions),
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: _schema,
    ),
  );

  @override
  Future<Recipe> scan(List<Uint8List> images) async {
    if (images.isEmpty) {
      throw const ScanException('Escolha pelo menos uma foto.');
    }
    final GenerateContentResponse response;
    try {
      response = await _gemini
          .generateContent([
            Content.multi([
              for (final img in images) InlineDataPart('image/jpeg', img),
              TextPart('Extraia a receita destas fotos.'),
            ]),
          ])
          .timeout(const Duration(seconds: 90));
    } on QuotaExceeded {
      throw const ScanException(
        'Limite de leituras atingido por agora. Tente de novo mais tarde.',
      );
    } on ServiceApiNotEnabled {
      throw const ScanException(
        'A leitura por foto ainda não foi ativada no Firebase (AI Logic).',
      );
    } on FirebaseAIException catch (e) {
      debugPrint('Gemini: $e');
      throw const ScanException('Não foi possível ler a foto. Tente de novo.');
    } catch (e) {
      debugPrint('Gemini: $e');
      throw const ScanException(
        'Não foi possível ler a foto. Confira sua internet e tente de novo.',
      );
    }
    final text = response.text;
    if (text == null || text.isEmpty) {
      throw const ScanException('Não consegui ler a receita nesta foto.');
    }
    return parse(text);
  }

  /// Converte a resposta JSON do modelo em uma [Recipe] (rascunho).
  @visibleForTesting
  static Recipe parse(String json) {
    final Map<String, dynamic> d;
    try {
      d = jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      throw const ScanException('Não consegui entender a receita da foto.');
    }
    List<String> list(String key) => [
      for (final v in (d[key] as List? ?? const []))
        if (v is String && v.trim().isNotEmpty) v.trim(),
    ];
    final title = (d['titulo'] as String? ?? '').trim();
    final ingredients = list('ingredientes');
    final steps = list('passos');
    if (d['encontrou'] == false ||
        (title.isEmpty && ingredients.isEmpty && steps.isEmpty)) {
      throw const ScanException(
        'Não encontrei uma receita nesta foto. Tente uma foto mais nítida.',
      );
    }
    int? positive(Object? v) => v is num && v > 0 ? v.round() : null;
    final now = DateTime.now();
    return Recipe(
      id: RecipeStore.newId(),
      title: title.isEmpty ? 'Receita sem nome' : title,
      category: RecipeCategory.fromName(d['categoria'] as String?),
      difficulty: Difficulty.fromName(d['dificuldade'] as String?),
      prepMinutes: positive(d['tempoMinutos']),
      servings: positive(d['porcoes']),
      ingredients: ingredients,
      steps: steps,
      notes: (d['observacoes'] as String? ?? '').trim(),
      createdAt: now,
      updatedAt: now,
    );
  }
}
