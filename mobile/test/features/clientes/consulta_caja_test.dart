import 'package:flutter_test/flutter_test.dart';
import 'package:veci/features/clientes/domain/reglas/consulta_caja.dart';

import 'clientes_dobles.dart';

void main() {
  group('inferirConsulta', () {
    test('10 dígitos que empiezan por 3 es un celular, con o sin espacios ni +57', () {
      expect(inferirConsulta('310 000 0102').tipo, TipoConsulta.celular);
      expect(inferirConsulta('+57 310-000-0102').digitos, '3100000102');
      expect(inferirConsulta('+57 310-000-0102').tipo, TipoConsulta.celular);
    });

    test('otros dígitos son un documento', () {
      expect(inferirConsulta('1.085.123.456').tipo, TipoConsulta.documento);
      expect(inferirConsulta('5678').tipo, TipoConsulta.documento);
      expect(inferirConsulta('4100000102').tipo, TipoConsulta.documento);
    });

    test('con letras es un nombre, sin tildes y por palabras', () {
      final consulta = inferirConsulta('  Luz   MARÍA ');
      expect(consulta.tipo, TipoConsulta.nombre);
      expect(consulta.palabras, ['luz', 'maria']);
      expect(consulta.texto, 'Luz MARÍA');
    });

    test('alcanza desde 3 letras o números', () {
      expect(inferirConsulta('lu').alcanza, isFalse);
      expect(inferirConsulta('luz').alcanza, isTrue);
      expect(inferirConsulta('56').alcanza, isFalse);
      expect(inferirConsulta('567').alcanza, isTrue);
    });
  });

  test('plegar deja el nombre como nombreBusqueda de la API', () {
    expect(plegar('  José  Ñúñez '), 'jose nunez');
  });

  group('buscarEnCopia', () {
    final luz = clienteDePrueba();
    final jose = clienteDePrueba(
      id: 'c2',
      nombre: 'José Ñúñez',
      busqueda: 'jose nunez',
      documentoFinal: '1234',
      celularFinal: null,
    );
    final copia = [jose, luz];

    test('por nombre sin tildes: cada palabra empieza una del nombre', () {
      expect(buscarEnCopia(copia, inferirConsulta('Jos Ñuñ')), [jose]);
      expect(buscarEnCopia(copia, inferirConsulta('luz cas')), [luz]);
      expect(buscarEnCopia(copia, inferirConsulta('marina luz')), [luz]);
      expect(buscarEnCopia(copia, inferirConsulta('arina')), isEmpty);
    });

    test('hasta 4 números: los últimos 4 del documento o del celular', () {
      expect(buscarEnCopia(copia, inferirConsulta('567')), [luz]);
      expect(buscarEnCopia(copia, inferirConsulta('8888')), [luz]);
      expect(buscarEnCopia(copia, inferirConsulta('1234')), [jose]);
    });

    test('un celular completo busca por sus últimos 4', () {
      expect(buscarEnCopia(copia, inferirConsulta('310 222 8888')), [luz]);
      expect(buscarEnCopia(copia, inferirConsulta('310 222 5678')), isEmpty);
    });

    test('un documento completo busca por sus últimos 4', () {
      expect(buscarEnCopia(copia, inferirConsulta('1085345678')), [luz]);
      expect(buscarEnCopia(copia, inferirConsulta('98761234')), [jose]);
      expect(buscarEnCopia(copia, inferirConsulta('98768888')), isEmpty);
    });

    test('en orden alfabético y sin buscar con menos de 3', () {
      final ana = clienteDePrueba(id: 'c3', nombre: 'Ana Luz', busqueda: 'ana luz');
      expect(buscarEnCopia([luz, ana], inferirConsulta('luz')), [ana, luz]);
      expect(buscarEnCopia(copia, inferirConsulta('lu')), isEmpty);
    });
  });
}
