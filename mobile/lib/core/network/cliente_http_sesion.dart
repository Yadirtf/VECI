import 'package:http/http.dart' as http;

/// Quien sabe el token vigente y cómo renovarlo (la sesión, conectada en core/di).
abstract interface class FuenteDeToken {
  Future<String?> tokenVigente();

  Future<String?> renovar();
}

/// Cliente HTTP que pone el token en cada petición y, si la API responde 401, renueva
/// una vez y repite. Así ninguna pantalla piensa en tokens.
class ClienteHttpConSesion extends http.BaseClient {
  ClienteHttpConSesion(this._sesion, [http.Client? interno]) : _interno = interno ?? http.Client();

  final FuenteDeToken _sesion;
  final http.Client _interno;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is! http.Request) return _interno.send(request);
    final respuesta = await _interno.send(_conToken(request, await _sesion.tokenVigente()));
    if (respuesta.statusCode != 401) return respuesta;
    final nuevo = await _sesion.renovar();
    if (nuevo == null) return respuesta;
    await respuesta.stream.drain<void>();
    return _interno.send(_conToken(request, nuevo));
  }

  http.Request _conToken(http.Request original, String? token) {
    final copia = http.Request(original.method, original.url)
      ..headers.addAll(original.headers)
      ..followRedirects = original.followRedirects
      ..bodyBytes = original.bodyBytes;
    if (token != null) copia.headers['Authorization'] = 'Bearer $token';
    return copia;
  }

  @override
  void close() => _interno.close();
}
