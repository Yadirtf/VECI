import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/comercios_providers.dart';
import '../../domain/entities/alta.dart';

/// Catálogo de tipos de negocio para la pregunta "¿Qué vendes?".
final tiposDeNegocioProvider = FutureProvider.autoDispose<List<TipoDeNegocio>>(
  (ref) => ref.watch(comerciosRepositoryProvider).tipos(),
);
