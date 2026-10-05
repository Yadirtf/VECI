//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;


class SedesApi {
  SedesApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Sedes donde trabaja un cajero
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [String] membresiaId (required):
  ///
  /// * [AsignarSedesRequest] asignarSedesRequest (required):
  Future<Response> asignarSedesACajeroWithHttpInfo(String xVeciComercio, String membresiaId, AsignarSedesRequest asignarSedesRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/sedes/cajeros/{membresiaId}'
      .replaceAll('{membresiaId}', membresiaId);

    // ignore: prefer_final_locals
    Object? postBody = asignarSedesRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'x-veci-comercio'] = parameterToString(xVeciComercio);

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Sedes donde trabaja un cajero
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [String] membresiaId (required):
  ///
  /// * [AsignarSedesRequest] asignarSedesRequest (required):
  Future<void> asignarSedesACajero(String xVeciComercio, String membresiaId, AsignarSedesRequest asignarSedesRequest, { Future<void>? abortTrigger, }) async {
    final response = await asignarSedesACajeroWithHttpInfo(xVeciComercio, membresiaId, asignarSedesRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Abre otra sede (plan Pro, HU-03-03)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [CrearSedeRequest] crearSedeRequest (required):
  Future<Response> crearSedeWithHttpInfo(String xVeciComercio, CrearSedeRequest crearSedeRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/sedes';

    // ignore: prefer_final_locals
    Object? postBody = crearSedeRequest;

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

  /// Abre otra sede (plan Pro, HU-03-03)
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [CrearSedeRequest] crearSedeRequest (required):
  Future<SedeResponse?> crearSede(String xVeciComercio, CrearSedeRequest crearSedeRequest, { Future<void>? abortTrigger, }) async {
    final response = await crearSedeWithHttpInfo(xVeciComercio, crearSedeRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SedeResponse',) as SedeResponse;
    
    }
    return null;
  }

  /// Cambia, desactiva o reabre una sede
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [String] sedeId (required):
  ///
  /// * [EditarSedeRequest] editarSedeRequest (required):
  Future<Response> editarSedeWithHttpInfo(String xVeciComercio, String sedeId, EditarSedeRequest editarSedeRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/sedes/{sedeId}'
      .replaceAll('{sedeId}', sedeId);

    // ignore: prefer_final_locals
    Object? postBody = editarSedeRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'x-veci-comercio'] = parameterToString(xVeciComercio);

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Cambia, desactiva o reabre una sede
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [String] sedeId (required):
  ///
  /// * [EditarSedeRequest] editarSedeRequest (required):
  Future<SedeResponse?> editarSede(String xVeciComercio, String sedeId, EditarSedeRequest editarSedeRequest, { Future<void>? abortTrigger, }) async {
    final response = await editarSedeWithHttpInfo(xVeciComercio, sedeId, editarSedeRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SedeResponse',) as SedeResponse;
    
    }
    return null;
  }

  /// Sedes, cajeros por sede y cupo del plan
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  Future<Response> listarSedesWithHttpInfo(String xVeciComercio, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/sedes';

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

  /// Sedes, cajeros por sede y cupo del plan
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  Future<MapaDeSedesResponse?> listarSedes(String xVeciComercio, { Future<void>? abortTrigger, }) async {
    final response = await listarSedesWithHttpInfo(xVeciComercio, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MapaDeSedesResponse',) as MapaDeSedesResponse;
    
    }
    return null;
  }
}
