//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class CatalogoDeVentaResponse {
  /// Returns a new [CatalogoDeVentaResponse] instance.
  CatalogoDeVentaResponse({
    this.medios = const [],
    this.tipos = const [],
    required this.version,
  });

  List<MedioDePagoResponse> medios;

  /// Solo los activos
  List<TipoResponse> tipos;

  /// Va también en el ETag
  String version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CatalogoDeVentaResponse &&
    _deepEquality.equals(other.medios, medios) &&
    _deepEquality.equals(other.tipos, tipos) &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (medios.hashCode) +
    (tipos.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'CatalogoDeVentaResponse[medios=$medios, tipos=$tipos, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'medios'] = this.medios;
      json[r'tipos'] = this.tipos;
      json[r'version'] = this.version;
    return json;
  }

  /// Returns a new [CatalogoDeVentaResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CatalogoDeVentaResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'medios'), 'Required key "CatalogoDeVentaResponse[medios]" is missing from JSON.');
        assert(json[r'medios'] != null, 'Required key "CatalogoDeVentaResponse[medios]" has a null value in JSON.');
        assert(json.containsKey(r'tipos'), 'Required key "CatalogoDeVentaResponse[tipos]" is missing from JSON.');
        assert(json[r'tipos'] != null, 'Required key "CatalogoDeVentaResponse[tipos]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "CatalogoDeVentaResponse[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "CatalogoDeVentaResponse[version]" has a null value in JSON.');
        return true;
      }());

      return CatalogoDeVentaResponse(
        medios: MedioDePagoResponse.listFromJson(json[r'medios']),
        tipos: TipoResponse.listFromJson(json[r'tipos']),
        version: mapValueOfType<String>(json, r'version')!,
      );
    }
    return null;
  }

  static List<CatalogoDeVentaResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CatalogoDeVentaResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CatalogoDeVentaResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CatalogoDeVentaResponse> mapFromJson(dynamic json) {
    final map = <String, CatalogoDeVentaResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CatalogoDeVentaResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CatalogoDeVentaResponse-objects as value to a dart map
  static Map<String, List<CatalogoDeVentaResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CatalogoDeVentaResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CatalogoDeVentaResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'medios',
    'tipos',
    'version',
  };
}

