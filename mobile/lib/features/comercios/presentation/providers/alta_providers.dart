import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/comercios_providers.dart';
import '../../domain/entities/alta.dart';
import '../../domain/entities/solicitud.dart';

/// Tipos de negocio y municipios atendidos para las preguntas de la solicitud.
final catalogosAltaProvider = FutureProvider.autoDispose<CatalogosAlta>(
  (ref) => ref.watch(comerciosRepositoryProvider).catalogos(),
);

/// Las solicitudes de registro de la persona, para Ajustes.
final misSolicitudesProvider = FutureProvider.autoDispose<List<SolicitudDeNegocio>>(
  (ref) => ref.watch(comerciosRepositoryProvider).misSolicitudes(),
);
