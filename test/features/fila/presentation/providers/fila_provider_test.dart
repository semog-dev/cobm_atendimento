import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cobm_atendimento/features/fila/data/fila_repository.dart';
import 'package:cobm_atendimento/features/fila/domain/models/entrada_fila.dart';
import 'package:cobm_atendimento/features/fila/presentation/providers/fila_provider.dart';
import '../../../../core/helpers/test_helpers.dart';

class MockFilaRepository extends Mock implements FilaRepository {}

void main() {
  late MockFilaRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockFilaRepository();
    container = ProviderContainer(
      overrides: [
        filaRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('FilaNotifier', () {
    test('should retornar lista vazia ao inicializar', () {
      final state = container.read(filaNotifierProvider);
      expect(state, isEmpty);
    });

    test('should atualizar estado ao assinar stream da sessão', () async {
      when(() => mockRepository.listarPorSessaoStream(any()))
          .thenAnswer((_) => Stream.value([entradaFilaFake]));

      container
          .read(filaNotifierProvider.notifier)
          .assinarSessao('uuid-sess-001');

      await Future.delayed(Duration.zero);

      final state = container.read(filaNotifierProvider);
      expect(state, [entradaFilaFake]);
    });

    test('should chamar proximo e atualizar estado', () async {
      final chamada = entradaFilaFake.copyWith(
        status: StatusFila.emAtendimento,
        chamadoEm: DateTime(2024, 1, 1, 9, 5),
      );
      when(() => mockRepository.listarPorSessaoStream(any()))
          .thenAnswer((_) => Stream.value([entradaFilaFake]));
      when(() => mockRepository.chamarProximo(any()))
          .thenAnswer((_) async => chamada);

      container
          .read(filaNotifierProvider.notifier)
          .assinarSessao('uuid-sess-001');
      await Future.delayed(Duration.zero);

      await container
          .read(filaNotifierProvider.notifier)
          .chamarProximo('uuid-fila-001');

      final state = container.read(filaNotifierProvider);
      expect(state.any((e) => e.id == 'uuid-fila-001' && e.isEmAtendimento),
          isTrue);
    });

    test('should encerrar atendimento e atualizar estado', () async {
      final encerrada = entradaFilaFake.copyWith(
        status: StatusFila.concluido,
        encerradoEm: DateTime(2024, 1, 1, 9, 30),
        duracaoSegundos: 1800,
      );
      when(() => mockRepository.listarPorSessaoStream(any()))
          .thenAnswer((_) => Stream.value([entradaFilaFake]));
      when(() => mockRepository.encerrarAtendimento(any()))
          .thenAnswer((_) async => encerrada);

      container
          .read(filaNotifierProvider.notifier)
          .assinarSessao('uuid-sess-001');
      await Future.delayed(Duration.zero);

      await container
          .read(filaNotifierProvider.notifier)
          .encerrarAtendimento('uuid-fila-001');

      final state = container.read(filaNotifierProvider);
      expect(state.any((e) => e.id == 'uuid-fila-001' && e.isConcluido),
          isTrue);
    });
  });

  group('FilaNotifier.entrarNaFila', () {
    test('deve adicionar entrada ao estado quando entrar na fila', () async {
      when(() => mockRepository.ultimaPosicao(
            sessaoId: any(named: 'sessaoId'),
            mediumEntidadeId: any(named: 'mediumEntidadeId'),
          )).thenAnswer((_) async => 0);
      when(() => mockRepository.entrarNaFila(
            sessaoId: any(named: 'sessaoId'),
            clienteId: any(named: 'clienteId'),
            mediumEntidadeId: any(named: 'mediumEntidadeId'),
            posicao: any(named: 'posicao'),
          )).thenAnswer((_) async => entradaFilaFake);

      await container.read(filaNotifierProvider.notifier).entrarNaFila(
            sessaoId: 'uuid-sess-001',
            clienteId: 'uuid-123',
            mediumEntidadeId: 'uuid-me-001',
          );

      final state = container.read(filaNotifierProvider);
      expect(state, contains(entradaFilaFake));
    });
  });

  group('FilaNotifier.cancelarEntrada', () {
    test('deve atualizar entrada para cancelado ao cancelar', () async {
      final cancelada = entradaFilaFake.copyWith(status: StatusFila.cancelado);
      when(() => mockRepository.cancelarEntrada(any()))
          .thenAnswer((_) async => cancelada);

      await container
          .read(filaNotifierProvider.notifier)
          .cancelarEntrada('uuid-fila-001');

      final state = container.read(filaNotifierProvider);
      expect(
        state.any((e) => e.id == 'uuid-fila-001' && e.isAguardando),
        isFalse,
      );
    });
  });
}
