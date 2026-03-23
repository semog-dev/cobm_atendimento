import 'package:flutter_test/flutter_test.dart';
import 'package:cobm_atendimento/features/entidades/domain/models/entidade.dart';

void main() {
  group('Entidade', () {
    final entidade = Entidade(
      id: 'uuid-001',
      nome: 'Exu Tranca Ruas',
      descricao: 'Guardião das encruzilhadas',
      ativa: true,
      createdAt: DateTime(2024, 1, 1),
    );

    test('deve criar entidade com todos os campos', () {
      expect(entidade.id, 'uuid-001');
      expect(entidade.nome, 'Exu Tranca Ruas');
      expect(entidade.descricao, 'Guardião das encruzilhadas');
      expect(entidade.ativa, isTrue);
      expect(entidade.createdAt, DateTime(2024, 1, 1));
    });

    test('deve ser igual quando todos os campos são iguais', () {
      final outra = Entidade(
        id: 'uuid-001',
        nome: 'Exu Tranca Ruas',
        descricao: 'Guardião das encruzilhadas',
        ativa: true,
        createdAt: DateTime(2024, 1, 1),
      );
      expect(entidade, equals(outra));
    });

    test('deve criar cópia com campo alterado via copyWith', () {
      final atualizada = entidade.copyWith(ativa: false);
      expect(atualizada.ativa, isFalse);
      expect(atualizada.id, entidade.id);
      expect(atualizada.nome, entidade.nome);
    });

    test('deve serializar para map corretamente', () {
      final map = entidade.toMap();
      expect(map['id'], 'uuid-001');
      expect(map['nome'], 'Exu Tranca Ruas');
      expect(map['descricao'], 'Guardião das encruzilhadas');
      expect(map['ativa'], isTrue);
      expect(map.containsKey('foto_url'), isFalse);
    });

    test('deve desserializar de map corretamente', () {
      final map = {
        'id': 'uuid-001',
        'nome': 'Exu Tranca Ruas',
        'descricao': 'Guardião das encruzilhadas',
        'ativa': true,
        'created_at': '2024-01-01T00:00:00.000',
      };
      final fromMap = Entidade.fromMap(map);
      expect(fromMap.id, 'uuid-001');
      expect(fromMap.nome, 'Exu Tranca Ruas');
      expect(fromMap.ativa, isTrue);
    });
  });
}
