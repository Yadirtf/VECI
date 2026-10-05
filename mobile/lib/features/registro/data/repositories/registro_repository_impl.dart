import 'package:veci_api/api.dart';

import '../../../../core/error/fallo.dart';
import '../../../../core/network/traducir_error.dart';
import '../../domain/entities/registro.dart';
import '../../domain/reglas/reglas_registro.dart';
import '../../domain/repositories/registro_repository.dart';

/// Registro del cliente con el cliente generado (RegistroDelClienteApi, sin sesión).
class RegistroRepositoryImpl implements RegistroRepository {
  /// [_dispositivo] describe este celular, como al entrar con PIN. [_alEntrar] abre la
  /// sesión que devuelve el registro; core/di la conecta con la sesión de la app.
  RegistroRepositoryImpl(this._api, this._dispositivo, this._alEntrar);

  final RegistroDelClienteApi _api;
  final Future<DispositivoRequest> Function() _dispositivo;
  final Future<void> Function(SesionResponse sesion) _alEntrar;

  static const _espera = Duration(seconds: 12);

  @override
  Future<List<TipoDocumento>> tiposDeDocumento() => _conRed(() async {
    final tipos = await _api.listarTiposDeDocumento().timeout(_espera) ?? const [];
    return [
      for (final t in tipos) TipoDocumento(codigo: t.codigo, nombre: t.nombre, patron: t.patron),
    ];
  });

  @override
  Future<PoliticaDeDatos> politica() => _conRed(() async {
    final p = await _api.consultarPoliticaDeDatos().timeout(_espera);
    if (p == null) throw const ServidorNoDisponible(0);
    return PoliticaDeDatos(
      id: p.id,
      version: p.version,
      anotamos: p.enCorto.anotamos,
      nuncaHacemos: p.enCorto.nuncaHacemos,
      paraQue: p.enCorto.paraQue,
      secciones: [
        for (final s in p.secciones)
          SeccionPolitica(
            titulo: s.titulo,
            enPalabrasDeVecino: s.enPalabrasDeVecino,
            texto: s.texto,
          ),
      ],
    );
  });

  @override
  Future<void> registrarme(BorradorRegistro b, String politicaVersionId) => _conRed(() async {
    final apellidos = b.apellidos.trim();
    final pedido = RegistroRequest(
      nombres: b.nombres.trim(),
      apellidos: apellidos.isEmpty ? null : apellidos,
      tipoDocumento: b.tipoDocumento,
      numeroDocumento: documentoLimpio(b.numeroDocumento),
      celular: celularLimpio(b.celular),
      pin: b.pin,
      politicaVersionId: politicaVersionId,
      dispositivo: await _dispositivo(),
    );
    final sesion = await _api.registrarme(pedido).timeout(_espera);
    if (sesion == null) throw const ServidorNoDisponible(0);
    await _alEntrar(sesion);
  });

  Future<T> _conRed<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on Object catch (error) {
      throw traducirError(error);
    }
  }
}
