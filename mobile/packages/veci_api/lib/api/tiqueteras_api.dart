//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;


class TiqueterasApi {
  TiqueterasApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Suma o quita unidades con motivo; queda en la historia (HU-05-05)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [String] tiqueteraId (required):
  ///
  /// * [AjusteRequest] ajusteRequest (required):
  Future<Response> ajustarSaldoWithHttpInfo(String xVeciComercio, String tiqueteraId, AjusteRequest ajusteRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/tiqueteras/{tiqueteraId}/ajustes'
      .replaceAll('{tiqueteraId}', tiqueteraId);

    // ignore: prefer_final_locals
    Object? postBody = ajusteRequest;

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

  /// Suma o quita unidades con motivo; queda en la historia (HU-05-05)
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [String] tiqueteraId (required):
  ///
  /// * [AjusteRequest] ajusteRequest (required):
  Future<EstadoDeCuentaResponse?> ajustarSaldo(String xVeciComercio, String tiqueteraId, AjusteRequest ajusteRequest, { Future<void>? abortTrigger, }) async {
    final response = await ajustarSaldoWithHttpInfo(xVeciComercio, tiqueteraId, ajusteRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'EstadoDeCuentaResponse',) as EstadoDeCuentaResponse;
    
    }
    return null;
  }

  /// Activar o desactivar la venta
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [String] tipoId (required):
  ///
  /// * [EstadoTipoRequest] estadoTipoRequest (required):
  Future<Response> cambiarEstadoDeTipoWithHttpInfo(String xVeciComercio, String tipoId, EstadoTipoRequest estadoTipoRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/tiqueteras/tipos/{tipoId}/estado'
      .replaceAll('{tipoId}', tipoId);

    // ignore: prefer_final_locals
    Object? postBody = estadoTipoRequest;

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

  /// Activar o desactivar la venta
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [String] tipoId (required):
  ///
  /// * [EstadoTipoRequest] estadoTipoRequest (required):
  Future<TipoResponse?> cambiarEstadoDeTipo(String xVeciComercio, String tipoId, EstadoTipoRequest estadoTipoRequest, { Future<void>? abortTrigger, }) async {
    final response = await cambiarEstadoDeTipoWithHttpInfo(xVeciComercio, tipoId, estadoTipoRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'TipoResponse',) as TipoResponse;
    
    }
    return null;
  }

  /// Mi saldo en cada negocio
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> consultarMisTiqueterasWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/mis-tiqueteras';

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

  /// Mi saldo en cada negocio
  Future<List<MisTiqueterasResponse>?> consultarMisTiqueteras({ Future<void>? abortTrigger, }) async {
    final response = await consultarMisTiqueterasWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<MisTiqueterasResponse>') as List)
        .cast<MisTiqueterasResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Saldo por unidad, tiqueteras e historia (HU-05-03)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [String] clienteId (required):
  Future<Response> consultarSaldoDelClienteWithHttpInfo(String xVeciComercio, String clienteId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/tiqueteras/cliente/{clienteId}'
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

  /// Saldo por unidad, tiqueteras e historia (HU-05-03)
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [String] clienteId (required):
  Future<EstadoDeCuentaResponse?> consultarSaldoDelCliente(String xVeciComercio, String clienteId, { Future<void>? abortTrigger, }) async {
    final response = await consultarSaldoDelClienteWithHttpInfo(xVeciComercio, clienteId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'EstadoDeCuentaResponse',) as EstadoDeCuentaResponse;
    
    }
    return null;
  }

  /// Nuevo paquete (HU-05-01)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [TipoRequest] tipoRequest (required):
  Future<Response> crearTipoDeTiqueteraWithHttpInfo(String xVeciComercio, TipoRequest tipoRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/tiqueteras/tipos';

    // ignore: prefer_final_locals
    Object? postBody = tipoRequest;

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

  /// Nuevo paquete (HU-05-01)
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [TipoRequest] tipoRequest (required):
  Future<TipoResponse?> crearTipoDeTiquetera(String xVeciComercio, TipoRequest tipoRequest, { Future<void>? abortTrigger, }) async {
    final response = await crearTipoDeTiqueteraWithHttpInfo(xVeciComercio, tipoRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'TipoResponse',) as TipoResponse;
    
    }
    return null;
  }

  /// Cambia precio o vigencia; lo vendido no cambia
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [String] tipoId (required):
  ///
  /// * [TipoRequest] tipoRequest (required):
  Future<Response> editarTipoDeTiqueteraWithHttpInfo(String xVeciComercio, String tipoId, TipoRequest tipoRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/tiqueteras/tipos/{tipoId}'
      .replaceAll('{tipoId}', tipoId);

    // ignore: prefer_final_locals
    Object? postBody = tipoRequest;

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

  /// Cambia precio o vigencia; lo vendido no cambia
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [String] tipoId (required):
  ///
  /// * [TipoRequest] tipoRequest (required):
  Future<TipoResponse?> editarTipoDeTiquetera(String xVeciComercio, String tipoId, TipoRequest tipoRequest, { Future<void>? abortTrigger, }) async {
    final response = await editarTipoDeTiqueteraWithHttpInfo(xVeciComercio, tipoId, tipoRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'TipoResponse',) as TipoResponse;
    
    }
    return null;
  }

  /// Para anular o ajustar
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  Future<Response> listarMotivosDeCorreccionWithHttpInfo(String xVeciComercio, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/tiqueteras/motivos';

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

  /// Para anular o ajustar
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  Future<List<MotivoResponse>?> listarMotivosDeCorreccion(String xVeciComercio, { Future<void>? abortTrigger, }) async {
    final response = await listarMotivosDeCorreccionWithHttpInfo(xVeciComercio, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<MotivoResponse>') as List)
        .cast<MotivoResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Activos y guardados
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  Future<Response> listarTiposDeTiqueteraWithHttpInfo(String xVeciComercio, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/tiqueteras/tipos';

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

  /// Activos y guardados
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  Future<List<TipoResponse>?> listarTiposDeTiquetera(String xVeciComercio, { Future<void>? abortTrigger, }) async {
    final response = await listarTiposDeTiqueteraWithHttpInfo(xVeciComercio, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<TipoResponse>') as List)
        .cast<TipoResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Almuerzo, desayuno, café…
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  Future<Response> listarUnidadesDeConsumoWithHttpInfo(String xVeciComercio, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/tiqueteras/unidades';

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

  /// Almuerzo, desayuno, café…
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  Future<List<UnidadResponse>?> listarUnidadesDeConsumo(String xVeciComercio, { Future<void>? abortTrigger, }) async {
    final response = await listarUnidadesDeConsumoWithHttpInfo(xVeciComercio, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<UnidadResponse>') as List)
        .cast<UnidadResponse>()
        .toList(growable: false);

    }
    return null;
  }
}
