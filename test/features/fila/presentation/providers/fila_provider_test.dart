import 'dart:async';
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
            clienteNome: any(named: 'clienteNome'),
            mediumEntidadeId: any(named: 'mediumEntidadeId'),
            posicao: any(named: 'posicao'),
          )).thenAnswer((_) async => entradaFilaFake);

      await container.read(filaNotifierProvider.notifier).entrarNaFila(
            sessaoId: 'uuid-sess-001',
            clienteNome: 'João Silva',
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

  group('FilaNotifier — error handling', () {
    test('should propagar exceção when chamarProximo falha', () async {
      when(() => mockRepository.chamarProximo(any()))
          .thenThrow(Exception('DB error'));

      expect(
        () => container
            .read(filaNotifierProvider.notifier)
            .chamarProximo('uuid-fila-001'),
        throwsA(isA<Exception>()),
      );
    });

    test('should propagar exceção when encerrarAtendimento falha', () async {
      when(() => mockRepository.encerrarAtendimento(any()))
          .thenThrow(Exception('DB error'));

      expect(
        () => container
            .read(filaNotifierProvider.notifier)
            .encerrarAtendimento('uuid-fila-001'),
        throwsA(isA<Exception>()),
      );
    });

    test('should propagar exceção when entrarNaFila falha', () async {
      when(() => mockRepository.ultimaPosicao(
            sessaoId: any(named: 'sessaoId'),
            mediumEntidadeId: any(named: 'mediumEntidadeId'),
          )).thenAnswer((_) async => 0);
      when(() => mockRepository.entrarNaFila(
            sessaoId: any(named: 'sessaoId'),
            clienteNome: any(named: 'clienteNome'),
            mediumEntidadeId: any(named: 'mediumEntidadeId'),
            posicao: any(named: 'posicao'),
          )).thenThrow(Exception('DB error'));

      expect(
        () => container.read(filaNotifierProvider.notifier).entrarNaFila(
              sessaoId: 'uuid-sess-001',
              clienteNome: 'João',
              mediumEntidadeId: 'uuid-me-001',
            ),
        throwsA(isA<Exception>()),
      );
    });

    test('should propagar exceção when cancelarEntrada falha', () async {
      when(() => mockRepository.cancelarEntrada(any()))
          .thenThrow(Exception('DB error'));

      expect(
        () => container
            .read(filaNotifierProvider.notifier)
            .cancelarEntrada('uuid-fila-001'),
        throwsA(isA<Exception>()),
      );
    });

    test('should manter estado anterior quando chamarProximo falha', () async {
      when(() => mockRepository.listarPorSessaoStream(any()))
          .thenAnswer((_) => Stream.value([entradaFilaFake]));
      when(() => mockRepository.chamarProximo(any()))
          .thenThrow(Exception('DB error'));

      container
          .read(filaNotifierProvider.notifier)
          .assinarSessao('uuid-sess-001');
      await Future.delayed(Duration.zero);

      try {
        await container
            .read(filaNotifierProvider.notifier)
            .chamarProximo('uuid-fila-001');
      } catch (_) {}

      final state = container.read(filaNotifierProvider);
      expect(state.first.isAguardando, isTrue);
    });
  });

  group('FilaNotifier — real-time stream', () {
    test('should atualizar estado a cada evento do stream', () async {
      final controller = StreamController<List<EntradaFila>>();

      when(() => mockRepository.listarPorSessaoStream(any()))
          .thenAnswer((_) => controller.stream);

      container
          .read(filaNotifierProvider.notifier)
          .assinarSessao('uuid-sess-001');

      controller.add([entradaFilaFake]);
      await Future.delayed(Duration.zero);
      expect(container.read(filaNotifierProvider), [entradaFilaFake]);

      final segunda = entradaFilaFake.copyWith(
        status: StatusFila.emAtendimento,
        chamadoEm: DateTime(2024, 1, 1, 9, 5),
      );
      controller.add([segunda]);
      await Future.delayed(Duration.zero);
      expect(container.read(filaNotifierProvider).first.isEmAtendimento, isTrue);

      await controller.close();
    });

    test('should limpar estado quando stream emite lista vazia', () async {
      final controller = StreamController<List<EntradaFila>>();

      when(() => mockRepository.listarPorSessaoStream(any()))
          .thenAnswer((_) => controller.stream);

      container
          .read(filaNotifierProvider.notifier)
          .assinarSessao('uuid-sess-001');

      controller.add([entradaFilaFake]);
      await Future.delayed(Duration.zero);
      expect(container.read(filaNotifierProvider), isNotEmpty);

      controller.add([]);
      await Future.delayed(Duration.zero);
      expect(container.read(filaNotifierProvider), isEmpty);

      await controller.close();
    });

    test('should cancelar stream anterior ao assinar nova sessão', () async {
      final controller1 = StreamController<List<EntradaFila>>();
      final controller2 = StreamController<List<EntradaFila>>();
      var callCount = 0;

      when(() => mockRepository.listarPorSessaoStream(any()))
          .thenAnswer((_) {
        callCount++;
        return callCount == 1 ? controller1.stream : controller2.stream;
      });

      container
          .read(filaNotifierProvider.notifier)
          .assinarSessao('uuid-sess-001');

      controller1.add([entradaFilaFake]);
      await Future.delayed(Duration.zero);
      expect(container.read(filaNotifierProvider), [entradaFilaFake]);

      container
          .read(filaNotifierProvider.notifier)
          .assinarSessao('uuid-sess-002');

      final outraEntrada = entradaFilaFake.copyWith(id: 'uuid-fila-002');
      controller2.add([outraEntrada]);
      await Future.delayed(Duration.zero);
      expect(container.read(filaNotifierProvider), [outraEntrada]);

      controller1.add([entradaFilaFake]);
      await Future.delayed(Duration.zero);
      expect(container.read(filaNotifierProvider), [outraEntrada]);

      await controller1.close();
      await controller2.close();
    });

    test('should cancelar stream ao descartar o provider', () async {
      final controller = StreamController<List<EntradaFila>>();

      when(() => mockRepository.listarPorSessaoStream(any()))
          .thenAnswer((_) => controller.stream);

      container
          .read(filaNotifierProvider.notifier)
          .assinarSessao('uuid-sess-001');

      controller.add([entradaFilaFake]);
      await Future.delayed(Duration.zero);

      container.dispose();

      expect(controller.hasListener, isFalse);

      await controller.close();
    });
  });
}
