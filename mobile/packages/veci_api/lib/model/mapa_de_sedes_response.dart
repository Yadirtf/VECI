//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class MapaDeSedesResponse {
  /// Returns a new [MapaDeSedesResponse] instance.
  MapaDeSedesResponse({
    this.cajeros = const [],
    required this.cupo,
    this.sedes = const [],
  });

  List<CajeroEnSedesResponse> cajeros;

  CupoDeSedesResponse cupo;

  List<SedeResponse> sedes;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MapaDeSedesResponse &&
    _deepEquality.equals(other.cajeros, cajeros) &&
    other.cupo == cupo &&
    _deepEquality.equals(other.sedes, sedes);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (cajeros.hashCode) +
    (cupo.hashCode) +
    (sedes.hashCode);

  @override
  String toString() => 'MapaDeSedesResponse[cajeros=$cajeros, cupo=$cupo, sedes=$sedes]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'cajeros'] = this.cajeros;
      json[r'cupo'] = this.cupo;
      json[r'sedes'] = this.sedes;
    return json;
  }

  /// Returns a new [MapaDeSedesResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MapaDeSedesResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'cajeros'), 'Required key "MapaDeSedesResponse[cajeros]" is missing from JSON.');
        assert(json[r'cajeros'] != null, 'Required key "MapaDeSedesResponse[cajeros]" has a null value in JSON.');
        assert(json.containsKey(r'cupo'), 'Required key "MapaDeSedesResponse[cupo]" is missing from JSON.');
        assert(json[r'cupo'] != null, 'Required key "MapaDeSedesResponse[cupo]" has a null value in JSON.');
        assert(json.containsKey(r'sedes'), 'Required key "MapaDeSedesResponse[sedes]" is missing from JSON.');
        assert(json[r'sedes'] != null, 'Required key "MapaDeSedesResponse[sedes]" has a null value in JSON.');
        return true;
      }());

      return MapaDeSedesResponse(
        cajeros: CajeroEnSedesResponse.listFromJson(json[r'cajeros']),
        cupo: CupoDeSedesResponse.fromJson(json[r'cupo'])!,
        sedes: SedeResponse.listFromJson(json[r'sedes']),
      );
    }
    return null;
  }

  static List<MapaDeSedesResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MapaDeSedesResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MapaDeSedesResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MapaDeSedesResponse> mapFromJson(dynamic json) {
    final map = <String, MapaDeSedesResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MapaDeSedesResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MapaDeSedesResponse-objects as value to a dart map
  static Map<String, List<MapaDeSedesResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MapaDeSedesResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MapaDeSedesResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'cajeros',
    'cupo',
    'sedes',
  };
}

