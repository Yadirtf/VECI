//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;


class ComerciosApi {
  ComerciosApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Abre el negocio para vender
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  Future<Response> abrirComercioWithHttpInfo(String xVeciComercio, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/comercio/abrir';

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

  /// Abre el negocio para vender
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  Future<PerfilComercioResponse?> abrirComercio(String xVeciComercio, { Future<void>? abortTrigger, }) async {
    final response = await abrirComercioWithHttpInfo(xVeciComercio, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PerfilComercioResponse',) as PerfilComercioResponse;
    
    }
    return null;
  }

  /// Datos, plan y camino para abrir
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  Future<Response> consultarComercioWithHttpInfo(String xVeciComercio, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/comercio';

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

  /// Datos, plan y camino para abrir
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  Future<PerfilComercioResponse?> consultarComercio(String xVeciComercio, { Future<void>? abortTrigger, }) async {
    final response = await consultarComercioWithHttpInfo(xVeciComercio, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PerfilComercioResponse',) as PerfilComercioResponse;
    
    }
    return null;
  }

  /// Cambia los datos del negocio
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [EditarComercioRequest] editarComercioRequest (required):
  Future<Response> editarComercioWithHttpInfo(String xVeciComercio, EditarComercioRequest editarComercioRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/comercio';

    // ignore: prefer_final_locals
    Object? postBody = editarComercioRequest;

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

  /// Cambia los datos del negocio
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [EditarComercioRequest] editarComercioRequest (required):
  Future<PerfilComercioResponse?> editarComercio(String xVeciComercio, EditarComercioRequest editarComercioRequest, { Future<void>? abortTrigger, }) async {
    final response = await editarComercioWithHttpInfo(xVeciComercio, editarComercioRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PerfilComercioResponse',) as PerfilComercioResponse;
    
    }
    return null;
  }

  /// Municipios donde opera VECI
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listarMunicipiosWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/comercios/municipios';

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

  /// Municipios donde opera VECI
  Future<List<MunicipioResponse>?> listarMunicipios({ Future<void>? abortTrigger, }) async {
    final response = await listarMunicipiosWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<MunicipioResponse>') as List)
        .cast<MunicipioResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Tipos de negocio y servicios
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listarTiposDeNegocioWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/comercios/tipos';

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

  /// Tipos de negocio y servicios
  Future<List<TipoDeNegocioResponse>?> listarTiposDeNegocio({ Future<void>? abortTrigger, }) async {
    final response = await listarTiposDeNegocioWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<TipoDeNegocioResponse>') as List)
        .cast<TipoDeNegocioResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Administración VECI registra un negocio e invita a su dueño (HU-03-01)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [RegistrarParaPropietarioRequest] registrarParaPropietarioRequest (required):
  Future<Response> registrarComercioParaPropietarioWithHttpInfo(RegistrarParaPropietarioRequest registrarParaPropietarioRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/plataforma/comercios';

    // ignore: prefer_final_locals
    Object? postBody = registrarParaPropietarioRequest;

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

  /// Administración VECI registra un negocio e invita a su dueño (HU-03-01)
  ///
  /// Parameters:
  ///
  /// * [RegistrarParaPropietarioRequest] registrarParaPropietarioRequest (required):
  Future<ComercioRegistradoResponse?> registrarComercioParaPropietario(RegistrarParaPropietarioRequest registrarParaPropietarioRequest, { Future<void>? abortTrigger, }) async {
    final response = await registrarComercioParaPropietarioWithHttpInfo(registrarParaPropietarioRequest, abortTrigger: abortTrigger,);
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
}
