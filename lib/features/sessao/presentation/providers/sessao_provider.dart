import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cobm_atendimento/features/sessao/data/sessao_repository.dart';
import 'package:cobm_atendimento/features/sessao/domain/models/sessao.dart';
import 'package:cobm_atendimento/features/sessao/domain/models/medium_entidade.dart';
import 'package:cobm_atendimento/core/config/supabase_config.dart';

final sessaoRepositoryProvider = Provider<SessaoRepository>((ref) {
  return SessaoRepository(client: supabase);
});

final sessaoAtualProvider = FutureProvider<Sessao?>((ref) {
  return ref.read(sessaoRepositoryProvider).buscarSessaoAberta();
});

final historicoSessoesProvider = FutureProvider<List<Sessao>>((ref) {
  return ref.read(sessaoRepositoryProvider).listar();
});

final mediumEntidadesDisponiveisProvider =
    FutureProvider.autoDispose<List<MediumEntidade>>((ref) {
  return ref.read(sessaoRepositoryProvider).listarMediumEntidades();
});

final mediumEntidadesDaSessaoProvider =
    FutureProvider.family<List<MediumEntidade>, String>((ref, sessaoId) {
  return ref
      .read(sessaoRepositoryProvider)
      .listarMediumEntidadesDaSessao(sessaoId);
});

final sessaoNotifierProvider =
    AsyncNotifierProvider<SessaoNotifier, Sessao?>(SessaoNotifier.new);

class SessaoNotifier extends AsyncNotifier<Sessao?> {
  SessaoRepository get _repository => ref.read(sessaoRepositoryProvider);

  @override
  Future<Sessao?> build() => _repository.buscarSessaoAberta();

  Future<void> abrirSessao({
    required String gestorId,
    required Set<String> mediumEntidadeIds,
  }) async {
    state = const AsyncLoading();
    final sessao = await _repository.abrirSessao(gestorId: gestorId);
    for (final id in mediumEntidadeIds) {
      await _repository.vincularMediumEntidade(
        sessaoId: sessao.id,
        mediumEntidadeId: id,
      );
    }
    state = AsyncData(sessao);
  }

  Future<void> encerrarSessao(String id) async {
    state = const AsyncLoading();
    await _repository.encerrarSessao(id);
    state = const AsyncData(null);
  }
}
