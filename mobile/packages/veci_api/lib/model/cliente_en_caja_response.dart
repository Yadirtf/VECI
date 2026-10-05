//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class ClienteEnCajaResponse {
  /// Returns a new [ClienteEnCajaResponse] instance.
  ClienteEnCajaResponse({
    this.celular,
    this.celularFinal,
    required this.clienteId,
    required this.cuenta,
    required this.documento,
    required this.documentoFinal,
    required this.estado,
    required this.nombre,
    required this.nombreBusqueda,
  });

  String? celular;

  String? celularFinal;

  String clienteId;

  ClienteEnCajaResponseCuentaEnum cuenta;

  String documento;

  /// Últimos 4 dígitos, para buscar sin internet
  String documentoFinal;

  ClienteEnCajaResponseEstadoEnum estado;

  String nombre;

  /// Sin tildes ni mayúsculas
  String nombreBusqueda;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ClienteEnCajaResponse &&
    other.celular == celular &&
    other.celularFinal == celularFinal &&
    other.clienteId == clienteId &&
    other.cuenta == cuenta &&
    other.documento == documento &&
    other.documentoFinal == documentoFinal &&
    other.estado == estado &&
    other.nombre == nombre &&
    other.nombreBusqueda == nombreBusqueda;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (celular == null ? 0 : celular!.hashCode) +
    (celularFinal == null ? 0 : celularFinal!.hashCode) +
    (clienteId.hashCode) +
    (cuenta.hashCode) +
    (documento.hashCode) +
    (documentoFinal.hashCode) +
    (estado.hashCode) +
    (nombre.hashCode) +
    (nombreBusqueda.hashCode);

  @override
  String toString() => 'ClienteEnCajaResponse[celular=$celular, celularFinal=$celularFinal, clienteId=$clienteId, cuenta=$cuenta, documento=$documento, documentoFinal=$documentoFinal, estado=$estado, nombre=$nombre, nombreBusqueda=$nombreBusqueda]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.celular != null) {
      json[r'celular'] = this.celular;
    } else {
      json[r'celular'] = null;
    }
    if (this.celularFinal != null) {
      json[r'celularFinal'] = this.celularFinal;
    } else {
      json[r'celularFinal'] = null;
    }
      json[r'clienteId'] = this.clienteId;
      json[r'cuenta'] = this.cuenta;
      json[r'documento'] = this.documento;
      json[r'documentoFinal'] = this.documentoFinal;
      json[r'estado'] = this.estado;
      json[r'nombre'] = this.nombre;
      json[r'nombreBusqueda'] = this.nombreBusqueda;
    return json;
  }

  /// Returns a new [ClienteEnCajaResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ClienteEnCajaResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'clienteId'), 'Required key "ClienteEnCajaResponse[clienteId]" is missing from JSON.');
        assert(json[r'clienteId'] != null, 'Required key "ClienteEnCajaResponse[clienteId]" has a null value in JSON.');
        assert(json.containsKey(r'cuenta'), 'Required key "ClienteEnCajaResponse[cuenta]" is missing from JSON.');
        assert(json[r'cuenta'] != null, 'Required key "ClienteEnCajaResponse[cuenta]" has a null value in JSON.');
        assert(json.containsKey(r'documento'), 'Required key "ClienteEnCajaResponse[documento]" is missing from JSON.');
        assert(json[r'documento'] != null, 'Required key "ClienteEnCajaResponse[documento]" has a null value in JSON.');
        assert(json.containsKey(r'documentoFinal'), 'Required key "ClienteEnCajaResponse[documentoFinal]" is missing from JSON.');
        assert(json[r'documentoFinal'] != null, 'Required key "ClienteEnCajaResponse[documentoFinal]" has a null value in JSON.');
        assert(json.containsKey(r'estado'), 'Required key "ClienteEnCajaResponse[estado]" is missing from JSON.');
        assert(json[r'estado'] != null, 'Required key "ClienteEnCajaResponse[estado]" has a null value in JSON.');
        assert(json.containsKey(r'nombre'), 'Required key "ClienteEnCajaResponse[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "ClienteEnCajaResponse[nombre]" has a null value in JSON.');
        assert(json.containsKey(r'nombreBusqueda'), 'Required key "ClienteEnCajaResponse[nombreBusqueda]" is missing from JSON.');
        assert(json[r'nombreBusqueda'] != null, 'Required key "ClienteEnCajaResponse[nombreBusqueda]" has a null value in JSON.');
        return true;
      }());

      return ClienteEnCajaResponse(
        celular: mapValueOfType<String>(json, r'celular'),
        celularFinal: mapValueOfType<String>(json, r'celularFinal'),
        clienteId: mapValueOfType<String>(json, r'clienteId')!,
        cuenta: ClienteEnCajaResponseCuentaEnum.fromJson(json[r'cuenta'])!,
        documento: mapValueOfType<String>(json, r'documento')!,
        documentoFinal: mapValueOfType<String>(json, r'documentoFinal')!,
        estado: ClienteEnCajaResponseEstadoEnum.fromJson(json[r'estado'])!,
        nombre: mapValueOfType<String>(json, r'nombre')!,
        nombreBusqueda: mapValueOfType<String>(json, r'nombreBusqueda')!,
      );
    }
    return null;
  }

  static List<ClienteEnCajaResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ClienteEnCajaResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ClienteEnCajaResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ClienteEnCajaResponse> mapFromJson(dynamic json) {
    final map = <String, ClienteEnCajaResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ClienteEnCajaResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ClienteEnCajaResponse-objects as value to a dart map
  static Map<String, List<ClienteEnCajaResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ClienteEnCajaResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ClienteEnCajaResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'clienteId',
    'cuenta',
    'documento',
    'documentoFinal',
    'estado',
    'nombre',
    'nombreBusqueda',
  };
}


