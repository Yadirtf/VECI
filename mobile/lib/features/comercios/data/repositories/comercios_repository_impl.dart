import 'package:veci_api/api.dart';

import '../../../../core/network/traducir_error.dart';
import '../../domain/entities/alta.dart';
import '../../domain/entities/solicitud.dart';
import '../../domain/repositories/comercios_repository.dart';
import '../../domain/reglas/reglas_alta.dart';

/// Solicitudes de negocio con el cliente generado desde OpenAPI. Necesita internet.
class ComerciosRepositoryImpl implements ComerciosRepository {
  ComerciosRepositoryImpl(this._comercios, this._solicitudes);

  final ComerciosApi _comercios;
  final SolicitudesDeNegocioApi _solicitudes;

  static const _espera = Duration(seconds: 12);

  @override
  Future<CatalogosAlta> catalogos() => _conRed(() async {
    final (tipos, municipios) = await (
      _comercios.listarTiposDeNegocio().timeout(_espera),
      _comercios.listarMunicipios().timeout(_espera),
    ).wait;
    return CatalogosAlta(
      tipos: [
        for (final t in tipos ?? const <TipoDeNegocioResponse>[])
          TipoDeNegocio(
            codigo: t.codigo,
            nombre: t.nombre,
            servicios: [for (final s in t.servicios) s.nombre],
          ),
      ],
      municipios: [
        for (final m in municipios ?? const <MunicipioResponse>[])
          Municipio(id: m.id.toInt(), nombre: m.nombre),
      ],
    );
  });

  @override
  Future<void> solicitar(BorradorAlta b) => _conRed(() async {
    final pedido = SolicitarRegistroRequest(
      nombre: b.nombre.trim(),
      tipoNegocio: b.tipoNegocio,
      tipoDocumento: b.esNit
          ? SolicitarRegistroRequestTipoDocumentoEnum.NIT
          : SolicitarRegistroRequestTipoDocumentoEnum.CC,
      numeroDocumento: documentoCompleto(b),
      celular: soloDigitos(b.celular),
      municipioId: b.municipioId ?? 0,
    );
    await _solicitudes.solicitarRegistroDeNegocio(pedido).timeout(_espera);
  });

  @override
  Future<List<SolicitudDeNegocio>> misSolicitudes() => _conRed(() async {
    final lista = await _solicitudes.listarMisSolicitudesDeNegocio().timeout(_espera);
    return [
      for (final s in lista ?? const <SolicitudResponse>[])
        SolicitudDeNegocio(
          id: s.solicitudId,
          nombre: s.nombre,
          estado: _estado(s.estado),
          radicadaEn: s.radicadaEn,
          nota: s.nota,
          comercioId: s.comercioId,
        ),
    ];
  });

  static EstadoSolicitud _estado(SolicitudResponseEstadoEnum estado) => switch (estado.toJson()) {
    'APPROVED' => EstadoSolicitud.aprobada,
    'REJECTED' => EstadoSolicitud.rechazada,
    _ => EstadoSolicitud.enRevision,
  };

  Future<T> _conRed<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on Object catch (error) {
      throw traducirError(error);
    }
  }
}
