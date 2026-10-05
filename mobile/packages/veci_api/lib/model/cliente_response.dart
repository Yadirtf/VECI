//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class ClienteResponse {
  /// Returns a new [ClienteResponse] instance.
  ClienteResponse({
    required this.afiliadoEn,
    this.apellidos,
    required this.canal,
    this.celular,
    required this.clienteId,
    required this.cuenta,
    required this.datosCompletos,
    required this.documento,
    required this.estado,
    required this.nombre,
    required this.nombres,
    required this.personaId,
    required this.tipoDocumento,
  });

  DateTime afiliadoEn;

  String? apellidos;

  ClienteResponseCanalEnum canal;

  String? celular;

  /// Id de la afiliación: el cliente en este negocio
  String clienteId;

  /// ACTIVA: usa la app. PENDIENTE: espera su PIN.
  ClienteResponseCuentaEnum cuenta;

  /// Se ven el documento y el celular completos
  bool datosCompletos;

  /// Completo solo con customers.view_full_document
  String documento;

  ClienteResponseEstadoEnum estado;

  String nombre;

  String nombres;

  String personaId;

  String tipoDocumento;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ClienteResponse &&
    other.afiliadoEn == afiliadoEn &&
    other.apellidos == apellidos &&
    other.canal == canal &&
    other.celular == celular &&
    other.clienteId == clienteId &&
    other.cuenta == cuenta &&
    other.datosCompletos == datosCompletos &&
    other.documento == documento &&
    other.estado == estado &&
    other.nombre == nombre &&
    other.nombres == nombres &&
    other.personaId == personaId &&
    other.tipoDocumento == tipoDocumento;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (afiliadoEn.hashCode) +
    (apellidos == null ? 0 : apellidos!.hashCode) +
    (canal.hashCode) +
    (celular == null ? 0 : celular!.hashCode) +
    (clienteId.hashCode) +
    (cuenta.hashCode) +
    (datosCompletos.hashCode) +
    (documento.hashCode) +
    (estado.hashCode) +
    (nombre.hashCode) +
    (nombres.hashCode) +
    (personaId.hashCode) +
    (tipoDocumento.hashCode);

  @override
  String toString() => 'ClienteResponse[afiliadoEn=$afiliadoEn, apellidos=$apellidos, canal=$canal, celular=$celular, clienteId=$clienteId, cuenta=$cuenta, datosCompletos=$datosCompletos, documento=$documento, estado=$estado, nombre=$nombre, nombres=$nombres, personaId=$personaId, tipoDocumento=$tipoDocumento]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'afiliadoEn'] = this.afiliadoEn.toUtc().toIso8601String();
    if (this.apellidos != null) {
      json[r'apellidos'] = this.apellidos;
    } else {
      json[r'apellidos'] = null;
    }
      json[r'canal'] = this.canal;
    if (this.celular != null) {
      json[r'celular'] = this.celular;
    } else {
      json[r'celular'] = null;
    }
      json[r'clienteId'] = this.clienteId;
      json[r'cuenta'] = this.cuenta;
      json[r'datosCompletos'] = this.datosCompletos;
      json[r'documento'] = this.documento;
      json[r'estado'] = this.estado;
      json[r'nombre'] = this.nombre;
      json[r'nombres'] = this.nombres;
      json[r'personaId'] = this.personaId;
      json[r'tipoDocumento'] = this.tipoDocumento;
    return json;
  }

  /// Returns a new [ClienteResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ClienteResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'afiliadoEn'), 'Required key "ClienteResponse[afiliadoEn]" is missing from JSON.');
        assert(json[r'afiliadoEn'] != null, 'Required key "ClienteResponse[afiliadoEn]" has a null value in JSON.');
        assert(json.containsKey(r'canal'), 'Required key "ClienteResponse[canal]" is missing from JSON.');
        assert(json[r'canal'] != null, 'Required key "ClienteResponse[canal]" has a null value in JSON.');
        assert(json.containsKey(r'clienteId'), 'Required key "ClienteResponse[clienteId]" is missing from JSON.');
        assert(json[r'clienteId'] != null, 'Required key "ClienteResponse[clienteId]" has a null value in JSON.');
        assert(json.containsKey(r'cuenta'), 'Required key "ClienteResponse[cuenta]" is missing from JSON.');
        assert(json[r'cuenta'] != null, 'Required key "ClienteResponse[cuenta]" has a null value in JSON.');
        assert(json.containsKey(r'datosCompletos'), 'Required key "ClienteResponse[datosCompletos]" is missing from JSON.');
        assert(json[r'datosCompletos'] != null, 'Required key "ClienteResponse[datosCompletos]" has a null value in JSON.');
        assert(json.containsKey(r'documento'), 'Required key "ClienteResponse[documento]" is missing from JSON.');
        assert(json[r'documento'] != null, 'Required key "ClienteResponse[documento]" has a null value in JSON.');
        assert(json.containsKey(r'estado'), 'Required key "ClienteResponse[estado]" is missing from JSON.');
        assert(json[r'estado'] != null, 'Required key "ClienteResponse[estado]" has a null value in JSON.');
        assert(json.containsKey(r'nombre'), 'Required key "ClienteResponse[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "ClienteResponse[nombre]" has a null value in JSON.');
        assert(json.containsKey(r'nombres'), 'Required key "ClienteResponse[nombres]" is missing from JSON.');
        assert(json[r'nombres'] != null, 'Required key "ClienteResponse[nombres]" has a null value in JSON.');
        assert(json.containsKey(r'personaId'), 'Required key "ClienteResponse[personaId]" is missing from JSON.');
        assert(json[r'personaId'] != null, 'Required key "ClienteResponse[personaId]" has a null value in JSON.');
        assert(json.containsKey(r'tipoDocumento'), 'Required key "ClienteResponse[tipoDocumento]" is missing from JSON.');
        assert(json[r'tipoDocumento'] != null, 'Required key "ClienteResponse[tipoDocumento]" has a null value in JSON.');
        return true;
      }());

      return ClienteResponse(
        afiliadoEn: mapDateTime(json, r'afiliadoEn', r'')!,
        apellidos: mapValueOfType<String>(json, r'apellidos'),
        canal: ClienteResponseCanalEnum.fromJson(json[r'canal'])!,
        celular: mapValueOfType<String>(json, r'celular'),
        clienteId: mapValueOfType<String>(json, r'clienteId')!,
        cuenta: ClienteResponseCuentaEnum.fromJson(json[r'cuenta'])!,
        datosCompletos: mapValueOfType<bool>(json, r'datosCompletos')!,
        documento: mapValueOfType<String>(json, r'documento')!,
        estado: ClienteResponseEstadoEnum.fromJson(json[r'estado'])!,
        nombre: mapValueOfType<String>(json, r'nombre')!,
        nombres: mapValueOfType<String>(json, r'nombres')!,
        personaId: mapValueOfType<String>(json, r'personaId')!,
        tipoDocumento: mapValueOfType<String>(json, r'tipoDocumento')!,
      );
    }
    return null;
  }

  static List<ClienteResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ClienteResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ClienteResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ClienteResponse> mapFromJson(dynamic json) {
    final map = <String, ClienteResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ClienteResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ClienteResponse-objects as value to a dart map
  static Map<String, List<ClienteResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ClienteResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ClienteResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'afiliadoEn',
    'canal',
    'clienteId',
    'cuenta',
    'datosCompletos',
    'documento',
    'estado',
    'nombre',
    'nombres',
    'personaId',
    'tipoDocumento',
  };
}


