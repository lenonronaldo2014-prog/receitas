import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:receitas/main.dart';
import 'package:receitas/models/recipe.dart';
import 'package:receitas/providers/auth_controller.dart';
import 'package:receitas/providers/recipe_store.dart';
import 'package:receitas/providers/theme_controller.dart';
import 'package:receitas/providers/user_data.dart';
import 'package:receitas/screens/recipe_form_screen.dart';
import 'package:receitas/services/recipe_scanner.dart';
import 'package:receitas/services/recipe_share.dart';
import 'package:receitas/services/update_service.dart';
import 'package:receitas/screens/auth_gate.dart';
import 'package:receitas/services/user_cloud.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Login falso: aceita qualquer senha "123456"; dados numa nuvem em memória.
class FakeAuth extends AuthController {
  FakeAuth({AppUser? signedIn}) : _user = signedIn;

  final clouds = <String, MemoryUserCloud>{};
  AppUser? _user;

  @override
  bool get ready => true;

  @override
  AppUser? get user => _user;

  @override
  UserCloud cloudFor(AppUser user) =>
      clouds.putIfAbsent(user.uid, MemoryUserCloud.new);

  @override
  Future<void> signIn(String email, String password) async {
    if (password != '123456') {
      throw const AuthException('E-mail ou senha incorretos.');
    }
    _user = AppUser(uid: email, email: email);
    notifyListeners();
  }

  @override
  Future<void> signUp(String name, String email, String password) async {
    _user = AppUser(uid: email, email: email, displayName: name);
    notifyListeners();
  }

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {
    _user = null;
    notifyListeners();
  }
}

const anna = AppUser(uid: 'anna', email: 'anna@email.com', displayName: 'Anna');

