//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class CopiaLocalResponse {
  /// Returns a new [CopiaLocalResponse] instance.
  CopiaLocalResponse({
    this.claves = const [],
    this.clientes = const [],
    required this.version,
  });

  List<ClavePublicaResponse> claves;

  List<ClienteEnCajaResponse> clientes;

  /// Va también en el ETag
  String version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CopiaLocalResponse &&
    _deepEquality.equals(other.claves, claves) &&
    _deepEquality.equals(other.clientes, clientes) &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (claves.hashCode) +
    (clientes.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'CopiaLocalResponse[claves=$claves, clientes=$clientes, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'claves'] = this.claves;
      json[r'clientes'] = this.clientes;
      json[r'version'] = this.version;
    return json;
  }

  /// Returns a new [CopiaLocalResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CopiaLocalResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'claves'), 'Required key "CopiaLocalResponse[claves]" is missing from JSON.');
        assert(json[r'claves'] != null, 'Required key "CopiaLocalResponse[claves]" has a null value in JSON.');
        assert(json.containsKey(r'clientes'), 'Required key "CopiaLocalResponse[clientes]" is missing from JSON.');
        assert(json[r'clientes'] != null, 'Required key "CopiaLocalResponse[clientes]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "CopiaLocalResponse[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "CopiaLocalResponse[version]" has a null value in JSON.');
        return true;
      }());

      return CopiaLocalResponse(
        claves: ClavePublicaResponse.listFromJson(json[r'claves']),
        clientes: ClienteEnCajaResponse.listFromJson(json[r'clientes']),
        version: mapValueOfType<String>(json, r'version')!,
      );
    }
    return null;
  }

  static List<CopiaLocalResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CopiaLocalResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CopiaLocalResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CopiaLocalResponse> mapFromJson(dynamic json) {
    final map = <String, CopiaLocalResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CopiaLocalResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CopiaLocalResponse-objects as value to a dart map
  static Map<String, List<CopiaLocalResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CopiaLocalResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CopiaLocalResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'claves',
    'clientes',
    'version',
  };
}

