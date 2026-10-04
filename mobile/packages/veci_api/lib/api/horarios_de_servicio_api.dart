//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;


class HorariosDeServicioApi {
  HorariosDeServicioApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Agrega un horario de servicio
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [CrearHorarioRequest] crearHorarioRequest (required):
  Future<Response> crearHorarioWithHttpInfo(String xVeciComercio, CrearHorarioRequest crearHorarioRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/horarios';

    // ignore: prefer_final_locals
    Object? postBody = crearHorarioRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'x-veci-comercio'] = parameterToString(xVeciComercio);

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Agrega un horario de servicio
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [CrearHorarioRequest] crearHorarioRequest (required):
  Future<HorarioResponse?> crearHorario(String xVeciComercio, CrearHorarioRequest crearHorarioRequest, { Future<void>? abortTrigger, }) async {
    final response = await crearHorarioWithHttpInfo(xVeciComercio, crearHorarioRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'HorarioResponse',) as HorarioResponse;
    
    }
    return null;
  }

  /// Horarios vigentes del negocio
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  Future<Response> listarHorariosWithHttpInfo(String xVeciComercio, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/horarios';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'x-veci-comercio'] = parameterToString(xVeciComercio);

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Horarios vigentes del negocio
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  Future<List<HorarioResponse>?> listarHorarios(String xVeciComercio, { Future<void>? abortTrigger, }) async {
    final response = await listarHorariosWithHttpInfo(xVeciComercio, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<HorarioResponse>') as List)
        .cast<HorarioResponse>()
        .toList(growable: false);

    }
    return null;
  }
}
