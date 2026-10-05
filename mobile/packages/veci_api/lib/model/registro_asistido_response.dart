//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class RegistroAsistidoResponse {
  /// Returns a new [RegistroAsistidoResponse] instance.
  RegistroAsistidoResponse({
    required this.cliente,
    this.pinBienvenida,
    required this.vinculado,
  });

  ClienteResponse cliente;

  /// Se muestra una sola vez para dictárselo. Sirve 7 días.
  String? pinBienvenida;

  /// Ya estaba en VECI y solo se afilió
  bool vinculado;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RegistroAsistidoResponse &&
    other.cliente == cliente &&
    other.pinBienvenida == pinBienvenida &&
    other.vinculado == vinculado;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (cliente.hashCode) +
    (pinBienvenida == null ? 0 : pinBienvenida!.hashCode) +
    (vinculado.hashCode);

  @override
  String toString() => 'RegistroAsistidoResponse[cliente=$cliente, pinBienvenida=$pinBienvenida, vinculado=$vinculado]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'cliente'] = this.cliente;
    if (this.pinBienvenida != null) {
      json[r'pinBienvenida'] = this.pinBienvenida;
    } else {
      json[r'pinBienvenida'] = null;
    }
      json[r'vinculado'] = this.vinculado;
    return json;
  }

  /// Returns a new [RegistroAsistidoResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RegistroAsistidoResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'cliente'), 'Required key "RegistroAsistidoResponse[cliente]" is missing from JSON.');
        assert(json[r'cliente'] != null, 'Required key "RegistroAsistidoResponse[cliente]" has a null value in JSON.');
        assert(json.containsKey(r'vinculado'), 'Required key "RegistroAsistidoResponse[vinculado]" is missing from JSON.');
        assert(json[r'vinculado'] != null, 'Required key "RegistroAsistidoResponse[vinculado]" has a null value in JSON.');
        return true;
      }());

      return RegistroAsistidoResponse(
        cliente: ClienteResponse.fromJson(json[r'cliente'])!,
        pinBienvenida: mapValueOfType<String>(json, r'pinBienvenida'),
        vinculado: mapValueOfType<bool>(json, r'vinculado')!,
      );
    }
    return null;
  }

  static List<RegistroAsistidoResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RegistroAsistidoResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RegistroAsistidoResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RegistroAsistidoResponse> mapFromJson(dynamic json) {
    final map = <String, RegistroAsistidoResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RegistroAsistidoResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RegistroAsistidoResponse-objects as value to a dart map
  static Map<String, List<RegistroAsistidoResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RegistroAsistidoResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RegistroAsistidoResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'cliente',
    'vinculado',
  };
}

