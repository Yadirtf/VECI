import 'package:veci_api/api.dart';

import '../../../../core/error/fallo.dart';
import '../../../../core/network/traducir_error.dart';
import '../../domain/entities/mi_qr.dart';
import '../../domain/repositories/mi_qr_repository.dart';
import '../datasources/copia_mi_qr.dart';

/// Mi QR y Tus negocios con el cliente generado (con sesión) y la copia del celular.
class MiQrRepositoryImpl implements MiQrRepository {
  MiQrRepositoryImpl(this._api, this._copia);

  final RegistroDelClienteApi _api;
  final CopiaMiQr _copia;

  static const _espera = Duration(seconds: 10);

  @override
  Future<MiQr?> qrGuardado() => _copia.leerQr();

  @override
  Future<MiQr> traerQr() => _guardarQr(() => _api.consultarMiQr());

  @override
  Future<MiQr> regenerar() => _guardarQr(() => _api.regenerarMiQr());

  @override
  Future<List<NegocioDondeSoyCliente>?> negociosGuardados() => _copia.leerNegocios();

  @override
  Future<List<NegocioDondeSoyCliente>> traerNegocios() => _conRed(() async {
    final lista = await _api.listarMisComercios().timeout(_espera);
    if (lista == null) throw const ServidorNoDisponible(0);
    final negocios = [for (final n in lista) _aNegocio(n)];
    await _copia.guardarNegocios(negocios);
    return negocios;
  });

  @override
  Future<void> olvidar() => _copia.olvidar();

  Future<MiQr> _guardarQr(Future<MiQrResponse?> Function() pedir) => _conRed(() async {
    final r = await pedir().timeout(_espera);
    if (r == null) throw const ServidorNoDisponible(0);
    final qr = MiQr(token: r.token, version: r.version.toInt(), emitidoEn: r.emitidoEn);
    await _copia.guardarQr(qr);
    return qr;
  });

  NegocioDondeSoyCliente _aNegocio(MiComercioResponse n) {
    final qr = n.qr;
    return NegocioDondeSoyCliente(
      comercioId: n.comercioId,
      nombre: n.nombre,
      tipoNegocio: n.tipoNegocio,
      afiliadoEn: n.afiliadoEn,
      qr: qr == null ? null : QrEnNegocio(token: qr.token, version: qr.version.toInt()),
    );
  }

  Future<T> _conRed<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on Object catch (error) {
      throw traducirError(error);
    }
  }
}
