import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cobm_atendimento/features/sessao/data/sessao_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late MockSupabaseClient mockClient;
  late SessaoRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    repository = SessaoRepository(client: mockClient);
  });

  group('SessaoRepository', () {
    test('deve ser instanciado corretamente', () {
      expect(repository, isA<SessaoRepository>());
    });

    test('deve expor os métodos do contrato', () {
      expect(repository.abrirSessao, isA<Function>());
      expect(repository.encerrarSessao, isA<Function>());
      expect(repository.buscarSessaoAberta, isA<Function>());
      expect(repository.listar, isA<Function>());
    });
  });
}
