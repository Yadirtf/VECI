//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class RenovarSesionRequest {
  /// Returns a new [RenovarSesionRequest] instance.
  RenovarSesionRequest({
    required this.tokenRenovacion,
  });

  String tokenRenovacion;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RenovarSesionRequest &&
    other.tokenRenovacion == tokenRenovacion;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (tokenRenovacion.hashCode);

  @override
  String toString() => 'RenovarSesionRequest[tokenRenovacion=$tokenRenovacion]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'tokenRenovacion'] = this.tokenRenovacion;
    return json;
  }

  /// Returns a new [RenovarSesionRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RenovarSesionRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'tokenRenovacion'), 'Required key "RenovarSesionRequest[tokenRenovacion]" is missing from JSON.');
        assert(json[r'tokenRenovacion'] != null, 'Required key "RenovarSesionRequest[tokenRenovacion]" has a null value in JSON.');
        return true;
      }());

      return RenovarSesionRequest(
        tokenRenovacion: mapValueOfType<String>(json, r'tokenRenovacion')!,
      );
    }
    return null;
  }

  static List<RenovarSesionRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RenovarSesionRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RenovarSesionRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RenovarSesionRequest> mapFromJson(dynamic json) {
    final map = <String, RenovarSesionRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RenovarSesionRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RenovarSesionRequest-objects as value to a dart map
  static Map<String, List<RenovarSesionRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RenovarSesionRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RenovarSesionRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'tokenRenovacion',
  };
}

