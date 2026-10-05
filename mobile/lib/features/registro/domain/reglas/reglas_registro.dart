import '../entities/registro.dart';

/// Motivos de la API cuando la persona ya está en VECI: se le ofrece entrar.
const motivosParaEntrar = {'YA_TIENE_CUENTA', 'YA_TE_ANOTARON'};

/// La política cambió mientras la leía: hay que mostrarle la nueva.
const motivoPoliticaDesactualizada = 'POLITICA_DESACTUALIZADA';

String soloDigitos(String texto) => texto.replaceAll(RegExp(r'\D'), '');

/// El celular sin espacios, guiones ni +57.
String celularLimpio(String texto) {
  final digitos = soloDigitos(texto);
  return digitos.length == 12 && digitos.startsWith('57') ? digitos.substring(2) : digitos;
}

/// El número del documento sin espacios, puntos ni guiones, en mayúsculas (pasaporte).
String documentoLimpio(String texto) => texto.replaceAll(RegExp(r'[\s.\-]'), '').toUpperCase();

TipoDocumento? tipoElegido(BorradorRegistro b, List<TipoDocumento> tipos) =>
    tipos.where((t) => t.codigo == b.tipoDocumento).firstOrNull;

/// Si el número es solo de dígitos, el teclado sale numérico.
bool esSoloNumeros(TipoDocumento? tipo) => tipo?.patron?.startsWith('^[0-9]') ?? false;

/// Revisión amable antes de llamar al servidor; la regla de verdad está allá.
String? problemaEnPaso(PasoRegistro paso, BorradorRegistro b, List<TipoDocumento> tipos) =>
    switch (paso) {
      PasoRegistro.celular => _problemaConCelular(b.celular),
      PasoRegistro.nombre when b.nombres.trim().length < 2 => '¿Cómo te llamas? Escribe tu nombre.',
      PasoRegistro.documento => _problemaConDocumento(b, tipoElegido(b, tipos)),
      PasoRegistro.pin => _problemaConPin(b),
      _ => null,
    };

String? _problemaConCelular(String texto) {
  final digitos = celularLimpio(texto);
  if (digitos.isEmpty) return 'Escribe tu número de celular.';
  if (digitos.length != 10 || !digitos.startsWith('3')) {
    return 'El celular son 10 números y empieza por 3.';
  }
  return null;
}

String? _problemaConDocumento(BorradorRegistro b, TipoDocumento? tipo) {
  if (tipo == null) return 'Toca el tipo de documento que tienes.';
  final numero = documentoLimpio(b.numeroDocumento);
  if (numero.isEmpty) return 'Escribe el número de tu documento.';
  final patron = tipo.patron;
  if (patron != null && !RegExp(patron).hasMatch(numero)) {
    return 'Revisa el número: no se ve como un documento de tipo ${tipo.nombre}.';
  }
  return null;
}

String? _problemaConPin(BorradorRegistro b) {
  if (!RegExp(r'^\d{6}$').hasMatch(b.pin)) return 'El PIN son 6 números.';
  return b.pin == b.pinRepetido ? null : 'Los dos PIN no coinciden. Escríbelo otra vez.';
}
