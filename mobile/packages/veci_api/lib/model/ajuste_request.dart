//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class AjusteRequest {
  /// Returns a new [AjusteRequest] instance.
  AjusteRequest({
    required this.motivo,
    this.nota,
    required this.unidades,
  });

  /// Código de la lista de motivos
  String motivo;

  /// Obligatoria con \"Otro\"
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? nota;

  /// Unidades que suma (+) o quita (-), sin cero
  num unidades;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AjusteRequest &&
    other.motivo == motivo &&
    other.nota == nota &&
    other.unidades == unidades;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (motivo.hashCode) +
    (nota == null ? 0 : nota!.hashCode) +
    (unidades.hashCode);

  @override
  String toString() => 'AjusteRequest[motivo=$motivo, nota=$nota, unidades=$unidades]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'motivo'] = this.motivo;
    if (this.nota != null) {
      json[r'nota'] = this.nota;
    } else {
      json[r'nota'] = null;
    }
      json[r'unidades'] = this.unidades;
    return json;
  }

  /// Returns a new [AjusteRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AjusteRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'motivo'), 'Required key "AjusteRequest[motivo]" is missing from JSON.');
        assert(json[r'motivo'] != null, 'Required key "AjusteRequest[motivo]" has a null value in JSON.');
        assert(json.containsKey(r'unidades'), 'Required key "AjusteRequest[unidades]" is missing from JSON.');
        assert(json[r'unidades'] != null, 'Required key "AjusteRequest[unidades]" has a null value in JSON.');
        return true;
      }());

      return AjusteRequest(
        motivo: mapValueOfType<String>(json, r'motivo')!,
        nota: mapValueOfType<String>(json, r'nota'),
        unidades: num.parse('${json[r'unidades']}'),
      );
    }
    return null;
  }

  static List<AjusteRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AjusteRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AjusteRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AjusteRequest> mapFromJson(dynamic json) {
    final map = <String, AjusteRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AjusteRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AjusteRequest-objects as value to a dart map
  static Map<String, List<AjusteRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AjusteRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AjusteRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'motivo',
    'unidades',
  };
}

