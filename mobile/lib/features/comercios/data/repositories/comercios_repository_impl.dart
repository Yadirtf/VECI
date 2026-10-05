import 'package:veci_api/api.dart';

import '../../../../core/error/fallo.dart';
import '../../../../core/network/traducir_error.dart';
import '../../domain/entities/alta.dart';
import '../../domain/repositories/comercios_repository.dart';
import '../../domain/reglas/reglas_alta.dart';

/// Alta de negocios con el cliente generado desde OpenAPI. Necesita internet.
class ComerciosRepositoryImpl implements ComerciosRepository {
  ComerciosRepositoryImpl(this._api);

  final ComerciosApi _api;

  static const _espera = Duration(seconds: 12);

  @override
  Future<List<TipoDeNegocio>> tipos() => _conRed(() async {
    final tipos = await _api.listarTiposDeNegocio().timeout(_espera) ?? const [];
    return [
      for (final t in tipos)
        TipoDeNegocio(
          codigo: t.codigo,
          nombre: t.nombre,
          servicios: [for (final s in t.servicios) s.nombre],
        ),
    ];
  });

  @override
  Future<String> registrar(BorradorAlta b) => _conRed(() async {
    final pedido = RegistrarComercioRequest(
      nombre: b.nombre.trim(),
      tipoNegocio: b.tipoNegocio,
      tipoDocumento: b.esNit
          ? RegistrarComercioRequestTipoDocumentoEnum.NIT
          : RegistrarComercioRequestTipoDocumentoEnum.CC,
      numeroDocumento: documentoCompleto(b),
      celular: soloDigitos(b.celular),
    );
    final registrado = await _api.registrarComercio(pedido).timeout(_espera);
    if (registrado == null) throw const ServidorNoDisponible(0);
    return registrado.comercioId;
  });

  Future<T> _conRed<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on Object catch (error) {
      throw traducirError(error);
    }
  }
}
