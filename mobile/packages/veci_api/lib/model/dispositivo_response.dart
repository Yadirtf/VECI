//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class DispositivoResponse {
  /// Returns a new [DispositivoResponse] instance.
  DispositivoResponse({
    required this.dispositivoId,
    this.nombre,
    required this.plataforma,
    required this.registradoEn,
    this.sesiones = const [],
    required this.ultimaVez,
  });

  String dispositivoId;

  String? nombre;

  String plataforma;

  DateTime registradoEn;

  List<SesionEnDispositivoResponse> sesiones;

  DateTime ultimaVez;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DispositivoResponse &&
    other.dispositivoId == dispositivoId &&
    other.nombre == nombre &&
    other.plataforma == plataforma &&
    other.registradoEn == registradoEn &&
    _deepEquality.equals(other.sesiones, sesiones) &&
    other.ultimaVez == ultimaVez;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (dispositivoId.hashCode) +
    (nombre == null ? 0 : nombre!.hashCode) +
    (plataforma.hashCode) +
    (registradoEn.hashCode) +
    (sesiones.hashCode) +
    (ultimaVez.hashCode);

  @override
  String toString() => 'DispositivoResponse[dispositivoId=$dispositivoId, nombre=$nombre, plataforma=$plataforma, registradoEn=$registradoEn, sesiones=$sesiones, ultimaVez=$ultimaVez]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'dispositivoId'] = this.dispositivoId;
    if (this.nombre != null) {
      json[r'nombre'] = this.nombre;
    } else {
      json[r'nombre'] = null;
    }
      json[r'plataforma'] = this.plataforma;
      json[r'registradoEn'] = this.registradoEn.toUtc().toIso8601String();
      json[r'sesiones'] = this.sesiones;
      json[r'ultimaVez'] = this.ultimaVez.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [DispositivoResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DispositivoResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'dispositivoId'), 'Required key "DispositivoResponse[dispositivoId]" is missing from JSON.');
        assert(json[r'dispositivoId'] != null, 'Required key "DispositivoResponse[dispositivoId]" has a null value in JSON.');
        assert(json.containsKey(r'plataforma'), 'Required key "DispositivoResponse[plataforma]" is missing from JSON.');
        assert(json[r'plataforma'] != null, 'Required key "DispositivoResponse[plataforma]" has a null value in JSON.');
        assert(json.containsKey(r'registradoEn'), 'Required key "DispositivoResponse[registradoEn]" is missing from JSON.');
        assert(json[r'registradoEn'] != null, 'Required key "DispositivoResponse[registradoEn]" has a null value in JSON.');
        assert(json.containsKey(r'sesiones'), 'Required key "DispositivoResponse[sesiones]" is missing from JSON.');
        assert(json[r'sesiones'] != null, 'Required key "DispositivoResponse[sesiones]" has a null value in JSON.');
        assert(json.containsKey(r'ultimaVez'), 'Required key "DispositivoResponse[ultimaVez]" is missing from JSON.');
        assert(json[r'ultimaVez'] != null, 'Required key "DispositivoResponse[ultimaVez]" has a null value in JSON.');
        return true;
      }());

      return DispositivoResponse(
        dispositivoId: mapValueOfType<String>(json, r'dispositivoId')!,
        nombre: mapValueOfType<String>(json, r'nombre'),
        plataforma: mapValueOfType<String>(json, r'plataforma')!,
        registradoEn: mapDateTime(json, r'registradoEn', r'')!,
        sesiones: SesionEnDispositivoResponse.listFromJson(json[r'sesiones']),
        ultimaVez: mapDateTime(json, r'ultimaVez', r'')!,
      );
    }
    return null;
  }

  static List<DispositivoResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DispositivoResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DispositivoResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DispositivoResponse> mapFromJson(dynamic json) {
    final map = <String, DispositivoResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DispositivoResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DispositivoResponse-objects as value to a dart map
  static Map<String, List<DispositivoResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DispositivoResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DispositivoResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'dispositivoId',
    'plataforma',
    'registradoEn',
    'sesiones',
    'ultimaVez',
  };
}

