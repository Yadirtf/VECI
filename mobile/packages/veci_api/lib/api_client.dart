//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class ApiClient {
  ApiClient({this.basePath = 'http://localhost', this.authentication,});

  final String basePath;
  final Authentication? authentication;

  var _client = Client();
  final _defaultHeaderMap = <String, String>{};

  /// Returns the current HTTP [Client] instance to use in this class.
  ///
  /// The return value is guaranteed to never be null.
  Client get client => _client;

  /// Requests to use a new HTTP [Client] in this class.
  set client(Client newClient) {
    _client = newClient;
  }

  Map<String, String> get defaultHeaderMap => _defaultHeaderMap;

  void addDefaultHeader(String key, String value) {
     _defaultHeaderMap[key] = value;
  }

  // We don't use a Map<String, String> for queryParams.
  // If collectionFormat is 'multi', a key might appear multiple times.
  Future<Response> invokeAPI(
    String path,
    String method,
    List<QueryParam> queryParams,
    Object? body,
    Map<String, String> headerParams,
    Map<String, String> formParams,
    String? contentType, {
    Future<void>? abortTrigger,
  }) async {
    await authentication?.applyToParams(queryParams, headerParams);

    headerParams.addAll(_defaultHeaderMap);
    if (contentType != null) {
      headerParams['Content-Type'] = contentType;
    }

    final urlEncodedQueryParams = queryParams.map((param) => '$param');
    final queryString = urlEncodedQueryParams.isNotEmpty ? '?${urlEncodedQueryParams.join('&')}' : '';
    final uri = Uri.parse('$basePath$path$queryString');

    try {
      // Special case for uploading a single file which isn't a 'multipart/form-data'.
      if (
        body is MultipartFile && (contentType == null ||
        !contentType.toLowerCase().startsWith('multipart/form-data'))
      ) {
        final request = AbortableStreamedRequest(method, uri, abortTrigger: abortTrigger);
        request.headers.addAll(headerParams);
        request.contentLength = body.length;
        body.finalize().listen(
          request.sink.add,
          onDone: request.sink.close,
          // ignore: avoid_types_on_closure_parameters
          onError: (Object error, StackTrace trace) => request.sink.close(),
          cancelOnError: true,
        );
        final response = await _client.send(request);
        return Response.fromStream(response);
      }

      if (body is MultipartRequest) {
        final request = AbortableMultipartRequest(method, uri, abortTrigger: abortTrigger);
        request.fields.addAll(body.fields);
        request.files.addAll(body.files);
        request.headers.addAll(body.headers);
        request.headers.addAll(headerParams);
        final response = await _client.send(request);
        return Response.fromStream(response);
      }

      final msgBody = contentType == 'application/x-www-form-urlencoded'
        ? formParams
        : await serializeAsync(body);
      final nullableHeaderParams = headerParams.isEmpty ? null : headerParams;

      final request = AbortableRequest(method, uri, abortTrigger: abortTrigger);
      if (nullableHeaderParams != null) {
        request.headers.addAll(nullableHeaderParams);
      }
      if (msgBody is String && msgBody.isNotEmpty) {
        request.body = msgBody;
      } else if (msgBody is List<int> && msgBody.isNotEmpty) {
        request.bodyBytes = msgBody;
      } else if (msgBody is Map<String, String>) {
        request.bodyFields = msgBody;
      }
      final response = await _client.send(request);
      return Response.fromStream(response);
    } on SocketException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'Socket operation failed: $method $path',
        error,
        trace,
      );
    } on TlsException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'TLS/SSL communication failed: $method $path',
        error,
        trace,
      );
    } on IOException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'I/O operation failed: $method $path',
        error,
        trace,
      );
    } on ClientException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'HTTP connection failed: $method $path',
        error,
        trace,
      );
    } on Exception catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'Exception occurred: $method $path',
        error,
        trace,
      );
    }
  }

  Future<dynamic> deserializeAsync(String value, String targetType, {bool growable = false,}) async =>
    // ignore: deprecated_member_use_from_same_package
    deserialize(value, targetType, growable: growable);

  @Deprecated('Scheduled for removal in OpenAPI Generator 6.x. Use deserializeAsync() instead.')
  dynamic deserialize(String value, String targetType, {bool growable = false,}) {
    // Remove all spaces. Necessary for regular expressions as well.
    targetType = targetType.replaceAll(' ', ''); // ignore: parameter_assignments

    // If the expected target type is String, nothing to do...
    return targetType == 'String'
      ? value
      : fromJson(json.decode(value), targetType, growable: growable);
  }

  // ignore: deprecated_member_use_from_same_package
  Future<String> serializeAsync(Object? value) async => serialize(value);

  @Deprecated('Scheduled for removal in OpenAPI Generator 6.x. Use serializeAsync() instead.')
  String serialize(Object? value) => value == null ? '' : json.encode(value);

  /// Returns a native instance of an OpenAPI class matching the [specified type][targetType].
  static dynamic fromJson(dynamic value, String targetType, {bool growable = false,}) {
    try {
      switch (targetType) {
        case 'String':
          return value is String ? value : value.toString();
        case 'int':
          return value is int ? value : int.parse('$value');
        case 'double':
          return value is double ? value : double.parse('$value');
        case 'bool':
          if (value is bool) {
            return value;
          }
          final valueString = '$value'.toLowerCase();
          return valueString == 'true' || valueString == '1';
        case 'DateTime':
          return value is DateTime ? value : DateTime.tryParse(value);
        case 'AfiliacionResponse':
          return AfiliacionResponse.fromJson(value);
        case 'AjusteRequest':
          return AjusteRequest.fromJson(value);
        case 'AsignarSedesRequest':
          return AsignarSedesRequest.fromJson(value);
        case 'AvanceResponse':
          return AvanceResponse.fromJson(value);
        case 'CajeroEnSedesResponse':
          return CajeroEnSedesResponse.fromJson(value);
        case 'CambiarEstadoCajeroRequest':
          return CambiarEstadoCajeroRequest.fromJson(value);
        case 'CambiarPinRequest':
          return CambiarPinRequest.fromJson(value);
        case 'CanalResponse':
          return CanalResponse.fromJson(value);
        case 'CatalogoDeVentaResponse':
          return CatalogoDeVentaResponse.fromJson(value);
        case 'CierreRemotoResponse':
          return CierreRemotoResponse.fromJson(value);
        case 'ClavePublicaResponse':
          return ClavePublicaResponse.fromJson(value);
        case 'ClienteEnCajaResponse':
          return ClienteEnCajaResponse.fromJson(value);
        case 'ClienteResponse':
          return ClienteResponse.fromJson(value);
        case 'ComercioActivoRequest':
          return ComercioActivoRequest.fromJson(value);
        case 'ComercioActivoResponse':
          return ComercioActivoResponse.fromJson(value);
        case 'ComercioRegistradoResponse':
          return ComercioRegistradoResponse.fromJson(value);
        case 'ContactoResponse':
          return ContactoResponse.fromJson(value);
        case 'CopiaLocalResponse':
          return CopiaLocalResponse.fromJson(value);
        case 'CorreccionRequest':
          return CorreccionRequest.fromJson(value);
        case 'CorreoResponse':
          return CorreoResponse.fromJson(value);
        case 'CorreoYContrasenaRequest':
          return CorreoYContrasenaRequest.fromJson(value);
        case 'CrearHorarioRequest':
          return CrearHorarioRequest.fromJson(value);
        case 'CrearSedeRequest':
          return CrearSedeRequest.fromJson(value);
        case 'CrearServicioRequest':
          return CrearServicioRequest.fromJson(value);
        case 'CupoDeSedesResponse':
          return CupoDeSedesResponse.fromJson(value);
        case 'DispositivoRequest':
          return DispositivoRequest.fromJson(value);
        case 'DispositivoResponse':
          return DispositivoResponse.fromJson(value);
        case 'DocumentoRequest':
          return DocumentoRequest.fromJson(value);
        case 'DocumentoResponse':
          return DocumentoResponse.fromJson(value);
        case 'EditarComercioRequest':
          return EditarComercioRequest.fromJson(value);
        case 'EditarHorarioRequest':
          return EditarHorarioRequest.fromJson(value);
        case 'EditarSedeRequest':
          return EditarSedeRequest.fromJson(value);
        case 'EnCortoResponse':
          return EnCortoResponse.fromJson(value);
        case 'EspacioResponse':
          return EspacioResponse.fromJson(value);
        case 'EstadoDeCuentaResponse':
          return EstadoDeCuentaResponse.fromJson(value);
        case 'EstadoHorarioRequest':
          return EstadoHorarioRequest.fromJson(value);
        case 'EstadoTipoRequest':
          return EstadoTipoRequest.fromJson(value);
        case 'HorarioResponse':
          return HorarioResponse.fromJson(value);
        case 'IngresoConContrasenaRequest':
          return IngresoConContrasenaRequest.fromJson(value);
        case 'IngresoConPinRequest':
          return IngresoConPinRequest.fromJson(value);
        case 'IngresoResponse':
          return IngresoResponse.fromJson(value);
        case 'InvitacionResponse':
          return InvitacionResponse.fromJson(value);
        case 'InvitarCajeroRequest':
          return InvitarCajeroRequest.fromJson(value);
        case 'LecturaQrResponse':
          return LecturaQrResponse.fromJson(value);
        case 'MapaDeSedesResponse':
          return MapaDeSedesResponse.fromJson(value);
        case 'MedioDePagoResponse':
          return MedioDePagoResponse.fromJson(value);
        case 'MiComercioResponse':
          return MiComercioResponse.fromJson(value);
        case 'MiQrResponse':
          return MiQrResponse.fromJson(value);
        case 'MiembroResponse':
          return MiembroResponse.fromJson(value);
        case 'MisTiqueterasResponse':
          return MisTiqueterasResponse.fromJson(value);
        case 'MotivoResponse':
          return MotivoResponse.fromJson(value);
        case 'MovimientoResponse':
          return MovimientoResponse.fromJson(value);
        case 'MunicipioResponse':
          return MunicipioResponse.fromJson(value);
        case 'PagoRequest':
          return PagoRequest.fromJson(value);
        case 'PagoResponse':
          return PagoResponse.fromJson(value);
        case 'PasoResponse':
          return PasoResponse.fromJson(value);
        case 'PerfilComercioResponse':
          return PerfilComercioResponse.fromJson(value);
        case 'PersonaPorAfiliarResponse':
          return PersonaPorAfiliarResponse.fromJson(value);
        case 'PinBienvenidaResponse':
          return PinBienvenidaResponse.fromJson(value);
        case 'PinClienteResponse':
          return PinClienteResponse.fromJson(value);
        case 'PinNuevoRequest':
          return PinNuevoRequest.fromJson(value);
        case 'PinTemporalResponse':
          return PinTemporalResponse.fromJson(value);
        case 'PlanResponse':
          return PlanResponse.fromJson(value);
        case 'PoliticaResponse':
          return PoliticaResponse.fromJson(value);
        case 'PropietarioInvitadoRequest':
          return PropietarioInvitadoRequest.fromJson(value);
        case 'QrEnComercioResponse':
          return QrEnComercioResponse.fromJson(value);
        case 'RegistrarComercioRequest':
          return RegistrarComercioRequest.fromJson(value);
        case 'RegistrarParaPropietarioRequest':
          return RegistrarParaPropietarioRequest.fromJson(value);
        case 'RegistroAsistidoRequest':
          return RegistroAsistidoRequest.fromJson(value);
        case 'RegistroAsistidoResponse':
          return RegistroAsistidoResponse.fromJson(value);
        case 'RegistroRequest':
          return RegistroRequest.fromJson(value);
        case 'RenovarSesionRequest':
          return RenovarSesionRequest.fromJson(value);
        case 'RespuestaErrorDto':
          return RespuestaErrorDto.fromJson(value);
        case 'RestablecerPinClienteRequest':
          return RestablecerPinClienteRequest.fromJson(value);
        case 'RevisionDocumentoResponse':
          return RevisionDocumentoResponse.fromJson(value);
        case 'SaldoResponse':
          return SaldoResponse.fromJson(value);
        case 'SaludResponse':
          return SaludResponse.fromJson(value);
        case 'SeccionPoliticaResponse':
          return SeccionPoliticaResponse.fromJson(value);
        case 'SedeResponse':
          return SedeResponse.fromJson(value);
        case 'ServicioResponse':
          return ServicioResponse.fromJson(value);
        case 'ServicioSugeridoResponse':
          return ServicioSugeridoResponse.fromJson(value);
        case 'SesionEnDispositivoResponse':
          return SesionEnDispositivoResponse.fromJson(value);
        case 'SesionResponse':
          return SesionResponse.fromJson(value);
        case 'TipoDeNegocioResponse':
          return TipoDeNegocioResponse.fromJson(value);
        case 'TipoDocumentoResponse':
          return TipoDocumentoResponse.fromJson(value);
        case 'TipoRequest':
          return TipoRequest.fromJson(value);
        case 'TipoResponse':
          return TipoResponse.fromJson(value);
        case 'TiqueteraResponse':
          return TiqueteraResponse.fromJson(value);
        case 'TokenQrRequest':
          return TokenQrRequest.fromJson(value);
        case 'UnidadResponse':
          return UnidadResponse.fromJson(value);
        case 'UsuarioResponse':
          return UsuarioResponse.fromJson(value);
        case 'VentaRequest':
          return VentaRequest.fromJson(value);
        case 'VentaResponse':
          return VentaResponse.fromJson(value);
        case 'VentaResumenResponse':
          return VentaResumenResponse.fromJson(value);
        default:
          dynamic match;
          if (value is List && (match = _regList.firstMatch(targetType)?.group(1)) != null) {
            return value
              .map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,))
              .toList(growable: growable);
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)?.group(1)) != null) {
            return value
              .map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,))
              .toSet();
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)?.group(1)) != null) {
            return Map<String, dynamic>.fromIterables(
              value.keys.cast<String>(),
              value.values.map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,)),
            );
          }
      }
    } on Exception catch (error, trace) {
      throw ApiException.withInner(HttpStatus.internalServerError, 'Exception during deserialization.', error, trace,);
    }
    throw ApiException(HttpStatus.internalServerError, 'Could not find a suitable class for deserialization',);
  }
}

