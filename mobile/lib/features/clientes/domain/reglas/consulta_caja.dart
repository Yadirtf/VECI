import '../entities/cliente_en_caja.dart';

/// Qué escribió el cajero en la ranura: un nombre, un celular o un documento.
enum TipoConsulta { nombre, celular, documento }

/// Desde 3 letras o números: antes, la lista no ayuda y cuesta en hora pico.
const minimoParaBuscar = 3;

/// Cuántos resultados caben en la lista de la caja.
const maximoDeResultados = 30;

/// Lo escrito en la ranura, ya interpretado.
class ConsultaCaja {
  const ConsultaCaja._(this.tipo, this.texto, {this.digitos = '', this.palabras = const []});

  final TipoConsulta tipo;

  /// Lo escrito, sin espacios de más: así se pone en el registro asistido.
  final String texto;

  /// Solo los números (celular o documento).
  final String digitos;

  /// Las palabras del nombre en minúsculas y sin tildes.
  final List<String> palabras;

  bool get esNumero => tipo != TipoConsulta.nombre;

  /// true cuando ya hay suficiente para buscar.
  bool get alcanza =>
      esNumero ? digitos.length >= minimoParaBuscar : palabras.join().length >= minimoParaBuscar;
}

final _separadoresDeNumero = RegExp(r'[\s\-+().]');
final _soloDigitos = RegExp(r'^\d+$');
final _noLetra = RegExp('[^a-z0-9 ]');
final _espacios = RegExp(r'\s+');

const _sinTilde = {
  'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a', //
  'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e', //
  'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i', //
  'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o', //
  'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u', //
  'ñ': 'n', 'ç': 'c',
};

/// Minúsculas sin tildes ni espacios de más, como `nombreBusqueda` de la API:
/// "  José  Ñúñez" → "jose nunez".
String plegar(String texto) {
  final minusculas = texto.toLowerCase();
  final buffer = StringBuffer();
  for (final letra in minusculas.split('')) {
    buffer.write(_sinTilde[letra] ?? letra);
  }
  return buffer.toString().replaceAll(_espacios, ' ').trim();
}

/// Solo dígitos de 10 que empiezan por 3 → celular (también con +57 adelante);
/// otros dígitos → documento; con letras → nombre.
ConsultaCaja inferirConsulta(String escrito) {
  final texto = escrito.trim().replaceAll(_espacios, ' ');
  var digitos = texto.replaceAll(_separadoresDeNumero, '');
  if (digitos.isNotEmpty && _soloDigitos.hasMatch(digitos)) {
    if (digitos.length == 12 && digitos.startsWith('573')) digitos = digitos.substring(2);
    final esCelular = digitos.length == 10 && digitos.startsWith('3');
    return ConsultaCaja._(
      esCelular ? TipoConsulta.celular : TipoConsulta.documento,
      texto,
      digitos: digitos,
    );
  }
  final palabras = plegar(texto).replaceAll(_noLetra, '').split(' ')..removeWhere((p) => p.isEmpty);
  return ConsultaCaja._(TipoConsulta.nombre, texto, palabras: palabras);
}

/// ¿Este cliente puede ser el que se busca?
/// - Nombre: cada palabra escrita empieza alguna palabra del nombre ("luz cas" → Luz Marina Castro).
/// - Hasta 4 números: los últimos 4 del documento o del celular empiezan así.
/// - Más de 4: sus últimos 4 son los últimos 4 del celular o del documento, según lo inferido.
bool coincide(ClienteEnCaja cliente, ConsultaCaja consulta) {
  if (!consulta.esNumero) {
    final palabrasDelNombre = cliente.nombreBusqueda.split(' ');
    return consulta.palabras.every((p) => palabrasDelNombre.any((n) => n.startsWith(p)));
  }
  final digitos = consulta.digitos;
  final celularFinal = cliente.celularFinal ?? '';
  if (digitos.length <= 4) {
    return cliente.documentoFinal.startsWith(digitos) ||
        (celularFinal.isNotEmpty && celularFinal.startsWith(digitos));
  }
  final final4 = digitos.substring(digitos.length - 4);
  return consulta.tipo == TipoConsulta.celular
      ? celularFinal == final4
      : cliente.documentoFinal == final4;
}

/// Busca en la copia local, en orden alfabético. Lista vacía si aún no alcanza.
List<ClienteEnCaja> buscarEnCopia(List<ClienteEnCaja> clientes, ConsultaCaja consulta) {
  if (!consulta.alcanza) return const [];
  final encontrados = clientes.where((c) => coincide(c, consulta)).toList()
    ..sort((a, b) => a.nombreBusqueda.compareTo(b.nombreBusqueda));
  return encontrados.take(maximoDeResultados).toList();
}
