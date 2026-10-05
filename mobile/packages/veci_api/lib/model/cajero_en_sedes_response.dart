//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class CajeroEnSedesResponse {
  /// Returns a new [CajeroEnSedesResponse] instance.
  CajeroEnSedesResponse({
    required this.membresiaId,
    required this.nombre,
    this.sedeIds = const [],
  });

  String membresiaId;

  String nombre;

  /// Vacío = trabaja en todas
  List<String> sedeIds;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CajeroEnSedesResponse &&
    other.membresiaId == membresiaId &&
    other.nombre == nombre &&
    _deepEquality.equals(other.sedeIds, sedeIds);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (membresiaId.hashCode) +
    (nombre.hashCode) +
    (sedeIds.hashCode);

  @override
  String toString() => 'CajeroEnSedesResponse[membresiaId=$membresiaId, nombre=$nombre, sedeIds=$sedeIds]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'membresiaId'] = this.membresiaId;
      json[r'nombre'] = this.nombre;
      json[r'sedeIds'] = this.sedeIds;
    return json;
  }

  /// Returns a new [CajeroEnSedesResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CajeroEnSedesResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'membresiaId'), 'Required key "CajeroEnSedesResponse[membresiaId]" is missing from JSON.');
        assert(json[r'membresiaId'] != null, 'Required key "CajeroEnSedesResponse[membresiaId]" has a null value in JSON.');
        assert(json.containsKey(r'nombre'), 'Required key "CajeroEnSedesResponse[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "CajeroEnSedesResponse[nombre]" has a null value in JSON.');
        assert(json.containsKey(r'sedeIds'), 'Required key "CajeroEnSedesResponse[sedeIds]" is missing from JSON.');
        assert(json[r'sedeIds'] != null, 'Required key "CajeroEnSedesResponse[sedeIds]" has a null value in JSON.');
        return true;
      }());

      return CajeroEnSedesResponse(
        membresiaId: mapValueOfType<String>(json, r'membresiaId')!,
        nombre: mapValueOfType<String>(json, r'nombre')!,
        sedeIds: json[r'sedeIds'] is Iterable
            ? (json[r'sedeIds'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<CajeroEnSedesResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CajeroEnSedesResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CajeroEnSedesResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CajeroEnSedesResponse> mapFromJson(dynamic json) {
    final map = <String, CajeroEnSedesResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CajeroEnSedesResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CajeroEnSedesResponse-objects as value to a dart map
  static Map<String, List<CajeroEnSedesResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CajeroEnSedesResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CajeroEnSedesResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'membresiaId',
    'nombre',
    'sedeIds',
  };
}

