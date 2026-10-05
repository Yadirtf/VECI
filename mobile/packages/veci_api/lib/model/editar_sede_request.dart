//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class EditarSedeRequest {
  /// Returns a new [EditarSedeRequest] instance.
  EditarSedeRequest({
    this.activa,
    this.direccion,
    this.municipioId,
    this.nombre,
  });

  /// false desactiva la sede; true la reabre
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? activa;

  String? direccion;

  num? municipioId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? nombre;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EditarSedeRequest &&
    other.activa == activa &&
    other.direccion == direccion &&
    other.municipioId == municipioId &&
    other.nombre == nombre;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (activa == null ? 0 : activa!.hashCode) +
    (direccion == null ? 0 : direccion!.hashCode) +
    (municipioId == null ? 0 : municipioId!.hashCode) +
    (nombre == null ? 0 : nombre!.hashCode);

  @override
  String toString() => 'EditarSedeRequest[activa=$activa, direccion=$direccion, municipioId=$municipioId, nombre=$nombre]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.activa != null) {
      json[r'activa'] = this.activa;
    } else {
      json[r'activa'] = null;
    }
    if (this.direccion != null) {
      json[r'direccion'] = this.direccion;
    } else {
      json[r'direccion'] = null;
    }
    if (this.municipioId != null) {
      json[r'municipioId'] = this.municipioId;
    } else {
      json[r'municipioId'] = null;
    }
    if (this.nombre != null) {
      json[r'nombre'] = this.nombre;
    } else {
      json[r'nombre'] = null;
    }
    return json;
  }

  /// Returns a new [EditarSedeRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EditarSedeRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        return true;
      }());

      return EditarSedeRequest(
        activa: mapValueOfType<bool>(json, r'activa'),
        direccion: mapValueOfType<String>(json, r'direccion'),
        municipioId: json[r'municipioId'] == null
            ? null
            : num.parse('${json[r'municipioId']}'),
        nombre: mapValueOfType<String>(json, r'nombre'),
      );
    }
    return null;
  }

  static List<EditarSedeRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EditarSedeRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EditarSedeRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EditarSedeRequest> mapFromJson(dynamic json) {
    final map = <String, EditarSedeRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EditarSedeRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EditarSedeRequest-objects as value to a dart map
  static Map<String, List<EditarSedeRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EditarSedeRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EditarSedeRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

