import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cobm_atendimento/features/auth/domain/models/usuario.dart';
import 'package:cobm_atendimento/features/auth/presentation/providers/auth_provider.dart';
import 'package:cobm_atendimento/features/auth/presentation/screens/login_screen.dart';
import 'package:cobm_atendimento/features/auth/presentation/screens/cadastro_screen.dart';
import 'package:cobm_atendimento/features/gestor/presentation/screens/gestor_shell.dart';
import 'package:cobm_atendimento/features/mediuns/domain/models/medium.dart';
import 'package:cobm_atendimento/features/mediuns/presentation/screens/mediuns_screen.dart';
import 'package:cobm_atendimento/features/mediuns/presentation/screens/medium_form_screen.dart';
import 'package:cobm_atendimento/features/entidades/domain/models/entidade.dart';
import 'package:cobm_atendimento/features/entidades/presentation/screens/entidades_screen.dart';
import 'package:cobm_atendimento/features/entidades/presentation/screens/entidade_form_screen.dart';
import 'package:cobm_atendimento/features/sessao/presentation/screens/sessao_screen.dart';
import 'package:cobm_atendimento/features/sessao/presentation/screens/abrir_sessao_screen.dart';
import 'package:cobm_atendimento/features/fila/domain/models/entrada_fila.dart';
import 'package:cobm_atendimento/features/fila/presentation/screens/fila_screen.dart';
import 'package:cobm_atendimento/features/fila/presentation/screens/fila_detalhe_screen.dart';
import 'package:cobm_atendimento/features/sessao/domain/models/medium_entidade.dart';
import 'package:cobm_atendimento/features/fila/presentation/screens/atendimento_screen.dart';
import 'package:cobm_atendimento/features/fila/presentation/screens/cliente_fila_screen.dart';
import 'package:cobm_atendimento/features/fila/presentation/screens/entrada_fila_screen.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<Usuario?>(authProvider, (prev, next) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final usuario = _ref.read(authProvider);
    final loc = state.matchedLocation;

    if (usuario == null && loc.startsWith('/gestor')) return '/login';
    if (usuario == null && loc.startsWith('/cliente')) return '/login';

    if (usuario != null && (loc == '/login' || loc == '/cadastro')) {
      return usuario.isGestor ? '/gestor/mediuns' : '/cliente/fila';
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
        path: '/gestor/atendimento',
        name: 'atendimento',
        builder: (context, state) =>
            AtendimentoScreen(entrada: state.extra as EntradaFila),
      ),
      GoRoute(
        path: '/cliente/fila',
        name: 'cliente-fila',
        builder: (context, state) => const ClienteFilaScreen(),
      ),
      GoRoute(
        path: '/cliente/entrar-fila',
        name: 'cliente-entrar-fila',
        builder: (context, state) =>
            EntradaFilaScreen(sessaoId: state.extra as String),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            GestorShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
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
                  builder: (context, state) =>
                      MediumFormScreen(medium: state.extra as Medium?),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/gestor/entidades',
              name: 'entidades',
              builder: (context, state) => const EntidadesScreen(),
              routes: [
                GoRoute(
                  path: 'nova',
                  name: 'entidade-nova',
                  builder: (context, state) => const EntidadeFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  name: 'entidade-editar',
                  builder: (context, state) =>
                      EntidadeFormScreen(entidade: state.extra as Entidade?),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/gestor/sessao',
              name: 'sessao',
              builder: (context, state) => const SessaoScreen(),
              routes: [
                GoRoute(
                  path: 'abrir',
                  name: 'sessao-abrir',
                  builder: (context, state) => const AbrirSessaoScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/gestor/fila',
              name: 'fila',
              builder: (context, state) => const FilaScreen(),
              routes: [
                GoRoute(
                  path: 'detalhe',
                  name: 'fila-detalhe',
                  builder: (context, state) => FilaDetalheScreen(
                    mediumEntidade: state.extra as MediumEntidade,
                  ),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});
