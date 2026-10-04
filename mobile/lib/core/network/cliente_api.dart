import 'package:veci_api/api.dart';

import 'api_config.dart';
import 'cliente_http_sesion.dart';

/// Cliente HTTP generado desde el contrato OpenAPI (HU-01-06). Con [sesion], cada
/// petición lleva el token y se renueva sola; sin ella, sirve para entrar y renovar.
ApiClient crearClienteApi(ApiConfig config, {FuenteDeToken? sesion}) {
  final cliente = ApiClient(basePath: config.urlBase);
  if (sesion != null) cliente.client = ClienteHttpConSesion(sesion);
  return cliente;
}

/// Cliente de una sola llamada con un token dado (por ejemplo, al elegir el negocio).
ApiClient clienteConToken(ApiConfig config, String token) =>
    ApiClient(basePath: config.urlBase, authentication: HttpBearerAuth()..accessToken = token);
