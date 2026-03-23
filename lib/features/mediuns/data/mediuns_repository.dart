import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cobm_atendimento/features/mediuns/domain/models/medium.dart';
import 'package:cobm_atendimento/features/entidades/domain/models/entidade.dart';

class MediunsRepository {
  MediunsRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  Future<List<Medium>> listar() async {
    final data = await _client.from('mediuns').select();
    return (data as List).map((e) => Medium.fromMap(e)).toList();
  }

  Future<List<Medium>> listarAtivos() async {
    final data = await _client
        .from('mediuns')
        .select()
        .eq('ativo', true)
        .order('nome');
    return (data as List).map((e) => Medium.fromMap(e)).toList();
  }

  Future<Medium> buscarPorId(String id) async {
    final data = await _client
        .from('mediuns')
        .select()
        .eq('id', id)
        .single();
    return Medium.fromMap(data);
  }

  Future<void> salvar(Medium medium) {
    return _client.from('mediuns').upsert(medium.toMap());
  }

  Future<void> ativar(String id) {
    return _client.from('mediuns').update({'ativo': true}).eq('id', id);
  }

  Future<void> desativar(String id) {
    return _client.from('mediuns').update({'ativo': false}).eq('id', id);
  }

  Future<List<Entidade>> listarEntidades(String mediumId) async {
    final data = await _client
        .from('medium_entidades')
        .select('entidades(*)')
        .eq('medium_id', mediumId);
    return (data as List)
        .map((e) => Entidade.fromMap(e['entidades'] as Map<String, dynamic>))
        .toList();
  }

  Future<void> vincularEntidade({
    required String mediumId,
    required String entidadeId,
  }) {
    return _client.from('medium_entidades').insert({
      'medium_id': mediumId,
      'entidade_id': entidadeId,
    });
  }

  Future<void> desvincularEntidade({
    required String mediumId,
    required String entidadeId,
  }) {
    return _client
        .from('medium_entidades')
        .delete()
        .eq('medium_id', mediumId)
        .eq('entidade_id', entidadeId);
  }
}
