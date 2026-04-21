import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cobm_atendimento/features/mediuns/data/mediuns_repository.dart';

// Os métodos de MediunsRepository usam a cadeia PostgREST do Supabase.
// Os cenários de CRUD são cobertos nos testes de provider
// (mediuns_provider_test.dart), onde o repositório inteiro é mockado.

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late MockSupabaseClient mockClient;
  late MediunsRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    repository = MediunsRepository(client: mockClient);
  });

  group('MediunsRepository — contrato', () {
    test('should ser instanciado corretamente', () {
      expect(repository, isA<MediunsRepository>());
    });

    test('should expor os métodos do contrato', () {
      expect(repository.listar, isA<Function>());
      expect(repository.listarAtivos, isA<Function>());
      expect(repository.buscarPorId, isA<Function>());
      expect(repository.criar, isA<Function>());
      expect(repository.salvar, isA<Function>());
      expect(repository.ativar, isA<Function>());
      expect(repository.desativar, isA<Function>());
      expect(repository.listarEntidades, isA<Function>());
      expect(repository.vincularEntidade, isA<Function>());
      expect(repository.desvincularEntidade, isA<Function>());
    });
  });
}
