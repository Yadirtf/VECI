import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:veci_api/api.dart';

import '../../../../core/error/fallo.dart';
import '../../domain/entities/horario.dart';
import '../models/horario_model.dart';

/// Lo que respondió el servidor: horarios nuevos con su ETag, o null si nada cambió (304).
class RespuestaHorarios {
  const RespuestaHorarios({required this.horarios, this.etag});

  final List<Horario>? horarios;
  final String? etag;

  bool get sinCambios => horarios == null;
}

/// Horarios desde el API, con el cliente generado desde OpenAPI.
class HorariosRemoteDatasource {
  HorariosRemoteDatasource(this._api, this._comercioId);

  final HorariosDeServicioApi _api;
  final String _comercioId;

  static const _espera = Duration(seconds: 8);

  /// Con [etag] el servidor solo manda los horarios si cambiaron (HU-03-02).
  Future<RespuestaHorarios> listar({String? etag}) async {
    try {
      final respuesta = await _api
          .listarHorariosWithHttpInfo(_comercioId, ifNoneMatch: etag)
          .timeout(_espera);
      if (respuesta.statusCode == HttpStatus.notModified) {
        return RespuestaHorarios(horarios: null, etag: etag);
      }
      if (respuesta.statusCode >= HttpStatus.badRequest) {
        throw ApiException(respuesta.statusCode, utf8.decode(respuesta.bodyBytes));
      }
      final lista = HorarioResponse.listFromJson(jsonDecode(utf8.decode(respuesta.bodyBytes)));
      return RespuestaHorarios(
        horarios: lista.map(HorarioModel.desdeApi).toList(),
        etag: respuesta.headers['etag'],
      );
    } on ApiException catch (error) {
      throw _traducir(error);
    } on SocketException {
      throw const SinConexion();
    } on TimeoutException {
      throw const SinConexion();
    }
  }

  Fallo _traducir(ApiException error) {
    if (error.innerException is SocketException) return const SinConexion();
    if (error.code >= 500 || error.code == 0) return ServidorNoDisponible(error.code);
    return PeticionRechazada(error.code, error.message ?? '');
  }
}
