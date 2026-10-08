//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class SaldoResponse {
  /// Returns a new [SaldoResponse] instance.
  SaldoResponse({
    required this.disponibles,
    required this.proximoVencimiento,
    required this.tiqueteras,
    required this.ultimoDia,
    required this.unidad,
  });

  num disponibles;

  /// Vencimiento de la que se gasta primero
  DateTime proximoVencimiento;

  /// Tiqueteras vigentes que suman ese saldo
  num tiqueteras;

  String ultimoDia;

  UnidadResponse unidad;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SaldoResponse &&
    other.disponibles == disponibles &&
    other.proximoVencimiento == proximoVencimiento &&
    other.tiqueteras == tiqueteras &&
    other.ultimoDia == ultimoDia &&
    other.unidad == unidad;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (disponibles.hashCode) +
    (proximoVencimiento.hashCode) +
    (tiqueteras.hashCode) +
    (ultimoDia.hashCode) +
    (unidad.hashCode);

  @override
  String toString() => 'SaldoResponse[disponibles=$disponibles, proximoVencimiento=$proximoVencimiento, tiqueteras=$tiqueteras, ultimoDia=$ultimoDia, unidad=$unidad]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'disponibles'] = this.disponibles;
      json[r'proximoVencimiento'] = this.proximoVencimiento.toUtc().toIso8601String();
      json[r'tiqueteras'] = this.tiqueteras;
      json[r'ultimoDia'] = this.ultimoDia;
      json[r'unidad'] = this.unidad;
    return json;
  }

  /// Returns a new [SaldoResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SaldoResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'disponibles'), 'Required key "SaldoResponse[disponibles]" is missing from JSON.');
        assert(json[r'disponibles'] != null, 'Required key "SaldoResponse[disponibles]" has a null value in JSON.');
        assert(json.containsKey(r'proximoVencimiento'), 'Required key "SaldoResponse[proximoVencimiento]" is missing from JSON.');
        assert(json[r'proximoVencimiento'] != null, 'Required key "SaldoResponse[proximoVencimiento]" has a null value in JSON.');
        assert(json.containsKey(r'tiqueteras'), 'Required key "SaldoResponse[tiqueteras]" is missing from JSON.');
        assert(json[r'tiqueteras'] != null, 'Required key "SaldoResponse[tiqueteras]" has a null value in JSON.');
        assert(json.containsKey(r'ultimoDia'), 'Required key "SaldoResponse[ultimoDia]" is missing from JSON.');
        assert(json[r'ultimoDia'] != null, 'Required key "SaldoResponse[ultimoDia]" has a null value in JSON.');
        assert(json.containsKey(r'unidad'), 'Required key "SaldoResponse[unidad]" is missing from JSON.');
        assert(json[r'unidad'] != null, 'Required key "SaldoResponse[unidad]" has a null value in JSON.');
        return true;
      }());

      return SaldoResponse(
        disponibles: num.parse('${json[r'disponibles']}'),
        proximoVencimiento: mapDateTime(json, r'proximoVencimiento', r'')!,
        tiqueteras: num.parse('${json[r'tiqueteras']}'),
        ultimoDia: mapValueOfType<String>(json, r'ultimoDia')!,
        unidad: UnidadResponse.fromJson(json[r'unidad'])!,
      );
    }
    return null;
  }

  static List<SaldoResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SaldoResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SaldoResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SaldoResponse> mapFromJson(dynamic json) {
    final map = <String, SaldoResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SaldoResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SaldoResponse-objects as value to a dart map
  static Map<String, List<SaldoResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SaldoResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SaldoResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'disponibles',
    'proximoVencimiento',
    'tiqueteras',
    'ultimoDia',
    'unidad',
  };
}

