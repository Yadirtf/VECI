//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class MedioDePagoResponse {
  /// Returns a new [MedioDePagoResponse] instance.
  MedioDePagoResponse({
    this.canales = const [],
    required this.codigo,
    required this.necesitaCanal,
    required this.nombre,
  });

  List<CanalResponse> canales;

  String codigo;

  /// Hay que decir por cuál canal llegó
  bool necesitaCanal;

  String nombre;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MedioDePagoResponse &&
    _deepEquality.equals(other.canales, canales) &&
    other.codigo == codigo &&
    other.necesitaCanal == necesitaCanal &&
    other.nombre == nombre;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (canales.hashCode) +
    (codigo.hashCode) +
    (necesitaCanal.hashCode) +
    (nombre.hashCode);

  @override
  String toString() => 'MedioDePagoResponse[canales=$canales, codigo=$codigo, necesitaCanal=$necesitaCanal, nombre=$nombre]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'canales'] = this.canales;
      json[r'codigo'] = this.codigo;
      json[r'necesitaCanal'] = this.necesitaCanal;
      json[r'nombre'] = this.nombre;
    return json;
  }

  /// Returns a new [MedioDePagoResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MedioDePagoResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'canales'), 'Required key "MedioDePagoResponse[canales]" is missing from JSON.');
        assert(json[r'canales'] != null, 'Required key "MedioDePagoResponse[canales]" has a null value in JSON.');
        assert(json.containsKey(r'codigo'), 'Required key "MedioDePagoResponse[codigo]" is missing from JSON.');
        assert(json[r'codigo'] != null, 'Required key "MedioDePagoResponse[codigo]" has a null value in JSON.');
        assert(json.containsKey(r'necesitaCanal'), 'Required key "MedioDePagoResponse[necesitaCanal]" is missing from JSON.');
        assert(json[r'necesitaCanal'] != null, 'Required key "MedioDePagoResponse[necesitaCanal]" has a null value in JSON.');
        assert(json.containsKey(r'nombre'), 'Required key "MedioDePagoResponse[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "MedioDePagoResponse[nombre]" has a null value in JSON.');
        return true;
      }());

      return MedioDePagoResponse(
        canales: CanalResponse.listFromJson(json[r'canales']),
        codigo: mapValueOfType<String>(json, r'codigo')!,
        necesitaCanal: mapValueOfType<bool>(json, r'necesitaCanal')!,
        nombre: mapValueOfType<String>(json, r'nombre')!,
      );
    }
    return null;
  }

  static List<MedioDePagoResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MedioDePagoResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MedioDePagoResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MedioDePagoResponse> mapFromJson(dynamic json) {
    final map = <String, MedioDePagoResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MedioDePagoResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MedioDePagoResponse-objects as value to a dart map
  static Map<String, List<MedioDePagoResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MedioDePagoResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MedioDePagoResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'canales',
    'codigo',
    'necesitaCanal',
    'nombre',
  };
}

