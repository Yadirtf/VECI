import 'package:flutter_test/flutter_test.dart';
import 'package:veci/features/inicio/domain/saludo.dart';

void main() {
  test('saluda según la hora del día', () {
    expect(saludoDelDia(DateTime(2026, 10, 5, 6)), 'Buenos días');
    expect(saludoDelDia(DateTime(2026, 10, 5, 12, 10)), 'Buenas tardes');
    expect(saludoDelDia(DateTime(2026, 10, 5, 19)), 'Buenas noches');
    expect(saludoDelDia(DateTime(2026, 10, 5, 2)), 'Buenas noches');
  });

  test('usa solo el primer nombre', () {
    expect(primerNombre('Luz Marina Rosero'), 'Luz');
    expect(primerNombre('  Ana '), 'Ana');
    expect(primerNombre(''), 'veci');
  });
}
