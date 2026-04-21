import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cobm_atendimento/features/entidades/data/entidades_repository.dart';
import 'package:cobm_atendimento/features/entidades/domain/models/entidade.dart';
import 'package:cobm_atendimento/features/mediuns/domain/models/medium.dart';
import 'package:cobm_atendimento/core/config/supabase_config.dart';

final entidadesRepositoryProvider = Provider<EntidadesRepository>((ref) {
  return EntidadesRepository(client: supabase);
});

final entidadesProvider = FutureProvider<List<Entidade>>((ref) {
  return ref.read(entidadesRepositoryProvider).listar();
});

final entidadesAtivasProvider = FutureProvider<List<Entidade>>((ref) {
  return ref.read(entidadesRepositoryProvider).listarAtivas();
});

final mediunsVinculadosProvider = FutureProvider.family<List<Medium>, String>((
  ref,
  entidadeId,
) {
  return ref.read(entidadesRepositoryProvider).listarMediuns(entidadeId);
});

final entidadesGestorProvider =
    AsyncNotifierProvider<EntidadesGestorNotifier, List<Entidade>>(
      EntidadesGestorNotifier.new,
    );

class EntidadesGestorNotifier extends AsyncNotifier<List<Entidade>> {
  EntidadesRepository get _repository => ref.read(entidadesRepositoryProvider);

  @override
  Future<List<Entidade>> build() => _repository.listar();

  Future<void> criar({
    required String nome,
    String? descricao,
    Set<String> mediumIds = const {},
  }) async {
    final entidade = await _repository.criar(nome: nome, descricao: descricao);
    for (final mediumId in mediumIds) {
      await _repository.vincularMedium(
        entidadeId: entidade.id,
        mediumId: mediumId,
      );
    }
    ref.invalidateSelf();
    await future;
  }

  Future<void> atualizar(Entidade entidade) async {
    await _repository.salvar(entidade);
    ref.invalidateSelf();
    await future;
  }

  Future<void> atualizarVinculos({
    required String entidadeId,
    required Set<String> novosIds,
    required Set<String> idsAntigos,
  }) async {
    final adicionar = novosIds.difference(idsAntigos);
    final remover = idsAntigos.difference(novosIds);

    for (final mediumId in adicionar) {
      await _repository.vincularMedium(
        entidadeId: entidadeId,
        mediumId: mediumId,
      );
    }
    for (final mediumId in remover) {
      await _repository.desvincularMedium(
        entidadeId: entidadeId,
        mediumId: mediumId,
      );
    }
  }

  Future<void> alternarAtiva(String id, {required bool ativa}) async {
    if (ativa) {
      await _repository.desativar(id);
    } else {
      await _repository.ativar(id);
    }
    ref.invalidateSelf();
    await future;
  }
}
