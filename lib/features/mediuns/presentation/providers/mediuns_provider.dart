import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cobm_atendimento/features/mediuns/data/mediuns_repository.dart';
import 'package:cobm_atendimento/features/mediuns/domain/models/medium.dart';
import 'package:cobm_atendimento/core/config/supabase_config.dart';

final mediunsRepositoryProvider = Provider<MediunsRepository>((ref) {
  return MediunsRepository(client: supabase);
});

final mediunsProvider = FutureProvider<List<Medium>>((ref) {
  return ref.read(mediunsRepositoryProvider).listar();
});

final mediunsAtivosProvider = FutureProvider<List<Medium>>((ref) async {
  final todos = await ref.watch(mediunsGestorProvider.future);
  return todos.where((m) => m.ativo).toList();
});

final mediunsGestorProvider =
    AsyncNotifierProvider<MediunsGestorNotifier, List<Medium>>(
  MediunsGestorNotifier.new,
);

class MediunsGestorNotifier extends AsyncNotifier<List<Medium>> {
  MediunsRepository get _repository => ref.read(mediunsRepositoryProvider);

  @override
  Future<List<Medium>> build() => _repository.listar();

  Future<void> criar({required String nome, String? fotoUrl}) async {
    await _repository.criar(nome: nome, fotoUrl: fotoUrl);
    ref.invalidateSelf();
    await future;
  }

  Future<void> atualizar(Medium medium) async {
    await _repository.salvar(medium);
    ref.invalidateSelf();
    await future;
  }

  Future<void> alternarAtivo(String id, {required bool ativo}) async {
    if (ativo) {
      await _repository.desativar(id);
    } else {
      await _repository.ativar(id);
    }
    ref.invalidateSelf();
    await future;
  }
}
