import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cobm_atendimento/features/entidades/data/entidades_repository.dart';
import 'package:cobm_atendimento/features/entidades/domain/models/entidade.dart';
import 'package:cobm_atendimento/features/entidades/presentation/providers/entidades_provider.dart';
import '../../../../core/helpers/test_helpers.dart';

class MockEntidadesRepository extends Mock implements EntidadesRepository {}

void main() {
  late MockEntidadesRepository mockRepository;
  late ProviderContainer container;

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
    test('deve retornar lista de entidades quando repositório retorna com sucesso',
        () async {
      when(() => mockRepository.listar())
          .thenAnswer((_) async => [entidadeFake]);

      final result = await container.read(entidadesProvider.future);

      expect(result, [entidadeFake]);
      expect(result.length, 1);
    });

    test('deve retornar lista vazia quando não há entidades', () async {
      when(() => mockRepository.listar()).thenAnswer((_) async => []);

      final result = await container.read(entidadesProvider.future);

      expect(result, isEmpty);
    });

    test('deve lançar exceção quando repositório falha', () async {
      when(() => mockRepository.listar())
          .thenThrow(Exception('Erro de conexão'));

      expect(
        () => container.read(entidadesProvider.future),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('entidadesAtivasProvider', () {
    test('deve retornar apenas entidades ativas', () async {
      final inativa = entidadeFake.copyWith(ativa: false);
      when(() => mockRepository.listarAtivas())
          .thenAnswer((_) async => [entidadeFake]);

      final result = await container.read(entidadesAtivasProvider.future);

      expect(result, [entidadeFake]);
      expect(result.every((e) => e.ativa), isTrue);
    });
  });
}
