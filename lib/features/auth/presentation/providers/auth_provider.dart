import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cobm_atendimento/features/auth/data/auth_repository.dart';
import 'package:cobm_atendimento/features/auth/domain/models/usuario.dart';
import 'package:cobm_atendimento/core/config/supabase_config.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(client: supabase);
});

final authProvider = NotifierProvider<AuthNotifier, Usuario?>(AuthNotifier.new);

class AuthNotifier extends Notifier<Usuario?> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  Usuario? build() {
    final user = _repository.usuarioAtual;
    if (user == null) return null;
    return null;
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
    final response =
        await _repository.cadastrar(email: email, password: password);
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
