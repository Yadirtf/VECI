// Genera lib/core/theme/veci_tokens.dart desde docs/diseno/tokens.json (HU-01-09)
// y falla si algún par de colores no alcanza su contraste mínimo.
// Uso (desde mobile/): dart run tool/generar_tokens.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';

const _aviso =
    '// Generado por tool/generar_tokens.dart desde docs/diseno/tokens.json. No editar a mano.';

void main() {
  final tokens =
      jsonDecode(File('../docs/diseno/tokens.json').readAsStringSync()) as Map<String, dynamic>;
  final colores = _valores(tokens['color']).cast<String, String>();
  final fallas = _paresSinContraste(colores, tokens['contraste'] as Map<String, dynamic>);
  if (fallas.isNotEmpty) {
    fallas.forEach(stderr.writeln);
    exit(1);
  }
  File('lib/core/theme/veci_tokens.dart').writeAsStringSync(_generarDart(tokens));
  stdout.writeln('✔ Tokens de diseño generados; los pares de contraste cumplen');
}

Map<String, Object> _valores(Object? grupo) => {
  for (final MapEntry(:key, :value) in (grupo as Map<String, dynamic>).entries)
    if (!key.startsWith(r'$')) key: value as Object,
};

String _generarDart(Map<String, dynamic> tokens) {
  String numero(Object v) => '$v.0';
  return [
    _aviso,
    "import 'package:flutter/painting.dart';\n",
    _clase('VeciColores', 'Color', tokens['color'], (v) {
      return 'Color(0xFF${(v as String).substring(1).toUpperCase()})';
    }),
    _clase('VeciTexto', 'double', tokens['texto'], numero),
    _clase('VeciPeso', 'FontWeight', tokens['peso'], (v) => 'FontWeight.w$v'),
    _clase('VeciEspacio', 'double', tokens['espacio'], numero),
    _clase('VeciRadio', 'double', tokens['radio'], numero),
    _clase('VeciToque', 'double', tokens['toque'], numero),
    _clase('VeciForma', 'double', tokens['forma'], numero),
  ].join('\n');
}

String _clase(String nombre, String tipo, Object? grupo, String Function(Object) formato) {
  final campos = _valores(grupo).entries
      .map((e) => '  static const $tipo ${e.key} = ${formato(e.value)};');
  return 'abstract final class $nombre {\n${campos.join('\n')}\n}\n';
}

List<String> _paresSinContraste(Map<String, String> colores, Map<String, dynamic> contraste) {
  final fallas = <String>[];
  for (final par in (contraste['pares'] as List<dynamic>).cast<List<dynamic>>()) {
    final [texto as String, fondo as String, minimo as num] = par;
    final valor = _contraste(colores[texto]!, colores[fondo]!);
    if (valor < minimo) {
      fallas.add('✘ $texto sobre $fondo: ${valor.toStringAsFixed(2)} (mínimo $minimo)');
    }
  }
  return fallas;
}

/// Contraste WCAG 2.x entre dos colores #RRGGBB.
double _contraste(String a, String b) {
  final luminancias = [_luminancia(a), _luminancia(b)]..sort();
  return (luminancias[1] + 0.05) / (luminancias[0] + 0.05);
}

double _luminancia(String hex) {
  final canales = [1, 3, 5].map((i) {
    final c = int.parse(hex.substring(i, i + 2), radix: 16) / 255;
    return c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4).toDouble();
  }).toList();
  return 0.2126 * canales[0] + 0.7152 * canales[1] + 0.0722 * canales[2];
}
