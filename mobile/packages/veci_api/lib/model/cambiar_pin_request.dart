//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class CambiarPinRequest {
  /// Returns a new [CambiarPinRequest] instance.
  CambiarPinRequest({
    required this.pinActual,
    required this.pinNuevo,
  });

  String pinActual;

  String pinNuevo;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CambiarPinRequest &&
    other.pinActual == pinActual &&
    other.pinNuevo == pinNuevo;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (pinActual.hashCode) +
    (pinNuevo.hashCode);

  @override
  String toString() => 'CambiarPinRequest[pinActual=$pinActual, pinNuevo=$pinNuevo]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'pinActual'] = this.pinActual;
      json[r'pinNuevo'] = this.pinNuevo;
    return json;
  }

  /// Returns a new [CambiarPinRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CambiarPinRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'pinActual'), 'Required key "CambiarPinRequest[pinActual]" is missing from JSON.');
        assert(json[r'pinActual'] != null, 'Required key "CambiarPinRequest[pinActual]" has a null value in JSON.');
        assert(json.containsKey(r'pinNuevo'), 'Required key "CambiarPinRequest[pinNuevo]" is missing from JSON.');
        assert(json[r'pinNuevo'] != null, 'Required key "CambiarPinRequest[pinNuevo]" has a null value in JSON.');
        return true;
      }());

      return CambiarPinRequest(
        pinActual: mapValueOfType<String>(json, r'pinActual')!,
        pinNuevo: mapValueOfType<String>(json, r'pinNuevo')!,
      );
    }
    return null;
  }

  static List<CambiarPinRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CambiarPinRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CambiarPinRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CambiarPinRequest> mapFromJson(dynamic json) {
    final map = <String, CambiarPinRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CambiarPinRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CambiarPinRequest-objects as value to a dart map
  static Map<String, List<CambiarPinRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CambiarPinRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CambiarPinRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'pinActual',
    'pinNuevo',
  };
}

