//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class TipoRequest {
  /// Returns a new [TipoRequest] instance.
  TipoRequest({
    required this.nombre,
    required this.precio,
    required this.unidad,
    required this.unidades,
    required this.vigenciaDias,
  });

  String nombre;

  /// Pesos, sin centavos
  num precio;

  /// Código de la unidad (lista de unidades)
  String unidad;

  num unidades;

  num vigenciaDias;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TipoRequest &&
    other.nombre == nombre &&
    other.precio == precio &&
    other.unidad == unidad &&
    other.unidades == unidades &&
    other.vigenciaDias == vigenciaDias;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (nombre.hashCode) +
    (precio.hashCode) +
    (unidad.hashCode) +
    (unidades.hashCode) +
    (vigenciaDias.hashCode);

  @override
  String toString() => 'TipoRequest[nombre=$nombre, precio=$precio, unidad=$unidad, unidades=$unidades, vigenciaDias=$vigenciaDias]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'nombre'] = this.nombre;
      json[r'precio'] = this.precio;
      json[r'unidad'] = this.unidad;
      json[r'unidades'] = this.unidades;
      json[r'vigenciaDias'] = this.vigenciaDias;
    return json;
  }

  /// Returns a new [TipoRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TipoRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'nombre'), 'Required key "TipoRequest[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "TipoRequest[nombre]" has a null value in JSON.');
        assert(json.containsKey(r'precio'), 'Required key "TipoRequest[precio]" is missing from JSON.');
        assert(json[r'precio'] != null, 'Required key "TipoRequest[precio]" has a null value in JSON.');
        assert(json.containsKey(r'unidad'), 'Required key "TipoRequest[unidad]" is missing from JSON.');
        assert(json[r'unidad'] != null, 'Required key "TipoRequest[unidad]" has a null value in JSON.');
        assert(json.containsKey(r'unidades'), 'Required key "TipoRequest[unidades]" is missing from JSON.');
        assert(json[r'unidades'] != null, 'Required key "TipoRequest[unidades]" has a null value in JSON.');
        assert(json.containsKey(r'vigenciaDias'), 'Required key "TipoRequest[vigenciaDias]" is missing from JSON.');
        assert(json[r'vigenciaDias'] != null, 'Required key "TipoRequest[vigenciaDias]" has a null value in JSON.');
        return true;
      }());

      return TipoRequest(
        nombre: mapValueOfType<String>(json, r'nombre')!,
        precio: num.parse('${json[r'precio']}'),
        unidad: mapValueOfType<String>(json, r'unidad')!,
        unidades: num.parse('${json[r'unidades']}'),
        vigenciaDias: num.parse('${json[r'vigenciaDias']}'),
      );
    }
    return null;
  }

  static List<TipoRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TipoRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TipoRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TipoRequest> mapFromJson(dynamic json) {
    final map = <String, TipoRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TipoRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TipoRequest-objects as value to a dart map
  static Map<String, List<TipoRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TipoRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TipoRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'nombre',
    'precio',
    'unidad',
    'unidades',
    'vigenciaDias',
  };
}

