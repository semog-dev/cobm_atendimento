import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cobm_atendimento/features/sessao/data/sessao_repository.dart';
import 'package:cobm_atendimento/features/sessao/domain/models/sessao.dart';
import 'package:cobm_atendimento/core/config/supabase_config.dart';

final sessaoRepositoryProvider = Provider<SessaoRepository>((ref) {
  return SessaoRepository(client: supabase);
});

final sessaoAtualProvider = FutureProvider<Sessao?>((ref) {
  return ref.read(sessaoRepositoryProvider).buscarSessaoAberta();
});

final sessaoNotifierProvider =
    NotifierProvider<SessaoNotifier, Sessao?>(SessaoNotifier.new);

class SessaoNotifier extends Notifier<Sessao?> {
  SessaoRepository get _repository => ref.read(sessaoRepositoryProvider);

  @override
  Sessao? build() => null;

  Future<void> abrirSessao({required String gestorId}) async {
    final sessao = await _repository.abrirSessao(gestorId: gestorId);
    state = sessao;
  }

  Future<void> encerrarSessao(String id) async {
    await _repository.encerrarSessao(id);
    state = null;
  }
}
