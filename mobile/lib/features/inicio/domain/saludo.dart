/// Saludo según la hora, como lo diría un vecino: "Buenos días", "Buenas tardes"...
String saludoDelDia(DateTime ahora) => switch (ahora.hour) {
  >= 5 && < 12 => 'Buenos días',
  >= 12 && < 19 => 'Buenas tardes',
  _ => 'Buenas noches',
};

/// Solo el primer nombre: "Luz Marina Rosero" → "Luz".
String primerNombre(String nombre) {
  final partes = nombre.trim().split(RegExp(r'\s+'));
  return partes.first.isEmpty ? 'veci' : partes.first;
}
