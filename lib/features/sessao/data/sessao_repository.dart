import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cobm_atendimento/features/sessao/domain/models/sessao.dart';

class SessaoRepository {
  SessaoRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  Future<Sessao> abrirSessao({required String gestorId}) async {
    final data = await _client.from('sessoes').insert({
      'gestor_id': gestorId,
      'status': StatusSessao.aberta.name,
      'aberta_em': DateTime.now().toIso8601String(),
    }).select().single();
    return Sessao.fromMap(data);
  }

  Future<Sessao> encerrarSessao(String id) async {
    final data = await _client.from('sessoes').update({
      'status': StatusSessao.encerrada.name,
      'encerrada_em': DateTime.now().toIso8601String(),
    }).eq('id', id).select().single();
    return Sessao.fromMap(data);
  }

  Future<Sessao?> buscarSessaoAberta() async {
    final data = await _client
        .from('sessoes')
        .select()
        .eq('status', StatusSessao.aberta.name)
        .order('aberta_em', ascending: false)
        .limit(1);
    final list = data as List;
    if (list.isEmpty) return null;
    return Sessao.fromMap(list.first as Map<String, dynamic>);
  }

  Future<List<Sessao>> listar() async {
    final data = await _client
        .from('sessoes')
        .select()
        .order('aberta_em', ascending: false);
    return (data as List).map((e) => Sessao.fromMap(e)).toList();
  }
}
