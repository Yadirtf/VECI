import 'package:veci_api/api.dart';

import 'api_config.dart';

/// Cliente HTTP generado desde el contrato OpenAPI (HU-01-06).
ApiClient crearClienteApi(ApiConfig config) {
  final cliente = ApiClient(basePath: config.urlBase);
  if (config.usuarioDesarrolloId.isNotEmpty) {
    cliente.addDefaultHeader('x-veci-usuario', config.usuarioDesarrolloId);
  }
  return cliente;
}
