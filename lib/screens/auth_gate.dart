import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_controller.dart';
import '../providers/recipe_store.dart';
import '../providers/user_data.dart';
import 'login_screen.dart';
import 'main_shell.dart';

/// Mostra o login ou o app, e conecta os dados à conta de quem entrou.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _attachedUid;

  void _sync(AuthController auth) {
    final user = auth.user;
    if (user?.uid == _attachedUid) return;
    _attachedUid = user?.uid;
    final store = context.read<RecipeStore>();
    final data = context.read<UserData>();
    // Depois do build: attach/detach avisam os ouvintes.
    Future.microtask(() async {
      if (user == null) {
        await store.detach();
        await data.detach();
      } else {
        final cloud = auth.cloudFor(user);
        await store.attach(cloud);
        await data.attach(
          cloud,
          email: user.email,
          displayName: user.displayName,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (auth.ready) _sync(auth);

    final Widget child;
    if (!auth.ready) {
      child = const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (auth.user == null) {
      child = const LoginScreen();
    } else {
      child = MainShell(key: ValueKey(auth.user!.uid));
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(
        key: ValueKey('${auth.ready}-${auth.user?.uid}'),
        child: child,
      ),
    );
  }
}
