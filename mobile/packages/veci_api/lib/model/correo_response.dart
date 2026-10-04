//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class CorreoResponse {
  /// Returns a new [CorreoResponse] instance.
  CorreoResponse({
    required this.correo,
  });

  String correo;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CorreoResponse &&
    other.correo == correo;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (correo.hashCode);

  @override
  String toString() => 'CorreoResponse[correo=$correo]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'correo'] = this.correo;
    return json;
  }

  /// Returns a new [CorreoResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CorreoResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'correo'), 'Required key "CorreoResponse[correo]" is missing from JSON.');
        assert(json[r'correo'] != null, 'Required key "CorreoResponse[correo]" has a null value in JSON.');
        return true;
      }());

      return CorreoResponse(
        correo: mapValueOfType<String>(json, r'correo')!,
      );
    }
    return null;
  }

  static List<CorreoResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CorreoResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CorreoResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CorreoResponse> mapFromJson(dynamic json) {
    final map = <String, CorreoResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CorreoResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CorreoResponse-objects as value to a dart map
  static Map<String, List<CorreoResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CorreoResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CorreoResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'correo',
  };
}

