//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class SesionResponse {
  /// Returns a new [SesionResponse] instance.
  SesionResponse({
    this.espacios = const [],
    required this.segundosAcceso,
    required this.tokenAcceso,
    required this.tokenRenovacion,
    required this.usuario,
  });

  List<EspacioResponse> espacios;

  num segundosAcceso;

  /// Va en Authorization: Bearer. Dura 15 minutos.
  String tokenAcceso;

  /// Se cambia por uno nuevo en cada renovación; guárdelo seguro.
  String tokenRenovacion;

  UsuarioResponse usuario;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SesionResponse &&
    _deepEquality.equals(other.espacios, espacios) &&
    other.segundosAcceso == segundosAcceso &&
    other.tokenAcceso == tokenAcceso &&
    other.tokenRenovacion == tokenRenovacion &&
    other.usuario == usuario;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (espacios.hashCode) +
    (segundosAcceso.hashCode) +
    (tokenAcceso.hashCode) +
    (tokenRenovacion.hashCode) +
    (usuario.hashCode);

  @override
  String toString() => 'SesionResponse[espacios=$espacios, segundosAcceso=$segundosAcceso, tokenAcceso=$tokenAcceso, tokenRenovacion=$tokenRenovacion, usuario=$usuario]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'espacios'] = this.espacios;
      json[r'segundosAcceso'] = this.segundosAcceso;
      json[r'tokenAcceso'] = this.tokenAcceso;
      json[r'tokenRenovacion'] = this.tokenRenovacion;
      json[r'usuario'] = this.usuario;
    return json;
  }

  /// Returns a new [SesionResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SesionResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'espacios'), 'Required key "SesionResponse[espacios]" is missing from JSON.');
        assert(json[r'espacios'] != null, 'Required key "SesionResponse[espacios]" has a null value in JSON.');
        assert(json.containsKey(r'segundosAcceso'), 'Required key "SesionResponse[segundosAcceso]" is missing from JSON.');
        assert(json[r'segundosAcceso'] != null, 'Required key "SesionResponse[segundosAcceso]" has a null value in JSON.');
        assert(json.containsKey(r'tokenAcceso'), 'Required key "SesionResponse[tokenAcceso]" is missing from JSON.');
        assert(json[r'tokenAcceso'] != null, 'Required key "SesionResponse[tokenAcceso]" has a null value in JSON.');
        assert(json.containsKey(r'tokenRenovacion'), 'Required key "SesionResponse[tokenRenovacion]" is missing from JSON.');
        assert(json[r'tokenRenovacion'] != null, 'Required key "SesionResponse[tokenRenovacion]" has a null value in JSON.');
        assert(json.containsKey(r'usuario'), 'Required key "SesionResponse[usuario]" is missing from JSON.');
        assert(json[r'usuario'] != null, 'Required key "SesionResponse[usuario]" has a null value in JSON.');
        return true;
      }());

      return SesionResponse(
        espacios: EspacioResponse.listFromJson(json[r'espacios']),
        segundosAcceso: num.parse('${json[r'segundosAcceso']}'),
        tokenAcceso: mapValueOfType<String>(json, r'tokenAcceso')!,
        tokenRenovacion: mapValueOfType<String>(json, r'tokenRenovacion')!,
        usuario: UsuarioResponse.fromJson(json[r'usuario'])!,
      );
    }
    return null;
  }

  static List<SesionResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SesionResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SesionResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SesionResponse> mapFromJson(dynamic json) {
    final map = <String, SesionResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SesionResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SesionResponse-objects as value to a dart map
  static Map<String, List<SesionResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SesionResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SesionResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'espacios',
    'segundosAcceso',
    'tokenAcceso',
    'tokenRenovacion',
    'usuario',
  };
}

