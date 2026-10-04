/// "11:30" → "11:30 a. m."; "15:00" → "3:00 p. m."
String horaLegible(String hora) {
  final partes = hora.split(':').map(int.parse).toList();
  final sufijo = partes[0] < 12 ? 'a. m.' : 'p. m.';
  final hora12 = partes[0] % 12 == 0 ? 12 : partes[0] % 12;
  return '$hora12:${partes[1].toString().padLeft(2, '0')} $sufijo';
}
