//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class ComercioActivoResponse {
  /// Returns a new [ComercioActivoResponse] instance.
  ComercioActivoResponse({
    required this.comercio,
    this.permisos = const [],
  });

  EspacioResponse comercio;

  List<String> permisos;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ComercioActivoResponse &&
    other.comercio == comercio &&
    _deepEquality.equals(other.permisos, permisos);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (comercio.hashCode) +
    (permisos.hashCode);

  @override
  String toString() => 'ComercioActivoResponse[comercio=$comercio, permisos=$permisos]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'comercio'] = this.comercio;
      json[r'permisos'] = this.permisos;
    return json;
  }

  /// Returns a new [ComercioActivoResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ComercioActivoResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'comercio'), 'Required key "ComercioActivoResponse[comercio]" is missing from JSON.');
        assert(json[r'comercio'] != null, 'Required key "ComercioActivoResponse[comercio]" has a null value in JSON.');
        assert(json.containsKey(r'permisos'), 'Required key "ComercioActivoResponse[permisos]" is missing from JSON.');
        assert(json[r'permisos'] != null, 'Required key "ComercioActivoResponse[permisos]" has a null value in JSON.');
        return true;
      }());

      return ComercioActivoResponse(
        comercio: EspacioResponse.fromJson(json[r'comercio'])!,
        permisos: json[r'permisos'] is Iterable
            ? (json[r'permisos'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<ComercioActivoResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ComercioActivoResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ComercioActivoResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ComercioActivoResponse> mapFromJson(dynamic json) {
    final map = <String, ComercioActivoResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ComercioActivoResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ComercioActivoResponse-objects as value to a dart map
  static Map<String, List<ComercioActivoResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ComercioActivoResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ComercioActivoResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'comercio',
    'permisos',
  };
}

