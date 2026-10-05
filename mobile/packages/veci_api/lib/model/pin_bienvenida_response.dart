//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class PinBienvenidaResponse {
  /// Returns a new [PinBienvenidaResponse] instance.
  PinBienvenidaResponse({
    required this.pinBienvenida,
  });

  /// Se muestra una sola vez. Sirve 7 días.
  String pinBienvenida;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PinBienvenidaResponse &&
    other.pinBienvenida == pinBienvenida;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (pinBienvenida.hashCode);

  @override
  String toString() => 'PinBienvenidaResponse[pinBienvenida=$pinBienvenida]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'pinBienvenida'] = this.pinBienvenida;
    return json;
  }

  /// Returns a new [PinBienvenidaResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PinBienvenidaResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'pinBienvenida'), 'Required key "PinBienvenidaResponse[pinBienvenida]" is missing from JSON.');
        assert(json[r'pinBienvenida'] != null, 'Required key "PinBienvenidaResponse[pinBienvenida]" has a null value in JSON.');
        return true;
      }());

      return PinBienvenidaResponse(
        pinBienvenida: mapValueOfType<String>(json, r'pinBienvenida')!,
      );
    }
    return null;
  }

  static List<PinBienvenidaResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PinBienvenidaResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PinBienvenidaResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PinBienvenidaResponse> mapFromJson(dynamic json) {
    final map = <String, PinBienvenidaResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PinBienvenidaResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PinBienvenidaResponse-objects as value to a dart map
  static Map<String, List<PinBienvenidaResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PinBienvenidaResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PinBienvenidaResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'pinBienvenida',
  };
}

