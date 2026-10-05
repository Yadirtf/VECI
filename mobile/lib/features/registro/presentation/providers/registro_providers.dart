import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/registro_providers.dart';
import '../../domain/entities/registro.dart';

/// Catálogo de tipos de documento para la pregunta "¿Cuál es tu documento?".
final tiposDeDocumentoProvider = FutureProvider.autoDispose<List<TipoDocumento>>(
  (ref) => ref.watch(registroRepositoryProvider).tiposDeDocumento(),
);

/// Política de datos vigente: el "en corto" y la completa.
final politicaDeDatosProvider = FutureProvider.autoDispose<PoliticaDeDatos>(
  (ref) => ref.watch(registroRepositoryProvider).politica(),
);
