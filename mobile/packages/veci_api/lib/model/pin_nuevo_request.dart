//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class PinNuevoRequest {
  /// Returns a new [PinNuevoRequest] instance.
  PinNuevoRequest({
    required this.dispositivo,
    required this.pinNuevo,
    required this.tokenCambio,
  });

  DispositivoRequest dispositivo;

  String pinNuevo;

  /// Token que entregó el ingreso con PIN temporal
  String tokenCambio;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PinNuevoRequest &&
    other.dispositivo == dispositivo &&
    other.pinNuevo == pinNuevo &&
    other.tokenCambio == tokenCambio;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (dispositivo.hashCode) +
    (pinNuevo.hashCode) +
    (tokenCambio.hashCode);

  @override
  String toString() => 'PinNuevoRequest[dispositivo=$dispositivo, pinNuevo=$pinNuevo, tokenCambio=$tokenCambio]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'dispositivo'] = this.dispositivo;
      json[r'pinNuevo'] = this.pinNuevo;
      json[r'tokenCambio'] = this.tokenCambio;
    return json;
  }

  /// Returns a new [PinNuevoRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PinNuevoRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'dispositivo'), 'Required key "PinNuevoRequest[dispositivo]" is missing from JSON.');
        assert(json[r'dispositivo'] != null, 'Required key "PinNuevoRequest[dispositivo]" has a null value in JSON.');
        assert(json.containsKey(r'pinNuevo'), 'Required key "PinNuevoRequest[pinNuevo]" is missing from JSON.');
        assert(json[r'pinNuevo'] != null, 'Required key "PinNuevoRequest[pinNuevo]" has a null value in JSON.');
        assert(json.containsKey(r'tokenCambio'), 'Required key "PinNuevoRequest[tokenCambio]" is missing from JSON.');
        assert(json[r'tokenCambio'] != null, 'Required key "PinNuevoRequest[tokenCambio]" has a null value in JSON.');
        return true;
      }());

      return PinNuevoRequest(
        dispositivo: DispositivoRequest.fromJson(json[r'dispositivo'])!,
        pinNuevo: mapValueOfType<String>(json, r'pinNuevo')!,
        tokenCambio: mapValueOfType<String>(json, r'tokenCambio')!,
      );
    }
    return null;
  }

  static List<PinNuevoRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PinNuevoRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PinNuevoRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PinNuevoRequest> mapFromJson(dynamic json) {
    final map = <String, PinNuevoRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PinNuevoRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PinNuevoRequest-objects as value to a dart map
  static Map<String, List<PinNuevoRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PinNuevoRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PinNuevoRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'dispositivo',
    'pinNuevo',
    'tokenCambio',
  };
}

