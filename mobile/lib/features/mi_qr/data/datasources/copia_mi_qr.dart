import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/mi_qr.dart';

const _claveQr = 'veci.mi-qr';
const _claveNegocios = 'veci.mis-negocios';

/// Dónde se guarda el texto: en la app, cifrado (Keystore); en las pruebas, en memoria.
abstract interface class Cajon {
  Future<String?> leer(String clave);

  /// null borra.
  Future<void> guardar(String clave, String? valor);
}

class CajonSeguro implements Cajon {
  const CajonSeguro(this._almacen);

  final FlutterSecureStorage _almacen;

  @override
  Future<String?> leer(String clave) => _almacen.read(key: clave);

  @override
  Future<void> guardar(String clave, String? valor) =>
      valor == null ? _almacen.delete(key: clave) : _almacen.write(key: clave, value: valor);
}

/// Copia en el celular de Mi QR y de Tus negocios, para mostrarlos sin internet.
/// Solo guarda tokens firmados y nombres de negocios: nada de documentos.
class CopiaMiQr {
  const CopiaMiQr(this._cajon);

  final Cajon _cajon;

  Future<MiQr?> leerQr() async {
    final j = await _leerJson(_claveQr);
    if (j is! Map<String, Object?>) return null;
    return MiQr(
      token: j['token']! as String,
      version: j['version']! as int,
      emitidoEn: DateTime.parse(j['emitidoEn']! as String),
    );
  }

  Future<void> guardarQr(MiQr qr) => _cajon.guardar(
    _claveQr,
    jsonEncode({
      'token': qr.token,
      'version': qr.version,
      'emitidoEn': qr.emitidoEn.toIso8601String(),
    }),
  );

  Future<List<NegocioDondeSoyCliente>?> leerNegocios() async {
    final j = await _leerJson(_claveNegocios);
    if (j is! List<Object?>) return null;
    return [for (final n in j.cast<Map<String, Object?>>()) _negocioDesdeJson(n)];
  }

  Future<void> guardarNegocios(List<NegocioDondeSoyCliente> negocios) =>
      _cajon.guardar(_claveNegocios, jsonEncode([for (final n in negocios) _negocioAJson(n)]));

  Future<void> olvidar() async {
    await _cajon.guardar(_claveQr, null);
    await _cajon.guardar(_claveNegocios, null);
  }

  /// Una copia dañada se descarta: la próxima vez se baja de nuevo.
  Future<Object?> _leerJson(String clave) async {
    final texto = await _cajon.leer(clave);
    if (texto == null) return null;
    try {
      return jsonDecode(texto);
    } on FormatException {
      await _cajon.guardar(clave, null);
      return null;
    }
  }
}

Map<String, Object?> _negocioAJson(NegocioDondeSoyCliente n) => {
  'comercioId': n.comercioId,
  'nombre': n.nombre,
  'tipoNegocio': n.tipoNegocio,
  'afiliadoEn': n.afiliadoEn.toIso8601String(),
  'qr': n.qr == null ? null : {'token': n.qr!.token, 'version': n.qr!.version},
};

NegocioDondeSoyCliente _negocioDesdeJson(Map<String, Object?> j) {
  final qr = j['qr'] as Map<String, Object?>?;
  return NegocioDondeSoyCliente(
    comercioId: j['comercioId']! as String,
    nombre: j['nombre']! as String,
    tipoNegocio: j['tipoNegocio']! as String,
    afiliadoEn: DateTime.parse(j['afiliadoEn']! as String),
    qr: qr == null
        ? null
        : QrEnNegocio(token: qr['token']! as String, version: qr['version']! as int),
  );
}
