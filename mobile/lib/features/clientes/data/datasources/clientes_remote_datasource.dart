import 'dart:convert';
import 'dart:io';

import 'package:veci_api/api.dart';

import '../../../../core/error/fallo.dart';
import '../../../../core/network/traducir_error.dart';
import '../../domain/entities/cliente_en_caja.dart';
import '../../domain/entities/ficha_cliente.dart';
import '../../domain/entities/lectura_qr.dart';
import '../../domain/entities/registro_asistido.dart';
import '../models/cliente_model.dart';

/// Lo que respondió el servidor por la copia: clientes nuevos con su versión y ETag,
/// o [sinCambios] si la del celular sigue al día (304).
class RespuestaCopia {
  const RespuestaCopia({this.clientes, this.version, this.etag});

  final List<ClienteEnCaja>? clientes;
  final String? version;
  final String? etag;

  bool get sinCambios => clientes == null;
}

/// Clientes desde el API (cliente generado desde OpenAPI) para el negocio activo.
class ClientesRemoteDatasource {
  ClientesRemoteDatasource(this._clientes, this._registro, this._comercioId);

  final ClientesApi _clientes;
  final RegistroDelClienteApi _registro;
  final String _comercioId;

  static const _espera = Duration(seconds: 10);

  /// Con [etag] el servidor responde 304 si la copia no cambió (HU-04-05). El cliente
  /// generado no expone If-None-Match en esta operación, así que se arma la petición.
  Future<RespuestaCopia> bajarCopia({String? etag}) => _conRed(() async {
    final respuesta = await _clientes.apiClient
        .invokeAPI(
          '/clientes/copia-local',
          'GET',
          [],
          null,
          {'x-veci-comercio': _comercioId, 'If-None-Match': ?etag},
          {},
          null,
        )
        .timeout(_espera);
    if (respuesta.statusCode == HttpStatus.notModified) return RespuestaCopia(etag: etag);
    if (respuesta.statusCode >= HttpStatus.badRequest) {
      throw ApiException(respuesta.statusCode, utf8.decode(respuesta.bodyBytes));
    }
    final copia = CopiaLocalResponse.fromJson(jsonDecode(utf8.decode(respuesta.bodyBytes)));
    if (copia == null) throw const ServidorNoDisponible(0);
    return RespuestaCopia(
      clientes: copia.clientes.map(ClienteModel.desdeCopia).toList(),
      version: copia.version,
      etag: respuesta.headers['etag'],
    );
  });

  Future<LecturaQr> leerQr(String token) => _conRed(() async {
    final lectura = await _clientes
        .leerQrDeCliente(_comercioId, TokenQrRequest(token: token))
        .timeout(_espera);
    return ClienteModel.lectura(_noNulo(lectura));
  });

  Future<(FichaCliente, bool)> afiliar(String token) => _conRed(() async {
    final hecha = _noNulo(
      await _clientes.afiliarPorQr(_comercioId, TokenQrRequest(token: token)).timeout(_espera),
    );
    return (ClienteModel.ficha(hecha.cliente), hecha.yaEstaba);
  });

  Future<FichaCliente> ficha(String clienteId) => _conRed(() async {
    final cliente = await _clientes.consultarCliente(_comercioId, clienteId).timeout(_espera);
    return ClienteModel.ficha(_noNulo(cliente));
  });

  Future<String> darPinDeBienvenida(String clienteId) => _conRed(() async {
    final pin = await _clientes.darPinDeBienvenida(_comercioId, clienteId).timeout(_espera);
    return _noNulo(pin).pinBienvenida;
  });

  Future<List<TipoDocumento>> tiposDeDocumento() => _conRed(() async {
    final tipos = await _registro.listarTiposDeDocumento().timeout(_espera) ?? const [];
    return tipos.map(ClienteModel.tipo).toList();
  });

  Future<PoliticaEnCorto> politica() => _conRed(() async {
    final politica = await _registro.consultarPoliticaDeDatos().timeout(_espera);
    return ClienteModel.politica(_noNulo(politica));
  });

  Future<PersonaEncontrada?> revisarDocumento(String tipo, String numero) => _conRed(() async {
    final pedido = DocumentoRequest(tipoDocumento: tipo, numeroDocumento: numero);
    final revision = await _clientes
        .revisarDocumentoDeCliente(_comercioId, pedido)
        .timeout(_espera);
    final persona = _noNulo(revision).persona;
    return persona == null ? null : ClienteModel.persona(persona);
  });

  Future<RegistroHecho> registrar(DatosRegistroAsistido datos) => _conRed(() async {
    final hecho = _noNulo(
      await _clientes
          .registrarClienteAsistido(_comercioId, ClienteModel.pedido(datos))
          .timeout(_espera),
    );
    return RegistroHecho(
      ficha: ClienteModel.ficha(hecho.cliente),
      vinculado: hecho.vinculado,
      pinBienvenida: hecho.pinBienvenida,
    );
  });

  static T _noNulo<T>(T? valor) => valor ?? (throw const ServidorNoDisponible(0));

  Future<T> _conRed<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on Object catch (error) {
      throw traducirError(error);
    }
  }
}
