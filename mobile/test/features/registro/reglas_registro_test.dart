import 'package:flutter_test/flutter_test.dart';
import 'package:veci/features/registro/domain/entities/registro.dart';
import 'package:veci/features/registro/domain/reglas/reglas_registro.dart';

const _tipos = [
  TipoDocumento(codigo: 'CC', nombre: 'Cédula', patron: r'^[0-9]{6,10}$'),
  TipoDocumento(codigo: 'PASSPORT', nombre: 'Pasaporte'),
];

String? _problema(PasoRegistro paso, BorradorRegistro b) => problemaEnPaso(paso, b, _tipos);

void main() {
  test('el celular son 10 números que empiezan por 3, con o sin +57', () {
    expect(_problema(PasoRegistro.celular, const BorradorRegistro()), contains('Escribe'));
    expect(
      _problema(PasoRegistro.celular, const BorradorRegistro(celular: '210 000 0000')),
      contains('empieza por 3'),
    );
    expect(
      _problema(PasoRegistro.celular, const BorradorRegistro(celular: '+57 315 777 8888')),
      isNull,
    );
    expect(celularLimpio('+57 315-777-8888'), '3157778888');
  });

  test('pide el nombre; los apellidos son opcionales', () {
    expect(_problema(PasoRegistro.nombre, const BorradorRegistro(nombres: ' ')), isNotNull);
    expect(_problema(PasoRegistro.nombre, const BorradorRegistro(nombres: 'Luz Marina')), isNull);
  });

  test('el documento se revisa con el patrón de su tipo', () {
    const cedula = BorradorRegistro(numeroDocumento: '1.124.500.777');
    expect(_problema(PasoRegistro.documento, cedula), isNull);
    expect(
      _problema(PasoRegistro.documento, const BorradorRegistro(numeroDocumento: '12AB')),
      contains('Cédula'),
    );
    const pasaporte = BorradorRegistro(tipoDocumento: 'PASSPORT', numeroDocumento: 'ab 12345');
    expect(_problema(PasoRegistro.documento, pasaporte), isNull);
    expect(documentoLimpio(pasaporte.numeroDocumento), 'AB12345');
    expect(
      _problema(PasoRegistro.documento, const BorradorRegistro(tipoDocumento: 'XX')),
      contains('tipo de documento'),
    );
    expect(esSoloNumeros(_tipos.first), isTrue);
    expect(esSoloNumeros(_tipos.last), isFalse);
  });

  test('el PIN son 6 números y hay que escribirlo igual dos veces', () {
    expect(_problema(PasoRegistro.pin, const BorradorRegistro(pin: '123')), contains('6 números'));
    expect(
      _problema(PasoRegistro.pin, const BorradorRegistro(pin: '190573', pinRepetido: '190574')),
      contains('no coinciden'),
    );
    expect(
      _problema(PasoRegistro.pin, const BorradorRegistro(pin: '190573', pinRepetido: '190573')),
      isNull,
    );
  });

  test('la política no tiene nada que revisar: se acepta con el botón', () {
    expect(_problema(PasoRegistro.politica, const BorradorRegistro()), isNull);
  });
}
