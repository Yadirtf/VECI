//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class SeccionPoliticaResponse {
  /// Returns a new [SeccionPoliticaResponse] instance.
  SeccionPoliticaResponse({
    required this.enPalabrasDeVecino,
    required this.texto,
    required this.titulo,
  });

  String enPalabrasDeVecino;

  String texto;

  String titulo;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SeccionPoliticaResponse &&
    other.enPalabrasDeVecino == enPalabrasDeVecino &&
    other.texto == texto &&
    other.titulo == titulo;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (enPalabrasDeVecino.hashCode) +
    (texto.hashCode) +
    (titulo.hashCode);

  @override
  String toString() => 'SeccionPoliticaResponse[enPalabrasDeVecino=$enPalabrasDeVecino, texto=$texto, titulo=$titulo]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'enPalabrasDeVecino'] = this.enPalabrasDeVecino;
      json[r'texto'] = this.texto;
      json[r'titulo'] = this.titulo;
    return json;
  }

  /// Returns a new [SeccionPoliticaResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SeccionPoliticaResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'enPalabrasDeVecino'), 'Required key "SeccionPoliticaResponse[enPalabrasDeVecino]" is missing from JSON.');
        assert(json[r'enPalabrasDeVecino'] != null, 'Required key "SeccionPoliticaResponse[enPalabrasDeVecino]" has a null value in JSON.');
        assert(json.containsKey(r'texto'), 'Required key "SeccionPoliticaResponse[texto]" is missing from JSON.');
        assert(json[r'texto'] != null, 'Required key "SeccionPoliticaResponse[texto]" has a null value in JSON.');
        assert(json.containsKey(r'titulo'), 'Required key "SeccionPoliticaResponse[titulo]" is missing from JSON.');
        assert(json[r'titulo'] != null, 'Required key "SeccionPoliticaResponse[titulo]" has a null value in JSON.');
        return true;
      }());

      return SeccionPoliticaResponse(
        enPalabrasDeVecino: mapValueOfType<String>(json, r'enPalabrasDeVecino')!,
        texto: mapValueOfType<String>(json, r'texto')!,
        titulo: mapValueOfType<String>(json, r'titulo')!,
      );
    }
    return null;
  }

  static List<SeccionPoliticaResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SeccionPoliticaResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SeccionPoliticaResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SeccionPoliticaResponse> mapFromJson(dynamic json) {
    final map = <String, SeccionPoliticaResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SeccionPoliticaResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SeccionPoliticaResponse-objects as value to a dart map
  static Map<String, List<SeccionPoliticaResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SeccionPoliticaResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SeccionPoliticaResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'enPalabrasDeVecino',
    'texto',
    'titulo',
  };
}

