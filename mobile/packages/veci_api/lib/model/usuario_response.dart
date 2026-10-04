//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class UsuarioResponse {
  /// Returns a new [UsuarioResponse] instance.
  UsuarioResponse({
    required this.id,
    required this.nombre,
  });

  String id;

  String nombre;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UsuarioResponse &&
    other.id == id &&
    other.nombre == nombre;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (nombre.hashCode);

  @override
  String toString() => 'UsuarioResponse[id=$id, nombre=$nombre]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'nombre'] = this.nombre;
    return json;
  }

  /// Returns a new [UsuarioResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UsuarioResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "UsuarioResponse[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "UsuarioResponse[id]" has a null value in JSON.');
        assert(json.containsKey(r'nombre'), 'Required key "UsuarioResponse[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "UsuarioResponse[nombre]" has a null value in JSON.');
        return true;
      }());

      return UsuarioResponse(
        id: mapValueOfType<String>(json, r'id')!,
        nombre: mapValueOfType<String>(json, r'nombre')!,
      );
    }
    return null;
  }

  static List<UsuarioResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UsuarioResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UsuarioResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UsuarioResponse> mapFromJson(dynamic json) {
    final map = <String, UsuarioResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UsuarioResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UsuarioResponse-objects as value to a dart map
  static Map<String, List<UsuarioResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UsuarioResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UsuarioResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'nombre',
  };
}

