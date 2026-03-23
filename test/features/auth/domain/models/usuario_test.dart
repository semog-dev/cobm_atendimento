import 'package:flutter_test/flutter_test.dart';
import 'package:cobm_atendimento/features/auth/domain/models/usuario.dart';

void main() {
  group('Usuario', () {
    final usuario = Usuario(
      id: '123',
      nome: 'João Silva',
      telefone: '11999999999',
      role: Role.cliente,
      createdAt: DateTime(2024, 1, 1),
    );

    test('deve criar usuário com todos os campos', () {
      expect(usuario.id, '123');
      expect(usuario.nome, 'João Silva');
      expect(usuario.telefone, '11999999999');
      expect(usuario.role, Role.cliente);
      expect(usuario.createdAt, DateTime(2024, 1, 1));
    });

    test('deve retornar true para isGestor quando role é gestor', () {
      final gestor = usuario.copyWith(role: Role.gestor);
      expect(gestor.isGestor, isTrue);
      expect(gestor.isCliente, isFalse);
    });

    test('deve retornar true para isCliente quando role é cliente', () {
      expect(usuario.isCliente, isTrue);
      expect(usuario.isGestor, isFalse);
    });

    test('deve ser igual quando todos os campos são iguais', () {
      final outro = Usuario(
        id: '123',
        nome: 'João Silva',
        telefone: '11999999999',
        role: Role.cliente,
        createdAt: DateTime(2024, 1, 1),
      );
      expect(usuario, equals(outro));
    });

    test('deve criar cópia com campo alterado via copyWith', () {
      final atualizado = usuario.copyWith(nome: 'Maria');
      expect(atualizado.nome, 'Maria');
      expect(atualizado.id, usuario.id);
    });

    test('deve serializar para map corretamente', () {
      final map = usuario.toMap();
      expect(map['id'], '123');
      expect(map['nome'], 'João Silva');
      expect(map['telefone'], '11999999999');
      expect(map['role'], 'cliente');
    });

    test('deve desserializar de map corretamente', () {
      final map = {
        'id': '123',
        'nome': 'João Silva',
        'telefone': '11999999999',
        'role': 'gestor',
        'created_at': '2024-01-01T00:00:00.000',
      };
      final fromMap = Usuario.fromMap(map);
      expect(fromMap.id, '123');
      expect(fromMap.role, Role.gestor);
    });
  });
}
