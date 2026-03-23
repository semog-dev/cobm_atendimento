class Entidade {
  const Entidade({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.ativa,
    required this.createdAt,
  });

  final String id;
  final String nome;
  final String descricao;
  final bool ativa;
  final DateTime createdAt;

  Entidade copyWith({
    String? id,
    String? nome,
    String? descricao,
    bool? ativa,
    DateTime? createdAt,
  }) {
    return Entidade(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      ativa: ativa ?? this.ativa,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'ativa': ativa,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Entidade.fromMap(Map<String, dynamic> map) {
    return Entidade(
      id: map['id'] as String,
      nome: map['nome'] as String,
      descricao: map['descricao'] as String,
      ativa: map['ativa'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entidade &&
          id == other.id &&
          nome == other.nome &&
          descricao == other.descricao &&
          ativa == other.ativa &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, nome, descricao, ativa, createdAt);
}
