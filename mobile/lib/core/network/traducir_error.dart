import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:veci_api/api.dart';

import '../error/fallo.dart';

const _mensajeRespaldo = 'Algo no salió bien. Intenta otra vez en un momento.';

/// Convierte lo que lanza el cliente generado en un [Fallo] que la pantalla sabe explicar.
Fallo traducirError(Object error) {
  if (error is Fallo) return error;
  if (error is SocketException || error is TimeoutException) return const SinConexion();
  if (error is! ApiException) return const ServidorNoDisponible(0);
  final interna = error.innerException;
  if (interna is Fallo) return interna;
  if (interna is SocketException || interna is IOException) return const SinConexion();
  if (error.code >= 500 || error.code == 0) return ServidorNoDisponible(error.code);
  return _rechazo(error.code, error.message);
}

/// Lee {codigo, message} del cuerpo de error de la API (RespuestaErrorDto).
PeticionRechazada _rechazo(int codigo, String? cuerpo) {
  try {
    final datos = jsonDecode(cuerpo ?? '');
    if (datos is Map<String, Object?>) {
      final mensaje = datos['message'];
      final texto = mensaje is List ? mensaje.join(' ') : mensaje;
      final motivo = datos['codigo'];
      return PeticionRechazada(
        codigo,
        texto is String ? texto : _mensajeRespaldo,
        motivo: motivo is String ? motivo : null,
      );
    }
  } on FormatException {
    // Cuerpo que no es JSON: se usa el mensaje de respaldo.
  }
  return PeticionRechazada(codigo, _mensajeRespaldo);
}
