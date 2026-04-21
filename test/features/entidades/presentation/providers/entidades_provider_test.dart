import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cobm_atendimento/features/entidades/data/entidades_repository.dart';
import 'package:cobm_atendimento/features/entidades/presentation/providers/entidades_provider.dart';
import '../../../../core/helpers/test_helpers.dart';

class MockEntidadesRepository extends Mock implements EntidadesRepository {}

void main() {
  late MockEntidadesRepository mockRepository;
  late ProviderContainer container;

  setUpAll(() => registerFallbackValue(entidadeFake));

  setUp(() {
    mockRepository = MockEntidadesRepository();
    container = ProviderContainer(
      overrides: [
        entidadesRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('entidadesProvider', () {
    test(
      'deve retornar lista de entidades quando repositório retorna com sucesso',
      () async {
        when(
          () => mockRepository.listar(),
        ).thenAnswer((_) async => [entidadeFake]);

        final result = await container.read(entidadesProvider.future);

        expect(result, [entidadeFake]);
        expect(result.length, 1);
      },
    );

    test('deve retornar lista vazia quando não há entidades', () async {
      when(() => mockRepository.listar()).thenAnswer((_) async => []);

      final result = await container.read(entidadesProvider.future);

      expect(result, isEmpty);
    });

    test('deve lançar exceção quando repositório falha', () async {
      when(
        () => mockRepository.listar(),
      ).thenThrow(Exception('Erro de conexão'));

      expect(
        () => container.read(entidadesProvider.future),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('entidadesAtivasProvider', () {
    test('deve retornar apenas entidades ativas', () async {
      when(
        () => mockRepository.listarAtivas(),
      ).thenAnswer((_) async => [entidadeFake]);

      final result = await container.read(entidadesAtivasProvider.future);

      expect(result, [entidadeFake]);
      expect(result.every((e) => e.ativa), isTrue);
    });
  });

  group('EntidadesGestorNotifier', () {
    test('deve carregar lista de entidades ao iniciar', () async {
      when(
        () => mockRepository.listar(),
      ).thenAnswer((_) async => [entidadeFake]);

      final result = await container.read(entidadesGestorProvider.future);

      expect(result, [entidadeFake]);
    });

    test('deve criar entidade sem médiuns vinculados', () async {
      when(
        () => mockRepository.listar(),
      ).thenAnswer((_) async => [entidadeFake]);
      when(
        () => mockRepository.criar(
          nome: any(named: 'nome'),
          descricao: any(named: 'descricao'),
        ),
      ).thenAnswer((_) async => entidadeFake);

      await container
          .read(entidadesGestorProvider.notifier)
          .criar(
            nome: 'Exu Tranca Ruas',
            descricao: 'Guardião das encruzilhadas',
          );

      verify(
        () => mockRepository.criar(
          nome: 'Exu Tranca Ruas',
          descricao: 'Guardião das encruzilhadas',
        ),
      ).called(1);
      verifyNever(
        () => mockRepository.vincularMedium(
          entidadeId: any(named: 'entidadeId'),
          mediumId: any(named: 'mediumId'),
        ),
      );
    });

    test('deve criar entidade e vincular médiuns selecionados', () async {
      when(
        () => mockRepository.listar(),
      ).thenAnswer((_) async => [entidadeFake]);
      when(
        () => mockRepository.criar(
          nome: any(named: 'nome'),
          descricao: any(named: 'descricao'),
        ),
      ).thenAnswer((_) async => entidadeFake);
      when(
        () => mockRepository.vincularMedium(
          entidadeId: any(named: 'entidadeId'),
          mediumId: any(named: 'mediumId'),
        ),
      ).thenAnswer((_) async {});

      await container
          .read(entidadesGestorProvider.notifier)
          .criar(nome: 'Exu', mediumIds: {mediumFake.id});

      verify(
        () => mockRepository.vincularMedium(
          entidadeId: entidadeFake.id,
          mediumId: mediumFake.id,
        ),
      ).called(1);
    });

    test('deve vincular novos médiuns ao atualizar vínculos', () async {
      when(
        () => mockRepository.listar(),
      ).thenAnswer((_) async => [entidadeFake]);
      when(
        () => mockRepository.vincularMedium(
          entidadeId: any(named: 'entidadeId'),
          mediumId: any(named: 'mediumId'),
        ),
      ).thenAnswer((_) async {});

      await container
          .read(entidadesGestorProvider.notifier)
          .atualizarVinculos(
            entidadeId: entidadeFake.id,
            novosIds: {mediumFake.id},
            idsAntigos: {},
          );

      verify(
        () => mockRepository.vincularMedium(
          entidadeId: entidadeFake.id,
          mediumId: mediumFake.id,
        ),
      ).called(1);
    });

    test('deve desvincular médiuns removidos ao atualizar vínculos', () async {
      when(
        () => mockRepository.listar(),
      ).thenAnswer((_) async => [entidadeFake]);
      when(
        () => mockRepository.desvincularMedium(
          entidadeId: any(named: 'entidadeId'),
          mediumId: any(named: 'mediumId'),
        ),
      ).thenAnswer((_) async {});

      await container
          .read(entidadesGestorProvider.notifier)
          .atualizarVinculos(
            entidadeId: entidadeFake.id,
            novosIds: {},
            idsAntigos: {mediumFake.id},
          );

      verify(
        () => mockRepository.desvincularMedium(
          entidadeId: entidadeFake.id,
          mediumId: mediumFake.id,
        ),
      ).called(1);
    });

    test('deve atualizar entidade e recarregar lista', () async {
      when(
        () => mockRepository.listar(),
      ).thenAnswer((_) async => [entidadeFake]);
      when(() => mockRepository.salvar(any())).thenAnswer((_) async {});

      await container
          .read(entidadesGestorProvider.notifier)
          .atualizar(entidadeFake);

      verify(() => mockRepository.salvar(entidadeFake)).called(1);
    });

    test('deve desativar entidade ativa ao alternar', () async {
      when(
        () => mockRepository.listar(),
      ).thenAnswer((_) async => [entidadeFake]);
      when(() => mockRepository.desativar(any())).thenAnswer((_) async {});

      await container
          .read(entidadesGestorProvider.notifier)
          .alternarAtiva(entidadeFake.id, ativa: true);

      verify(() => mockRepository.desativar(entidadeFake.id)).called(1);
    });

    test('deve ativar entidade inativa ao alternar', () async {
      when(
        () => mockRepository.listar(),
      ).thenAnswer((_) async => [entidadeFake]);
      when(() => mockRepository.ativar(any())).thenAnswer((_) async {});

      await container
          .read(entidadesGestorProvider.notifier)
          .alternarAtiva(entidadeFake.id, ativa: false);

      verify(() => mockRepository.ativar(entidadeFake.id)).called(1);
    });

    test('should expor AsyncError when repositório falha no build', () async {
      when(
        () => mockRepository.listar(),
      ).thenThrow(Exception('Erro de conexão'));

      await expectLater(
        container.read(entidadesGestorProvider.future),
        throwsA(isA<Exception>()),
      );

      final state = container.read(entidadesGestorProvider);
      expect(state, isA<AsyncError>());
    });

    test('should propagar exceção when criar falha', () async {
      when(() => mockRepository.listar()).thenAnswer((_) async => []);
      when(
        () => mockRepository.criar(
          nome: any(named: 'nome'),
          descricao: any(named: 'descricao'),
        ),
      ).thenThrow(Exception('Duplicate entry'));

      await container.read(entidadesGestorProvider.future);

      expect(
        () =>
            container.read(entidadesGestorProvider.notifier).criar(nome: 'Exu'),
        throwsA(isA<Exception>()),
      );
    });

    test('should propagar exceção when atualizar falha', () async {
      when(() => mockRepository.listar()).thenAnswer((_) async => []);
      when(() => mockRepository.salvar(any())).thenThrow(Exception('DB error'));

      await container.read(entidadesGestorProvider.future);

      expect(
        () => container
            .read(entidadesGestorProvider.notifier)
            .atualizar(entidadeFake),
        throwsA(isA<Exception>()),
      );
    });

    test('should propagar exceção when alternarAtiva falha', () async {
      when(() => mockRepository.listar()).thenAnswer((_) async => []);
      when(
        () => mockRepository.desativar(any()),
      ).thenThrow(Exception('DB error'));

      await container.read(entidadesGestorProvider.future);

      expect(
        () => container
            .read(entidadesGestorProvider.notifier)
            .alternarAtiva(entidadeFake.id, ativa: true),
        throwsA(isA<Exception>()),
      );
    });
  });
}
