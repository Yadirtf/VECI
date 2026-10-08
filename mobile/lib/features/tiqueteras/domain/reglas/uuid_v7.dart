import 'dart:math';

/// UUID v7 (RFC 9562): 48 bits de milisegundos y 74 al azar. Ordenado por tiempo e
/// irrepetible en la práctica; es la llave que evita registrar dos veces una venta.
String uuidV7(DateTime ahora, Random azar) {
  final bytes = List<int>.generate(16, (_) => azar.nextInt(256));
  var ms = ahora.millisecondsSinceEpoch;
  for (var i = 5; i >= 0; i--) {
    bytes[i] = ms & 0xff;
    ms >>= 8;
  }
  bytes[6] = 0x70 | (bytes[6] & 0x0f);
  bytes[8] = 0x80 | (bytes[8] & 0x3f);
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
      '${hex.substring(16, 20)}-${hex.substring(20)}';
}
