import 'dart:io';

import 'package:veci/features/mi_qr/data/datasources/copia_mi_qr.dart';
import 'package:veci_api/api.dart';

/// Cajón en memoria en vez del almacén cifrado del celular.
class CajonEnMemoria implements Cajon {
  final datos = <String, String>{};

  @override
  Future<String?> leer(String clave) async => datos[clave];

  @override
  Future<void> guardar(String clave, String? valor) async =>
      valor == null ? datos.remove(clave) : datos[clave] = valor;
}

/// API de mentiras: cada regeneración sube el número del QR.
class ApiMiQrFalsa extends RegistroDelClienteApi {
  var version = 1;
  var sinSenal = false;
  var negocios = <MiComercioResponse>[];

  MiQrResponse _qr() =>
      MiQrResponse(token: 'VP1.qr$version.firma', version: version, emitidoEn: DateTime(2026, 10));

  @override
  Future<MiQrResponse?> consultarMiQr({Future<void>? abortTrigger}) async {
    if (sinSenal) throw const SocketException('sin red');
    return _qr();
  }

  @override
  Future<MiQrResponse?> regenerarMiQr({Future<void>? abortTrigger}) async {
    if (sinSenal) throw const SocketException('sin red');
    version++;
    return _qr();
  }

  @override
  Future<List<MiComercioResponse>?> listarMisComercios({Future<void>? abortTrigger}) async {
    if (sinSenal) throw const SocketException('sin red');
    return negocios;
  }
}

MiComercioResponse negocioDePrueba({bool conQr = true}) => MiComercioResponse(
  comercioId: 'c1',
  nombre: 'Restaurante La Vecina',
  tipoNegocio: 'RESTAURANT',
  afiliadoEn: DateTime(2026, 10, 3),
  qr: conQr ? QrEnComercioResponse(token: 'V1.c1.firma', version: 1) : null,
);
