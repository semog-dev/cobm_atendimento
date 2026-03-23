class Medium {
  const Medium({
    required this.id,
    required this.nome,
    required this.fotoUrl,
    required this.ativo,
    required this.createdAt,
  });

  final String id;
  final String nome;
  final String? fotoUrl;
  final bool ativo;
  final DateTime createdAt;

  static const _unset = Object();

  Medium copyWith({
    String? id,
    String? nome,
    Object? fotoUrl = _unset,
    bool? ativo,
    DateTime? createdAt,
  }) {
    return Medium(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      fotoUrl: identical(fotoUrl, _unset) ? this.fotoUrl : fotoUrl as String?,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'foto_url': fotoUrl,
      'ativo': ativo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Medium.fromMap(Map<String, dynamic> map) {
    return Medium(
      id: map['id'] as String,
      nome: map['nome'] as String,
      fotoUrl: map['foto_url'] as String?,
      ativo: map['ativo'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Medium &&
          id == other.id &&
          nome == other.nome &&
          fotoUrl == other.fotoUrl &&
          ativo == other.ativo &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, nome, fotoUrl, ativo, createdAt);
}
