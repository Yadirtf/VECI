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

/// "3 de octubre de 2026" (guía de tono: nunca 2026-10-03 en pantalla).
String fechaLegible(DateTime fecha) {
  final local = fecha.toLocal();
  return '${local.day} de ${_meses[local.month - 1]} de ${local.year}';
}

/// "10:42 a. m.".
String horaLegible(DateTime fecha) {
  final local = fecha.toLocal();
  final sufijo = local.hour < 12 ? 'a. m.' : 'p. m.';
  final hora12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
  return '$hora12:${local.minute.toString().padLeft(2, '0')} $sufijo';
}

/// Pie de la lista: "Copia al día a las 10:42 a. m." (o con la fecha si no es de hoy).
String copiaAlDia(DateTime? alDiaEn, DateTime ahora) {
  if (alDiaEn == null) return 'Aún no hay copia de tus clientes en el celular.';
  final local = alDiaEn.toLocal();
  final hoy = ahora.toLocal();
  final esHoy = local.year == hoy.year && local.month == hoy.month && local.day == hoy.day;
  if (esHoy) return 'Copia al día a las ${horaLegible(local)}';
  return 'Copia al día el ${local.day} de ${_meses[local.month - 1]} a las ${horaLegible(local)}';
}
