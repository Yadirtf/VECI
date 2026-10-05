//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class RevisionDocumentoResponse {
  /// Returns a new [RevisionDocumentoResponse] instance.
  RevisionDocumentoResponse({
    this.persona,
  });

  PersonaPorAfiliarResponse? persona;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RevisionDocumentoResponse &&
    other.persona == persona;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (persona == null ? 0 : persona!.hashCode);

  @override
  String toString() => 'RevisionDocumentoResponse[persona=$persona]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.persona != null) {
      json[r'persona'] = this.persona;
    } else {
      json[r'persona'] = null;
    }
    return json;
  }

  /// Returns a new [RevisionDocumentoResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RevisionDocumentoResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        return true;
      }());

      return RevisionDocumentoResponse(
        persona: PersonaPorAfiliarResponse.fromJson(json[r'persona']),
      );
    }
    return null;
  }

  static List<RevisionDocumentoResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RevisionDocumentoResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RevisionDocumentoResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RevisionDocumentoResponse> mapFromJson(dynamic json) {
    final map = <String, RevisionDocumentoResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RevisionDocumentoResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RevisionDocumentoResponse-objects as value to a dart map
  static Map<String, List<RevisionDocumentoResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RevisionDocumentoResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RevisionDocumentoResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