Future<FakeAuth> pumpApp(
  WidgetTester tester, {
  AppUser? signedIn = anna,
}) async {
  // Tela de celular (390x780 lógicos) para testar o layout real.
  tester.view.physicalSize = const Size(1170, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final auth = FakeAuth(signedIn: signedIn);
  final user = UserData();
  await user.load();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider<AuthController>.value(value: auth),
        ChangeNotifierProvider(create: (_) => RecipeStore()),
        ChangeNotifierProvider.value(value: user),
      ],
      child: const ReceitasApp(home: AuthGate()),
    ),
  );
  await tester.pumpAndSettle();
  return auth;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Receitas da Anna',
      packageName: 'com.receitas.receitas',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  test('compara versões para saber se há atualização', () {
    expect(UpdateService.isNewer('1.0.1', '1.0.0'), isTrue);
    expect(UpdateService.isNewer('1.2.0', '1.10.0'), isFalse);
    expect(UpdateService.isNewer('2.0.0', '1.9.9'), isTrue);
    expect(UpdateService.isNewer('1.0.0', '1.0.0+5'), isFalse);
  });

  test('busca ignora acentos e encontra ingredientes', () {
    final r = Recipe(
      id: '1',
      title: 'Bolo de Cenoura',
      category: RecipeCategory.bolo,
      ingredients: ['3 cenouras', '2 xícaras de açúcar'],
      steps: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    expect(r.matches('cenoura'), isTrue);
    expect(r.matches('acucar'), isTrue);
    expect(r.matches('frango'), isFalse);
  });

  test('receitas da versão anterior continuam carregando', () {
    final r = Recipe.fromJson({
      'id': 'x',
      'title': 'Brigadeiro',
      'category': 'doce',
      'ingredients': ['1 lata de leite condensado'],
      'steps': ['Misture tudo'],
    });
    expect(r.category, RecipeCategory.sobremesa);
    expect(r.difficulty, Difficulty.facil);
    expect(r.photoId, isNull);
  });

  test('código de compartilhamento ida e volta', () {
    final original = Recipe(
      id: 'abc',
      title: 'Pão de Queijo',
      category: RecipeCategory.salgado,
      difficulty: Difficulty.medio,
      prepMinutes: 40,
      servings: 20,
      ingredients: ['500g de polvilho', '2 ovos', '200g de queijo'],
      steps: ['Misture tudo', 'Faça bolinhas', 'Asse a 180°C'],
      notes: 'Receita da vovó ❤️',
      photoId: 'foto1',
      favorite: true,
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );
    // Aceita a mensagem inteira, mesmo com quebra de linha no meio do código.
    final msg = RecipeShare.message(original);
    final code = RecipeShare.encode(original);
    final copy = RecipeShare.decode(
      msg.replaceFirst(code, '${code.substring(0, 30)}\n${code.substring(30)}'),
    )!;
    expect(copy.title, 'Pão de Queijo');
    expect(copy.category, RecipeCategory.salgado);
    expect(copy.difficulty, Difficulty.medio);
    expect(copy.prepMinutes, 40);
    expect(copy.servings, 20);
    expect(copy.ingredients, original.ingredients);
    expect(copy.steps, original.steps);
    expect(copy.notes, original.notes);
    expect(copy.id, isNot('abc'));
    expect(copy.favorite, isFalse);
    expect(copy.photoId, isNull);

    expect(RecipeShare.decode('bolo de cenoura'), isNull);
    expect(RecipeShare.decode('RDA1-lixo'), isNull);
  });

  testWidgets('adiciona receita colando o código', (tester) async {
    await pumpApp(tester);
    final code = RecipeShare.encode(
      Recipe(
        id: 'x',
        title: 'Brigadeiro',
        category: RecipeCategory.sobremesa,
        ingredients: ['1 lata de leite condensado'],
        steps: ['Mexa até desgrudar'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    await tester.tap(find.byIcon(Icons.add_rounded).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adicionar por código').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), code);
    await tester.pumpAndSettle();
    expect(find.text('Receita encontrada'), findsOneWidget);

    await tester.tap(find.text('Adicionar receita'));
    await tester.pumpAndSettle();
    expect(find.text('Brigadeiro'), findsOneWidget);
    expect(find.text('Mexa até desgrudar'), findsOneWidget);
  });

  testWidgets('tela inicial vazia mostra saudação e botão de criar', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Olá, Anna!'), findsOneWidget);
    expect(find.text('Nenhuma receita ainda'), findsOneWidget);
    expect(find.text('Criar receita'), findsOneWidget);
  });

  testWidgets('cria uma receita pelo botão + e ela aparece na home', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.add_rounded).last);
    await tester.pumpAndSettle();
    expect(find.text('Adicionar por código'), findsWidgets);
    await tester.tap(find.text('Criar receita').last);
    await tester.pumpAndSettle();
    expect(find.text('Nova Receita'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Coxinha');
    await tester.tap(find.text('Selecione uma categoria'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salgados').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salvar Receita'));
    await tester.pumpAndSettle();

    expect(find.text('Coxinha'), findsWidgets);
    expect(find.text('Destaque'), findsOneWidget);

    // Abre a receita, favorita e entra em editar.
    await tester.tap(find.text('Destaque'));
    await tester.pumpAndSettle();
    expect(find.text('Modo de preparo'), findsOneWidget);
    await tester.tap(find.text('Adicionar aos favoritos'));
    await tester.pumpAndSettle();
    expect(find.text('Remover dos favoritos'), findsOneWidget);

    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    expect(find.text('Editar Receita'), findsOneWidget);
    expect(find.text('Salvar Alterações'), findsOneWidget);
  });

  testWidgets('navega pelas abas', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Categorias'));
    await tester.pumpAndSettle();
    expect(find.text('Carnes'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Café da manhã'), 200);
    expect(find.text('Café da manhã'), findsOneWidget);

    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma favorita ainda'), findsOneWidget);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Lista de Compras'), findsNothing);
    expect(find.text('Buscar atualização'), findsOneWidget);
    expect(find.text('Versão 1.0.0'), findsOneWidget);
  });

  testWidgets('sem conta mostra o login; entrar abre o app', (tester) async {
    await pumpApp(tester, signedIn: null);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Continuar com o Google'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'anna@email.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'errada');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma receita ainda'), findsOneWidget);
  });

  testWidgets('sair da conta volta para o login', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('anna@email.com'), findsOneWidget);

    await tester.tap(find.text('Sair da conta'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sair'));
    await tester.pumpAndSettle();
    expect(find.text('Esqueci minha senha'), findsOneWidget);
  });

  testWidgets('receitas antigas do aparelho sobem para a conta', (
    tester,
  ) async {
    final legacy = Recipe(
      id: 'velha',
      title: 'Pudim da Vovó',
      category: RecipeCategory.sobremesa,
      ingredients: ['leite'],
      steps: ['misture'],
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    );
    SharedPreferences.setMockInitialValues({
      'recipes': jsonEncode([legacy.toJson()]),
      'profile_name': 'Anna Maria',
    });
    final auth = await pumpApp(tester);
    expect(find.text('Pudim da Vovó'), findsWidgets);
    expect(find.text('Olá, Anna!'), findsOneWidget);

    final cloud = auth.clouds['anna']!;
    final saved = await cloud.recipes().first;
    expect(saved.map((r) => r.title), ['Pudim da Vovó']);
    expect((await cloud.profile().first)['name'], 'Anna Maria');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('recipes'), isNull);
    expect(prefs.getString('recipes_backup_local'), isNotNull);
  });

  group('leitura de receita por foto', () {
    test('separa nome, ingredientes, passos e demais campos', () {
      final r = GeminiRecipeScanner.parse(
        jsonEncode({
          'encontrou': true,
          'titulo': 'Bolo de Fubá',
          'categoria': 'bolo',
          'dificuldade': 'facil',
          'tempoMinutos': 45,
          'porcoes': 12,
          'ingredientes': ['3 ovos', '2 xícaras de fubá', ' '],
          'passos': ['Bata tudo no liquidificador', 'Asse por 40 minutos'],
          'observacoes': 'Fica ótimo com café',
        }),
      );
      expect(r.title, 'Bolo de Fubá');
      expect(r.category, RecipeCategory.bolo);
      expect(r.prepMinutes, 45);
      expect(r.servings, 12);
      expect(r.ingredients, ['3 ovos', '2 xícaras de fubá']);
      expect(r.steps, hasLength(2));
      expect(r.notes, 'Fica ótimo com café');
      expect(r.photoId, isNull);
    });

    test('aceita campos faltando e valores estranhos', () {
      final r = GeminiRecipeScanner.parse(
        jsonEncode({
          'titulo': '',
          'categoria': 'inexistente',
          'tempoMinutos': 0,
          'ingredientes': ['farinha'],
        }),
      );
      expect(r.title, 'Receita sem nome');
      expect(r.category, RecipeCategory.outro);
      expect(r.prepMinutes, isNull);
      expect(r.steps, isEmpty);
    });

    test('avisa quando a foto não é uma receita', () {
      expect(
        () => GeminiRecipeScanner.parse(jsonEncode({'encontrou': false})),
        throwsA(isA<ScanException>()),
      );
      expect(
        () => GeminiRecipeScanner.parse('isto não é json'),
        throwsA(isA<ScanException>()),
      );
    });
  });

  testWidgets('receita lida da foto abre preenchida e salva', (tester) async {
    await pumpApp(tester);
    final draft = GeminiRecipeScanner.parse(
      jsonEncode({
        'titulo': 'Coxinha de Frango',
        'categoria': 'salgado',
        'dificuldade': 'medio',
        'ingredientes': ['500g de frango', '2 xícaras de farinha'],
        'passos': ['Cozinhe o frango', 'Modele as coxinhas'],
      }),
    );
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute(builder: (_) => RecipeFormScreen(draft: draft)));
    await tester.pumpAndSettle();

    expect(find.text('Nova Receita'), findsOneWidget);
    expect(find.textContaining('Receita lida da foto'), findsOneWidget);
    expect(find.text('Coxinha de Frango'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('500g de frango'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(RecipeFormScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('500g de frango'), findsOneWidget);

    await tester.tap(find.text('Salvar Receita'));
    await tester.pumpAndSettle();
    expect(find.text('Coxinha de Frango'), findsWidgets);
    expect(find.text('Destaque'), findsOneWidget);
  });
}
