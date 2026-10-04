//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class CorreoYContrasenaRequest {
  /// Returns a new [CorreoYContrasenaRequest] instance.
  CorreoYContrasenaRequest({
    required this.contrasena,
    required this.correo,
    required this.pinActual,
  });

  String contrasena;

  String correo;

  /// PIN actual, para confirmar que eres tú
  String pinActual;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CorreoYContrasenaRequest &&
    other.contrasena == contrasena &&
    other.correo == correo &&
    other.pinActual == pinActual;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (contrasena.hashCode) +
    (correo.hashCode) +
    (pinActual.hashCode);

  @override
  String toString() => 'CorreoYContrasenaRequest[contrasena=$contrasena, correo=$correo, pinActual=$pinActual]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'contrasena'] = this.contrasena;
      json[r'correo'] = this.correo;
      json[r'pinActual'] = this.pinActual;
    return json;
  }

  /// Returns a new [CorreoYContrasenaRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CorreoYContrasenaRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'contrasena'), 'Required key "CorreoYContrasenaRequest[contrasena]" is missing from JSON.');
        assert(json[r'contrasena'] != null, 'Required key "CorreoYContrasenaRequest[contrasena]" has a null value in JSON.');
        assert(json.containsKey(r'correo'), 'Required key "CorreoYContrasenaRequest[correo]" is missing from JSON.');
        assert(json[r'correo'] != null, 'Required key "CorreoYContrasenaRequest[correo]" has a null value in JSON.');
        assert(json.containsKey(r'pinActual'), 'Required key "CorreoYContrasenaRequest[pinActual]" is missing from JSON.');
        assert(json[r'pinActual'] != null, 'Required key "CorreoYContrasenaRequest[pinActual]" has a null value in JSON.');
        return true;
      }());

      return CorreoYContrasenaRequest(
        contrasena: mapValueOfType<String>(json, r'contrasena')!,
        correo: mapValueOfType<String>(json, r'correo')!,
        pinActual: mapValueOfType<String>(json, r'pinActual')!,
      );
    }
    return null;
  }

  static List<CorreoYContrasenaRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CorreoYContrasenaRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CorreoYContrasenaRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CorreoYContrasenaRequest> mapFromJson(dynamic json) {
    final map = <String, CorreoYContrasenaRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CorreoYContrasenaRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CorreoYContrasenaRequest-objects as value to a dart map
  static Map<String, List<CorreoYContrasenaRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CorreoYContrasenaRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CorreoYContrasenaRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'contrasena',
    'correo',
    'pinActual',
  };
}

