//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class VentaResumenResponse {
  /// Returns a new [VentaResumenResponse] instance.
  VentaResumenResponse({
    this.cajero,
    required this.cliente,
    required this.clienteId,
    required this.estado,
    required this.ocurridaEn,
    required this.origen,
    required this.pago,
    required this.precio,
    required this.saldo,
    required this.tiquetera,
    required this.ventaId,
  });

  String? cajero;

  String cliente;

  String clienteId;

  VentaResumenResponseEstadoEnum estado;

  DateTime ocurridaEn;

  VentaResumenResponseOrigenEnum origen;

  PagoResponse pago;

  num precio;

  /// Unidades que le quedan a esa tiquetera
  num saldo;

  String tiquetera;

  String ventaId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is VentaResumenResponse &&
    other.cajero == cajero &&
    other.cliente == cliente &&
    other.clienteId == clienteId &&
    other.estado == estado &&
    other.ocurridaEn == ocurridaEn &&
    other.origen == origen &&
    other.pago == pago &&
    other.precio == precio &&
    other.saldo == saldo &&
    other.tiquetera == tiquetera &&
    other.ventaId == ventaId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (cajero == null ? 0 : cajero!.hashCode) +
    (cliente.hashCode) +
    (clienteId.hashCode) +
    (estado.hashCode) +
    (ocurridaEn.hashCode) +
    (origen.hashCode) +
    (pago.hashCode) +
    (precio.hashCode) +
    (saldo.hashCode) +
    (tiquetera.hashCode) +
    (ventaId.hashCode);

  @override
  String toString() => 'VentaResumenResponse[cajero=$cajero, cliente=$cliente, clienteId=$clienteId, estado=$estado, ocurridaEn=$ocurridaEn, origen=$origen, pago=$pago, precio=$precio, saldo=$saldo, tiquetera=$tiquetera, ventaId=$ventaId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.cajero != null) {
      json[r'cajero'] = this.cajero;
    } else {
      json[r'cajero'] = null;
    }
      json[r'cliente'] = this.cliente;
      json[r'clienteId'] = this.clienteId;
      json[r'estado'] = this.estado;
      json[r'ocurridaEn'] = this.ocurridaEn.toUtc().toIso8601String();
      json[r'origen'] = this.origen;
      json[r'pago'] = this.pago;
      json[r'precio'] = this.precio;
      json[r'saldo'] = this.saldo;
      json[r'tiquetera'] = this.tiquetera;
      json[r'ventaId'] = this.ventaId;
    return json;
  }

  /// Returns a new [VentaResumenResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static VentaResumenResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'cliente'), 'Required key "VentaResumenResponse[cliente]" is missing from JSON.');
        assert(json[r'cliente'] != null, 'Required key "VentaResumenResponse[cliente]" has a null value in JSON.');
        assert(json.containsKey(r'clienteId'), 'Required key "VentaResumenResponse[clienteId]" is missing from JSON.');
        assert(json[r'clienteId'] != null, 'Required key "VentaResumenResponse[clienteId]" has a null value in JSON.');
        assert(json.containsKey(r'estado'), 'Required key "VentaResumenResponse[estado]" is missing from JSON.');
        assert(json[r'estado'] != null, 'Required key "VentaResumenResponse[estado]" has a null value in JSON.');
        assert(json.containsKey(r'ocurridaEn'), 'Required key "VentaResumenResponse[ocurridaEn]" is missing from JSON.');
        assert(json[r'ocurridaEn'] != null, 'Required key "VentaResumenResponse[ocurridaEn]" has a null value in JSON.');
        assert(json.containsKey(r'origen'), 'Required key "VentaResumenResponse[origen]" is missing from JSON.');
        assert(json[r'origen'] != null, 'Required key "VentaResumenResponse[origen]" has a null value in JSON.');
        assert(json.containsKey(r'pago'), 'Required key "VentaResumenResponse[pago]" is missing from JSON.');
        assert(json[r'pago'] != null, 'Required key "VentaResumenResponse[pago]" has a null value in JSON.');
        assert(json.containsKey(r'precio'), 'Required key "VentaResumenResponse[precio]" is missing from JSON.');
        assert(json[r'precio'] != null, 'Required key "VentaResumenResponse[precio]" has a null value in JSON.');
        assert(json.containsKey(r'saldo'), 'Required key "VentaResumenResponse[saldo]" is missing from JSON.');
        assert(json[r'saldo'] != null, 'Required key "VentaResumenResponse[saldo]" has a null value in JSON.');
        assert(json.containsKey(r'tiquetera'), 'Required key "VentaResumenResponse[tiquetera]" is missing from JSON.');
        assert(json[r'tiquetera'] != null, 'Required key "VentaResumenResponse[tiquetera]" has a null value in JSON.');
        assert(json.containsKey(r'ventaId'), 'Required key "VentaResumenResponse[ventaId]" is missing from JSON.');
        assert(json[r'ventaId'] != null, 'Required key "VentaResumenResponse[ventaId]" has a null value in JSON.');
        return true;
      }());

      return VentaResumenResponse(
        cajero: mapValueOfType<String>(json, r'cajero'),
        cliente: mapValueOfType<String>(json, r'cliente')!,
        clienteId: mapValueOfType<String>(json, r'clienteId')!,
        estado: VentaResumenResponseEstadoEnum.fromJson(json[r'estado'])!,
        ocurridaEn: mapDateTime(json, r'ocurridaEn', r'')!,
        origen: VentaResumenResponseOrigenEnum.fromJson(json[r'origen'])!,
        pago: PagoResponse.fromJson(json[r'pago'])!,
        precio: num.parse('${json[r'precio']}'),
        saldo: num.parse('${json[r'saldo']}'),
        tiquetera: mapValueOfType<String>(json, r'tiquetera')!,
        ventaId: mapValueOfType<String>(json, r'ventaId')!,
      );
    }
    return null;
  }

  static List<VentaResumenResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <VentaResumenResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VentaResumenResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, VentaResumenResponse> mapFromJson(dynamic json) {
    final map = <String, VentaResumenResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = VentaResumenResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of VentaResumenResponse-objects as value to a dart map
  static Map<String, List<VentaResumenResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<VentaResumenResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = VentaResumenResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'cliente',
    'clienteId',
    'estado',
    'ocurridaEn',
    'origen',
    'pago',
    'precio',
    'saldo',
    'tiquetera',
    'ventaId',
  };
}


