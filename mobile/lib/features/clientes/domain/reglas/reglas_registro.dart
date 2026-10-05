import '../entities/registro_asistido.dart';

final _noDigito = RegExp(r'\D');

/// "310 000-0102" → "3100000102".
String soloDigitos(String texto) => texto.replaceAll(_noDigito, '');

final _separadoresDeDocumento = RegExp(r'[\s.\-]');

/// "1.085.123.456" → "1085123456"; los pasaportes quedan en mayúsculas.
String limpiarDocumento(String numero) =>
    numero.replaceAll(_separadoresDeDocumento, '').toUpperCase();

/// Revisa el número con el patrón del tipo de documento; null si está bien.
String? problemaConDocumento(TipoDocumento? tipo, String numero) {
  if (tipo == null) return 'Elige el tipo de documento.';
  final limpio = limpiarDocumento(numero);
  if (limpio.isEmpty) return 'Escribe el número del documento.';
  final patron = tipo.patron;
  if (patron != null && !RegExp(patron).hasMatch(limpio)) {
    return 'Revisa el número: no parece de ${tipo.nombre.toLowerCase()}.';
  }
  return null;
}

String? problemaConNombres(String nombres) =>
    nombres.trim().isEmpty ? 'Escribe el nombre del cliente.' : null;

String? problemaConCelular(String celular) {
  final digitos = soloDigitos(celular);
  if (digitos.length != 10 || !digitos.startsWith('3')) {
    return 'El celular tiene 10 números y empieza por 3.';
  }
  return null;
}
