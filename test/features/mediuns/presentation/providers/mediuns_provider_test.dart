import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cobm_atendimento/features/mediuns/data/mediuns_repository.dart';
import 'package:cobm_atendimento/features/mediuns/domain/models/medium.dart';
import 'package:cobm_atendimento/features/mediuns/presentation/providers/mediuns_provider.dart';
import '../../../../core/helpers/test_helpers.dart';

class MockMediunsRepository extends Mock implements MediunsRepository {}

void main() {
  late MockMediunsRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockMediunsRepository();
    container = ProviderContainer(
      overrides: [
        mediunsRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('mediunsProvider', () {
    test('deve retornar lista de médiuns quando repositório retorna com sucesso',
        () async {
      when(() => mockRepository.listar())
          .thenAnswer((_) async => [mediumFake]);

      final result = await container.read(mediunsProvider.future);

      expect(result, [mediumFake]);
      expect(result.length, 1);
    });

    test('deve retornar lista vazia quando não há médiuns', () async {
      when(() => mockRepository.listar()).thenAnswer((_) async => []);

      final result = await container.read(mediunsProvider.future);

      expect(result, isEmpty);
    });

    test('deve lançar exceção quando repositório falha', () async {
      when(() => mockRepository.listar())
          .thenThrow(Exception('Erro de conexão'));

      expect(
        () => container.read(mediunsProvider.future),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('mediunsAtivosProvider', () {
    test('deve retornar apenas médiuns ativos', () async {
      when(() => mockRepository.listarAtivos())
          .thenAnswer((_) async => [mediumFake]);

      final result = await container.read(mediunsAtivosProvider.future);

      expect(result, [mediumFake]);
      expect(result.every((m) => m.ativo), isTrue);
    });
  });
}
