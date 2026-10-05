//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;


class RegistroDelClienteApi {
  RegistroDelClienteApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Mi QR personal para afiliarme
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> consultarMiQrWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/mi-qr';

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

  /// Mi QR personal para afiliarme
  Future<MiQrResponse?> consultarMiQr({ Future<void>? abortTrigger, }) async {
    final response = await consultarMiQrWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MiQrResponse',) as MiQrResponse;
    
    }
    return null;
  }

  /// Política de datos vigente
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> consultarPoliticaDeDatosWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/politica-de-datos';

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

  /// Política de datos vigente
  Future<PoliticaResponse?> consultarPoliticaDeDatos({ Future<void>? abortTrigger, }) async {
    final response = await consultarPoliticaDeDatosWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PoliticaResponse',) as PoliticaResponse;
    
    }
    return null;
  }

  /// Negocios donde soy cliente, con mi QR en cada uno
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listarMisComerciosWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/mis-comercios';

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

  /// Negocios donde soy cliente, con mi QR en cada uno
  Future<List<MiComercioResponse>?> listarMisComercios({ Future<void>? abortTrigger, }) async {
    final response = await listarMisComerciosWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<MiComercioResponse>') as List)
        .cast<MiComercioResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Documentos de personas
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listarTiposDeDocumentoWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/registro/tipos-documento';

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

  /// Documentos de personas
  Future<List<TipoDocumentoResponse>?> listarTiposDeDocumento({ Future<void>? abortTrigger, }) async {
    final response = await listarTiposDeDocumentoWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<TipoDocumentoResponse>') as List)
        .cast<TipoDocumentoResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// QR nuevo; el anterior deja de servir (HU-04-02)
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> regenerarMiQrWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/mi-qr/regenerar';

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

  /// QR nuevo; el anterior deja de servir (HU-04-02)
  Future<MiQrResponse?> regenerarMiQr({ Future<void>? abortTrigger, }) async {
    final response = await regenerarMiQrWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MiQrResponse',) as MiQrResponse;
    
    }
    return null;
  }

  /// El cliente crea su cuenta y entra (HU-04-01)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [RegistroRequest] registroRequest (required):
  Future<Response> registrarmeWithHttpInfo(RegistroRequest registroRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/registro';

    // ignore: prefer_final_locals
    Object? postBody = registroRequest;

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

  /// El cliente crea su cuenta y entra (HU-04-01)
  ///
  /// Parameters:
  ///
  /// * [RegistroRequest] registroRequest (required):
  Future<SesionResponse?> registrarme(RegistroRequest registroRequest, { Future<void>? abortTrigger, }) async {
    final response = await registrarmeWithHttpInfo(registroRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SesionResponse',) as SesionResponse;
    
    }
    return null;
  }
}
