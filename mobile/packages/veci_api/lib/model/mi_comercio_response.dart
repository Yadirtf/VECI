//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class MiComercioResponse {
  /// Returns a new [MiComercioResponse] instance.
  MiComercioResponse({
    required this.afiliadoEn,
    required this.comercioId,
    required this.nombre,
    this.qr,
    required this.tipoNegocio,
  });

  DateTime afiliadoEn;

  String comercioId;

  String nombre;

  QrEnComercioResponse? qr;

  String tipoNegocio;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MiComercioResponse &&
    other.afiliadoEn == afiliadoEn &&
    other.comercioId == comercioId &&
    other.nombre == nombre &&
    other.qr == qr &&
    other.tipoNegocio == tipoNegocio;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (afiliadoEn.hashCode) +
    (comercioId.hashCode) +
    (nombre.hashCode) +
    (qr == null ? 0 : qr!.hashCode) +
    (tipoNegocio.hashCode);

  @override
  String toString() => 'MiComercioResponse[afiliadoEn=$afiliadoEn, comercioId=$comercioId, nombre=$nombre, qr=$qr, tipoNegocio=$tipoNegocio]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'afiliadoEn'] = this.afiliadoEn.toUtc().toIso8601String();
      json[r'comercioId'] = this.comercioId;
      json[r'nombre'] = this.nombre;
    if (this.qr != null) {
      json[r'qr'] = this.qr;
    } else {
      json[r'qr'] = null;
    }
      json[r'tipoNegocio'] = this.tipoNegocio;
    return json;
  }

  /// Returns a new [MiComercioResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MiComercioResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'afiliadoEn'), 'Required key "MiComercioResponse[afiliadoEn]" is missing from JSON.');
        assert(json[r'afiliadoEn'] != null, 'Required key "MiComercioResponse[afiliadoEn]" has a null value in JSON.');
        assert(json.containsKey(r'comercioId'), 'Required key "MiComercioResponse[comercioId]" is missing from JSON.');
        assert(json[r'comercioId'] != null, 'Required key "MiComercioResponse[comercioId]" has a null value in JSON.');
        assert(json.containsKey(r'nombre'), 'Required key "MiComercioResponse[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "MiComercioResponse[nombre]" has a null value in JSON.');
        assert(json.containsKey(r'tipoNegocio'), 'Required key "MiComercioResponse[tipoNegocio]" is missing from JSON.');
        assert(json[r'tipoNegocio'] != null, 'Required key "MiComercioResponse[tipoNegocio]" has a null value in JSON.');
        return true;
      }());

      return MiComercioResponse(
        afiliadoEn: mapDateTime(json, r'afiliadoEn', r'')!,
        comercioId: mapValueOfType<String>(json, r'comercioId')!,
        nombre: mapValueOfType<String>(json, r'nombre')!,
        qr: QrEnComercioResponse.fromJson(json[r'qr']),
        tipoNegocio: mapValueOfType<String>(json, r'tipoNegocio')!,
      );
    }
    return null;
  }

  static List<MiComercioResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MiComercioResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MiComercioResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MiComercioResponse> mapFromJson(dynamic json) {
    final map = <String, MiComercioResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MiComercioResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MiComercioResponse-objects as value to a dart map
  static Map<String, List<MiComercioResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MiComercioResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MiComercioResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'afiliadoEn',
    'comercioId',
    'nombre',
    'tipoNegocio',
  };
}

