import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cobm_atendimento/features/entidades/data/entidades_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late MockSupabaseClient mockClient;
  late EntidadesRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    repository = EntidadesRepository(client: mockClient);
  });

  group('EntidadesRepository', () {
    test('deve ser instanciado corretamente', () {
      expect(repository, isA<EntidadesRepository>());
    });

    test('deve expor os métodos do contrato', () {
      expect(repository.listar, isA<Function>());
      expect(repository.listarAtivas, isA<Function>());
      expect(repository.buscarPorId, isA<Function>());
      expect(repository.salvar, isA<Function>());
      expect(repository.ativar, isA<Function>());
      expect(repository.desativar, isA<Function>());
    });
  });
}
