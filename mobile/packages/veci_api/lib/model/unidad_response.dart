//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class UnidadResponse {
  /// Returns a new [UnidadResponse] instance.
  UnidadResponse({
    required this.codigo,
    required this.plural,
    required this.singular,
  });

  String codigo;

  String plural;

  String singular;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UnidadResponse &&
    other.codigo == codigo &&
    other.plural == plural &&
    other.singular == singular;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (codigo.hashCode) +
    (plural.hashCode) +
    (singular.hashCode);

  @override
  String toString() => 'UnidadResponse[codigo=$codigo, plural=$plural, singular=$singular]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'codigo'] = this.codigo;
      json[r'plural'] = this.plural;
      json[r'singular'] = this.singular;
    return json;
  }

  /// Returns a new [UnidadResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UnidadResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'codigo'), 'Required key "UnidadResponse[codigo]" is missing from JSON.');
        assert(json[r'codigo'] != null, 'Required key "UnidadResponse[codigo]" has a null value in JSON.');
        assert(json.containsKey(r'plural'), 'Required key "UnidadResponse[plural]" is missing from JSON.');
        assert(json[r'plural'] != null, 'Required key "UnidadResponse[plural]" has a null value in JSON.');
        assert(json.containsKey(r'singular'), 'Required key "UnidadResponse[singular]" is missing from JSON.');
        assert(json[r'singular'] != null, 'Required key "UnidadResponse[singular]" has a null value in JSON.');
        return true;
      }());

      return UnidadResponse(
        codigo: mapValueOfType<String>(json, r'codigo')!,
        plural: mapValueOfType<String>(json, r'plural')!,
        singular: mapValueOfType<String>(json, r'singular')!,
      );
    }
    return null;
  }

  static List<UnidadResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UnidadResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UnidadResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UnidadResponse> mapFromJson(dynamic json) {
    final map = <String, UnidadResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UnidadResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UnidadResponse-objects as value to a dart map
  static Map<String, List<UnidadResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UnidadResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UnidadResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'codigo',
    'plural',
    'singular',
  };
}

