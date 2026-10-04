//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class RestablecerPinClienteRequest {
  /// Returns a new [RestablecerPinClienteRequest] instance.
  RestablecerPinClienteRequest({
    required this.celular,
    required this.numeroDocumento,
    required this.tipoDocumento,
  });

  String celular;

  /// El que dice la persona por teléfono
  String numeroDocumento;

  String tipoDocumento;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RestablecerPinClienteRequest &&
    other.celular == celular &&
    other.numeroDocumento == numeroDocumento &&
    other.tipoDocumento == tipoDocumento;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (celular.hashCode) +
    (numeroDocumento.hashCode) +
    (tipoDocumento.hashCode);

  @override
  String toString() => 'RestablecerPinClienteRequest[celular=$celular, numeroDocumento=$numeroDocumento, tipoDocumento=$tipoDocumento]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'celular'] = this.celular;
      json[r'numeroDocumento'] = this.numeroDocumento;
      json[r'tipoDocumento'] = this.tipoDocumento;
    return json;
  }

  /// Returns a new [RestablecerPinClienteRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RestablecerPinClienteRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'celular'), 'Required key "RestablecerPinClienteRequest[celular]" is missing from JSON.');
        assert(json[r'celular'] != null, 'Required key "RestablecerPinClienteRequest[celular]" has a null value in JSON.');
        assert(json.containsKey(r'numeroDocumento'), 'Required key "RestablecerPinClienteRequest[numeroDocumento]" is missing from JSON.');
        assert(json[r'numeroDocumento'] != null, 'Required key "RestablecerPinClienteRequest[numeroDocumento]" has a null value in JSON.');
        assert(json.containsKey(r'tipoDocumento'), 'Required key "RestablecerPinClienteRequest[tipoDocumento]" is missing from JSON.');
        assert(json[r'tipoDocumento'] != null, 'Required key "RestablecerPinClienteRequest[tipoDocumento]" has a null value in JSON.');
        return true;
      }());

      return RestablecerPinClienteRequest(
        celular: mapValueOfType<String>(json, r'celular')!,
        numeroDocumento: mapValueOfType<String>(json, r'numeroDocumento')!,
        tipoDocumento: mapValueOfType<String>(json, r'tipoDocumento')!,
      );
    }
    return null;
  }

  static List<RestablecerPinClienteRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RestablecerPinClienteRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RestablecerPinClienteRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RestablecerPinClienteRequest> mapFromJson(dynamic json) {
    final map = <String, RestablecerPinClienteRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RestablecerPinClienteRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RestablecerPinClienteRequest-objects as value to a dart map
  static Map<String, List<RestablecerPinClienteRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RestablecerPinClienteRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RestablecerPinClienteRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'celular',
    'numeroDocumento',
    'tipoDocumento',
  };
}

