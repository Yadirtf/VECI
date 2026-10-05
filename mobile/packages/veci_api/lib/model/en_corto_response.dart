//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class EnCortoResponse {
  /// Returns a new [EnCortoResponse] instance.
  EnCortoResponse({
    this.anotamos = const [],
    this.nuncaHacemos = const [],
    required this.paraQue,
  });

  List<String> anotamos;

  List<String> nuncaHacemos;

  String paraQue;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EnCortoResponse &&
    _deepEquality.equals(other.anotamos, anotamos) &&
    _deepEquality.equals(other.nuncaHacemos, nuncaHacemos) &&
    other.paraQue == paraQue;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (anotamos.hashCode) +
    (nuncaHacemos.hashCode) +
    (paraQue.hashCode);

  @override
  String toString() => 'EnCortoResponse[anotamos=$anotamos, nuncaHacemos=$nuncaHacemos, paraQue=$paraQue]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'anotamos'] = this.anotamos;
      json[r'nuncaHacemos'] = this.nuncaHacemos;
      json[r'paraQue'] = this.paraQue;
    return json;
  }

  /// Returns a new [EnCortoResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EnCortoResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'anotamos'), 'Required key "EnCortoResponse[anotamos]" is missing from JSON.');
        assert(json[r'anotamos'] != null, 'Required key "EnCortoResponse[anotamos]" has a null value in JSON.');
        assert(json.containsKey(r'nuncaHacemos'), 'Required key "EnCortoResponse[nuncaHacemos]" is missing from JSON.');
        assert(json[r'nuncaHacemos'] != null, 'Required key "EnCortoResponse[nuncaHacemos]" has a null value in JSON.');
        assert(json.containsKey(r'paraQue'), 'Required key "EnCortoResponse[paraQue]" is missing from JSON.');
        assert(json[r'paraQue'] != null, 'Required key "EnCortoResponse[paraQue]" has a null value in JSON.');
        return true;
      }());

      return EnCortoResponse(
        anotamos: json[r'anotamos'] is Iterable
            ? (json[r'anotamos'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        nuncaHacemos: json[r'nuncaHacemos'] is Iterable
            ? (json[r'nuncaHacemos'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        paraQue: mapValueOfType<String>(json, r'paraQue')!,
      );
    }
    return null;
  }

  static List<EnCortoResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EnCortoResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EnCortoResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EnCortoResponse> mapFromJson(dynamic json) {
    final map = <String, EnCortoResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EnCortoResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EnCortoResponse-objects as value to a dart map
  static Map<String, List<EnCortoResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EnCortoResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EnCortoResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'anotamos',
    'nuncaHacemos',
    'paraQue',
  };
}

