import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cobm_atendimento/features/entidades/data/entidades_repository.dart';
import 'package:cobm_atendimento/features/entidades/domain/models/entidade.dart';
import 'package:cobm_atendimento/core/config/supabase_config.dart';

final entidadesRepositoryProvider = Provider<EntidadesRepository>((ref) {
  return EntidadesRepository(client: supabase);
});

final entidadesProvider = FutureProvider<List<Entidade>>((ref) {
  return ref.read(entidadesRepositoryProvider).listar();
});

final entidadesAtivasProvider = FutureProvider<List<Entidade>>((ref) {
  return ref.read(entidadesRepositoryProvider).listarAtivas();
});
