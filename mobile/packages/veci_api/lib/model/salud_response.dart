//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class SaludResponse {
  /// Returns a new [SaludResponse] instance.
  SaludResponse({
    required this.baseDatos,
    required this.estado,
    required this.version,
  });

  SaludResponseBaseDatosEnum baseDatos;

  SaludResponseEstadoEnum estado;

  String version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SaludResponse &&
    other.baseDatos == baseDatos &&
    other.estado == estado &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (baseDatos.hashCode) +
    (estado.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'SaludResponse[baseDatos=$baseDatos, estado=$estado, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'baseDatos'] = this.baseDatos;
      json[r'estado'] = this.estado;
      json[r'version'] = this.version;
    return json;
  }

  /// Returns a new [SaludResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SaludResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'baseDatos'), 'Required key "SaludResponse[baseDatos]" is missing from JSON.');
        assert(json[r'baseDatos'] != null, 'Required key "SaludResponse[baseDatos]" has a null value in JSON.');
        assert(json.containsKey(r'estado'), 'Required key "SaludResponse[estado]" is missing from JSON.');
        assert(json[r'estado'] != null, 'Required key "SaludResponse[estado]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "SaludResponse[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "SaludResponse[version]" has a null value in JSON.');
        return true;
      }());

      return SaludResponse(
        baseDatos: SaludResponseBaseDatosEnum.fromJson(json[r'baseDatos'])!,
        estado: SaludResponseEstadoEnum.fromJson(json[r'estado'])!,
        version: mapValueOfType<String>(json, r'version')!,
      );
    }
    return null;
  }

  static List<SaludResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SaludResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SaludResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SaludResponse> mapFromJson(dynamic json) {
    final map = <String, SaludResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SaludResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SaludResponse-objects as value to a dart map
  static Map<String, List<SaludResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SaludResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SaludResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'baseDatos',
    'estado',
    'version',
  };
}


enum SaludResponseBaseDatosEnum {
  ok._(r'ok'),
  sinConexion._(r'sin-conexion'),
  ;

  /// Instantiate a new enum with the provided value.
  const SaludResponseBaseDatosEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [SaludResponseBaseDatosEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static SaludResponseBaseDatosEnum? fromJson(dynamic value) => SaludResponseBaseDatosEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [SaludResponseBaseDatosEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<SaludResponseBaseDatosEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SaludResponseBaseDatosEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SaludResponseBaseDatosEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SaludResponseBaseDatosEnum] to String,
/// and [decode] dynamic data back to [SaludResponseBaseDatosEnum].
class SaludResponseBaseDatosEnumTypeTransformer {
  factory SaludResponseBaseDatosEnumTypeTransformer() => _instance ??= const SaludResponseBaseDatosEnumTypeTransformer._();

  const SaludResponseBaseDatosEnumTypeTransformer._();

  String encode(SaludResponseBaseDatosEnum data) => data._value;

  /// Returns the instance of [SaludResponseBaseDatosEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SaludResponseBaseDatosEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is SaludResponseBaseDatosEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'ok': return SaludResponseBaseDatosEnum.ok;
        case r'sin-conexion': return SaludResponseBaseDatosEnum.sinConexion;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static SaludResponseBaseDatosEnumTypeTransformer? _instance;
}



enum SaludResponseEstadoEnum {
  ok._(r'ok'),
  degradado._(r'degradado'),
  ;

  /// Instantiate a new enum with the provided value.
  const SaludResponseEstadoEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [SaludResponseEstadoEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static SaludResponseEstadoEnum? fromJson(dynamic value) => SaludResponseEstadoEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [SaludResponseEstadoEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<SaludResponseEstadoEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SaludResponseEstadoEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SaludResponseEstadoEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SaludResponseEstadoEnum] to String,
/// and [decode] dynamic data back to [SaludResponseEstadoEnum].
class SaludResponseEstadoEnumTypeTransformer {
  factory SaludResponseEstadoEnumTypeTransformer() => _instance ??= const SaludResponseEstadoEnumTypeTransformer._();

  const SaludResponseEstadoEnumTypeTransformer._();

  String encode(SaludResponseEstadoEnum data) => data._value;

  /// Returns the instance of [SaludResponseEstadoEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SaludResponseEstadoEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is SaludResponseEstadoEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'ok': return SaludResponseEstadoEnum.ok;
        case r'degradado': return SaludResponseEstadoEnum.degradado;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static SaludResponseEstadoEnumTypeTransformer? _instance;
}


