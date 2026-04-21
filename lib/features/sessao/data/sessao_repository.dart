import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cobm_atendimento/features/sessao/domain/models/sessao.dart';
import 'package:cobm_atendimento/features/sessao/domain/models/medium_entidade.dart';

class SessaoRepository {
  SessaoRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  Future<Sessao> abrirSessao({required String gestorId}) async {
    final data = await _client
        .from('sessoes')
        .insert({
          'gestor_id': gestorId,
          'status': StatusSessao.aberta.name,
          'aberta_em': DateTime.now().toIso8601String(),
        })
        .select()
        .single();
    return Sessao.fromMap(data);
  }

  Future<Sessao> encerrarSessao(String id) async {
    final data = await _client
        .from('sessoes')
        .update({
          'status': StatusSessao.encerrada.name,
          'encerrada_em': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
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

  Future<List<MediumEntidade>> listarMediumEntidades() async {
    final data = await _client
        .from('medium_entidades')
        .select(
          'id, medium_id, entidade_id, mediuns(nome, ativo), entidades(nome, ativa)',
        );
    return (data as List)
        .where((e) {
          final m = e['mediuns'] as Map<String, dynamic>?;
          final en = e['entidades'] as Map<String, dynamic>?;
          return m != null &&
              en != null &&
              (m['ativo'] as bool) &&
              (en['ativa'] as bool);
        })
        .map((e) => MediumEntidade.fromMap(e))
        .toList();
  }

  Future<void> vincularMediumEntidade({
    required String sessaoId,
    required String mediumEntidadeId,
  }) {
    return _client.from('sessao_medium_entidades').insert({
      'sessao_id': sessaoId,
      'medium_entidade_id': mediumEntidadeId,
    });
  }

  Future<List<MediumEntidade>> listarMediumEntidadesDaSessao(
    String sessaoId,
  ) async {
    final data = await _client
        .from('sessao_medium_entidades')
        .select(
          'medium_entidades(id, medium_id, entidade_id, mediuns(nome), entidades(nome))',
        )
        .eq('sessao_id', sessaoId);
    return (data as List)
        .map(
          (e) => MediumEntidade.fromMap(
            e['medium_entidades'] as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
