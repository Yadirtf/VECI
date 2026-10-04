//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;


class SesionesApi {
  SesionesApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Crea el PIN propio tras uno temporal
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [PinNuevoRequest] pinNuevoRequest (required):
  Future<Response> crearPinNuevoWithHttpInfo(PinNuevoRequest pinNuevoRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/sesion/pin-nuevo';

    // ignore: prefer_final_locals
    Object? postBody = pinNuevoRequest;

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

  /// Crea el PIN propio tras uno temporal
  ///
  /// Parameters:
  ///
  /// * [PinNuevoRequest] pinNuevoRequest (required):
  Future<SesionResponse?> crearPinNuevo(PinNuevoRequest pinNuevoRequest, { Future<void>? abortTrigger, }) async {
    final response = await crearPinNuevoWithHttpInfo(pinNuevoRequest, abortTrigger: abortTrigger,);
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

  /// Entra al panel con correo (HU-02-02)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [IngresoConContrasenaRequest] ingresoConContrasenaRequest (required):
  Future<Response> entrarConContrasenaWithHttpInfo(IngresoConContrasenaRequest ingresoConContrasenaRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/sesion/con-contrasena';

    // ignore: prefer_final_locals
    Object? postBody = ingresoConContrasenaRequest;

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

  /// Entra al panel con correo (HU-02-02)
  ///
  /// Parameters:
  ///
  /// * [IngresoConContrasenaRequest] ingresoConContrasenaRequest (required):
  Future<IngresoResponse?> entrarConContrasena(IngresoConContrasenaRequest ingresoConContrasenaRequest, { Future<void>? abortTrigger, }) async {
    final response = await entrarConContrasenaWithHttpInfo(ingresoConContrasenaRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'IngresoResponse',) as IngresoResponse;
    
    }
    return null;
  }

  /// Entra con celular y PIN (HU-02-01)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [IngresoConPinRequest] ingresoConPinRequest (required):
  Future<Response> entrarConPinWithHttpInfo(IngresoConPinRequest ingresoConPinRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/sesion/con-pin';

    // ignore: prefer_final_locals
    Object? postBody = ingresoConPinRequest;

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

  /// Entra con celular y PIN (HU-02-01)
  ///
  /// Parameters:
  ///
  /// * [IngresoConPinRequest] ingresoConPinRequest (required):
  Future<IngresoResponse?> entrarConPin(IngresoConPinRequest ingresoConPinRequest, { Future<void>? abortTrigger, }) async {
    final response = await entrarConPinWithHttpInfo(ingresoConPinRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'IngresoResponse',) as IngresoResponse;
    
    }
    return null;
  }

  /// Cambia el token de renovación por otro
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [RenovarSesionRequest] renovarSesionRequest (required):
  Future<Response> renovarSesionWithHttpInfo(RenovarSesionRequest renovarSesionRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/sesion/renovar';

    // ignore: prefer_final_locals
    Object? postBody = renovarSesionRequest;

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

  /// Cambia el token de renovación por otro
  ///
  /// Parameters:
  ///
  /// * [RenovarSesionRequest] renovarSesionRequest (required):
  Future<SesionResponse?> renovarSesion(RenovarSesionRequest renovarSesionRequest, { Future<void>? abortTrigger, }) async {
    final response = await renovarSesionWithHttpInfo(renovarSesionRequest, abortTrigger: abortTrigger,);
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

  /// Cierra la sesión en este dispositivo
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> salirWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/sesion/salir';

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

  /// Cierra la sesión en este dispositivo
  Future<void> salir({ Future<void>? abortTrigger, }) async {
    final response = await salirWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
