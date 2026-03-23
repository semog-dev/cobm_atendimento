import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cobm_atendimento/features/fila/data/fila_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late MockSupabaseClient mockClient;
  late FilaRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    repository = FilaRepository(client: mockClient);
  });

  group('FilaRepository', () {
    test('deve ser instanciado corretamente', () {
      expect(repository, isA<FilaRepository>());
    });

    test('deve expor os métodos do contrato', () {
      expect(repository.entrarNaFila, isA<Function>());
      expect(repository.cancelarEntrada, isA<Function>());
      expect(repository.chamarProximo, isA<Function>());
      expect(repository.iniciarAtendimento, isA<Function>());
      expect(repository.encerrarAtendimento, isA<Function>());
      expect(repository.listarPorSessao, isA<Function>());
      expect(repository.buscarEntradaDoCliente, isA<Function>());
    });
  });
}
