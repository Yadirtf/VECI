//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class ComercioActivoRequest {
  /// Returns a new [ComercioActivoRequest] instance.
  ComercioActivoRequest({
    required this.comercioId,
  });

  String comercioId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ComercioActivoRequest &&
    other.comercioId == comercioId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (comercioId.hashCode);

  @override
  String toString() => 'ComercioActivoRequest[comercioId=$comercioId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'comercioId'] = this.comercioId;
    return json;
  }

  /// Returns a new [ComercioActivoRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ComercioActivoRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'comercioId'), 'Required key "ComercioActivoRequest[comercioId]" is missing from JSON.');
        assert(json[r'comercioId'] != null, 'Required key "ComercioActivoRequest[comercioId]" has a null value in JSON.');
        return true;
      }());

      return ComercioActivoRequest(
        comercioId: mapValueOfType<String>(json, r'comercioId')!,
      );
    }
    return null;
  }

  static List<ComercioActivoRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ComercioActivoRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ComercioActivoRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ComercioActivoRequest> mapFromJson(dynamic json) {
    final map = <String, ComercioActivoRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ComercioActivoRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ComercioActivoRequest-objects as value to a dart map
  static Map<String, List<ComercioActivoRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ComercioActivoRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ComercioActivoRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'comercioId',
  };
}

