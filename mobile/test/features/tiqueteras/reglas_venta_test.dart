import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:veci/features/tiqueteras/domain/reglas/reglas_venta.dart';
import 'package:veci/features/tiqueteras/domain/reglas/uuid_v7.dart';

import 'tiqueteras_dobles.dart';

void main() {
  test('los pesos llevan punto de miles y sin centavos', () {
    expect(pesos(220000), r'$ 220.000');
    expect(pesos(1000), r'$ 1.000');
    expect(pesos(950), r'$ 950');
    expect(pesos(-15000), r'-$ 15.000');
  });

  test('las fechas y las unidades se dicen como en el barrio', () {
    expect(diaLegible('2026-11-06'), '6 nov');
    expect(diaLegible('raro'), 'raro');
    expect(almuerzo.de(1), '1 almuerzo');
    expect(almuerzo.de(20), '20 almuerzos');
  });

  test('la transferencia pide por dónde llegó; el efectivo no', () {
    expect(armarPago(null, null, '').falta, 'Elige cómo pagó.');
    expect(armarPago(efectivo, 'NEQUI', 'x').pago?.canal, isNull);
    expect(armarPago(transferencia, null, '').falta, contains('Nequi'));
    final pago = armarPago(transferencia, 'NEQUI', '  M88 ').pago!;
    expect((pago.medio, pago.canal, pago.referencia), ('BANK_TRANSFER', 'NEQUI', 'M88'));
    expect(armarPago(transferencia, 'NEQUI', ' ').pago!.referencia, isNull);
  });

  test('el id de la venta es un UUID v7 ordenado por tiempo', () {
    final azar = Random(7);
    final primero = uuidV7(DateTime.utc(2026, 10, 8, 12), azar);
    final despues = uuidV7(DateTime.utc(2026, 10, 8, 12, 0, 1), azar);
    final formato = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    expect(primero, matches(formato));
    expect(primero.compareTo(despues), lessThan(0));
    expect(uuidV7(DateTime.utc(2026), Random(1)), isNot(uuidV7(DateTime.utc(2026), Random(2))));
  });
}
