//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class RegistroAsistidoRequest {
  /// Returns a new [RegistroAsistidoRequest] instance.
  RegistroAsistidoRequest({
    this.apellidos,
    this.celular,
    this.celularCompartido = false,
    this.nombres,
    required this.numeroDocumento,
    required this.politicaVersionId,
    required this.tipoDocumento,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? apellidos;

  /// Solo si la persona es nueva
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? celular;

  /// El celular es de otra persona de la familia: queda solo de contacto
  bool celularCompartido;

  /// Solo si la persona es nueva
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? nombres;

  String numeroDocumento;

  /// Versión de la política que se le leyó y aceptó (confirmada por el cajero)
  String politicaVersionId;

  /// Código del tipo de documento (catálogo)
  String tipoDocumento;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RegistroAsistidoRequest &&
    other.apellidos == apellidos &&
    other.celular == celular &&
    other.celularCompartido == celularCompartido &&
    other.nombres == nombres &&
    other.numeroDocumento == numeroDocumento &&
    other.politicaVersionId == politicaVersionId &&
    other.tipoDocumento == tipoDocumento;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (apellidos == null ? 0 : apellidos!.hashCode) +
    (celular == null ? 0 : celular!.hashCode) +
    (celularCompartido.hashCode) +
    (nombres == null ? 0 : nombres!.hashCode) +
    (numeroDocumento.hashCode) +
    (politicaVersionId.hashCode) +
    (tipoDocumento.hashCode);

  @override
  String toString() => 'RegistroAsistidoRequest[apellidos=$apellidos, celular=$celular, celularCompartido=$celularCompartido, nombres=$nombres, numeroDocumento=$numeroDocumento, politicaVersionId=$politicaVersionId, tipoDocumento=$tipoDocumento]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.apellidos != null) {
      json[r'apellidos'] = this.apellidos;
    } else {
      json[r'apellidos'] = null;
    }
    if (this.celular != null) {
      json[r'celular'] = this.celular;
    } else {
      json[r'celular'] = null;
    }
      json[r'celularCompartido'] = this.celularCompartido;
    if (this.nombres != null) {
      json[r'nombres'] = this.nombres;
    } else {
      json[r'nombres'] = null;
    }
      json[r'numeroDocumento'] = this.numeroDocumento;
      json[r'politicaVersionId'] = this.politicaVersionId;
      json[r'tipoDocumento'] = this.tipoDocumento;
    return json;
  }

  /// Returns a new [RegistroAsistidoRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RegistroAsistidoRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'numeroDocumento'), 'Required key "RegistroAsistidoRequest[numeroDocumento]" is missing from JSON.');
        assert(json[r'numeroDocumento'] != null, 'Required key "RegistroAsistidoRequest[numeroDocumento]" has a null value in JSON.');
        assert(json.containsKey(r'politicaVersionId'), 'Required key "RegistroAsistidoRequest[politicaVersionId]" is missing from JSON.');
        assert(json[r'politicaVersionId'] != null, 'Required key "RegistroAsistidoRequest[politicaVersionId]" has a null value in JSON.');
        assert(json.containsKey(r'tipoDocumento'), 'Required key "RegistroAsistidoRequest[tipoDocumento]" is missing from JSON.');
        assert(json[r'tipoDocumento'] != null, 'Required key "RegistroAsistidoRequest[tipoDocumento]" has a null value in JSON.');
        return true;
      }());

      return RegistroAsistidoRequest(
        apellidos: mapValueOfType<String>(json, r'apellidos'),
        celular: mapValueOfType<String>(json, r'celular'),
        celularCompartido: mapValueOfType<bool>(json, r'celularCompartido') ?? false,
        nombres: mapValueOfType<String>(json, r'nombres'),
        numeroDocumento: mapValueOfType<String>(json, r'numeroDocumento')!,
        politicaVersionId: mapValueOfType<String>(json, r'politicaVersionId')!,
        tipoDocumento: mapValueOfType<String>(json, r'tipoDocumento')!,
      );
    }
    return null;
  }

  static List<RegistroAsistidoRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RegistroAsistidoRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RegistroAsistidoRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RegistroAsistidoRequest> mapFromJson(dynamic json) {
    final map = <String, RegistroAsistidoRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RegistroAsistidoRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RegistroAsistidoRequest-objects as value to a dart map
  static Map<String, List<RegistroAsistidoRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RegistroAsistidoRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RegistroAsistidoRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'numeroDocumento',
    'politicaVersionId',
    'tipoDocumento',
  };
}

