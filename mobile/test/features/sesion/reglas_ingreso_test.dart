import 'package:flutter_test/flutter_test.dart';
import 'package:veci/features/sesion/domain/reglas/reglas_ingreso.dart';

import 'sesion_dobles.dart';

void main() {
  test('acepta el celular con espacios o con +57', () {
    expect(soloDigitosDelCelular('+57 310 000 0102'), '3100000102');
    expect(problemaConCelular('310-000-0102'), isNull);
    expect(problemaConCelular('210'), contains('empieza por 3'));
  });

  test('el PIN son 6 números', () {
    expect(problemaConPin('246813'), isNull);
    expect(problemaConPin('24'), contains('6 números'));
  });

  test('arranca con el negocio guardado o con el único', () {
    expect(comercioInicial(const [negocio], null), 'c1');
    expect(comercioInicial(const [negocio], 'otro'), 'c1');
    expect(comercioInicial(const [], 'c1'), isNull);
  });

  test('el cajero trabaja en la caja; el cliente no', () {
    expect(esDeLaCaja(negocio), isTrue);
  });

  test('avisa con calma cuántos registros faltan por enviar', () {
    expect(avisoDeSesionCerrada(0), isNot(contains('registro')));
    expect(avisoDeSesionCerrada(1), contains('un registro guardado'));
    expect(avisoDeSesionCerrada(4), contains('4 registros guardados'));
  });
}
