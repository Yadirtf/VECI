import '../entities/horario.dart';

/// Códigos de día en el orden de [DateTime.weekday] (1 = lunes).
const diasDeLaSemana = [
  'MONDAY',
  'TUESDAY',
  'WEDNESDAY',
  'THURSDAY',
  'FRIDAY',
  'SATURDAY',
  'SUNDAY',
];

/// En qué punto del día de servicio está el negocio: lo que la cajera necesita saber
/// de un vistazo antes de registrar un consumo, aun sin internet (HU-03-02).
sealed class MomentoDelServicio {
  const MomentoDelServicio();
}

/// Hay un servicio abierto ahora; [faltan] minutos para que cierre.
final class EnServicio extends MomentoDelServicio {
  const EnServicio(this.horario, this.faltan);
  final Horario horario;
  final int faltan;
}

/// Todavía no abre el siguiente servicio; [faltan] minutos para empezar.
final class AntesDeServicio extends MomentoDelServicio {
  const AntesDeServicio(this.horario, this.faltan);
  final Horario horario;
  final int faltan;
}

/// Ya pasaron todos los servicios de hoy.
final class CerradoPorHoy extends MomentoDelServicio {
  const CerradoPorHoy();
}

/// Hoy no hay servicios (o todos están en pausa).
final class DiaDeDescanso extends MomentoDelServicio {
  const DiaDeDescanso();
}

/// Horarios activos de ese día de la semana, en orden de hora.
List<Horario> horariosDelDia(List<Horario> horarios, DateTime fecha) {
  final codigo = diasDeLaSemana[fecha.weekday - 1];
  return horarios.where((h) => h.dia == codigo && h.activo).toList()
    ..sort((a, b) => a.minutoInicio.compareTo(b.minutoInicio));
}

MomentoDelServicio momentoDelServicio(List<Horario> horarios, DateTime ahora) {
  final hoy = horariosDelDia(horarios, ahora);
  if (hoy.isEmpty) return const DiaDeDescanso();
  final minuto = ahora.hour * 60 + ahora.minute;
  for (final h in hoy) {
    if (minuto < h.minutoInicio) return AntesDeServicio(h, h.minutoInicio - minuto);
    if (minuto < h.minutoFin) return EnServicio(h, h.minutoFin - minuto);
  }
  return const CerradoPorHoy();
}
