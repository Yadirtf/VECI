import '../entities/horario.dart';

/// Lo que devuelve el repositorio: los horarios y si salieron del celular (sin internet).
class ResultadoHorarios {
  const ResultadoHorarios({required this.horarios, required this.desdeCelular});

  final List<Horario> horarios;
  final bool desdeCelular;
}

/// Fuente de horarios del negocio activo. La capa de datos decide si va al API o al celular.
abstract interface class HorariosRepository {
  Future<ResultadoHorarios> obtener();
}
