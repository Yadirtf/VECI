const _meses = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// "3 de octubre" (o "3 de octubre de 2025" si no es de este año), como lo diría un vecino.
String fechaLegible(DateTime fecha, DateTime hoy) {
  final local = fecha.toLocal();
  final base = '${local.day} de ${_meses[local.month - 1]}';
  return local.year == hoy.year ? base : '$base de ${local.year}';
}

/// Solo el primer nombre: "Luz Marina Chindoy" → "Luz".
String primerNombre(String nombre) {
  final partes = nombre.trim().split(RegExp(r'\s+'));
  return partes.first.isEmpty ? 'veci' : partes.first;
}

/// Lo que cada negocio sabe de la persona (HU-04-03).
const queVeCadaNegocio =
    'Tu nombre y los últimos 4 números de tu documento. Solo el dueño ve el documento '
    'completo. Ningún negocio sabe en qué otros estás.';
