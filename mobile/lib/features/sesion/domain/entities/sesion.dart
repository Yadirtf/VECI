/// Negocio donde la persona trabaja o es cliente.
class Espacio {
  const Espacio({
    required this.comercioId,
    required this.nombre,
    required this.roles,
    required this.invitacionPendiente,
  });

  final String comercioId;
  final String nombre;
  final List<String> roles;
  final bool invitacionPendiente;
}

/// Sesión recién abierta o renovada. El token de renovación se guarda cifrado en el celular.
class SesionAbierta {
  const SesionAbierta({
    required this.tokenAcceso,
    required this.tokenRenovacion,
    required this.venceEn,
    required this.nombre,
    required this.espacios,
  });

  final String tokenAcceso;
  final String tokenRenovacion;
  final DateTime venceEn;
  final String nombre;
  final List<Espacio> espacios;
}

/// Resultado de entrar con celular y PIN.
sealed class ResultadoIngreso {
  const ResultadoIngreso();
}

final class IngresoConSesion extends ResultadoIngreso {
  const IngresoConSesion(this.sesion);

  final SesionAbierta sesion;
}

/// Entró con un PIN temporal: debe crear el suyo antes de seguir (HU-02-05).
final class IngresoConCambioDePin extends ResultadoIngreso {
  const IngresoConCambioDePin({required this.tokenCambio, required this.nombre});

  final String tokenCambio;
  final String nombre;
}