/// Primarily intended for use in an isolate.
class DeserializationMessage {
  const DeserializationMessage({
    required this.json,
    required this.targetType,
    this.growable = false,
  });

  /// The JSON value to deserialize.
  final String json;

  /// Target type to deserialize to.
  final String targetType;

  /// Whether to make deserialized lists or maps growable.
  final bool growable;
}

/// Primarily intended for use in an isolate.
Future<dynamic> decodeAsync(DeserializationMessage message) async {
  // Remove all spaces. Necessary for regular expressions as well.
  final targetType = message.targetType.replaceAll(' ', '');

  // If the expected target type is String, nothing to do...
  return targetType == 'String'
    ? message.json
    : json.decode(message.json);
}

/// Primarily intended for use in an isolate.
Future<dynamic> deserializeAsync(DeserializationMessage message) async {
  // Remove all spaces. Necessary for regular expressions as well.
  final targetType = message.targetType.replaceAll(' ', '');

  // If the expected target type is String, nothing to do...
  return targetType == 'String'
    ? message.json
    : ApiClient.fromJson(
        json.decode(message.json),
        targetType,
        growable: message.growable,
      );
}

/// Primarily intended for use in an isolate.
Future<String> serializeAsync(Object? value) async => value == null ? '' : json.encode(value);
