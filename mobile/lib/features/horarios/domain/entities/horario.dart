/// Horario de servicio de una sede: "Almuerzo, lunes de 11:30 a 15:00".
class Horario {
  const Horario({
    required this.id,
    required this.servicioNombre,
    required this.sedeId,
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
  });

  final String id;
  final String servicioNombre;
  final String sedeId;

  /// Código del día en el catálogo (MONDAY...).
  final String dia;
  final String horaInicio;
  final String horaFin;
}
