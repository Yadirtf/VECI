//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class SesionEnDispositivoResponse {
  /// Returns a new [SesionEnDispositivoResponse] instance.
  SesionEnDispositivoResponse({
    required this.abiertaDesde,
    required this.nombre,
    required this.sesionId,
    required this.ultimoUso,
    required this.usuarioId,
  });

  DateTime abiertaDesde;

  String nombre;

  String sesionId;

  DateTime ultimoUso;

  String usuarioId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SesionEnDispositivoResponse &&
    other.abiertaDesde == abiertaDesde &&
    other.nombre == nombre &&
    other.sesionId == sesionId &&
    other.ultimoUso == ultimoUso &&
    other.usuarioId == usuarioId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (abiertaDesde.hashCode) +
    (nombre.hashCode) +
    (sesionId.hashCode) +
    (ultimoUso.hashCode) +
    (usuarioId.hashCode);

  @override
  String toString() => 'SesionEnDispositivoResponse[abiertaDesde=$abiertaDesde, nombre=$nombre, sesionId=$sesionId, ultimoUso=$ultimoUso, usuarioId=$usuarioId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'abiertaDesde'] = this.abiertaDesde.toUtc().toIso8601String();
      json[r'nombre'] = this.nombre;
      json[r'sesionId'] = this.sesionId;
      json[r'ultimoUso'] = this.ultimoUso.toUtc().toIso8601String();
      json[r'usuarioId'] = this.usuarioId;
    return json;
  }

  /// Returns a new [SesionEnDispositivoResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SesionEnDispositivoResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'abiertaDesde'), 'Required key "SesionEnDispositivoResponse[abiertaDesde]" is missing from JSON.');
        assert(json[r'abiertaDesde'] != null, 'Required key "SesionEnDispositivoResponse[abiertaDesde]" has a null value in JSON.');
        assert(json.containsKey(r'nombre'), 'Required key "SesionEnDispositivoResponse[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "SesionEnDispositivoResponse[nombre]" has a null value in JSON.');
        assert(json.containsKey(r'sesionId'), 'Required key "SesionEnDispositivoResponse[sesionId]" is missing from JSON.');
        assert(json[r'sesionId'] != null, 'Required key "SesionEnDispositivoResponse[sesionId]" has a null value in JSON.');
        assert(json.containsKey(r'ultimoUso'), 'Required key "SesionEnDispositivoResponse[ultimoUso]" is missing from JSON.');
        assert(json[r'ultimoUso'] != null, 'Required key "SesionEnDispositivoResponse[ultimoUso]" has a null value in JSON.');
        assert(json.containsKey(r'usuarioId'), 'Required key "SesionEnDispositivoResponse[usuarioId]" is missing from JSON.');
        assert(json[r'usuarioId'] != null, 'Required key "SesionEnDispositivoResponse[usuarioId]" has a null value in JSON.');
        return true;
      }());

      return SesionEnDispositivoResponse(
        abiertaDesde: mapDateTime(json, r'abiertaDesde', r'')!,
        nombre: mapValueOfType<String>(json, r'nombre')!,
        sesionId: mapValueOfType<String>(json, r'sesionId')!,
        ultimoUso: mapDateTime(json, r'ultimoUso', r'')!,
        usuarioId: mapValueOfType<String>(json, r'usuarioId')!,
      );
    }
    return null;
  }

  static List<SesionEnDispositivoResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SesionEnDispositivoResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SesionEnDispositivoResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SesionEnDispositivoResponse> mapFromJson(dynamic json) {
    final map = <String, SesionEnDispositivoResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SesionEnDispositivoResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SesionEnDispositivoResponse-objects as value to a dart map
  static Map<String, List<SesionEnDispositivoResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SesionEnDispositivoResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SesionEnDispositivoResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'abiertaDesde',
    'nombre',
    'sesionId',
    'ultimoUso',
    'usuarioId',
  };
}

