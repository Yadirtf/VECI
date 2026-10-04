import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:veci/core/error/fallo.dart';
import 'package:veci/core/network/cliente_http_sesion.dart';
import 'package:veci/core/network/traducir_error.dart';
import 'package:veci_api/api.dart';

class _Fuente implements FuenteDeToken {
  _Fuente(this.nuevo);

  final String? nuevo;
  int renovaciones = 0;

  @override
  Future<String?> tokenVigente() async => 'viejo';

  @override
  Future<String?> renovar() async {
    renovaciones++;
    return nuevo;
  }
}

void main() {
  test('pone el token y, si venció, renueva una vez y repite con el mismo cuerpo', () async {
    final vistos = <(String?, String)>[];
    final interno = MockClient((pedido) async {
      vistos.add((pedido.headers['Authorization'], pedido.body));
      return http.Response('', vistos.length == 1 ? 401 : 200);
    });
    final fuente = _Fuente('nuevo');
    final cliente = ClienteHttpConSesion(fuente, interno);
    final r = await cliente.post(Uri.parse('http://api/cuenta/pin'), body: '{"a":1}');
    expect(r.statusCode, 200);
    expect(vistos, [('Bearer viejo', '{"a":1}'), ('Bearer nuevo', '{"a":1}')]);
    expect(fuente.renovaciones, 1);
  });

  test('si no se puede renovar, devuelve el 401', () async {
    final cliente = ClienteHttpConSesion(
      _Fuente(null),
      MockClient((_) async => http.Response('', 401)),
    );
    final r = await cliente.get(Uri.parse('http://api/horarios'));
    expect(r.statusCode, 401);
  });

  test('traduce el error de la API a un mensaje en tono VECI', () {
    final cuerpo = jsonEncode({'codigo': 'CREDENCIALES_INCORRECTAS', 'message': 'No coinciden.'});
    final fallo = traducirError(ApiException(401, cuerpo)) as PeticionRechazada;
    expect(fallo.mensaje, 'No coinciden.');
    expect(fallo.motivo, 'CREDENCIALES_INCORRECTAS');
  });

  test('sin red o con el servidor caído, lo dice claro', () {
    expect(traducirError(const SocketException('x')), isA<SinConexion>());
    expect(
      traducirError(ApiException.withInner(400, 'x', const SinConexion(), null)),
      isA<SinConexion>(),
    );
    expect(traducirError(ApiException(503, '')), isA<ServidorNoDisponible>());
    expect((traducirError(ApiException(400, 'no json')) as PeticionRechazada).mensaje, isNotEmpty);
  });
}
