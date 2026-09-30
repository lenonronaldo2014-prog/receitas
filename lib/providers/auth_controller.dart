import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/user_cloud.dart';

/// Usuário conectado.
class AppUser {
  const AppUser({required this.uid, required this.email, this.displayName});

  final String uid;
  final String email;
  final String? displayName;
}

/// Erro de login com mensagem pronta para mostrar.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Conta do usuário (login, cadastro, sair).
abstract class AuthController extends ChangeNotifier {
  /// Já sabemos se há alguém conectado (a sessão fica salva no aparelho).
  bool get ready;
  AppUser? get user;

  Future<void> signIn(String email, String password);
  Future<void> signUp(String name, String email, String password);
  Future<void> resetPassword(String email);
  Future<void> signInWithGoogle();
  Future<void> signOut();

  /// Onde ficam os dados desse usuário.
  UserCloud cloudFor(AppUser user);
}

class FirebaseAuthController extends AuthController {
  FirebaseAuthController() {
    _sub = _auth.authStateChanges().listen((u) {
      _user = u == null
          ? null
          : AppUser(
              uid: u.uid,
              email: u.email ?? '',
              displayName: u.displayName,
            );
      _ready = true;
      notifyListeners();
    });
  }

  /// "Web client" do projeto no Firebase (o login do Google no Android usa).
  static const _googleServerClientId =
      '962392016831-mfsk48bgb1fack18kprhhjbiirukv8h3.apps.googleusercontent.com';

  final _auth = FirebaseAuth.instance;
  late final StreamSubscription<User?> _sub;
  AppUser? _user;
  bool _ready = false;
  Future<void>? _googleInit;

  @override
  bool get ready => _ready;

  @override
  AppUser? get user => _user;

  @override
  UserCloud cloudFor(AppUser user) => FirestoreUserCloud(user.uid);

  @override
  Future<void> signIn(String email, String password) => _guard(
    () => _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ),
  );

  @override
  Future<void> signUp(String name, String email, String password) =>
      _guard(() async {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final u = cred.user!;
        await u.updateDisplayName(name.trim());
        unawaited(cloudFor(_toAppUser(u)).saveProfile({'name': name.trim()}));
      });

  @override
  Future<void> resetPassword(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<void> signInWithGoogle() => _guard(() async {
    final google = GoogleSignIn.instance;
    await (_googleInit ??= google.initialize(
      serverClientId: _googleServerClientId,
    ));
    final GoogleSignInAccount account;
    try {
      account = await google.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return; // a pessoa fechou a janela
      }
      throw AuthException('Não foi possível entrar com o Google.');
    }
    final idToken = account.authentication.idToken;
    await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
  });

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    if (_googleInit != null) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
    }
  }

  AppUser _toAppUser(User u) =>
      AppUser(uid: u.uid, email: u.email ?? '', displayName: u.displayName);

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e.code));
    }
  }

  static String _message(String code) => switch (code) {
    'invalid-email' => 'E-mail inválido.',
    'user-disabled' => 'Esta conta foi desativada.',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'E-mail ou senha incorretos.',
    'email-already-in-use' => 'Já existe uma conta com este e-mail.',
    'weak-password' => 'Senha fraca: use pelo menos 6 caracteres.',
    'too-many-requests' =>
      'Muitas tentativas. Espere um pouco e tente de novo.',
    'network-request-failed' => 'Sem conexão com a internet.',
    'account-exists-with-different-credential' =>
      'Este e-mail já está cadastrado com outro tipo de login.',
    _ => 'Não foi possível concluir ($code).',
  };

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
