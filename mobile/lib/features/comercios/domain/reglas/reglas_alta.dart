import '../entities/alta.dart';

String soloDigitos(String texto) => texto.replaceAll(RegExp(r'\D'), '');

const _pesosDian = [3, 7, 13, 17, 19, 23, 29, 37, 41, 43, 47, 53, 59, 67, 71];

/// Dígito de verificación del NIT (DIAN, módulo 11). Lo pone VECI, no la persona.
int digitoVerificacion(String nit) {
  final digitos = soloDigitos(nit).split('').reversed.map(int.parse).toList();
  var suma = 0;
  for (var i = 0; i < digitos.length; i++) {
    suma += digitos[i] * _pesosDian[i];
  }
  final residuo = suma % 11;
  return residuo > 1 ? 11 - residuo : residuo;
}

/// Documento como lo guarda VECI: el NIT con su dígito al final.
String documentoCompleto(BorradorAlta b) {
  final digitos = soloDigitos(b.documento);
  return b.esNit ? '$digitos${digitoVerificacion(digitos)}' : digitos;
}

/// Qué falta para seguir; null = puede avanzar. La regla de verdad vive en el servidor.
String? problemaEnPaso(PasoAlta paso, BorradorAlta b) => switch (paso) {
  PasoAlta.nombre when b.nombre.trim().length < 3 => '¿Cómo te conoce la gente? Mínimo 3 letras.',
  PasoAlta.tipo when b.tipoNegocio.isEmpty => 'Toca el que más se parezca a tu negocio.',
  PasoAlta.documento when b.esNit && !RegExp(r'^\d{8,9}$').hasMatch(soloDigitos(b.documento)) =>
    'Escribe los 9 números del NIT. El dígito de verificación lo ponemos nosotros.',
  PasoAlta.documento when !b.esNit && !RegExp(r'^\d{6,10}$').hasMatch(soloDigitos(b.documento)) =>
    'La cédula tiene de 6 a 10 números.',
  PasoAlta.contacto when !RegExp(r'^3\d{9}$').hasMatch(soloDigitos(b.celular)) =>
    'El celular son 10 números y empieza por 3.',
  _ => null,
};

/// Inicial para el sello del negocio cuando no hay logo.
String inicialDe(String nombre) {
  final palabras = nombre
      .trim()
      .split(RegExp(r'\s+'))
      .where(
        (p) => !RegExp(
          r'^(restaurante|cafeter[ií]a|panader[ií]a|tienda|colegio|el|la|los|las|de)$',
          caseSensitive: false,
        ).hasMatch(p),
      );
  final base = palabras.isEmpty ? nombre.trim() : palabras.first;
  return base.isEmpty ? 'V' : base[0].toUpperCase();
}
