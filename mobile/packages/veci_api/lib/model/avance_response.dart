//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class AvanceResponse {
  /// Returns a new [AvanceResponse] instance.
  AvanceResponse({
    required this.cajeros,
    required this.serviciosConHorario,
    required this.tiqueteras,
  });

  num cajeros;

  num serviciosConHorario;

  num tiqueteras;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AvanceResponse &&
    other.cajeros == cajeros &&
    other.serviciosConHorario == serviciosConHorario &&
    other.tiqueteras == tiqueteras;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (cajeros.hashCode) +
    (serviciosConHorario.hashCode) +
    (tiqueteras.hashCode);

  @override
  String toString() => 'AvanceResponse[cajeros=$cajeros, serviciosConHorario=$serviciosConHorario, tiqueteras=$tiqueteras]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'cajeros'] = this.cajeros;
      json[r'serviciosConHorario'] = this.serviciosConHorario;
      json[r'tiqueteras'] = this.tiqueteras;
    return json;
  }

  /// Returns a new [AvanceResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AvanceResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'cajeros'), 'Required key "AvanceResponse[cajeros]" is missing from JSON.');
        assert(json[r'cajeros'] != null, 'Required key "AvanceResponse[cajeros]" has a null value in JSON.');
        assert(json.containsKey(r'serviciosConHorario'), 'Required key "AvanceResponse[serviciosConHorario]" is missing from JSON.');
        assert(json[r'serviciosConHorario'] != null, 'Required key "AvanceResponse[serviciosConHorario]" has a null value in JSON.');
        assert(json.containsKey(r'tiqueteras'), 'Required key "AvanceResponse[tiqueteras]" is missing from JSON.');
        assert(json[r'tiqueteras'] != null, 'Required key "AvanceResponse[tiqueteras]" has a null value in JSON.');
        return true;
      }());

      return AvanceResponse(
        cajeros: num.parse('${json[r'cajeros']}'),
        serviciosConHorario: num.parse('${json[r'serviciosConHorario']}'),
        tiqueteras: num.parse('${json[r'tiqueteras']}'),
      );
    }
    return null;
  }

  static List<AvanceResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AvanceResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AvanceResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AvanceResponse> mapFromJson(dynamic json) {
    final map = <String, AvanceResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AvanceResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AvanceResponse-objects as value to a dart map
  static Map<String, List<AvanceResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AvanceResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AvanceResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'cajeros',
    'serviciosConHorario',
    'tiqueteras',
  };
}

