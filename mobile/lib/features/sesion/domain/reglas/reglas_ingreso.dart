import '../entities/sesion.dart';

/// Roles que trabajan en la caja con la app.
const rolesDeLaCaja = ['OWNER', 'CASHIER'];

/// Propietario o cajero: trabaja en la caja. Si no, es cliente de ese negocio.
bool esDeLaCaja(Espacio espacio) => espacio.roles.any(rolesDeLaCaja.contains);

/// Quita espacios, guiones y el +57.
String soloDigitosDelCelular(String texto) {
  final digitos = texto.replaceAll(RegExp(r'\D'), '');
  return digitos.length == 12 && digitos.startsWith('57') ? digitos.substring(2) : digitos;
}

/// Revisión amable antes de llamar al servidor; la regla de verdad está allá.
String? problemaConCelular(String texto) {
  final digitos = soloDigitosDelCelular(texto);
  if (digitos.isEmpty) return 'Escribe tu número de celular.';
  if (digitos.length != 10 || !digitos.startsWith('3')) {
    return 'El celular son 10 números y empieza por 3.';
  }
  return null;
}

String? problemaConPin(String pin) =>
    RegExp(r'^\d{6}$').hasMatch(pin) ? null : 'El PIN son 6 números.';

/// El negocio guardado si sigue siendo válido, o el único que tiene.
String? comercioInicial(List<Espacio> negocios, String? guardado) {
  if (guardado != null && negocios.any((n) => n.comercioId == guardado)) return guardado;
  return negocios.length == 1 ? negocios.first.comercioId : null;
}

/// Qué decirle a la persona cuando su sesión se cerró desde otro lado (HU-02-06).
String avisoDeSesionCerrada(int pendientes) {
  const base = 'Tu sesión se cerró en este celular. Entra de nuevo con tu PIN.';
  if (pendientes == 0) return base;
  if (pendientes == 1) {
    return '$base Tienes un registro guardado que aún no llega al servidor: entra para enviarlo.';
  }
  return '$base Tienes $pendientes registros guardados que aún no llegan al servidor: '
      'entra para enviarlos.';
}
