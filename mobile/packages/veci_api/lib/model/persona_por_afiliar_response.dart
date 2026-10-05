//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class PersonaPorAfiliarResponse {
  /// Returns a new [PersonaPorAfiliarResponse] instance.
  PersonaPorAfiliarResponse({
    this.clienteId,
    required this.documento,
    required this.nombre,
    required this.personaId,
  });

  String? clienteId;

  String documento;

  String nombre;

  String personaId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PersonaPorAfiliarResponse &&
    other.clienteId == clienteId &&
    other.documento == documento &&
    other.nombre == nombre &&
    other.personaId == personaId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (clienteId == null ? 0 : clienteId!.hashCode) +
    (documento.hashCode) +
    (nombre.hashCode) +
    (personaId.hashCode);

  @override
  String toString() => 'PersonaPorAfiliarResponse[clienteId=$clienteId, documento=$documento, nombre=$nombre, personaId=$personaId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.clienteId != null) {
      json[r'clienteId'] = this.clienteId;
    } else {
      json[r'clienteId'] = null;
    }
      json[r'documento'] = this.documento;
      json[r'nombre'] = this.nombre;
      json[r'personaId'] = this.personaId;
    return json;
  }

  /// Returns a new [PersonaPorAfiliarResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PersonaPorAfiliarResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'documento'), 'Required key "PersonaPorAfiliarResponse[documento]" is missing from JSON.');
        assert(json[r'documento'] != null, 'Required key "PersonaPorAfiliarResponse[documento]" has a null value in JSON.');
        assert(json.containsKey(r'nombre'), 'Required key "PersonaPorAfiliarResponse[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "PersonaPorAfiliarResponse[nombre]" has a null value in JSON.');
        assert(json.containsKey(r'personaId'), 'Required key "PersonaPorAfiliarResponse[personaId]" is missing from JSON.');
        assert(json[r'personaId'] != null, 'Required key "PersonaPorAfiliarResponse[personaId]" has a null value in JSON.');
        return true;
      }());

      return PersonaPorAfiliarResponse(
        clienteId: mapValueOfType<String>(json, r'clienteId'),
        documento: mapValueOfType<String>(json, r'documento')!,
        nombre: mapValueOfType<String>(json, r'nombre')!,
        personaId: mapValueOfType<String>(json, r'personaId')!,
      );
    }
    return null;
  }

  static List<PersonaPorAfiliarResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PersonaPorAfiliarResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PersonaPorAfiliarResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PersonaPorAfiliarResponse> mapFromJson(dynamic json) {
    final map = <String, PersonaPorAfiliarResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PersonaPorAfiliarResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PersonaPorAfiliarResponse-objects as value to a dart map
  static Map<String, List<PersonaPorAfiliarResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PersonaPorAfiliarResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PersonaPorAfiliarResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'documento',
    'nombre',
    'personaId',
  };
}

