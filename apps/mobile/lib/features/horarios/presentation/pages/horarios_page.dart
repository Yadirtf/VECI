import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/fallo.dart';
import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_boton.dart';
import '../../domain/entities/horarios_semana.dart';
import '../providers/horarios_controller.dart';
import '../widgets/dia_horarios_card.dart';

/// Horarios de servicio de la semana. Funciona sin internet con lo último guardado.
class HorariosPage extends ConsumerWidget {
  const HorariosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(horariosSemanaProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Horarios de servicio')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(horariosSemanaProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(VeciEspacio.m),
          children: switch (estado) {
            AsyncData(:final value) => _semana(value),
            AsyncError(:final error) => _error(error, () => ref.invalidate(horariosSemanaProvider)),
            _ => const [Center(child: CircularProgressIndicator())],
          },
        ),
      ),
    );
  }

  List<Widget> _semana(HorariosSemana semana) => [
    if (semana.desdeCelular)
      const VeciAviso(
        tono: TonoAviso.aviso,
        mensaje: 'Estás sin internet. Te mostramos los horarios que guardamos en tu celular.',
      ),
    if (semana.dias.isEmpty)
      const VeciAviso(
        tono: TonoAviso.aviso,
        mensaje: 'Aún no tienes horarios de servicio. El dueño los crea desde el panel.',
      ),
    for (final dia in semana.dias) ...[
      const SizedBox(height: VeciEspacio.m),
      DiaHorariosCard(dia: dia),
    ],
  ];

  List<Widget> _error(Object error, VoidCallback reintentar) => [
    VeciAviso(tono: TonoAviso.error, mensaje: _mensaje(error)),
    const SizedBox(height: VeciEspacio.l),
    VeciBoton(texto: 'Intentar de nuevo', icono: Icons.refresh, alTocar: reintentar),
  ];

  static String _mensaje(Object error) => switch (error) {
    SinConexion() => 'No hay internet y aún no guardamos tus horarios. Conéctate una vez, veci.',
    PeticionRechazada(codigo: 403) => 'No tienes acceso a este negocio. Habla con el dueño.',
    _ => 'No pudimos traer tus horarios. Intenta de nuevo en un momento.',
  };
}
