//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class PropietarioInvitadoRequest {
  /// Returns a new [PropietarioInvitadoRequest] instance.
  PropietarioInvitadoRequest({
    this.apellidos,
    required this.celular,
    required this.nombres,
    required this.numeroDocumento,
    required this.tipoDocumento,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? apellidos;

  String celular;

  String nombres;

  String numeroDocumento;

  String tipoDocumento;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PropietarioInvitadoRequest &&
    other.apellidos == apellidos &&
    other.celular == celular &&
    other.nombres == nombres &&
    other.numeroDocumento == numeroDocumento &&
    other.tipoDocumento == tipoDocumento;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (apellidos == null ? 0 : apellidos!.hashCode) +
    (celular.hashCode) +
    (nombres.hashCode) +
    (numeroDocumento.hashCode) +
    (tipoDocumento.hashCode);

  @override
  String toString() => 'PropietarioInvitadoRequest[apellidos=$apellidos, celular=$celular, nombres=$nombres, numeroDocumento=$numeroDocumento, tipoDocumento=$tipoDocumento]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.apellidos != null) {
      json[r'apellidos'] = this.apellidos;
    } else {
      json[r'apellidos'] = null;
    }
      json[r'celular'] = this.celular;
      json[r'nombres'] = this.nombres;
      json[r'numeroDocumento'] = this.numeroDocumento;
      json[r'tipoDocumento'] = this.tipoDocumento;
    return json;
  }

  /// Returns a new [PropietarioInvitadoRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PropietarioInvitadoRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'celular'), 'Required key "PropietarioInvitadoRequest[celular]" is missing from JSON.');
        assert(json[r'celular'] != null, 'Required key "PropietarioInvitadoRequest[celular]" has a null value in JSON.');
        assert(json.containsKey(r'nombres'), 'Required key "PropietarioInvitadoRequest[nombres]" is missing from JSON.');
        assert(json[r'nombres'] != null, 'Required key "PropietarioInvitadoRequest[nombres]" has a null value in JSON.');
        assert(json.containsKey(r'numeroDocumento'), 'Required key "PropietarioInvitadoRequest[numeroDocumento]" is missing from JSON.');
        assert(json[r'numeroDocumento'] != null, 'Required key "PropietarioInvitadoRequest[numeroDocumento]" has a null value in JSON.');
        assert(json.containsKey(r'tipoDocumento'), 'Required key "PropietarioInvitadoRequest[tipoDocumento]" is missing from JSON.');
        assert(json[r'tipoDocumento'] != null, 'Required key "PropietarioInvitadoRequest[tipoDocumento]" has a null value in JSON.');
        return true;
      }());

      return PropietarioInvitadoRequest(
        apellidos: mapValueOfType<String>(json, r'apellidos'),
        celular: mapValueOfType<String>(json, r'celular')!,
        nombres: mapValueOfType<String>(json, r'nombres')!,
        numeroDocumento: mapValueOfType<String>(json, r'numeroDocumento')!,
        tipoDocumento: mapValueOfType<String>(json, r'tipoDocumento')!,
      );
    }
    return null;
  }

  static List<PropietarioInvitadoRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PropietarioInvitadoRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PropietarioInvitadoRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PropietarioInvitadoRequest> mapFromJson(dynamic json) {
    final map = <String, PropietarioInvitadoRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PropietarioInvitadoRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PropietarioInvitadoRequest-objects as value to a dart map
  static Map<String, List<PropietarioInvitadoRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PropietarioInvitadoRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PropietarioInvitadoRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'celular',
    'nombres',
    'numeroDocumento',
    'tipoDocumento',
  };
}

