import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:veci_api/api.dart';

const _clave = 'veci.mis-tiqueteras';

/// Dónde se guarda el texto: en la app, cifrado (Keystore); en las pruebas, en memoria.
abstract interface class CajonDeSaldos {
  Future<String?> leer();

  /// null borra.
  Future<void> guardar(String? valor);
}

class CajonDeSaldosSeguro implements CajonDeSaldos {
  const CajonDeSaldosSeguro(this._almacen);

  final FlutterSecureStorage _almacen;

  @override
  Future<String?> leer() => _almacen.read(key: _clave);

  @override
  Future<void> guardar(String? valor) =>
      valor == null ? _almacen.delete(key: _clave) : _almacen.write(key: _clave, value: valor);
}

/// Copia del saldo de la persona en sus negocios, para verlo sin internet. Se guarda tal
/// como lo manda la API; no lleva precios ni documentos.
class CopiaMisTiqueteras {
  const CopiaMisTiqueteras(this._cajon);

  final CajonDeSaldos _cajon;

  Future<List<MisTiqueterasResponse>?> leer() async {
    final texto = await _cajon.leer();
    if (texto == null) return null;
    try {
      return MisTiqueterasResponse.listFromJson(jsonDecode(texto));
    } on Object {
      // Una copia dañada se descarta: la próxima vez se baja de nuevo.
      await _cajon.guardar(null);
      return null;
    }
  }

  Future<void> guardar(List<MisTiqueterasResponse> saldos) =>
      _cajon.guardar(jsonEncode([for (final s in saldos) s.toJson()]));

  Future<void> olvidar() => _cajon.guardar(null);
}
