import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_tarjeta.dart';
import '../../domain/entities/horarios_semana.dart';
import 'hora_legible.dart';

/// Tarjeta con los servicios de un día: "Lunes · Almuerzo 11:30 a. m. – 3:00 p. m.".
class DiaHorariosCard extends StatelessWidget {
  const DiaHorariosCard({super.key, required this.dia});

  final DiaConHorarios dia;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return VeciTarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dia.nombre, style: textos.titleLarge),
          const SizedBox(height: VeciEspacio.s),
          for (final horario in dia.horarios)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: VeciEspacio.xs),
              child: Row(
                children: [
                  Expanded(child: Text(horario.servicioNombre, style: textos.titleMedium)),
                  Text(
                    '${horaLegible(horario.horaInicio)} – ${horaLegible(horario.horaFin)}',
                    style: const TextStyle(color: VeciColores.tintaSuave),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
