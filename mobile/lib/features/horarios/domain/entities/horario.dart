/// Horario de servicio de una sede: "Almuerzo, lunes de 11:30 a 15:00".
class Horario {
  const Horario({
    required this.id,
    required this.servicioNombre,
    required this.sedeId,
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
    this.activo = true,
  });

  final String id;
  final String servicioNombre;
  final String sedeId;

  /// Código del día en el catálogo (MONDAY...).
  final String dia;
  final String horaInicio;
  final String horaFin;

  /// false = en pausa: el dueño lo apagó y la caja no lo cuenta.
  final bool activo;

  int get minutoInicio => _minutos(horaInicio);
  int get minutoFin => _minutos(horaFin);

  static int _minutos(String hora) {
    final partes = hora.split(':').map(int.parse).toList();
    return partes[0] * 60 + partes[1];
  }
}
