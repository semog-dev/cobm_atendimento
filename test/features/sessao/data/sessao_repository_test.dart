import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cobm_atendimento/features/sessao/data/sessao_repository.dart';

// Os métodos de SessaoRepository usam a cadeia PostgREST do Supabase.
// Os cenários de CRUD são cobertos nos testes de provider
// (sessao_provider_test.dart), onde o repositório inteiro é mockado.

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late MockSupabaseClient mockClient;
  late SessaoRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    repository = SessaoRepository(client: mockClient);
  });

  group('SessaoRepository — contrato', () {
    test('should ser instanciado corretamente', () {
      expect(repository, isA<SessaoRepository>());
    });

    test('should expor os métodos do contrato', () {
      expect(repository.abrirSessao, isA<Function>());
      expect(repository.encerrarSessao, isA<Function>());
      expect(repository.buscarSessaoAberta, isA<Function>());
      expect(repository.listar, isA<Function>());
      expect(repository.listarMediumEntidades, isA<Function>());
      expect(repository.listarMediumEntidadesDaSessao, isA<Function>());
      expect(repository.vincularMediumEntidade, isA<Function>());
    });
  });
}
