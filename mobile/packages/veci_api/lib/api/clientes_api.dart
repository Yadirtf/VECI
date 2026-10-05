//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;


class ClientesApi {
  ClientesApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Afilia con el QR personal (HU-04-03)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [TokenQrRequest] tokenQrRequest (required):
  Future<Response> afiliarPorQrWithHttpInfo(String xVeciComercio, TokenQrRequest tokenQrRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/clientes/afiliaciones';

    // ignore: prefer_final_locals
    Object? postBody = tokenQrRequest;

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

  /// Afilia con el QR personal (HU-04-03)
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [TokenQrRequest] tokenQrRequest (required):
  Future<AfiliacionResponse?> afiliarPorQr(String xVeciComercio, TokenQrRequest tokenQrRequest, { Future<void>? abortTrigger, }) async {
    final response = await afiliarPorQrWithHttpInfo(xVeciComercio, tokenQrRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AfiliacionResponse',) as AfiliacionResponse;
    
    }
    return null;
  }

  /// Copia para buscar sin internet; 304 si no cambió (HU-04-05)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  Future<Response> bajarCopiaLocalDeClientesWithHttpInfo(String xVeciComercio, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/clientes/copia-local';

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

  /// Copia para buscar sin internet; 304 si no cambió (HU-04-05)
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  Future<CopiaLocalResponse?> bajarCopiaLocalDeClientes(String xVeciComercio, { Future<void>? abortTrigger, }) async {
    final response = await bajarCopiaLocalDeClientesWithHttpInfo(xVeciComercio, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CopiaLocalResponse',) as CopiaLocalResponse;
    
    }
    return null;
  }

  /// Por nombre, celular o documento (HU-04-05)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [Object] q (required):
  ///   Desde 3 letras o números
  Future<Response> buscarClientesWithHttpInfo(String xVeciComercio, Object q, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/clientes';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'q', q));

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

  /// Por nombre, celular o documento (HU-04-05)
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [Object] q (required):
  ///   Desde 3 letras o números
  Future<List<ClienteResponse>?> buscarClientes(String xVeciComercio, Object q, { Future<void>? abortTrigger, }) async {
    final response = await buscarClientesWithHttpInfo(xVeciComercio, q, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<ClienteResponse>') as List)
        .cast<ClienteResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Ficha del cliente
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [String] clienteId (required):
  Future<Response> consultarClienteWithHttpInfo(String xVeciComercio, String clienteId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/clientes/{clienteId}'
      .replaceAll('{clienteId}', clienteId);

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

  /// Ficha del cliente
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [String] clienteId (required):
  Future<ClienteResponse?> consultarCliente(String xVeciComercio, String clienteId, { Future<void>? abortTrigger, }) async {
    final response = await consultarClienteWithHttpInfo(xVeciComercio, clienteId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ClienteResponse',) as ClienteResponse;
    
    }
    return null;
  }

  /// PIN nuevo para activar la app (HU-04-04)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [String] clienteId (required):
  Future<Response> darPinDeBienvenidaWithHttpInfo(String xVeciComercio, String clienteId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/clientes/{clienteId}/pin-bienvenida'
      .replaceAll('{clienteId}', clienteId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'x-veci-comercio'] = parameterToString(xVeciComercio);

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

  /// PIN nuevo para activar la app (HU-04-04)
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [String] clienteId (required):
  Future<PinBienvenidaResponse?> darPinDeBienvenida(String xVeciComercio, String clienteId, { Future<void>? abortTrigger, }) async {
    final response = await darPinDeBienvenidaWithHttpInfo(xVeciComercio, clienteId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PinBienvenidaResponse',) as PinBienvenidaResponse;
    
    }
    return null;
  }

  /// Qué es el QR que escaneó la caja
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [TokenQrRequest] tokenQrRequest (required):
  Future<Response> leerQrDeClienteWithHttpInfo(String xVeciComercio, TokenQrRequest tokenQrRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/clientes/qr';

    // ignore: prefer_final_locals
    Object? postBody = tokenQrRequest;

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

  /// Qué es el QR que escaneó la caja
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [TokenQrRequest] tokenQrRequest (required):
  Future<LecturaQrResponse?> leerQrDeCliente(String xVeciComercio, TokenQrRequest tokenQrRequest, { Future<void>? abortTrigger, }) async {
    final response = await leerQrDeClienteWithHttpInfo(xVeciComercio, tokenQrRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'LecturaQrResponse',) as LecturaQrResponse;
    
    }
    return null;
  }

  /// Registra a quien no tiene la app (HU-04-04)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [RegistroAsistidoRequest] registroAsistidoRequest (required):
  Future<Response> registrarClienteAsistidoWithHttpInfo(String xVeciComercio, RegistroAsistidoRequest registroAsistidoRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/clientes/registro-asistido';

    // ignore: prefer_final_locals
    Object? postBody = registroAsistidoRequest;

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

  /// Registra a quien no tiene la app (HU-04-04)
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [RegistroAsistidoRequest] registroAsistidoRequest (required):
  Future<RegistroAsistidoResponse?> registrarClienteAsistido(String xVeciComercio, RegistroAsistidoRequest registroAsistidoRequest, { Future<void>? abortTrigger, }) async {
    final response = await registrarClienteAsistidoWithHttpInfo(xVeciComercio, registroAsistidoRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RegistroAsistidoResponse',) as RegistroAsistidoResponse;
    
    }
    return null;
  }

  /// ¿Ya está en VECI? Solo datos enmascarados (HU-04-04)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [DocumentoRequest] documentoRequest (required):
  Future<Response> revisarDocumentoDeClienteWithHttpInfo(String xVeciComercio, DocumentoRequest documentoRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/clientes/registro-asistido/revisar';

    // ignore: prefer_final_locals
    Object? postBody = documentoRequest;

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

  /// ¿Ya está en VECI? Solo datos enmascarados (HU-04-04)
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [DocumentoRequest] documentoRequest (required):
  Future<RevisionDocumentoResponse?> revisarDocumentoDeCliente(String xVeciComercio, DocumentoRequest documentoRequest, { Future<void>? abortTrigger, }) async {
    final response = await revisarDocumentoDeClienteWithHttpInfo(xVeciComercio, documentoRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RevisionDocumentoResponse',) as RevisionDocumentoResponse;
    
    }
    return null;
  }
}
