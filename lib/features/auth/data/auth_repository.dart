import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  User? get usuarioAtual => _client.auth.currentUser;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> cadastrar({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<void> logout() => _client.auth.signOut();

  Future<Map<String, dynamic>> buscarPerfil(String userId) {
    return _client.from('profiles').select().eq('id', userId).single();
  }

  Future<void> salvarPerfil({
    required String id,
    required String nome,
    required String telefone,
    required String role,
  }) {
    return _client.from('profiles').upsert({
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'role': role,
    });
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
