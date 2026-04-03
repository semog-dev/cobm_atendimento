import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cobm_atendimento/features/fila/domain/models/entrada_fila.dart';

class FilaRepository {
  FilaRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  Future<EntradaFila> entrarNaFila({
    required String sessaoId,
    required String clienteId,
    required String mediumEntidadeId,
    required int posicao,
  }) async {
    final data = await _client.from('fila').insert({
      'sessao_id': sessaoId,
      'cliente_id': clienteId,
      'medium_entidade_id': mediumEntidadeId,
      'posicao': posicao,
      'status': StatusFila.aguardando.toJson(),
      'criado_em': DateTime.now().toIso8601String(),
    }).select().single();
    return EntradaFila.fromMap(data);
  }

  Future<EntradaFila> cancelarEntrada(String id) async {
    final data = await _client
        .from('fila')
        .update({'status': StatusFila.cancelado.toJson()})
        .eq('id', id)
        .select()
        .single();
    return EntradaFila.fromMap(data);
  }

  Future<EntradaFila> chamarProximo(String id) async {
    final data = await _client.from('fila').update({
      'status': StatusFila.emAtendimento.toJson(),
      'chamado_em': DateTime.now().toIso8601String(),
    }).eq('id', id).select().single();
    return EntradaFila.fromMap(data);
  }

  Future<EntradaFila> iniciarAtendimento(String id) async {
    final data = await _client.from('fila').update({
      'iniciado_em': DateTime.now().toIso8601String(),
    }).eq('id', id).select().single();
    return EntradaFila.fromMap(data);
  }

  Future<EntradaFila> encerrarAtendimento(String id) async {
    final iniciadoData = await _client
        .from('fila')
        .select('iniciado_em, chamado_em')
        .eq('id', id)
        .single();

    final inicio = iniciadoData['iniciado_em'] != null
        ? DateTime.parse(iniciadoData['iniciado_em'] as String)
        : DateTime.parse(iniciadoData['chamado_em'] as String);
    final encerradoEm = DateTime.now();
    final duracao = encerradoEm.difference(inicio).inSeconds;

    final data = await _client.from('fila').update({
      'status': StatusFila.concluido.toJson(),
      'encerrado_em': encerradoEm.toIso8601String(),
      'duracao_segundos': duracao,
    }).eq('id', id).select().single();
    return EntradaFila.fromMap(data);
  }

  Future<List<EntradaFila>> listarPorSessao(String sessaoId) async {
    final data = await _client
        .from('fila')
        .select()
        .eq('sessao_id', sessaoId)
        .order('posicao');
    return (data as List).map((e) => EntradaFila.fromMap(e)).toList();
  }

  Future<EntradaFila?> buscarEntradaDoCliente({
    required String sessaoId,
    required String clienteId,
  }) async {
    final data = await _client
        .from('fila')
        .select()
        .eq('sessao_id', sessaoId)
        .eq('cliente_id', clienteId)
        .inFilter('status', [
          StatusFila.aguardando.toJson(),
          StatusFila.emAtendimento.toJson(),
        ])
        .limit(1);
    final list = data as List;
    if (list.isEmpty) return null;
    return EntradaFila.fromMap(list.first as Map<String, dynamic>);
  }

  Stream<List<EntradaFila>> listarPorSessaoStream(String sessaoId) {
    return _client
        .from('fila')
        .stream(primaryKey: ['id'])
        .eq('sessao_id', sessaoId)
        .order('posicao')
        .map((data) => data.map((e) => EntradaFila.fromMap(e)).toList());
  }
}
