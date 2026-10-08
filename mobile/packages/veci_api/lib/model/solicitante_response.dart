//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class SolicitanteResponse {
  /// Returns a new [SolicitanteResponse] instance.
  SolicitanteResponse({
    this.celular,
    required this.nombre,
    required this.usuarioId,
  });

  String? celular;

  String nombre;

  String usuarioId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SolicitanteResponse &&
    other.celular == celular &&
    other.nombre == nombre &&
    other.usuarioId == usuarioId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (celular == null ? 0 : celular!.hashCode) +
    (nombre.hashCode) +
    (usuarioId.hashCode);

  @override
  String toString() => 'SolicitanteResponse[celular=$celular, nombre=$nombre, usuarioId=$usuarioId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.celular != null) {
      json[r'celular'] = this.celular;
    } else {
      json[r'celular'] = null;
    }
      json[r'nombre'] = this.nombre;
      json[r'usuarioId'] = this.usuarioId;
    return json;
  }

  /// Returns a new [SolicitanteResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SolicitanteResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'nombre'), 'Required key "SolicitanteResponse[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "SolicitanteResponse[nombre]" has a null value in JSON.');
        assert(json.containsKey(r'usuarioId'), 'Required key "SolicitanteResponse[usuarioId]" is missing from JSON.');
        assert(json[r'usuarioId'] != null, 'Required key "SolicitanteResponse[usuarioId]" has a null value in JSON.');
        return true;
      }());

      return SolicitanteResponse(
        celular: mapValueOfType<String>(json, r'celular'),
        nombre: mapValueOfType<String>(json, r'nombre')!,
        usuarioId: mapValueOfType<String>(json, r'usuarioId')!,
      );
    }
    return null;
  }

  static List<SolicitanteResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SolicitanteResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SolicitanteResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SolicitanteResponse> mapFromJson(dynamic json) {
    final map = <String, SolicitanteResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SolicitanteResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SolicitanteResponse-objects as value to a dart map
  static Map<String, List<SolicitanteResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SolicitanteResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SolicitanteResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'nombre',
    'usuarioId',
  };
}

