import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/auth/domain/models/usuario.dart';
import 'package:cobm_atendimento/features/auth/presentation/providers/auth_provider.dart';
import 'package:cobm_atendimento/features/auth/presentation/screens/login_screen.dart';
import 'package:cobm_atendimento/features/auth/presentation/screens/cadastro_screen.dart';
import 'package:cobm_atendimento/features/mediuns/domain/models/medium.dart';
import 'package:cobm_atendimento/features/mediuns/presentation/screens/mediuns_screen.dart';
import 'package:cobm_atendimento/features/mediuns/presentation/screens/medium_form_screen.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<Usuario?>(authProvider, (prev, next) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final usuario = _ref.read(authProvider);
    final loc = state.matchedLocation;

    // Não autenticado tentando acessar rota de gestor
    if (usuario == null && loc.startsWith('/gestor')) return '/login';

    // Autenticado na tela de login/cadastro → vai para home
    if (usuario != null && (loc == '/login' || loc == '/cadastro')) {
      return usuario.isGestor ? '/gestor/mediuns' : '/login';
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);
  return GoRouter(
    refreshListenable: notifier,
    redirect: notifier.redirect,
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/cadastro',
        name: 'cadastro',
        builder: (context, state) => const CadastroScreen(),
      ),
      GoRoute(
        path: '/gestor/mediuns',
        name: 'mediuns',
        builder: (context, state) => const MediunsScreen(),
        routes: [
          GoRoute(
            path: 'novo',
            name: 'medium-novo',
            builder: (context, state) => const MediumFormScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'medium-editar',
            builder: (context, state) => MediumFormScreen(
              medium: state.extra as Medium?,
            ),
          ),
        ],
      ),
    ],
  );
});