enum VentaResumenResponseEstadoEnum {
  COMPLETED._(r'COMPLETED'),
  VOIDED._(r'VOIDED'),
  ;

  /// Instantiate a new enum with the provided value.
  const VentaResumenResponseEstadoEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [VentaResumenResponseEstadoEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static VentaResumenResponseEstadoEnum? fromJson(dynamic value) => VentaResumenResponseEstadoEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [VentaResumenResponseEstadoEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<VentaResumenResponseEstadoEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <VentaResumenResponseEstadoEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VentaResumenResponseEstadoEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [VentaResumenResponseEstadoEnum] to String,
/// and [decode] dynamic data back to [VentaResumenResponseEstadoEnum].
class VentaResumenResponseEstadoEnumTypeTransformer {
  factory VentaResumenResponseEstadoEnumTypeTransformer() => _instance ??= const VentaResumenResponseEstadoEnumTypeTransformer._();

  const VentaResumenResponseEstadoEnumTypeTransformer._();

  String encode(VentaResumenResponseEstadoEnum data) => data._value;

  /// Returns the instance of [VentaResumenResponseEstadoEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  VentaResumenResponseEstadoEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is VentaResumenResponseEstadoEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'COMPLETED': return VentaResumenResponseEstadoEnum.COMPLETED;
        case r'VOIDED': return VentaResumenResponseEstadoEnum.VOIDED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static VentaResumenResponseEstadoEnumTypeTransformer? _instance;
}



enum VentaResumenResponseOrigenEnum {
  ONLINE._(r'ONLINE'),
  OFFLINE_SYNC._(r'OFFLINE_SYNC'),
  ;

  /// Instantiate a new enum with the provided value.
  const VentaResumenResponseOrigenEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [VentaResumenResponseOrigenEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static VentaResumenResponseOrigenEnum? fromJson(dynamic value) => VentaResumenResponseOrigenEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [VentaResumenResponseOrigenEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<VentaResumenResponseOrigenEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <VentaResumenResponseOrigenEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VentaResumenResponseOrigenEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [VentaResumenResponseOrigenEnum] to String,
/// and [decode] dynamic data back to [VentaResumenResponseOrigenEnum].
class VentaResumenResponseOrigenEnumTypeTransformer {
  factory VentaResumenResponseOrigenEnumTypeTransformer() => _instance ??= const VentaResumenResponseOrigenEnumTypeTransformer._();

  const VentaResumenResponseOrigenEnumTypeTransformer._();

  String encode(VentaResumenResponseOrigenEnum data) => data._value;

  /// Returns the instance of [VentaResumenResponseOrigenEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  VentaResumenResponseOrigenEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is VentaResumenResponseOrigenEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'ONLINE': return VentaResumenResponseOrigenEnum.ONLINE;
        case r'OFFLINE_SYNC': return VentaResumenResponseOrigenEnum.OFFLINE_SYNC;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static VentaResumenResponseOrigenEnumTypeTransformer? _instance;
}


