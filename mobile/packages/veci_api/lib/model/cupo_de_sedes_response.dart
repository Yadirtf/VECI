//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class CupoDeSedesResponse {
  /// Returns a new [CupoDeSedesResponse] instance.
  CupoDeSedesResponse({
    this.limite,
    required this.ocupadas,
    required this.variasSedes,
  });

  /// null = sin límite
  num? limite;

  num ocupadas;

  /// El plan permite varias sedes (plan Pro)
  bool variasSedes;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CupoDeSedesResponse &&
    other.limite == limite &&
    other.ocupadas == ocupadas &&
    other.variasSedes == variasSedes;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (limite == null ? 0 : limite!.hashCode) +
    (ocupadas.hashCode) +
    (variasSedes.hashCode);

  @override
  String toString() => 'CupoDeSedesResponse[limite=$limite, ocupadas=$ocupadas, variasSedes=$variasSedes]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.limite != null) {
      json[r'limite'] = this.limite;
    } else {
      json[r'limite'] = null;
    }
      json[r'ocupadas'] = this.ocupadas;
      json[r'variasSedes'] = this.variasSedes;
    return json;
  }

  /// Returns a new [CupoDeSedesResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CupoDeSedesResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'ocupadas'), 'Required key "CupoDeSedesResponse[ocupadas]" is missing from JSON.');
        assert(json[r'ocupadas'] != null, 'Required key "CupoDeSedesResponse[ocupadas]" has a null value in JSON.');
        assert(json.containsKey(r'variasSedes'), 'Required key "CupoDeSedesResponse[variasSedes]" is missing from JSON.');
        assert(json[r'variasSedes'] != null, 'Required key "CupoDeSedesResponse[variasSedes]" has a null value in JSON.');
        return true;
      }());

      return CupoDeSedesResponse(
        limite: json[r'limite'] == null
            ? null
            : num.parse('${json[r'limite']}'),
        ocupadas: num.parse('${json[r'ocupadas']}'),
        variasSedes: mapValueOfType<bool>(json, r'variasSedes')!,
      );
    }
    return null;
  }

  static List<CupoDeSedesResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CupoDeSedesResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CupoDeSedesResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CupoDeSedesResponse> mapFromJson(dynamic json) {
    final map = <String, CupoDeSedesResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CupoDeSedesResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CupoDeSedesResponse-objects as value to a dart map
  static Map<String, List<CupoDeSedesResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CupoDeSedesResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CupoDeSedesResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'ocupadas',
    'variasSedes',
  };
}

