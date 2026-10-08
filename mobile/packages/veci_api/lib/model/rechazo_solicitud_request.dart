//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class RechazoSolicitudRequest {
  /// Returns a new [RechazoSolicitudRequest] instance.
  RechazoSolicitudRequest({
    required this.motivo,
  });

  String motivo;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RechazoSolicitudRequest &&
    other.motivo == motivo;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (motivo.hashCode);

  @override
  String toString() => 'RechazoSolicitudRequest[motivo=$motivo]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'motivo'] = this.motivo;
    return json;
  }

  /// Returns a new [RechazoSolicitudRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RechazoSolicitudRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'motivo'), 'Required key "RechazoSolicitudRequest[motivo]" is missing from JSON.');
        assert(json[r'motivo'] != null, 'Required key "RechazoSolicitudRequest[motivo]" has a null value in JSON.');
        return true;
      }());

      return RechazoSolicitudRequest(
        motivo: mapValueOfType<String>(json, r'motivo')!,
      );
    }
    return null;
  }

  static List<RechazoSolicitudRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RechazoSolicitudRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RechazoSolicitudRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RechazoSolicitudRequest> mapFromJson(dynamic json) {
    final map = <String, RechazoSolicitudRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RechazoSolicitudRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RechazoSolicitudRequest-objects as value to a dart map
  static Map<String, List<RechazoSolicitudRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RechazoSolicitudRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RechazoSolicitudRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'motivo',
  };
}

