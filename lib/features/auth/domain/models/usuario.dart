enum Role { gestor, cliente }

class Usuario {
  const Usuario({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String nome;
  final String telefone;
  final Role role;
  final DateTime createdAt;

  bool get isGestor => role == Role.gestor;
  bool get isCliente => role == Role.cliente;

  Usuario copyWith({
    String? id,
    String? nome,
    String? telefone,
    Role? role,
    DateTime? createdAt,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'role': role.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as String,
      nome: map['nome'] as String,
      telefone: map['telefone'] as String,
      role: Role.values.byName(map['role'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Usuario &&
          id == other.id &&
          nome == other.nome &&
          telefone == other.telefone &&
          role == other.role &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, nome, telefone, role, createdAt);
}
