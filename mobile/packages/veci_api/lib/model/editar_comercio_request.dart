//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class EditarComercioRequest {
  /// Returns a new [EditarComercioRequest] instance.
  EditarComercioRequest({
    this.celular,
    this.correo,
    this.logoUrl,
    this.nombre,
    this.tipoNegocio,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? celular;

  /// null lo quita
  String? correo;

  /// null lo quita
  String? logoUrl;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? nombre;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? tipoNegocio;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EditarComercioRequest &&
    other.celular == celular &&
    other.correo == correo &&
    other.logoUrl == logoUrl &&
    other.nombre == nombre &&
    other.tipoNegocio == tipoNegocio;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (celular == null ? 0 : celular!.hashCode) +
    (correo == null ? 0 : correo!.hashCode) +
    (logoUrl == null ? 0 : logoUrl!.hashCode) +
    (nombre == null ? 0 : nombre!.hashCode) +
    (tipoNegocio == null ? 0 : tipoNegocio!.hashCode);

  @override
  String toString() => 'EditarComercioRequest[celular=$celular, correo=$correo, logoUrl=$logoUrl, nombre=$nombre, tipoNegocio=$tipoNegocio]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.celular != null) {
      json[r'celular'] = this.celular;
    } else {
      json[r'celular'] = null;
    }
    if (this.correo != null) {
      json[r'correo'] = this.correo;
    } else {
      json[r'correo'] = null;
    }
    if (this.logoUrl != null) {
      json[r'logoUrl'] = this.logoUrl;
    } else {
      json[r'logoUrl'] = null;
    }
    if (this.nombre != null) {
      json[r'nombre'] = this.nombre;
    } else {
      json[r'nombre'] = null;
    }
    if (this.tipoNegocio != null) {
      json[r'tipoNegocio'] = this.tipoNegocio;
    } else {
      json[r'tipoNegocio'] = null;
    }
    return json;
  }

  /// Returns a new [EditarComercioRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EditarComercioRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        return true;
      }());

      return EditarComercioRequest(
        celular: mapValueOfType<String>(json, r'celular'),
        correo: mapValueOfType<String>(json, r'correo'),
        logoUrl: mapValueOfType<String>(json, r'logoUrl'),
        nombre: mapValueOfType<String>(json, r'nombre'),
        tipoNegocio: mapValueOfType<String>(json, r'tipoNegocio'),
      );
    }
    return null;
  }

  static List<EditarComercioRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EditarComercioRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EditarComercioRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EditarComercioRequest> mapFromJson(dynamic json) {
    final map = <String, EditarComercioRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EditarComercioRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EditarComercioRequest-objects as value to a dart map
  static Map<String, List<EditarComercioRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EditarComercioRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EditarComercioRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

