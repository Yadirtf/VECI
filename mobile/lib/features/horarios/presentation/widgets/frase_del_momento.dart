import '../../domain/reglas/ya_es_hora.dart';
import 'hora_legible.dart';

/// "en 40 minutos", "en 1 hora y 5 minutos".
String enCuanto(int minutos) {
  final horas = minutos ~/ 60;
  final resto = minutos % 60;
  final textoHoras = horas == 1 ? '1 hora' : '$horas horas';
  final textoMinutos = resto == 1 ? '1 minuto' : '$resto minutos';
  if (horas == 0) return 'en $textoMinutos';
  if (resto == 0) return 'en $textoHoras';
  return 'en $textoHoras y $textoMinutos';
}

/// La respuesta grande a "¿ya es hora?" y el detalle debajo, en tono VECI.
(String, String) fraseDelMomento(MomentoDelServicio momento) => switch (momento) {
  EnServicio(:final horario, :final faltan) => (
    'Sí, es hora ${_del(horario.servicioNombre)}',
    'Atiendes hasta las ${horaLegible(horario.horaFin)} (${enCuanto(faltan)}).',
  ),
  AntesDeServicio(:final horario, :final faltan) => (
    'Todavía no',
    '${horario.servicioNombre} empieza a las ${horaLegible(horario.horaInicio)}, ${enCuanto(faltan)}.',
  ),
  CerradoPorHoy() => ('Ya cerramos por hoy', 'Mañana seguimos, veci.'),
  DiaDeDescanso() => ('Hoy se descansa', 'No hay servicios para hoy.'),
};

/// "del almuerzo", "de las onces": el artículo solo cuando suena natural.
String _del(String servicio) {
  final nombre = servicio.toLowerCase();
  if (nombre.endsWith('s')) return 'de las $nombre';
  if (nombre.endsWith('a')) return 'de la $nombre';
  return 'del $nombre';
}
