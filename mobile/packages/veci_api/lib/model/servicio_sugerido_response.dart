//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class ServicioSugeridoResponse {
  /// Returns a new [ServicioSugeridoResponse] instance.
  ServicioSugeridoResponse({
    required this.horaFin,
    required this.horaInicio,
    required this.nombre,
  });

  String horaFin;

  String horaInicio;

  String nombre;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ServicioSugeridoResponse &&
    other.horaFin == horaFin &&
    other.horaInicio == horaInicio &&
    other.nombre == nombre;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (horaFin.hashCode) +
    (horaInicio.hashCode) +
    (nombre.hashCode);

  @override
  String toString() => 'ServicioSugeridoResponse[horaFin=$horaFin, horaInicio=$horaInicio, nombre=$nombre]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'horaFin'] = this.horaFin;
      json[r'horaInicio'] = this.horaInicio;
      json[r'nombre'] = this.nombre;
    return json;
  }

  /// Returns a new [ServicioSugeridoResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ServicioSugeridoResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'horaFin'), 'Required key "ServicioSugeridoResponse[horaFin]" is missing from JSON.');
        assert(json[r'horaFin'] != null, 'Required key "ServicioSugeridoResponse[horaFin]" has a null value in JSON.');
        assert(json.containsKey(r'horaInicio'), 'Required key "ServicioSugeridoResponse[horaInicio]" is missing from JSON.');
        assert(json[r'horaInicio'] != null, 'Required key "ServicioSugeridoResponse[horaInicio]" has a null value in JSON.');
        assert(json.containsKey(r'nombre'), 'Required key "ServicioSugeridoResponse[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "ServicioSugeridoResponse[nombre]" has a null value in JSON.');
        return true;
      }());

      return ServicioSugeridoResponse(
        horaFin: mapValueOfType<String>(json, r'horaFin')!,
        horaInicio: mapValueOfType<String>(json, r'horaInicio')!,
        nombre: mapValueOfType<String>(json, r'nombre')!,
      );
    }
    return null;
  }

  static List<ServicioSugeridoResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ServicioSugeridoResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ServicioSugeridoResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ServicioSugeridoResponse> mapFromJson(dynamic json) {
    final map = <String, ServicioSugeridoResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ServicioSugeridoResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ServicioSugeridoResponse-objects as value to a dart map
  static Map<String, List<ServicioSugeridoResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ServicioSugeridoResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ServicioSugeridoResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'horaFin',
    'horaInicio',
    'nombre',
  };
}

