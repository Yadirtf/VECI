import 'horario.dart';

/// Horarios de un día de la semana, en orden de hora.
class DiaConHorarios {
  const DiaConHorarios({required this.dia, required this.nombre, required this.horarios});

  final String dia;
  final String nombre;
  final List<Horario> horarios;
}

/// La semana de servicio del negocio y de dónde salió la información.
class HorariosSemana {
  const HorariosSemana({required this.dias, required this.desdeCelular});

  final List<DiaConHorarios> dias;

  /// true si no hubo internet y se muestra lo último guardado en el celular.
  final bool desdeCelular;
}
