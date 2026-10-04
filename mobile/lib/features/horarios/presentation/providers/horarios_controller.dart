import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/horarios_providers.dart';
import '../../domain/entities/horarios_semana.dart';

/// Estado de la pantalla de horarios: ejecuta el caso de uso y permite refrescar.
final horariosSemanaProvider = FutureProvider.autoDispose<HorariosSemana>(
  (ref) => ref.watch(obtenerHorariosSemanaProvider).ejecutar(),
);
