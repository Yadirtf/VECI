//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class VentaRequest {
  /// Returns a new [VentaRequest] instance.
  VentaRequest({
    required this.clienteId,
    this.ocurridaEn,
    required this.pago,
    required this.precio,
    this.sinConexion = false,
    required this.tipoId,
    required this.ventaId,
  });

  String clienteId;

  /// Hora real de la venta hecha sin conexión
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? ocurridaEn;

  PagoRequest pago;

  /// Lo que se le cobró al cliente
  num precio;

  /// Se hizo sin señal y llega después: se respeta el precio y la hora de la caja
  bool sinConexion;

  String tipoId;

  /// UUID v7 que genera la caja: reenviar la misma venta no la duplica
  String ventaId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is VentaRequest &&
    other.clienteId == clienteId &&
    other.ocurridaEn == ocurridaEn &&
    other.pago == pago &&
    other.precio == precio &&
    other.sinConexion == sinConexion &&
    other.tipoId == tipoId &&
    other.ventaId == ventaId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (clienteId.hashCode) +
    (ocurridaEn == null ? 0 : ocurridaEn!.hashCode) +
    (pago.hashCode) +
    (precio.hashCode) +
    (sinConexion.hashCode) +
    (tipoId.hashCode) +
    (ventaId.hashCode);

  @override
  String toString() => 'VentaRequest[clienteId=$clienteId, ocurridaEn=$ocurridaEn, pago=$pago, precio=$precio, sinConexion=$sinConexion, tipoId=$tipoId, ventaId=$ventaId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'clienteId'] = this.clienteId;
    if (this.ocurridaEn != null) {
      json[r'ocurridaEn'] = this.ocurridaEn!.toUtc().toIso8601String();
    } else {
      json[r'ocurridaEn'] = null;
    }
      json[r'pago'] = this.pago;
      json[r'precio'] = this.precio;
      json[r'sinConexion'] = this.sinConexion;
      json[r'tipoId'] = this.tipoId;
      json[r'ventaId'] = this.ventaId;
    return json;
  }

  /// Returns a new [VentaRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static VentaRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'clienteId'), 'Required key "VentaRequest[clienteId]" is missing from JSON.');
        assert(json[r'clienteId'] != null, 'Required key "VentaRequest[clienteId]" has a null value in JSON.');
        assert(json.containsKey(r'pago'), 'Required key "VentaRequest[pago]" is missing from JSON.');
        assert(json[r'pago'] != null, 'Required key "VentaRequest[pago]" has a null value in JSON.');
        assert(json.containsKey(r'precio'), 'Required key "VentaRequest[precio]" is missing from JSON.');
        assert(json[r'precio'] != null, 'Required key "VentaRequest[precio]" has a null value in JSON.');
        assert(json.containsKey(r'tipoId'), 'Required key "VentaRequest[tipoId]" is missing from JSON.');
        assert(json[r'tipoId'] != null, 'Required key "VentaRequest[tipoId]" has a null value in JSON.');
        assert(json.containsKey(r'ventaId'), 'Required key "VentaRequest[ventaId]" is missing from JSON.');
        assert(json[r'ventaId'] != null, 'Required key "VentaRequest[ventaId]" has a null value in JSON.');
        return true;
      }());

      return VentaRequest(
        clienteId: mapValueOfType<String>(json, r'clienteId')!,
        ocurridaEn: mapDateTime(json, r'ocurridaEn', r''),
        pago: PagoRequest.fromJson(json[r'pago'])!,
        precio: num.parse('${json[r'precio']}'),
        sinConexion: mapValueOfType<bool>(json, r'sinConexion') ?? false,
        tipoId: mapValueOfType<String>(json, r'tipoId')!,
        ventaId: mapValueOfType<String>(json, r'ventaId')!,
      );
    }
    return null;
  }

  static List<VentaRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <VentaRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VentaRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, VentaRequest> mapFromJson(dynamic json) {
    final map = <String, VentaRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = VentaRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of VentaRequest-objects as value to a dart map
  static Map<String, List<VentaRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<VentaRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = VentaRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'clienteId',
    'pago',
    'precio',
    'tipoId',
    'ventaId',
  };
}

