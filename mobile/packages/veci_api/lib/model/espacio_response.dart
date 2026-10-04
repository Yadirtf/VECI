//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class EspacioResponse {
  /// Returns a new [EspacioResponse] instance.
  EspacioResponse({
    required this.comercioId,
    required this.invitacionPendiente,
    required this.nombre,
    this.roles = const [],
    required this.tipoNegocio,
  });

  String comercioId;

  /// Lo invitaron como cajero y aún no ha entrado a este negocio
  bool invitacionPendiente;

  String nombre;

  /// OWNER, CASHIER o CUSTOMER
  List<String> roles;

  /// Código del tipo de negocio
  String tipoNegocio;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EspacioResponse &&
    other.comercioId == comercioId &&
    other.invitacionPendiente == invitacionPendiente &&
    other.nombre == nombre &&
    _deepEquality.equals(other.roles, roles) &&
    other.tipoNegocio == tipoNegocio;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (comercioId.hashCode) +
    (invitacionPendiente.hashCode) +
    (nombre.hashCode) +
    (roles.hashCode) +
    (tipoNegocio.hashCode);

  @override
  String toString() => 'EspacioResponse[comercioId=$comercioId, invitacionPendiente=$invitacionPendiente, nombre=$nombre, roles=$roles, tipoNegocio=$tipoNegocio]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'comercioId'] = this.comercioId;
      json[r'invitacionPendiente'] = this.invitacionPendiente;
      json[r'nombre'] = this.nombre;
      json[r'roles'] = this.roles;
      json[r'tipoNegocio'] = this.tipoNegocio;
    return json;
  }

  /// Returns a new [EspacioResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EspacioResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'comercioId'), 'Required key "EspacioResponse[comercioId]" is missing from JSON.');
        assert(json[r'comercioId'] != null, 'Required key "EspacioResponse[comercioId]" has a null value in JSON.');
        assert(json.containsKey(r'invitacionPendiente'), 'Required key "EspacioResponse[invitacionPendiente]" is missing from JSON.');
        assert(json[r'invitacionPendiente'] != null, 'Required key "EspacioResponse[invitacionPendiente]" has a null value in JSON.');
        assert(json.containsKey(r'nombre'), 'Required key "EspacioResponse[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "EspacioResponse[nombre]" has a null value in JSON.');
        assert(json.containsKey(r'roles'), 'Required key "EspacioResponse[roles]" is missing from JSON.');
        assert(json[r'roles'] != null, 'Required key "EspacioResponse[roles]" has a null value in JSON.');
        assert(json.containsKey(r'tipoNegocio'), 'Required key "EspacioResponse[tipoNegocio]" is missing from JSON.');
        assert(json[r'tipoNegocio'] != null, 'Required key "EspacioResponse[tipoNegocio]" has a null value in JSON.');
        return true;
      }());

      return EspacioResponse(
        comercioId: mapValueOfType<String>(json, r'comercioId')!,
        invitacionPendiente: mapValueOfType<bool>(json, r'invitacionPendiente')!,
        nombre: mapValueOfType<String>(json, r'nombre')!,
        roles: json[r'roles'] is Iterable
            ? (json[r'roles'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        tipoNegocio: mapValueOfType<String>(json, r'tipoNegocio')!,
      );
    }
    return null;
  }

  static List<EspacioResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EspacioResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EspacioResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EspacioResponse> mapFromJson(dynamic json) {
    final map = <String, EspacioResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EspacioResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EspacioResponse-objects as value to a dart map
  static Map<String, List<EspacioResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EspacioResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EspacioResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'comercioId',
    'invitacionPendiente',
    'nombre',
    'roles',
    'tipoNegocio',
  };
}

