//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class MiembroResponse {
  /// Returns a new [MiembroResponse] instance.
  MiembroResponse({
    this.celular,
    required this.estado,
    required this.membresiaId,
    required this.nombre,
    this.roles = const [],
    required this.usuarioId,
  });

  String? celular;

  MiembroResponseEstadoEnum estado;

  String membresiaId;

  String nombre;

  List<String> roles;

  String usuarioId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MiembroResponse &&
    other.celular == celular &&
    other.estado == estado &&
    other.membresiaId == membresiaId &&
    other.nombre == nombre &&
    _deepEquality.equals(other.roles, roles) &&
    other.usuarioId == usuarioId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (celular == null ? 0 : celular!.hashCode) +
    (estado.hashCode) +
    (membresiaId.hashCode) +
    (nombre.hashCode) +
    (roles.hashCode) +
    (usuarioId.hashCode);

  @override
  String toString() => 'MiembroResponse[celular=$celular, estado=$estado, membresiaId=$membresiaId, nombre=$nombre, roles=$roles, usuarioId=$usuarioId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.celular != null) {
      json[r'celular'] = this.celular;
    } else {
      json[r'celular'] = null;
    }
      json[r'estado'] = this.estado;
      json[r'membresiaId'] = this.membresiaId;
      json[r'nombre'] = this.nombre;
      json[r'roles'] = this.roles;
      json[r'usuarioId'] = this.usuarioId;
    return json;
  }

  /// Returns a new [MiembroResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MiembroResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'estado'), 'Required key "MiembroResponse[estado]" is missing from JSON.');
        assert(json[r'estado'] != null, 'Required key "MiembroResponse[estado]" has a null value in JSON.');
        assert(json.containsKey(r'membresiaId'), 'Required key "MiembroResponse[membresiaId]" is missing from JSON.');
        assert(json[r'membresiaId'] != null, 'Required key "MiembroResponse[membresiaId]" has a null value in JSON.');
        assert(json.containsKey(r'nombre'), 'Required key "MiembroResponse[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "MiembroResponse[nombre]" has a null value in JSON.');
        assert(json.containsKey(r'roles'), 'Required key "MiembroResponse[roles]" is missing from JSON.');
        assert(json[r'roles'] != null, 'Required key "MiembroResponse[roles]" has a null value in JSON.');
        assert(json.containsKey(r'usuarioId'), 'Required key "MiembroResponse[usuarioId]" is missing from JSON.');
        assert(json[r'usuarioId'] != null, 'Required key "MiembroResponse[usuarioId]" has a null value in JSON.');
        return true;
      }());

      return MiembroResponse(
        celular: mapValueOfType<String>(json, r'celular'),
        estado: MiembroResponseEstadoEnum.fromJson(json[r'estado'])!,
        membresiaId: mapValueOfType<String>(json, r'membresiaId')!,
        nombre: mapValueOfType<String>(json, r'nombre')!,
        roles: json[r'roles'] is Iterable
            ? (json[r'roles'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        usuarioId: mapValueOfType<String>(json, r'usuarioId')!,
      );
    }
    return null;
  }

  static List<MiembroResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MiembroResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MiembroResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MiembroResponse> mapFromJson(dynamic json) {
    final map = <String, MiembroResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MiembroResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MiembroResponse-objects as value to a dart map
  static Map<String, List<MiembroResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MiembroResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MiembroResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'estado',
    'membresiaId',
    'nombre',
    'roles',
    'usuarioId',
  };
}


enum MiembroResponseEstadoEnum {
  INVITED._(r'INVITED'),
  ACTIVE._(r'ACTIVE'),
  SUSPENDED._(r'SUSPENDED'),
  REMOVED._(r'REMOVED'),
  ;

  /// Instantiate a new enum with the provided value.
  const MiembroResponseEstadoEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [MiembroResponseEstadoEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static MiembroResponseEstadoEnum? fromJson(dynamic value) => MiembroResponseEstadoEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [MiembroResponseEstadoEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<MiembroResponseEstadoEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MiembroResponseEstadoEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MiembroResponseEstadoEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MiembroResponseEstadoEnum] to String,
/// and [decode] dynamic data back to [MiembroResponseEstadoEnum].
class MiembroResponseEstadoEnumTypeTransformer {
  factory MiembroResponseEstadoEnumTypeTransformer() => _instance ??= const MiembroResponseEstadoEnumTypeTransformer._();

  const MiembroResponseEstadoEnumTypeTransformer._();

  String encode(MiembroResponseEstadoEnum data) => data._value;

  /// Returns the instance of [MiembroResponseEstadoEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MiembroResponseEstadoEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is MiembroResponseEstadoEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'INVITED': return MiembroResponseEstadoEnum.INVITED;
        case r'ACTIVE': return MiembroResponseEstadoEnum.ACTIVE;
        case r'SUSPENDED': return MiembroResponseEstadoEnum.SUSPENDED;
        case r'REMOVED': return MiembroResponseEstadoEnum.REMOVED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static MiembroResponseEstadoEnumTypeTransformer? _instance;
}


