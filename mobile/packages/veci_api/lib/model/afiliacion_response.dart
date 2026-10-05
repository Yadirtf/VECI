//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class AfiliacionResponse {
  /// Returns a new [AfiliacionResponse] instance.
  AfiliacionResponse({
    required this.cliente,
    required this.yaEstaba,
  });

  ClienteResponse cliente;

  /// Ya era cliente: no se creó nada
  bool yaEstaba;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AfiliacionResponse &&
    other.cliente == cliente &&
    other.yaEstaba == yaEstaba;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (cliente.hashCode) +
    (yaEstaba.hashCode);

  @override
  String toString() => 'AfiliacionResponse[cliente=$cliente, yaEstaba=$yaEstaba]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'cliente'] = this.cliente;
      json[r'yaEstaba'] = this.yaEstaba;
    return json;
  }

  /// Returns a new [AfiliacionResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AfiliacionResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'cliente'), 'Required key "AfiliacionResponse[cliente]" is missing from JSON.');
        assert(json[r'cliente'] != null, 'Required key "AfiliacionResponse[cliente]" has a null value in JSON.');
        assert(json.containsKey(r'yaEstaba'), 'Required key "AfiliacionResponse[yaEstaba]" is missing from JSON.');
        assert(json[r'yaEstaba'] != null, 'Required key "AfiliacionResponse[yaEstaba]" has a null value in JSON.');
        return true;
      }());

      return AfiliacionResponse(
        cliente: ClienteResponse.fromJson(json[r'cliente'])!,
        yaEstaba: mapValueOfType<bool>(json, r'yaEstaba')!,
      );
    }
    return null;
  }

  static List<AfiliacionResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AfiliacionResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AfiliacionResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AfiliacionResponse> mapFromJson(dynamic json) {
    final map = <String, AfiliacionResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AfiliacionResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AfiliacionResponse-objects as value to a dart map
  static Map<String, List<AfiliacionResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AfiliacionResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AfiliacionResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'cliente',
    'yaEstaba',
  };
}

