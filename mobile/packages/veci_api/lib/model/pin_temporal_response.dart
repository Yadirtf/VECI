//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class PinTemporalResponse {
  /// Returns a new [PinTemporalResponse] instance.
  PinTemporalResponse({
    required this.pinTemporal,
  });

  /// Se muestra una sola vez
  String pinTemporal;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PinTemporalResponse &&
    other.pinTemporal == pinTemporal;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (pinTemporal.hashCode);

  @override
  String toString() => 'PinTemporalResponse[pinTemporal=$pinTemporal]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'pinTemporal'] = this.pinTemporal;
    return json;
  }

  /// Returns a new [PinTemporalResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PinTemporalResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'pinTemporal'), 'Required key "PinTemporalResponse[pinTemporal]" is missing from JSON.');
        assert(json[r'pinTemporal'] != null, 'Required key "PinTemporalResponse[pinTemporal]" has a null value in JSON.');
        return true;
      }());

      return PinTemporalResponse(
        pinTemporal: mapValueOfType<String>(json, r'pinTemporal')!,
      );
    }
    return null;
  }

  static List<PinTemporalResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PinTemporalResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PinTemporalResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PinTemporalResponse> mapFromJson(dynamic json) {
    final map = <String, PinTemporalResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PinTemporalResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PinTemporalResponse-objects as value to a dart map
  static Map<String, List<PinTemporalResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PinTemporalResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PinTemporalResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'pinTemporal',
  };
}

