//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class EditarHorarioRequest {
  /// Returns a new [EditarHorarioRequest] instance.
  EditarHorarioRequest({
    required this.horaFin,
    required this.horaInicio,
  });

  String horaFin;

  String horaInicio;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EditarHorarioRequest &&
    other.horaFin == horaFin &&
    other.horaInicio == horaInicio;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (horaFin.hashCode) +
    (horaInicio.hashCode);

  @override
  String toString() => 'EditarHorarioRequest[horaFin=$horaFin, horaInicio=$horaInicio]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'horaFin'] = this.horaFin;
      json[r'horaInicio'] = this.horaInicio;
    return json;
  }

  /// Returns a new [EditarHorarioRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EditarHorarioRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'horaFin'), 'Required key "EditarHorarioRequest[horaFin]" is missing from JSON.');
        assert(json[r'horaFin'] != null, 'Required key "EditarHorarioRequest[horaFin]" has a null value in JSON.');
        assert(json.containsKey(r'horaInicio'), 'Required key "EditarHorarioRequest[horaInicio]" is missing from JSON.');
        assert(json[r'horaInicio'] != null, 'Required key "EditarHorarioRequest[horaInicio]" has a null value in JSON.');
        return true;
      }());

      return EditarHorarioRequest(
        horaFin: mapValueOfType<String>(json, r'horaFin')!,
        horaInicio: mapValueOfType<String>(json, r'horaInicio')!,
      );
    }
    return null;
  }

  static List<EditarHorarioRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EditarHorarioRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EditarHorarioRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EditarHorarioRequest> mapFromJson(dynamic json) {
    final map = <String, EditarHorarioRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EditarHorarioRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EditarHorarioRequest-objects as value to a dart map
  static Map<String, List<EditarHorarioRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EditarHorarioRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EditarHorarioRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'horaFin',
    'horaInicio',
  };
}

