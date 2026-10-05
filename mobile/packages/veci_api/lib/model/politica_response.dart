//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class PoliticaResponse {
  /// Returns a new [PoliticaResponse] instance.
  PoliticaResponse({
    required this.enCorto,
    required this.huella,
    required this.id,
    required this.publicadaEn,
    this.secciones = const [],
    required this.version,
  });

  EnCortoResponse enCorto;

  /// SHA-256 del contenido, en hexadecimal
  String huella;

  /// Se envía al aceptar
  String id;

  DateTime publicadaEn;

  List<SeccionPoliticaResponse> secciones;

  String version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PoliticaResponse &&
    other.enCorto == enCorto &&
    other.huella == huella &&
    other.id == id &&
    other.publicadaEn == publicadaEn &&
    _deepEquality.equals(other.secciones, secciones) &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (enCorto.hashCode) +
    (huella.hashCode) +
    (id.hashCode) +
    (publicadaEn.hashCode) +
    (secciones.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'PoliticaResponse[enCorto=$enCorto, huella=$huella, id=$id, publicadaEn=$publicadaEn, secciones=$secciones, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'enCorto'] = this.enCorto;
      json[r'huella'] = this.huella;
      json[r'id'] = this.id;
      json[r'publicadaEn'] = this.publicadaEn.toUtc().toIso8601String();
      json[r'secciones'] = this.secciones;
      json[r'version'] = this.version;
    return json;
  }

  /// Returns a new [PoliticaResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PoliticaResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'enCorto'), 'Required key "PoliticaResponse[enCorto]" is missing from JSON.');
        assert(json[r'enCorto'] != null, 'Required key "PoliticaResponse[enCorto]" has a null value in JSON.');
        assert(json.containsKey(r'huella'), 'Required key "PoliticaResponse[huella]" is missing from JSON.');
        assert(json[r'huella'] != null, 'Required key "PoliticaResponse[huella]" has a null value in JSON.');
        assert(json.containsKey(r'id'), 'Required key "PoliticaResponse[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "PoliticaResponse[id]" has a null value in JSON.');
        assert(json.containsKey(r'publicadaEn'), 'Required key "PoliticaResponse[publicadaEn]" is missing from JSON.');
        assert(json[r'publicadaEn'] != null, 'Required key "PoliticaResponse[publicadaEn]" has a null value in JSON.');
        assert(json.containsKey(r'secciones'), 'Required key "PoliticaResponse[secciones]" is missing from JSON.');
        assert(json[r'secciones'] != null, 'Required key "PoliticaResponse[secciones]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "PoliticaResponse[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "PoliticaResponse[version]" has a null value in JSON.');
        return true;
      }());

      return PoliticaResponse(
        enCorto: EnCortoResponse.fromJson(json[r'enCorto'])!,
        huella: mapValueOfType<String>(json, r'huella')!,
        id: mapValueOfType<String>(json, r'id')!,
        publicadaEn: mapDateTime(json, r'publicadaEn', r'')!,
        secciones: SeccionPoliticaResponse.listFromJson(json[r'secciones']),
        version: mapValueOfType<String>(json, r'version')!,
      );
    }
    return null;
  }

  static List<PoliticaResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PoliticaResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PoliticaResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PoliticaResponse> mapFromJson(dynamic json) {
    final map = <String, PoliticaResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PoliticaResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PoliticaResponse-objects as value to a dart map
  static Map<String, List<PoliticaResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PoliticaResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PoliticaResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'enCorto',
    'huella',
    'id',
    'publicadaEn',
    'secciones',
    'version',
  };
}

