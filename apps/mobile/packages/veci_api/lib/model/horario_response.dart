//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class HorarioResponse {
  /// Returns a new [HorarioResponse] instance.
  HorarioResponse({
    required this.dia,
    required this.horaFin,
    required this.horaInicio,
    required this.id,
    required this.sedeId,
    required this.servicioId,
    this.servicioNombre,
  });

  String dia;

  String horaFin;

  String horaInicio;

  String id;

  String sedeId;

  String servicioId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? servicioNombre;

  @override
  bool operator ==(Object other) => identical(this, other) || other is HorarioResponse &&
    other.dia == dia &&
    other.horaFin == horaFin &&
    other.horaInicio == horaInicio &&
    other.id == id &&
    other.sedeId == sedeId &&
    other.servicioId == servicioId &&
    other.servicioNombre == servicioNombre;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (dia.hashCode) +
    (horaFin.hashCode) +
    (horaInicio.hashCode) +
    (id.hashCode) +
    (sedeId.hashCode) +
    (servicioId.hashCode) +
    (servicioNombre == null ? 0 : servicioNombre!.hashCode);

  @override
  String toString() => 'HorarioResponse[dia=$dia, horaFin=$horaFin, horaInicio=$horaInicio, id=$id, sedeId=$sedeId, servicioId=$servicioId, servicioNombre=$servicioNombre]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'dia'] = this.dia;
      json[r'horaFin'] = this.horaFin;
      json[r'horaInicio'] = this.horaInicio;
      json[r'id'] = this.id;
      json[r'sedeId'] = this.sedeId;
      json[r'servicioId'] = this.servicioId;
    if (this.servicioNombre != null) {
      json[r'servicioNombre'] = this.servicioNombre;
    } else {
      json[r'servicioNombre'] = null;
    }
    return json;
  }

  /// Returns a new [HorarioResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static HorarioResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'dia'), 'Required key "HorarioResponse[dia]" is missing from JSON.');
        assert(json[r'dia'] != null, 'Required key "HorarioResponse[dia]" has a null value in JSON.');
        assert(json.containsKey(r'horaFin'), 'Required key "HorarioResponse[horaFin]" is missing from JSON.');
        assert(json[r'horaFin'] != null, 'Required key "HorarioResponse[horaFin]" has a null value in JSON.');
        assert(json.containsKey(r'horaInicio'), 'Required key "HorarioResponse[horaInicio]" is missing from JSON.');
        assert(json[r'horaInicio'] != null, 'Required key "HorarioResponse[horaInicio]" has a null value in JSON.');
        assert(json.containsKey(r'id'), 'Required key "HorarioResponse[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "HorarioResponse[id]" has a null value in JSON.');
        assert(json.containsKey(r'sedeId'), 'Required key "HorarioResponse[sedeId]" is missing from JSON.');
        assert(json[r'sedeId'] != null, 'Required key "HorarioResponse[sedeId]" has a null value in JSON.');
        assert(json.containsKey(r'servicioId'), 'Required key "HorarioResponse[servicioId]" is missing from JSON.');
        assert(json[r'servicioId'] != null, 'Required key "HorarioResponse[servicioId]" has a null value in JSON.');
        return true;
      }());

      return HorarioResponse(
        dia: mapValueOfType<String>(json, r'dia')!,
        horaFin: mapValueOfType<String>(json, r'horaFin')!,
        horaInicio: mapValueOfType<String>(json, r'horaInicio')!,
        id: mapValueOfType<String>(json, r'id')!,
        sedeId: mapValueOfType<String>(json, r'sedeId')!,
        servicioId: mapValueOfType<String>(json, r'servicioId')!,
        servicioNombre: mapValueOfType<String>(json, r'servicioNombre'),
      );
    }
    return null;
  }

  static List<HorarioResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <HorarioResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = HorarioResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, HorarioResponse> mapFromJson(dynamic json) {
    final map = <String, HorarioResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = HorarioResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of HorarioResponse-objects as value to a dart map
  static Map<String, List<HorarioResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<HorarioResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = HorarioResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'dia',
    'horaFin',
    'horaInicio',
    'id',
    'sedeId',
    'servicioId',
  };
}

