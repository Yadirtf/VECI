import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/sesion.dart';
import '../../domain/repositories/sesion_repository.dart';

const _claveSesion = 'veci.sesion';
const _claveComercio = 'veci.comercio';

/// Sesión cifrada con el Keystore de Android: sobrevive a cerrar la app, no a desinstalarla.
class AlmacenSesionSeguro implements AlmacenSesion {
  AlmacenSesionSeguro(this._almacen);

  final FlutterSecureStorage _almacen;

  @override
  Future<SesionAbierta?> leerSesion() async {
    final texto = await _almacen.read(key: _claveSesion);
    if (texto == null) return null;
    try {
      return sesionDesdeJson(jsonDecode(texto) as Map<String, Object?>);
    } on Object {
      await _almacen.delete(key: _claveSesion);
      return null;
    }
  }

  @override
  Future<void> guardarSesion(SesionAbierta? sesion) => sesion == null
      ? _almacen.delete(key: _claveSesion)
      : _almacen.write(key: _claveSesion, value: jsonEncode(sesionAJson(sesion)));

  @override
  Future<String?> leerComercio() => _almacen.read(key: _claveComercio);

  @override
  Future<void> guardarComercio(String? comercioId) => comercioId == null
      ? _almacen.delete(key: _claveComercio)
      : _almacen.write(key: _claveComercio, value: comercioId);
}

Map<String, Object?> sesionAJson(SesionAbierta s) => {
  'tokenAcceso': s.tokenAcceso,
  'tokenRenovacion': s.tokenRenovacion,
  'venceEn': s.venceEn.toIso8601String(),
  'nombre': s.nombre,
  'espacios': [
    for (final e in s.espacios)
      {
        'comercioId': e.comercioId,
        'nombre': e.nombre,
        'roles': e.roles,
        'invitacionPendiente': e.invitacionPendiente,
      },
  ],
};

SesionAbierta sesionDesdeJson(Map<String, Object?> j) => SesionAbierta(
  tokenAcceso: j['tokenAcceso']! as String,
  tokenRenovacion: j['tokenRenovacion']! as String,
  venceEn: DateTime.parse(j['venceEn']! as String),
  nombre: j['nombre']! as String,
  espacios: [
    for (final e in (j['espacios']! as List<Object?>).cast<Map<String, Object?>>())
      Espacio(
        comercioId: e['comercioId']! as String,
        nombre: e['nombre']! as String,
        roles: (e['roles']! as List<Object?>).cast<String>(),
        invitacionPendiente: e['invitacionPendiente']! as bool,
      ),
  ],
);