enum ClienteEnCajaResponseCuentaEnum {
  ACTIVA._(r'ACTIVA'),
  PENDIENTE._(r'PENDIENTE'),
  SIN_CUENTA._(r'SIN_CUENTA'),
  ;

  /// Instantiate a new enum with the provided value.
  const ClienteEnCajaResponseCuentaEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [ClienteEnCajaResponseCuentaEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static ClienteEnCajaResponseCuentaEnum? fromJson(dynamic value) => ClienteEnCajaResponseCuentaEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [ClienteEnCajaResponseCuentaEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<ClienteEnCajaResponseCuentaEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ClienteEnCajaResponseCuentaEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ClienteEnCajaResponseCuentaEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ClienteEnCajaResponseCuentaEnum] to String,
/// and [decode] dynamic data back to [ClienteEnCajaResponseCuentaEnum].
class ClienteEnCajaResponseCuentaEnumTypeTransformer {
  factory ClienteEnCajaResponseCuentaEnumTypeTransformer() => _instance ??= const ClienteEnCajaResponseCuentaEnumTypeTransformer._();

  const ClienteEnCajaResponseCuentaEnumTypeTransformer._();

  String encode(ClienteEnCajaResponseCuentaEnum data) => data._value;

  /// Returns the instance of [ClienteEnCajaResponseCuentaEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ClienteEnCajaResponseCuentaEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is ClienteEnCajaResponseCuentaEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'ACTIVA': return ClienteEnCajaResponseCuentaEnum.ACTIVA;
        case r'PENDIENTE': return ClienteEnCajaResponseCuentaEnum.PENDIENTE;
        case r'SIN_CUENTA': return ClienteEnCajaResponseCuentaEnum.SIN_CUENTA;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static ClienteEnCajaResponseCuentaEnumTypeTransformer? _instance;
}



enum ClienteEnCajaResponseEstadoEnum {
  ACTIVE._(r'ACTIVE'),
  BLOCKED._(r'BLOCKED'),
  ENDED._(r'ENDED'),
  ;

  /// Instantiate a new enum with the provided value.
  const ClienteEnCajaResponseEstadoEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [ClienteEnCajaResponseEstadoEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static ClienteEnCajaResponseEstadoEnum? fromJson(dynamic value) => ClienteEnCajaResponseEstadoEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [ClienteEnCajaResponseEstadoEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<ClienteEnCajaResponseEstadoEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ClienteEnCajaResponseEstadoEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ClienteEnCajaResponseEstadoEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ClienteEnCajaResponseEstadoEnum] to String,
/// and [decode] dynamic data back to [ClienteEnCajaResponseEstadoEnum].
class ClienteEnCajaResponseEstadoEnumTypeTransformer {
  factory ClienteEnCajaResponseEstadoEnumTypeTransformer() => _instance ??= const ClienteEnCajaResponseEstadoEnumTypeTransformer._();

  const ClienteEnCajaResponseEstadoEnumTypeTransformer._();

  String encode(ClienteEnCajaResponseEstadoEnum data) => data._value;

  /// Returns the instance of [ClienteEnCajaResponseEstadoEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ClienteEnCajaResponseEstadoEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is ClienteEnCajaResponseEstadoEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'ACTIVE': return ClienteEnCajaResponseEstadoEnum.ACTIVE;
        case r'BLOCKED': return ClienteEnCajaResponseEstadoEnum.BLOCKED;
        case r'ENDED': return ClienteEnCajaResponseEstadoEnum.ENDED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static ClienteEnCajaResponseEstadoEnumTypeTransformer? _instance;
}