enum ClienteResponseCanalEnum {
  PERSONAL_QR_SCAN._(r'PERSONAL_QR_SCAN'),
  ASSISTED_REGISTRATION._(r'ASSISTED_REGISTRATION'),
  DATA_IMPORT._(r'DATA_IMPORT'),
  ;

  /// Instantiate a new enum with the provided value.
  const ClienteResponseCanalEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [ClienteResponseCanalEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static ClienteResponseCanalEnum? fromJson(dynamic value) => ClienteResponseCanalEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [ClienteResponseCanalEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<ClienteResponseCanalEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ClienteResponseCanalEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ClienteResponseCanalEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ClienteResponseCanalEnum] to String,
/// and [decode] dynamic data back to [ClienteResponseCanalEnum].
class ClienteResponseCanalEnumTypeTransformer {
  factory ClienteResponseCanalEnumTypeTransformer() => _instance ??= const ClienteResponseCanalEnumTypeTransformer._();

  const ClienteResponseCanalEnumTypeTransformer._();

  String encode(ClienteResponseCanalEnum data) => data._value;

  /// Returns the instance of [ClienteResponseCanalEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ClienteResponseCanalEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is ClienteResponseCanalEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'PERSONAL_QR_SCAN': return ClienteResponseCanalEnum.PERSONAL_QR_SCAN;
        case r'ASSISTED_REGISTRATION': return ClienteResponseCanalEnum.ASSISTED_REGISTRATION;
        case r'DATA_IMPORT': return ClienteResponseCanalEnum.DATA_IMPORT;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static ClienteResponseCanalEnumTypeTransformer? _instance;
}


/// ACTIVA: usa la app. PENDIENTE: espera su PIN.
enum ClienteResponseCuentaEnum {
  ACTIVA._(r'ACTIVA'),
  PENDIENTE._(r'PENDIENTE'),
  SIN_CUENTA._(r'SIN_CUENTA'),
  ;

  /// Instantiate a new enum with the provided value.
  const ClienteResponseCuentaEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [ClienteResponseCuentaEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static ClienteResponseCuentaEnum? fromJson(dynamic value) => ClienteResponseCuentaEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [ClienteResponseCuentaEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<ClienteResponseCuentaEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ClienteResponseCuentaEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ClienteResponseCuentaEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ClienteResponseCuentaEnum] to String,
/// and [decode] dynamic data back to [ClienteResponseCuentaEnum].
class ClienteResponseCuentaEnumTypeTransformer {
  factory ClienteResponseCuentaEnumTypeTransformer() => _instance ??= const ClienteResponseCuentaEnumTypeTransformer._();

  const ClienteResponseCuentaEnumTypeTransformer._();

  String encode(ClienteResponseCuentaEnum data) => data._value;

  /// Returns the instance of [ClienteResponseCuentaEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ClienteResponseCuentaEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is ClienteResponseCuentaEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'ACTIVA': return ClienteResponseCuentaEnum.ACTIVA;
        case r'PENDIENTE': return ClienteResponseCuentaEnum.PENDIENTE;
        case r'SIN_CUENTA': return ClienteResponseCuentaEnum.SIN_CUENTA;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static ClienteResponseCuentaEnumTypeTransformer? _instance;
}



enum ClienteResponseEstadoEnum {
  ACTIVE._(r'ACTIVE'),
  BLOCKED._(r'BLOCKED'),
  ENDED._(r'ENDED'),
  ;

  /// Instantiate a new enum with the provided value.
  const ClienteResponseEstadoEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [ClienteResponseEstadoEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static ClienteResponseEstadoEnum? fromJson(dynamic value) => ClienteResponseEstadoEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [ClienteResponseEstadoEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<ClienteResponseEstadoEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ClienteResponseEstadoEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ClienteResponseEstadoEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ClienteResponseEstadoEnum] to String,
/// and [decode] dynamic data back to [ClienteResponseEstadoEnum].
class ClienteResponseEstadoEnumTypeTransformer {
  factory ClienteResponseEstadoEnumTypeTransformer() => _instance ??= const ClienteResponseEstadoEnumTypeTransformer._();

  const ClienteResponseEstadoEnumTypeTransformer._();

  String encode(ClienteResponseEstadoEnum data) => data._value;

  /// Returns the instance of [ClienteResponseEstadoEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ClienteResponseEstadoEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is ClienteResponseEstadoEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'ACTIVE': return ClienteResponseEstadoEnum.ACTIVE;
        case r'BLOCKED': return ClienteResponseEstadoEnum.BLOCKED;
        case r'ENDED': return ClienteResponseEstadoEnum.ENDED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static ClienteResponseEstadoEnumTypeTransformer? _instance;
}


