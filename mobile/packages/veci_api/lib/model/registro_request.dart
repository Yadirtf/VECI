//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class RegistroRequest {
  /// Returns a new [RegistroRequest] instance.
  RegistroRequest({
    this.apellidos,
    required this.celular,
    required this.dispositivo,
    required this.nombres,
    required this.numeroDocumento,
    required this.pin,
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

  /// Celular como lo escribe la persona
  String celular;

  DispositivoRequest dispositivo;

  String nombres;

  String numeroDocumento;

  String pin;

  /// Versión de la política que la persona aceptó
  String politicaVersionId;

  /// Código del tipo de documento (catálogo)
  String tipoDocumento;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RegistroRequest &&
    other.apellidos == apellidos &&
    other.celular == celular &&
    other.dispositivo == dispositivo &&
    other.nombres == nombres &&
    other.numeroDocumento == numeroDocumento &&
    other.pin == pin &&
    other.politicaVersionId == politicaVersionId &&
    other.tipoDocumento == tipoDocumento;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (apellidos == null ? 0 : apellidos!.hashCode) +
    (celular.hashCode) +
    (dispositivo.hashCode) +
    (nombres.hashCode) +
    (numeroDocumento.hashCode) +
    (pin.hashCode) +
    (politicaVersionId.hashCode) +
    (tipoDocumento.hashCode);

  @override
  String toString() => 'RegistroRequest[apellidos=$apellidos, celular=$celular, dispositivo=$dispositivo, nombres=$nombres, numeroDocumento=$numeroDocumento, pin=$pin, politicaVersionId=$politicaVersionId, tipoDocumento=$tipoDocumento]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.apellidos != null) {
      json[r'apellidos'] = this.apellidos;
    } else {
      json[r'apellidos'] = null;
    }
      json[r'celular'] = this.celular;
      json[r'dispositivo'] = this.dispositivo;
      json[r'nombres'] = this.nombres;
      json[r'numeroDocumento'] = this.numeroDocumento;
      json[r'pin'] = this.pin;
      json[r'politicaVersionId'] = this.politicaVersionId;
      json[r'tipoDocumento'] = this.tipoDocumento;
    return json;
  }

  /// Returns a new [RegistroRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RegistroRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'celular'), 'Required key "RegistroRequest[celular]" is missing from JSON.');
        assert(json[r'celular'] != null, 'Required key "RegistroRequest[celular]" has a null value in JSON.');
        assert(json.containsKey(r'dispositivo'), 'Required key "RegistroRequest[dispositivo]" is missing from JSON.');
        assert(json[r'dispositivo'] != null, 'Required key "RegistroRequest[dispositivo]" has a null value in JSON.');
        assert(json.containsKey(r'nombres'), 'Required key "RegistroRequest[nombres]" is missing from JSON.');
        assert(json[r'nombres'] != null, 'Required key "RegistroRequest[nombres]" has a null value in JSON.');
        assert(json.containsKey(r'numeroDocumento'), 'Required key "RegistroRequest[numeroDocumento]" is missing from JSON.');
        assert(json[r'numeroDocumento'] != null, 'Required key "RegistroRequest[numeroDocumento]" has a null value in JSON.');
        assert(json.containsKey(r'pin'), 'Required key "RegistroRequest[pin]" is missing from JSON.');
        assert(json[r'pin'] != null, 'Required key "RegistroRequest[pin]" has a null value in JSON.');
        assert(json.containsKey(r'politicaVersionId'), 'Required key "RegistroRequest[politicaVersionId]" is missing from JSON.');
        assert(json[r'politicaVersionId'] != null, 'Required key "RegistroRequest[politicaVersionId]" has a null value in JSON.');
        assert(json.containsKey(r'tipoDocumento'), 'Required key "RegistroRequest[tipoDocumento]" is missing from JSON.');
        assert(json[r'tipoDocumento'] != null, 'Required key "RegistroRequest[tipoDocumento]" has a null value in JSON.');
        return true;
      }());

      return RegistroRequest(
        apellidos: mapValueOfType<String>(json, r'apellidos'),
        celular: mapValueOfType<String>(json, r'celular')!,
        dispositivo: DispositivoRequest.fromJson(json[r'dispositivo'])!,
        nombres: mapValueOfType<String>(json, r'nombres')!,
        numeroDocumento: mapValueOfType<String>(json, r'numeroDocumento')!,
        pin: mapValueOfType<String>(json, r'pin')!,
        politicaVersionId: mapValueOfType<String>(json, r'politicaVersionId')!,
        tipoDocumento: mapValueOfType<String>(json, r'tipoDocumento')!,
      );
    }
    return null;
  }

  static List<RegistroRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RegistroRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RegistroRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RegistroRequest> mapFromJson(dynamic json) {
    final map = <String, RegistroRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RegistroRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RegistroRequest-objects as value to a dart map
  static Map<String, List<RegistroRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RegistroRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RegistroRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'celular',
    'dispositivo',
    'nombres',
    'numeroDocumento',
    'pin',
    'politicaVersionId',
    'tipoDocumento',
  };
}

