import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cobm_atendimento/features/mediuns/data/mediuns_repository.dart';
import 'package:cobm_atendimento/features/mediuns/presentation/providers/mediuns_provider.dart';
import '../../../../core/helpers/test_helpers.dart';

class MockMediunsRepository extends Mock implements MediunsRepository {}

void main() {
  late MockMediunsRepository mockRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(mediumFake);
  });

  setUp(() {
    mockRepository = MockMediunsRepository();
    container = ProviderContainer(
      overrides: [mediunsRepositoryProvider.overrideWithValue(mockRepository)],
    );
  });

  tearDown(() => container.dispose());

  group('mediunsProvider', () {
    test(
      'deve retornar lista de médiuns quando repositório retorna com sucesso',
      () async {
        when(
          () => mockRepository.listar(),
        ).thenAnswer((_) async => [mediumFake]);

        final result = await container.read(mediunsProvider.future);

        expect(result, [mediumFake]);
        expect(result.length, 1);
      },
    );

    test('deve retornar lista vazia quando não há médiuns', () async {
      when(() => mockRepository.listar()).thenAnswer((_) async => []);

      final result = await container.read(mediunsProvider.future);

      expect(result, isEmpty);
    });

    test('deve lançar exceção quando repositório falha', () async {
      when(
        () => mockRepository.listar(),
      ).thenThrow(Exception('Erro de conexão'));

      expect(
        () => container.read(mediunsProvider.future),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('mediunsAtivosProvider', () {
    test('deve retornar apenas médiuns ativos', () async {
      final mediumInativo = mediumFake.copyWith(ativo: false);
      when(
        () => mockRepository.listar(),
      ).thenAnswer((_) async => [mediumFake, mediumInativo]);

      final result = await container.read(mediunsAtivosProvider.future);

      expect(result, [mediumFake]);
      expect(result.every((m) => m.ativo), isTrue);
    });
  });

  group('MediunsGestorNotifier', () {
    test('deve carregar lista de médiuns ao inicializar', () async {
      when(() => mockRepository.listar()).thenAnswer((_) async => [mediumFake]);

      final result = await container.read(mediunsGestorProvider.future);

      expect(result, [mediumFake]);
    });

    test('deve criar médium e recarregar lista', () async {
      when(() => mockRepository.listar()).thenAnswer((_) async => [mediumFake]);
      when(
        () => mockRepository.criar(
          nome: any(named: 'nome'),
          fotoUrl: any(named: 'fotoUrl'),
        ),
      ).thenAnswer((_) async => mediumFake);

      await container.read(mediunsGestorProvider.future);
      await container
          .read(mediunsGestorProvider.notifier)
          .criar(nome: 'José da Silva', fotoUrl: null);

      verify(
        () => mockRepository.criar(nome: 'José da Silva', fotoUrl: null),
      ).called(1);
      verify(() => mockRepository.listar()).called(greaterThanOrEqualTo(2));
    });

    test('deve atualizar médium e recarregar lista', () async {
      when(() => mockRepository.listar()).thenAnswer((_) async => [mediumFake]);
      when(() => mockRepository.salvar(any())).thenAnswer((_) async {});

      await container.read(mediunsGestorProvider.future);
      await container
          .read(mediunsGestorProvider.notifier)
          .atualizar(mediumFake);

      verify(() => mockRepository.salvar(mediumFake)).called(1);
    });

    test('deve desativar médium ativo ao alternar', () async {
      when(() => mockRepository.listar()).thenAnswer((_) async => [mediumFake]);
      when(() => mockRepository.desativar(any())).thenAnswer((_) async {});

      await container.read(mediunsGestorProvider.future);
      await container
          .read(mediunsGestorProvider.notifier)
          .alternarAtivo(mediumFake.id, ativo: true);

      verify(() => mockRepository.desativar(mediumFake.id)).called(1);
    });

    test('deve ativar médium inativo ao alternar', () async {
      final mediumInativo = mediumFake.copyWith(ativo: false);
      when(
        () => mockRepository.listar(),
      ).thenAnswer((_) async => [mediumInativo]);
      when(() => mockRepository.ativar(any())).thenAnswer((_) async {});

      await container.read(mediunsGestorProvider.future);
      await container
          .read(mediunsGestorProvider.notifier)
          .alternarAtivo(mediumInativo.id, ativo: false);

      verify(() => mockRepository.ativar(mediumInativo.id)).called(1);
    });

    test('should expor AsyncError when repositório falha no build', () async {
      when(
        () => mockRepository.listar(),
      ).thenThrow(Exception('Erro de conexão'));

      await expectLater(
        container.read(mediunsGestorProvider.future),
        throwsA(isA<Exception>()),
      );

      final state = container.read(mediunsGestorProvider);
      expect(state, isA<AsyncError>());
    });

    test('should propagar exceção when criar falha', () async {
      when(() => mockRepository.listar()).thenAnswer((_) async => []);
      when(
        () => mockRepository.criar(
          nome: any(named: 'nome'),
          fotoUrl: any(named: 'fotoUrl'),
        ),
      ).thenThrow(Exception('DB error'));

      await container.read(mediunsGestorProvider.future);

      expect(
        () =>
            container.read(mediunsGestorProvider.notifier).criar(nome: 'José'),
        throwsA(isA<Exception>()),
      );
    });

    test('should propagar exceção when atualizar falha', () async {
      when(() => mockRepository.listar()).thenAnswer((_) async => []);
      when(() => mockRepository.salvar(any())).thenThrow(Exception('DB error'));

      await container.read(mediunsGestorProvider.future);

      expect(
        () => container
            .read(mediunsGestorProvider.notifier)
            .atualizar(mediumFake),
        throwsA(isA<Exception>()),
      );
    });

    test('should propagar exceção when alternarAtivo falha', () async {
      when(() => mockRepository.listar()).thenAnswer((_) async => []);
      when(
        () => mockRepository.desativar(any()),
      ).thenThrow(Exception('DB error'));

      await container.read(mediunsGestorProvider.future);

      expect(
        () => container
            .read(mediunsGestorProvider.notifier)
            .alternarAtivo(mediumFake.id, ativo: true),
        throwsA(isA<Exception>()),
      );
    });
  });
}
