//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class SedeResponse {
  /// Returns a new [SedeResponse] instance.
  SedeResponse({
    required this.activa,
    this.direccion,
    required this.estado,
    this.municipio,
    this.municipioId,
    required this.nombre,
    required this.principal,
    required this.sedeId,
  });

  bool activa;

  String? direccion;

  String estado;

  String? municipio;

  num? municipioId;

  String nombre;

  bool principal;

  String sedeId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SedeResponse &&
    other.activa == activa &&
    other.direccion == direccion &&
    other.estado == estado &&
    other.municipio == municipio &&
    other.municipioId == municipioId &&
    other.nombre == nombre &&
    other.principal == principal &&
    other.sedeId == sedeId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (activa.hashCode) +
    (direccion == null ? 0 : direccion!.hashCode) +
    (estado.hashCode) +
    (municipio == null ? 0 : municipio!.hashCode) +
    (municipioId == null ? 0 : municipioId!.hashCode) +
    (nombre.hashCode) +
    (principal.hashCode) +
    (sedeId.hashCode);

  @override
  String toString() => 'SedeResponse[activa=$activa, direccion=$direccion, estado=$estado, municipio=$municipio, municipioId=$municipioId, nombre=$nombre, principal=$principal, sedeId=$sedeId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'activa'] = this.activa;
    if (this.direccion != null) {
      json[r'direccion'] = this.direccion;
    } else {
      json[r'direccion'] = null;
    }
      json[r'estado'] = this.estado;
    if (this.municipio != null) {
      json[r'municipio'] = this.municipio;
    } else {
      json[r'municipio'] = null;
    }
    if (this.municipioId != null) {
      json[r'municipioId'] = this.municipioId;
    } else {
      json[r'municipioId'] = null;
    }
      json[r'nombre'] = this.nombre;
      json[r'principal'] = this.principal;
      json[r'sedeId'] = this.sedeId;
    return json;
  }

  /// Returns a new [SedeResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SedeResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'activa'), 'Required key "SedeResponse[activa]" is missing from JSON.');
        assert(json[r'activa'] != null, 'Required key "SedeResponse[activa]" has a null value in JSON.');
        assert(json.containsKey(r'estado'), 'Required key "SedeResponse[estado]" is missing from JSON.');
        assert(json[r'estado'] != null, 'Required key "SedeResponse[estado]" has a null value in JSON.');
        assert(json.containsKey(r'nombre'), 'Required key "SedeResponse[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "SedeResponse[nombre]" has a null value in JSON.');
        assert(json.containsKey(r'principal'), 'Required key "SedeResponse[principal]" is missing from JSON.');
        assert(json[r'principal'] != null, 'Required key "SedeResponse[principal]" has a null value in JSON.');
        assert(json.containsKey(r'sedeId'), 'Required key "SedeResponse[sedeId]" is missing from JSON.');
        assert(json[r'sedeId'] != null, 'Required key "SedeResponse[sedeId]" has a null value in JSON.');
        return true;
      }());

      return SedeResponse(
        activa: mapValueOfType<bool>(json, r'activa')!,
        direccion: mapValueOfType<String>(json, r'direccion'),
        estado: mapValueOfType<String>(json, r'estado')!,
        municipio: mapValueOfType<String>(json, r'municipio'),
        municipioId: json[r'municipioId'] == null
            ? null
            : num.parse('${json[r'municipioId']}'),
        nombre: mapValueOfType<String>(json, r'nombre')!,
        principal: mapValueOfType<bool>(json, r'principal')!,
        sedeId: mapValueOfType<String>(json, r'sedeId')!,
      );
    }
    return null;
  }

  static List<SedeResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SedeResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SedeResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SedeResponse> mapFromJson(dynamic json) {
    final map = <String, SedeResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SedeResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SedeResponse-objects as value to a dart map
  static Map<String, List<SedeResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SedeResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SedeResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'activa',
    'estado',
    'nombre',
    'principal',
    'sedeId',
  };
}

