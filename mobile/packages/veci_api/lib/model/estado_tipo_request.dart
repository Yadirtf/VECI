//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class EstadoTipoRequest {
  /// Returns a new [EstadoTipoRequest] instance.
  EstadoTipoRequest({
    required this.activo,
  });

  /// true: se vende. false: se guarda sin borrar lo vendido.
  bool activo;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EstadoTipoRequest &&
    other.activo == activo;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (activo.hashCode);

  @override
  String toString() => 'EstadoTipoRequest[activo=$activo]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'activo'] = this.activo;
    return json;
  }

  /// Returns a new [EstadoTipoRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EstadoTipoRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'activo'), 'Required key "EstadoTipoRequest[activo]" is missing from JSON.');
        assert(json[r'activo'] != null, 'Required key "EstadoTipoRequest[activo]" has a null value in JSON.');
        return true;
      }());

      return EstadoTipoRequest(
        activo: mapValueOfType<bool>(json, r'activo')!,
      );
    }
    return null;
  }

  static List<EstadoTipoRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EstadoTipoRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EstadoTipoRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EstadoTipoRequest> mapFromJson(dynamic json) {
    final map = <String, EstadoTipoRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EstadoTipoRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EstadoTipoRequest-objects as value to a dart map
  static Map<String, List<EstadoTipoRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EstadoTipoRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EstadoTipoRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'activo',
  };
}

