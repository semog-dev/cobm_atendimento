import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cobm_atendimento/features/entidades/domain/models/entidade.dart';

class EntidadesRepository {
  EntidadesRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  Future<List<Entidade>> listar() async {
    final data = await _client.from('entidades').select();
    return (data as List).map((e) => Entidade.fromMap(e)).toList();
  }

  Future<List<Entidade>> listarAtivas() async {
    final data = await _client
        .from('entidades')
        .select()
        .eq('ativa', true)
        .order('nome');
    return (data as List).map((e) => Entidade.fromMap(e)).toList();
  }

  Future<Entidade> buscarPorId(String id) async {
    final data = await _client
        .from('entidades')
        .select()
        .eq('id', id)
        .single();
    return Entidade.fromMap(data);
  }

  Future<Entidade> criar({required String nome, String? descricao}) async {
    final data = await _client
        .from('entidades')
        .insert({'nome': nome, 'descricao': descricao ?? '', 'ativa': true})
        .select()
        .single();
    return Entidade.fromMap(data);
  }

  Future<void> salvar(Entidade entidade) {
    return _client.from('entidades').upsert(entidade.toMap());
  }

  Future<void> ativar(String id) {
    return _client.from('entidades').update({'ativa': true}).eq('id', id);
  }

  Future<void> desativar(String id) {
    return _client.from('entidades').update({'ativa': false}).eq('id', id);
  }
}
