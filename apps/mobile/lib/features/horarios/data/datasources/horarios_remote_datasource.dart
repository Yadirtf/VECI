import 'dart:async';
import 'dart:io';

import 'package:veci_api/api.dart';

import '../../../../core/error/fallo.dart';
import '../../domain/entities/horario.dart';
import '../models/horario_model.dart';

/// Horarios desde el API, con el cliente generado desde OpenAPI.
class HorariosRemoteDatasource {
  HorariosRemoteDatasource(this._api, this._comercioId);

  final HorariosDeServicioApi _api;
  final String _comercioId;

  static const _espera = Duration(seconds: 8);

  Future<List<Horario>> listar() async {
    try {
      final respuesta = await _api.listarHorarios(_comercioId).timeout(_espera);
      return (respuesta ?? const <HorarioResponse>[]).map(HorarioModel.desdeApi).toList();
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
