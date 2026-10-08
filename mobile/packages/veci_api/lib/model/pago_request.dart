//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class PagoRequest {
  /// Returns a new [PagoRequest] instance.
  PagoRequest({
    this.canal,
    required this.medio,
    this.referencia,
  });

  /// Obligatorio en transferencias
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? canal;

  /// Código del medio de pago
  String medio;

  /// Referencia de la transferencia
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? referencia;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PagoRequest &&
    other.canal == canal &&
    other.medio == medio &&
    other.referencia == referencia;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (canal == null ? 0 : canal!.hashCode) +
    (medio.hashCode) +
    (referencia == null ? 0 : referencia!.hashCode);

  @override
  String toString() => 'PagoRequest[canal=$canal, medio=$medio, referencia=$referencia]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.canal != null) {
      json[r'canal'] = this.canal;
    } else {
      json[r'canal'] = null;
    }
      json[r'medio'] = this.medio;
    if (this.referencia != null) {
      json[r'referencia'] = this.referencia;
    } else {
      json[r'referencia'] = null;
    }
    return json;
  }

  /// Returns a new [PagoRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PagoRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'medio'), 'Required key "PagoRequest[medio]" is missing from JSON.');
        assert(json[r'medio'] != null, 'Required key "PagoRequest[medio]" has a null value in JSON.');
        return true;
      }());

      return PagoRequest(
        canal: mapValueOfType<String>(json, r'canal'),
        medio: mapValueOfType<String>(json, r'medio')!,
        referencia: mapValueOfType<String>(json, r'referencia'),
      );
    }
    return null;
  }

  static List<PagoRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PagoRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PagoRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PagoRequest> mapFromJson(dynamic json) {
    final map = <String, PagoRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PagoRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PagoRequest-objects as value to a dart map
  static Map<String, List<PagoRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PagoRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PagoRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'medio',
  };
}

