import 'package:flutter_test/flutter_test.dart';
import 'package:veci/core/observabilidad/vigilante_sincronizacion.dart';

void main() {
  test('alerta al tercer fallo seguido y luego cada tres', () {
    final alertas = <int>[];
    final vigilante = VigilanteSincronizacion(alertar: (n, _) => alertas.add(n));

    for (var i = 0; i < 7; i++) {
      vigilante.registrarFallo(Exception('sin señal'));
    }

    expect(alertas, [3, 6]);
  });

  test('un éxito reinicia la cuenta', () {
    final alertas = <int>[];
    final vigilante = VigilanteSincronizacion(alertar: (n, _) => alertas.add(n))
      ..registrarFallo('x')
      ..registrarFallo('x')
      ..registrarExito()
      ..registrarFallo('x');

    expect(alertas, isEmpty);
    expect(vigilante.fallosSeguidos, 1);
  });
}
