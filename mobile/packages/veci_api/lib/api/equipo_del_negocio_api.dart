//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;


class EquipoDelNegocioApi {
  EquipoDelNegocioApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Suspende, reactiva o retira
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
  /// * [CambiarEstadoCajeroRequest] cambiarEstadoCajeroRequest (required):
  Future<Response> cambiarEstadoCajeroWithHttpInfo(String xVeciComercio, String membresiaId, CambiarEstadoCajeroRequest cambiarEstadoCajeroRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/equipo/{membresiaId}/estado'
      .replaceAll('{membresiaId}', membresiaId);

    // ignore: prefer_final_locals
    Object? postBody = cambiarEstadoCajeroRequest;

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

  /// Suspende, reactiva o retira
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [String] membresiaId (required):
  ///
  /// * [CambiarEstadoCajeroRequest] cambiarEstadoCajeroRequest (required):
  Future<MiembroResponse?> cambiarEstadoCajero(String xVeciComercio, String membresiaId, CambiarEstadoCajeroRequest cambiarEstadoCajeroRequest, { Future<void>? abortTrigger, }) async {
    final response = await cambiarEstadoCajeroWithHttpInfo(xVeciComercio, membresiaId, cambiarEstadoCajeroRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MiembroResponse',) as MiembroResponse;
    
    }
    return null;
  }

  /// Cierre remoto (HU-02-06)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [String] dispositivoId (required):
  Future<Response> cerrarSesionDispositivoWithHttpInfo(String xVeciComercio, String dispositivoId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/dispositivos/{dispositivoId}/cerrar-sesion'
      .replaceAll('{dispositivoId}', dispositivoId);

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

  /// Cierre remoto (HU-02-06)
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [String] dispositivoId (required):
  Future<CierreRemotoResponse?> cerrarSesionDispositivo(String xVeciComercio, String dispositivoId, { Future<void>? abortTrigger, }) async {
    final response = await cerrarSesionDispositivoWithHttpInfo(xVeciComercio, dispositivoId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CierreRemotoResponse',) as CierreRemotoResponse;
    
    }
    return null;
  }

  /// Invita un cajero por su celular (HU-02-04)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [InvitarCajeroRequest] invitarCajeroRequest (required):
  Future<Response> invitarCajeroWithHttpInfo(String xVeciComercio, InvitarCajeroRequest invitarCajeroRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/equipo/cajeros';

    // ignore: prefer_final_locals
    Object? postBody = invitarCajeroRequest;

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

  /// Invita un cajero por su celular (HU-02-04)
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [InvitarCajeroRequest] invitarCajeroRequest (required):
  Future<InvitacionResponse?> invitarCajero(String xVeciComercio, InvitarCajeroRequest invitarCajeroRequest, { Future<void>? abortTrigger, }) async {
    final response = await invitarCajeroWithHttpInfo(xVeciComercio, invitarCajeroRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'InvitacionResponse',) as InvitacionResponse;
    
    }
    return null;
  }

  /// Celulares de la caja y sus sesiones
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  Future<Response> listarDispositivosWithHttpInfo(String xVeciComercio, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/dispositivos';

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

  /// Celulares de la caja y sus sesiones
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  Future<List<DispositivoResponse>?> listarDispositivos(String xVeciComercio, { Future<void>? abortTrigger, }) async {
    final response = await listarDispositivosWithHttpInfo(xVeciComercio, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<DispositivoResponse>') as List)
        .cast<DispositivoResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Propietarios y cajeros del negocio
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  Future<Response> listarEquipoWithHttpInfo(String xVeciComercio, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/equipo';

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

  /// Propietarios y cajeros del negocio
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  Future<List<MiembroResponse>?> listarEquipo(String xVeciComercio, { Future<void>? abortTrigger, }) async {
    final response = await listarEquipoWithHttpInfo(xVeciComercio, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<MiembroResponse>') as List)
        .cast<MiembroResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// PIN temporal para un cajero (HU-02-05)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [String] membresiaId (required):
  Future<Response> restablecerPinCajeroWithHttpInfo(String xVeciComercio, String membresiaId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/equipo/{membresiaId}/restablecer-pin'
      .replaceAll('{membresiaId}', membresiaId);

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

  /// PIN temporal para un cajero (HU-02-05)
  ///
  /// Parameters:
  ///
  /// * [String] xVeciComercio (required):
  ///   Id del negocio activo
  ///
  /// * [String] membresiaId (required):
  Future<PinTemporalResponse?> restablecerPinCajero(String xVeciComercio, String membresiaId, { Future<void>? abortTrigger, }) async {
    final response = await restablecerPinCajeroWithHttpInfo(xVeciComercio, membresiaId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PinTemporalResponse',) as PinTemporalResponse;
    
    }
    return null;
  }
}
