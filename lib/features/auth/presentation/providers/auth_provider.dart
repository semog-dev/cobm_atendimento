import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cobm_atendimento/features/auth/data/auth_repository.dart';
import 'package:cobm_atendimento/features/auth/domain/models/usuario.dart';
import 'package:cobm_atendimento/core/config/supabase_config.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(client: supabase);
});

/// True enquanto a sessão salva está sendo restaurada automaticamente.
final authInicializandoProvider = StateProvider<bool>(
  (ref) => supabase.auth.currentUser != null,
);

final authProvider = NotifierProvider<AuthNotifier, Usuario?>(AuthNotifier.new);

class AuthNotifier extends Notifier<Usuario?> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  Usuario? build() {
    // Escuta mudanças de sessão (token refresh, logout externo)
    final sub = _repository.authStateChanges.listen((event) {
      if (event.event == AuthChangeEvent.signedOut) {
        state = null;
      }
    });
    ref.onDispose(sub.cancel);

    // Restaura sessão existente de forma assíncrona
    final user = _repository.usuarioAtual;
    if (user != null) {
      Future.microtask(() => _carregarPerfil(user.id));
    }

    return null;
  }

  Future<void> _carregarPerfil(String userId) async {
    try {
      final map = await _repository.buscarPerfil(userId);
      state = Usuario.fromMap(map);
    } catch (_) {
      // sessão inválida ou perfil não encontrado — mantém null
    } finally {
      ref.read(authInicializandoProvider.notifier).state = false;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await _repository.login(email: email, password: password);
    final userId = response.user!.id;
    final map = await _repository.buscarPerfil(userId);
    state = Usuario.fromMap(map);
  }

  Future<void> cadastrar({
    required String nome,
    required String telefone,
    required String email,
    required String password,
  }) async {
    await _repository.cadastrar(email: email, password: password);
    // Faz login explícito para garantir que o JWT está ativo antes de
    // inserir em profiles (signUp pode não propagar a sessão imediatamente)
    final response = await _repository.login(email: email, password: password);
    final userId = response.user!.id;
    await _repository.salvarPerfil(
      id: userId,
      nome: nome,
      telefone: telefone,
      role: Role.cliente.name,
    );
    final map = await _repository.buscarPerfil(userId);
    state = Usuario.fromMap(map);
  }

  Future<void> logout() async {
    await _repository.logout();
    state = null;
  }
}
