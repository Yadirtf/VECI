//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;


class SolicitudesDeNegocioApi {
  SolicitudesDeNegocioApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Aprueba: nace el negocio con quien lo pidió como propietaria
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] solicitudId (required):
  Future<Response> aprobarSolicitudDeNegocioWithHttpInfo(String solicitudId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/plataforma/solicitudes-de-negocio/{solicitudId}/aprobacion'
      .replaceAll('{solicitudId}', solicitudId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


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

  /// Aprueba: nace el negocio con quien lo pidió como propietaria
  ///
  /// Parameters:
  ///
  /// * [String] solicitudId (required):
  Future<ComercioRegistradoResponse?> aprobarSolicitudDeNegocio(String solicitudId, { Future<void>? abortTrigger, }) async {
    final response = await aprobarSolicitudDeNegocioWithHttpInfo(solicitudId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ComercioRegistradoResponse',) as ComercioRegistradoResponse;
    
    }
    return null;
  }

  /// Mis solicitudes
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listarMisSolicitudesDeNegocioWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/solicitudes-de-negocio';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Mis solicitudes
  Future<List<SolicitudResponse>?> listarMisSolicitudesDeNegocio({ Future<void>? abortTrigger, }) async {
    final response = await listarMisSolicitudesDeNegocioWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<SolicitudResponse>') as List)
        .cast<SolicitudResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Solicitudes por revisar
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] estado:
  Future<Response> listarSolicitudesDeNegocioWithHttpInfo({ String? estado, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/plataforma/solicitudes-de-negocio';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (estado != null) {
      queryParams.addAll(_queryParams('', 'estado', estado));
    }

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

  /// Solicitudes por revisar
  ///
  /// Parameters:
  ///
  /// * [String] estado:
  Future<List<SolicitudResponse>?> listarSolicitudesDeNegocio({ String? estado, Future<void>? abortTrigger, }) async {
    final response = await listarSolicitudesDeNegocioWithHttpInfo(estado: estado, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<SolicitudResponse>') as List)
        .cast<SolicitudResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Rechaza y dice por qué
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] solicitudId (required):
  ///
  /// * [RechazoSolicitudRequest] rechazoSolicitudRequest (required):
  Future<Response> rechazarSolicitudDeNegocioWithHttpInfo(String solicitudId, RechazoSolicitudRequest rechazoSolicitudRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/plataforma/solicitudes-de-negocio/{solicitudId}/rechazo'
      .replaceAll('{solicitudId}', solicitudId);

    // ignore: prefer_final_locals
    Object? postBody = rechazoSolicitudRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Rechaza y dice por qué
  ///
  /// Parameters:
  ///
  /// * [String] solicitudId (required):
  ///
  /// * [RechazoSolicitudRequest] rechazoSolicitudRequest (required):
  Future<void> rechazarSolicitudDeNegocio(String solicitudId, RechazoSolicitudRequest rechazoSolicitudRequest, { Future<void>? abortTrigger, }) async {
    final response = await rechazarSolicitudDeNegocioWithHttpInfo(solicitudId, rechazoSolicitudRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Pide registrar mi negocio
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [SolicitarRegistroRequest] solicitarRegistroRequest (required):
  Future<Response> solicitarRegistroDeNegocioWithHttpInfo(SolicitarRegistroRequest solicitarRegistroRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/solicitudes-de-negocio';

    // ignore: prefer_final_locals
    Object? postBody = solicitarRegistroRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Pide registrar mi negocio
  ///
  /// Parameters:
  ///
  /// * [SolicitarRegistroRequest] solicitarRegistroRequest (required):
  Future<void> solicitarRegistroDeNegocio(SolicitarRegistroRequest solicitarRegistroRequest, { Future<void>? abortTrigger, }) async {
    final response = await solicitarRegistroDeNegocioWithHttpInfo(solicitarRegistroRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
