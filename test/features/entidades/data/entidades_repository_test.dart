import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cobm_atendimento/features/entidades/data/entidades_repository.dart';

// Os métodos de EntidadesRepository usam a cadeia PostgREST do Supabase
// (from().select().eq()...), cujos tipos genéricos tornam o mock unitário
// inviável sem um wrapper. Os cenários de CRUD são cobertos nos testes de
// provider (entidades_provider_test.dart), onde o repositório inteiro é
// mockado com MockEntidadesRepository.
//
// Estes testes verificam o contrato público e o comportamento básico.

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late MockSupabaseClient mockClient;
  late EntidadesRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    repository = EntidadesRepository(client: mockClient);
  });

  group('EntidadesRepository — contrato', () {
    test('should ser instanciado corretamente', () {
      expect(repository, isA<EntidadesRepository>());
    });

    test('should expor os métodos do contrato', () {
      expect(repository.listar, isA<Function>());
      expect(repository.listarAtivas, isA<Function>());
      expect(repository.buscarPorId, isA<Function>());
      expect(repository.criar, isA<Function>());
      expect(repository.salvar, isA<Function>());
      expect(repository.ativar, isA<Function>());
      expect(repository.desativar, isA<Function>());
      expect(repository.listarMediuns, isA<Function>());
      expect(repository.vincularMedium, isA<Function>());
      expect(repository.desvincularMedium, isA<Function>());
    });
  });
}
