//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class CrearSedeRequest {
  /// Returns a new [CrearSedeRequest] instance.
  CrearSedeRequest({
    this.direccion,
    this.municipioId,
    required this.nombre,
  });

  String? direccion;

  num? municipioId;

  String nombre;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CrearSedeRequest &&
    other.direccion == direccion &&
    other.municipioId == municipioId &&
    other.nombre == nombre;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (direccion == null ? 0 : direccion!.hashCode) +
    (municipioId == null ? 0 : municipioId!.hashCode) +
    (nombre.hashCode);

  @override
  String toString() => 'CrearSedeRequest[direccion=$direccion, municipioId=$municipioId, nombre=$nombre]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.direccion != null) {
      json[r'direccion'] = this.direccion;
    } else {
      json[r'direccion'] = null;
    }
    if (this.municipioId != null) {
      json[r'municipioId'] = this.municipioId;
    } else {
      json[r'municipioId'] = null;
    }
      json[r'nombre'] = this.nombre;
    return json;
  }

  /// Returns a new [CrearSedeRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CrearSedeRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'nombre'), 'Required key "CrearSedeRequest[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "CrearSedeRequest[nombre]" has a null value in JSON.');
        return true;
      }());

      return CrearSedeRequest(
        direccion: mapValueOfType<String>(json, r'direccion'),
        municipioId: json[r'municipioId'] == null
            ? null
            : num.parse('${json[r'municipioId']}'),
        nombre: mapValueOfType<String>(json, r'nombre')!,
      );
    }
    return null;
  }

  static List<CrearSedeRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CrearSedeRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CrearSedeRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CrearSedeRequest> mapFromJson(dynamic json) {
    final map = <String, CrearSedeRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CrearSedeRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CrearSedeRequest-objects as value to a dart map
  static Map<String, List<CrearSedeRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CrearSedeRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CrearSedeRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'nombre',
  };
}

