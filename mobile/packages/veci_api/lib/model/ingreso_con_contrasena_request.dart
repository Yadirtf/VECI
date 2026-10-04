//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class IngresoConContrasenaRequest {
  /// Returns a new [IngresoConContrasenaRequest] instance.
  IngresoConContrasenaRequest({
    required this.contrasena,
    required this.correo,
    required this.dispositivo,
  });

  String contrasena;

  String correo;

  DispositivoRequest dispositivo;

  @override
  bool operator ==(Object other) => identical(this, other) || other is IngresoConContrasenaRequest &&
    other.contrasena == contrasena &&
    other.correo == correo &&
    other.dispositivo == dispositivo;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (contrasena.hashCode) +
    (correo.hashCode) +
    (dispositivo.hashCode);

  @override
  String toString() => 'IngresoConContrasenaRequest[contrasena=$contrasena, correo=$correo, dispositivo=$dispositivo]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'contrasena'] = this.contrasena;
      json[r'correo'] = this.correo;
      json[r'dispositivo'] = this.dispositivo;
    return json;
  }

  /// Returns a new [IngresoConContrasenaRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static IngresoConContrasenaRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'contrasena'), 'Required key "IngresoConContrasenaRequest[contrasena]" is missing from JSON.');
        assert(json[r'contrasena'] != null, 'Required key "IngresoConContrasenaRequest[contrasena]" has a null value in JSON.');
        assert(json.containsKey(r'correo'), 'Required key "IngresoConContrasenaRequest[correo]" is missing from JSON.');
        assert(json[r'correo'] != null, 'Required key "IngresoConContrasenaRequest[correo]" has a null value in JSON.');
        assert(json.containsKey(r'dispositivo'), 'Required key "IngresoConContrasenaRequest[dispositivo]" is missing from JSON.');
        assert(json[r'dispositivo'] != null, 'Required key "IngresoConContrasenaRequest[dispositivo]" has a null value in JSON.');
        return true;
      }());

      return IngresoConContrasenaRequest(
        contrasena: mapValueOfType<String>(json, r'contrasena')!,
        correo: mapValueOfType<String>(json, r'correo')!,
        dispositivo: DispositivoRequest.fromJson(json[r'dispositivo'])!,
      );
    }
    return null;
  }

  static List<IngresoConContrasenaRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <IngresoConContrasenaRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = IngresoConContrasenaRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, IngresoConContrasenaRequest> mapFromJson(dynamic json) {
    final map = <String, IngresoConContrasenaRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = IngresoConContrasenaRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of IngresoConContrasenaRequest-objects as value to a dart map
  static Map<String, List<IngresoConContrasenaRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<IngresoConContrasenaRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = IngresoConContrasenaRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'contrasena',
    'correo',
    'dispositivo',
  };
}

