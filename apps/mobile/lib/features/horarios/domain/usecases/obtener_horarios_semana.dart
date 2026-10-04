import '../entities/horario.dart';
import '../entities/horarios_semana.dart';
import '../repositories/horarios_repository.dart';

/// Días de la semana en orden colombiano (lunes primero).
const _dias = [
  ('MONDAY', 'Lunes'),
  ('TUESDAY', 'Martes'),
  ('WEDNESDAY', 'Miércoles'),
  ('THURSDAY', 'Jueves'),
  ('FRIDAY', 'Viernes'),
  ('SATURDAY', 'Sábado'),
  ('SUNDAY', 'Domingo'),
];

/// Caso de uso: ver la semana de servicio, agrupada por día y ordenada por hora.
class ObtenerHorariosSemana {
  const ObtenerHorariosSemana(this._repositorio);

  final HorariosRepository _repositorio;

  Future<HorariosSemana> ejecutar() async {
    final resultado = await _repositorio.obtener();
    return HorariosSemana(dias: agrupar(resultado.horarios), desdeCelular: resultado.desdeCelular);
  }

  static List<DiaConHorarios> agrupar(List<Horario> horarios) => [
    for (final (dia, nombre) in _dias)
      if (horarios.any((h) => h.dia == dia))
        DiaConHorarios(
          dia: dia,
          nombre: nombre,
          horarios: horarios.where((h) => h.dia == dia).toList()
            ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio)),
        ),
  ];
}
