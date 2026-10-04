//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class IngresoResponse {
  /// Returns a new [IngresoResponse] instance.
  IngresoResponse({
    required this.nombre,
    required this.requiereCambioDePin,
    this.sesion,
    this.tokenCambio,
  });

  String nombre;

  /// Entró con un PIN temporal: debe crear el suyo antes de seguir
  bool requiereCambioDePin;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  SesionResponse? sesion;

  /// Solo si requiereCambioDePin. Dura 10 minutos.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? tokenCambio;

  @override
  bool operator ==(Object other) => identical(this, other) || other is IngresoResponse &&
    other.nombre == nombre &&
    other.requiereCambioDePin == requiereCambioDePin &&
    other.sesion == sesion &&
    other.tokenCambio == tokenCambio;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (nombre.hashCode) +
    (requiereCambioDePin.hashCode) +
    (sesion == null ? 0 : sesion!.hashCode) +
    (tokenCambio == null ? 0 : tokenCambio!.hashCode);

  @override
  String toString() => 'IngresoResponse[nombre=$nombre, requiereCambioDePin=$requiereCambioDePin, sesion=$sesion, tokenCambio=$tokenCambio]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'nombre'] = this.nombre;
      json[r'requiereCambioDePin'] = this.requiereCambioDePin;
    if (this.sesion != null) {
      json[r'sesion'] = this.sesion;
    } else {
      json[r'sesion'] = null;
    }
    if (this.tokenCambio != null) {
      json[r'tokenCambio'] = this.tokenCambio;
    } else {
      json[r'tokenCambio'] = null;
    }
    return json;
  }

  /// Returns a new [IngresoResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static IngresoResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'nombre'), 'Required key "IngresoResponse[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "IngresoResponse[nombre]" has a null value in JSON.');
        assert(json.containsKey(r'requiereCambioDePin'), 'Required key "IngresoResponse[requiereCambioDePin]" is missing from JSON.');
        assert(json[r'requiereCambioDePin'] != null, 'Required key "IngresoResponse[requiereCambioDePin]" has a null value in JSON.');
        return true;
      }());

      return IngresoResponse(
        nombre: mapValueOfType<String>(json, r'nombre')!,
        requiereCambioDePin: mapValueOfType<bool>(json, r'requiereCambioDePin')!,
        sesion: SesionResponse.fromJson(json[r'sesion']),
        tokenCambio: mapValueOfType<String>(json, r'tokenCambio'),
      );
    }
    return null;
  }

  static List<IngresoResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <IngresoResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = IngresoResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, IngresoResponse> mapFromJson(dynamic json) {
    final map = <String, IngresoResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = IngresoResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of IngresoResponse-objects as value to a dart map
  static Map<String, List<IngresoResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<IngresoResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = IngresoResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'nombre',
    'requiereCambioDePin',
  };
}

