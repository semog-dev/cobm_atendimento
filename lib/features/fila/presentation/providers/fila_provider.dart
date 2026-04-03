import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cobm_atendimento/features/fila/data/fila_repository.dart';
import 'package:cobm_atendimento/features/fila/domain/models/entrada_fila.dart';
import 'package:cobm_atendimento/core/config/supabase_config.dart';

final filaRepositoryProvider = Provider<FilaRepository>((ref) {
  return FilaRepository(client: supabase);
});

final filaNotifierProvider =
    NotifierProvider<FilaNotifier, List<EntradaFila>>(FilaNotifier.new);

class FilaNotifier extends Notifier<List<EntradaFila>> {
  FilaRepository get _repository => ref.read(filaRepositoryProvider);
  StreamSubscription<List<EntradaFila>>? _sub;

  @override
  List<EntradaFila> build() {
    ref.onDispose(() => _sub?.cancel());
    return [];
  }

  void assinarSessao(String sessaoId) {
    _sub?.cancel();
    _sub = _repository.listarPorSessaoStream(sessaoId).listen((fila) {
      state = fila;
    });
  }

  Future<void> entrarNaFila({
    required String sessaoId,
    required String clienteId,
    required String mediumEntidadeId,
  }) async {
    final ultimaPosicao = await _repository.ultimaPosicao(
      sessaoId: sessaoId,
      mediumEntidadeId: mediumEntidadeId,
    );
    final entrada = await _repository.entrarNaFila(
      sessaoId: sessaoId,
      clienteId: clienteId,
      mediumEntidadeId: mediumEntidadeId,
      posicao: ultimaPosicao + 1,
    );
    state = [...state, entrada];
  }

  Future<void> cancelarEntrada(String id) async {
    final cancelada = await _repository.cancelarEntrada(id);
    state = state.map((e) => e.id == id ? cancelada : e).toList();
  }

  Future<void> chamarProximo(String id) async {
    final chamado = await _repository.chamarProximo(id);
    state = state.map((e) => e.id == id ? chamado : e).toList();
  }

  Future<void> encerrarAtendimento(String id) async {
    final encerrado = await _repository.encerrarAtendimento(id);
    state = state.map((e) => e.id == id ? encerrado : e).toList();
  }
}
