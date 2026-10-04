//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class IngresoConPinRequest {
  /// Returns a new [IngresoConPinRequest] instance.
  IngresoConPinRequest({
    required this.celular,
    required this.dispositivo,
    required this.pin,
  });

  /// Celular como lo escribe la persona
  String celular;

  DispositivoRequest dispositivo;

  String pin;

  @override
  bool operator ==(Object other) => identical(this, other) || other is IngresoConPinRequest &&
    other.celular == celular &&
    other.dispositivo == dispositivo &&
    other.pin == pin;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (celular.hashCode) +
    (dispositivo.hashCode) +
    (pin.hashCode);

  @override
  String toString() => 'IngresoConPinRequest[celular=$celular, dispositivo=$dispositivo, pin=$pin]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'celular'] = this.celular;
      json[r'dispositivo'] = this.dispositivo;
      json[r'pin'] = this.pin;
    return json;
  }

  /// Returns a new [IngresoConPinRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static IngresoConPinRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'celular'), 'Required key "IngresoConPinRequest[celular]" is missing from JSON.');
        assert(json[r'celular'] != null, 'Required key "IngresoConPinRequest[celular]" has a null value in JSON.');
        assert(json.containsKey(r'dispositivo'), 'Required key "IngresoConPinRequest[dispositivo]" is missing from JSON.');
        assert(json[r'dispositivo'] != null, 'Required key "IngresoConPinRequest[dispositivo]" has a null value in JSON.');
        assert(json.containsKey(r'pin'), 'Required key "IngresoConPinRequest[pin]" is missing from JSON.');
        assert(json[r'pin'] != null, 'Required key "IngresoConPinRequest[pin]" has a null value in JSON.');
        return true;
      }());

      return IngresoConPinRequest(
        celular: mapValueOfType<String>(json, r'celular')!,
        dispositivo: DispositivoRequest.fromJson(json[r'dispositivo'])!,
        pin: mapValueOfType<String>(json, r'pin')!,
      );
    }
    return null;
  }

  static List<IngresoConPinRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <IngresoConPinRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = IngresoConPinRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, IngresoConPinRequest> mapFromJson(dynamic json) {
    final map = <String, IngresoConPinRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = IngresoConPinRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of IngresoConPinRequest-objects as value to a dart map
  static Map<String, List<IngresoConPinRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<IngresoConPinRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = IngresoConPinRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'celular',
    'dispositivo',
    'pin',
  };
}

