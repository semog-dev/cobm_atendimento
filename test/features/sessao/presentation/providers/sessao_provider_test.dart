import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cobm_atendimento/features/sessao/data/sessao_repository.dart';
import 'package:cobm_atendimento/features/sessao/domain/models/sessao.dart';
import 'package:cobm_atendimento/features/sessao/presentation/providers/sessao_provider.dart';
import '../../../../core/helpers/test_helpers.dart';

class MockSessaoRepository extends Mock implements SessaoRepository {}

void main() {
  late MockSessaoRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockSessaoRepository();
    container = ProviderContainer(
      overrides: [sessaoRepositoryProvider.overrideWithValue(mockRepository)],
    );
  });

  tearDown(() => container.dispose());

  group('sessaoAtualProvider', () {
    test('deve retornar sessão aberta quando existe', () async {
      when(
        () => mockRepository.buscarSessaoAberta(),
      ).thenAnswer((_) async => sessaoFake);

      final result = await container.read(sessaoAtualProvider.future);

      expect(result, sessaoFake);
      expect(result!.isAberta, isTrue);
    });

    test('deve retornar null quando não há sessão aberta', () async {
      when(
        () => mockRepository.buscarSessaoAberta(),
      ).thenAnswer((_) async => null);

      final result = await container.read(sessaoAtualProvider.future);

      expect(result, isNull);
    });
  });

  group('SessaoNotifier.abrirSessao', () {
    test('deve atualizar estado com sessão aberta', () async {
      when(
        () => mockRepository.abrirSessao(gestorId: any(named: 'gestorId')),
      ).thenAnswer((_) async => sessaoFake);
      when(
        () => mockRepository.buscarSessaoAberta(),
      ).thenAnswer((_) async => null);

      await container
          .read(sessaoNotifierProvider.notifier)
          .abrirSessao(gestorId: 'uuid-456', mediumEntidadeIds: {});

      final state = container.read(sessaoNotifierProvider);
      expect(state.value, sessaoFake);
    });
  });

  group('SessaoNotifier.encerrarSessao', () {
    test('deve atualizar estado para null após encerrar sessão', () async {
      final encerrada = sessaoFake.copyWith(
        status: StatusSessao.encerrada,
        encerradaEm: DateTime(2024, 1, 1, 12, 0),
      );

      when(
        () => mockRepository.buscarSessaoAberta(),
      ).thenAnswer((_) async => null);
      when(
        () => mockRepository.encerrarSessao(any()),
      ).thenAnswer((_) async => encerrada);

      await container
          .read(sessaoNotifierProvider.notifier)
          .encerrarSessao('uuid-sess-001');

      final state = container.read(sessaoNotifierProvider);
      expect(state.value, isNull);
    });

    test('should propagar exceção when encerrarSessao falha', () async {
      when(
        () => mockRepository.buscarSessaoAberta(),
      ).thenAnswer((_) async => null);
      when(
        () => mockRepository.encerrarSessao(any()),
      ).thenThrow(Exception('DB error'));

      expect(
        () => container
            .read(sessaoNotifierProvider.notifier)
            .encerrarSessao('uuid-sess-001'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('SessaoNotifier — error handling', () {
    test(
      'should expor AsyncError when buscarSessaoAberta falha no build',
      () async {
        when(
          () => mockRepository.buscarSessaoAberta(),
        ).thenThrow(Exception('Sem conexão'));

        await expectLater(
          container.read(sessaoNotifierProvider.future),
          throwsA(isA<Exception>()),
        );

        final state = container.read(sessaoNotifierProvider);
        expect(state, isA<AsyncError>());
      },
    );

    test('should propagar exceção when abrirSessao falha', () async {
      when(
        () => mockRepository.buscarSessaoAberta(),
      ).thenAnswer((_) async => null);
      when(
        () => mockRepository.abrirSessao(gestorId: any(named: 'gestorId')),
      ).thenThrow(Exception('DB error'));

      await container.read(sessaoNotifierProvider.future);

      expect(
        () => container
            .read(sessaoNotifierProvider.notifier)
            .abrirSessao(gestorId: 'uuid-456', mediumEntidadeIds: {}),
        throwsA(isA<Exception>()),
      );
    });
  });
}
