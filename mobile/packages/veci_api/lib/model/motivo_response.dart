//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class MotivoResponse {
  /// Returns a new [MotivoResponse] instance.
  MotivoResponse({
    required this.codigo,
    required this.nombre,
  });

  String codigo;

  String nombre;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MotivoResponse &&
    other.codigo == codigo &&
    other.nombre == nombre;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (codigo.hashCode) +
    (nombre.hashCode);

  @override
  String toString() => 'MotivoResponse[codigo=$codigo, nombre=$nombre]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'codigo'] = this.codigo;
      json[r'nombre'] = this.nombre;
    return json;
  }

  /// Returns a new [MotivoResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MotivoResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'codigo'), 'Required key "MotivoResponse[codigo]" is missing from JSON.');
        assert(json[r'codigo'] != null, 'Required key "MotivoResponse[codigo]" has a null value in JSON.');
        assert(json.containsKey(r'nombre'), 'Required key "MotivoResponse[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "MotivoResponse[nombre]" has a null value in JSON.');
        return true;
      }());

      return MotivoResponse(
        codigo: mapValueOfType<String>(json, r'codigo')!,
        nombre: mapValueOfType<String>(json, r'nombre')!,
      );
    }
    return null;
  }

  static List<MotivoResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MotivoResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MotivoResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MotivoResponse> mapFromJson(dynamic json) {
    final map = <String, MotivoResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MotivoResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MotivoResponse-objects as value to a dart map
  static Map<String, List<MotivoResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MotivoResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MotivoResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'codigo',
    'nombre',
  };
}

