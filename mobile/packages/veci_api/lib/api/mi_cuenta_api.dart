//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;


class MiCuentaApi {
  MiCuentaApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Cambia mi PIN
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CambiarPinRequest] cambiarPinRequest (required):
  Future<Response> cambiarMiPinWithHttpInfo(CambiarPinRequest cambiarPinRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/cuenta/pin';

    // ignore: prefer_final_locals
    Object? postBody = cambiarPinRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Cambia mi PIN
  ///
  /// Parameters:
  ///
  /// * [CambiarPinRequest] cambiarPinRequest (required):
  Future<void> cambiarMiPin(CambiarPinRequest cambiarPinRequest, { Future<void>? abortTrigger, }) async {
    final response = await cambiarMiPinWithHttpInfo(cambiarPinRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Correo y contraseña para entrar al panel (HU-02-02)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CorreoYContrasenaRequest] correoYContrasenaRequest (required):
  Future<Response> definirCorreoYContrasenaWithHttpInfo(CorreoYContrasenaRequest correoYContrasenaRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/cuenta/correo-y-contrasena';

    // ignore: prefer_final_locals
    Object? postBody = correoYContrasenaRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Correo y contraseña para entrar al panel (HU-02-02)
  ///
  /// Parameters:
  ///
  /// * [CorreoYContrasenaRequest] correoYContrasenaRequest (required):
  Future<CorreoResponse?> definirCorreoYContrasena(CorreoYContrasenaRequest correoYContrasenaRequest, { Future<void>? abortTrigger, }) async {
    final response = await definirCorreoYContrasenaWithHttpInfo(correoYContrasenaRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CorreoResponse',) as CorreoResponse;
    
    }
    return null;
  }

  /// Elige el negocio con el que trabajo
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [ComercioActivoRequest] comercioActivoRequest (required):
  Future<Response> elegirComercioWithHttpInfo(ComercioActivoRequest comercioActivoRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/cuenta/comercio-activo';

    // ignore: prefer_final_locals
    Object? postBody = comercioActivoRequest;

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

  /// Elige el negocio con el que trabajo
  ///
  /// Parameters:
  ///
  /// * [ComercioActivoRequest] comercioActivoRequest (required):
  Future<ComercioActivoResponse?> elegirComercio(ComercioActivoRequest comercioActivoRequest, { Future<void>? abortTrigger, }) async {
    final response = await elegirComercioWithHttpInfo(comercioActivoRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ComercioActivoResponse',) as ComercioActivoResponse;
    
    }
    return null;
  }

  /// Comercios donde trabajo o soy cliente
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listarMisEspaciosWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/cuenta/espacios';

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

  /// Comercios donde trabajo o soy cliente
  Future<List<EspacioResponse>?> listarMisEspacios({ Future<void>? abortTrigger, }) async {
    final response = await listarMisEspaciosWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<EspacioResponse>') as List)
        .cast<EspacioResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Qué puedo hacer en la consola VECI (vacío si no soy del equipo VECI)
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listarMisPermisosDePlataformaWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/cuenta/permisos-de-plataforma';

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

  /// Qué puedo hacer en la consola VECI (vacío si no soy del equipo VECI)
  Future<List<String>?> listarMisPermisosDePlataforma({ Future<void>? abortTrigger, }) async {
    final response = await listarMisPermisosDePlataformaWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<String>') as List)
        .cast<String>()
        .toList(growable: false);

    }
    return null;
  }
}
