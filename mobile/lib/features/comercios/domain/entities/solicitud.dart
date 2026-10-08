/// En qué va la solicitud para registrar un negocio: VECI la revisa antes de crearlo.
enum EstadoSolicitud { enRevision, aprobada, rechazada }

/// Solicitud de registro de negocio que hizo la persona (HU-03-01).
class SolicitudDeNegocio {
  const SolicitudDeNegocio({
    required this.id,
    required this.nombre,
    required this.estado,
    required this.radicadaEn,
    this.nota,
    this.comercioId,
  });

  final String id;
  final String nombre;
  final EstadoSolicitud estado;
  final DateTime radicadaEn;

  /// Por qué se rechazó, en palabras para la persona.
  final String? nota;

  /// El negocio que nació al aprobarla.
  final String? comercioId;
}
