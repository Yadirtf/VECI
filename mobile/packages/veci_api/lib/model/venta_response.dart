//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class VentaResponse {
  /// Returns a new [VentaResponse] instance.
  VentaResponse({
    required this.clienteId,
    required this.origen,
    required this.repetida,
    this.saldos = const [],
    required this.tiquetera,
    this.tiqueteras = const [],
    required this.ventaId,
  });

  String clienteId;

  VentaResponseOrigenEnum origen;

  /// Ya había llegado: no se registró otra vez
  bool repetida;

  List<SaldoResponse> saldos;

  /// La tiquetera que se vendió
  TiqueteraResponse tiquetera;

  List<TiqueteraResponse> tiqueteras;

  String ventaId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is VentaResponse &&
    other.clienteId == clienteId &&
    other.origen == origen &&
    other.repetida == repetida &&
    _deepEquality.equals(other.saldos, saldos) &&
    other.tiquetera == tiquetera &&
    _deepEquality.equals(other.tiqueteras, tiqueteras) &&
    other.ventaId == ventaId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (clienteId.hashCode) +
    (origen.hashCode) +
    (repetida.hashCode) +
    (saldos.hashCode) +
    (tiquetera.hashCode) +
    (tiqueteras.hashCode) +
    (ventaId.hashCode);

  @override
  String toString() => 'VentaResponse[clienteId=$clienteId, origen=$origen, repetida=$repetida, saldos=$saldos, tiquetera=$tiquetera, tiqueteras=$tiqueteras, ventaId=$ventaId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'clienteId'] = this.clienteId;
      json[r'origen'] = this.origen;
      json[r'repetida'] = this.repetida;
      json[r'saldos'] = this.saldos;
      json[r'tiquetera'] = this.tiquetera;
      json[r'tiqueteras'] = this.tiqueteras;
      json[r'ventaId'] = this.ventaId;
    return json;
  }

  /// Returns a new [VentaResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static VentaResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'clienteId'), 'Required key "VentaResponse[clienteId]" is missing from JSON.');
        assert(json[r'clienteId'] != null, 'Required key "VentaResponse[clienteId]" has a null value in JSON.');
        assert(json.containsKey(r'origen'), 'Required key "VentaResponse[origen]" is missing from JSON.');
        assert(json[r'origen'] != null, 'Required key "VentaResponse[origen]" has a null value in JSON.');
        assert(json.containsKey(r'repetida'), 'Required key "VentaResponse[repetida]" is missing from JSON.');
        assert(json[r'repetida'] != null, 'Required key "VentaResponse[repetida]" has a null value in JSON.');
        assert(json.containsKey(r'saldos'), 'Required key "VentaResponse[saldos]" is missing from JSON.');
        assert(json[r'saldos'] != null, 'Required key "VentaResponse[saldos]" has a null value in JSON.');
        assert(json.containsKey(r'tiquetera'), 'Required key "VentaResponse[tiquetera]" is missing from JSON.');
        assert(json[r'tiquetera'] != null, 'Required key "VentaResponse[tiquetera]" has a null value in JSON.');
        assert(json.containsKey(r'tiqueteras'), 'Required key "VentaResponse[tiqueteras]" is missing from JSON.');
        assert(json[r'tiqueteras'] != null, 'Required key "VentaResponse[tiqueteras]" has a null value in JSON.');
        assert(json.containsKey(r'ventaId'), 'Required key "VentaResponse[ventaId]" is missing from JSON.');
        assert(json[r'ventaId'] != null, 'Required key "VentaResponse[ventaId]" has a null value in JSON.');
        return true;
      }());

      return VentaResponse(
        clienteId: mapValueOfType<String>(json, r'clienteId')!,
        origen: VentaResponseOrigenEnum.fromJson(json[r'origen'])!,
        repetida: mapValueOfType<bool>(json, r'repetida')!,
        saldos: SaldoResponse.listFromJson(json[r'saldos']),
        tiquetera: TiqueteraResponse.fromJson(json[r'tiquetera'])!,
        tiqueteras: TiqueteraResponse.listFromJson(json[r'tiqueteras']),
        ventaId: mapValueOfType<String>(json, r'ventaId')!,
      );
    }
    return null;
  }

  static List<VentaResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <VentaResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VentaResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, VentaResponse> mapFromJson(dynamic json) {
    final map = <String, VentaResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = VentaResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of VentaResponse-objects as value to a dart map
  static Map<String, List<VentaResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<VentaResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = VentaResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'clienteId',
    'origen',
    'repetida',
    'saldos',
    'tiquetera',
    'tiqueteras',
    'ventaId',
  };
}


enum VentaResponseOrigenEnum {
  ONLINE._(r'ONLINE'),
  OFFLINE_SYNC._(r'OFFLINE_SYNC'),
  ;

  /// Instantiate a new enum with the provided value.
  const VentaResponseOrigenEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [VentaResponseOrigenEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static VentaResponseOrigenEnum? fromJson(dynamic value) => VentaResponseOrigenEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [VentaResponseOrigenEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<VentaResponseOrigenEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <VentaResponseOrigenEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VentaResponseOrigenEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [VentaResponseOrigenEnum] to String,
/// and [decode] dynamic data back to [VentaResponseOrigenEnum].
class VentaResponseOrigenEnumTypeTransformer {
  factory VentaResponseOrigenEnumTypeTransformer() => _instance ??= const VentaResponseOrigenEnumTypeTransformer._();

  const VentaResponseOrigenEnumTypeTransformer._();

  String encode(VentaResponseOrigenEnum data) => data._value;

  /// Returns the instance of [VentaResponseOrigenEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  VentaResponseOrigenEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is VentaResponseOrigenEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'ONLINE': return VentaResponseOrigenEnum.ONLINE;
        case r'OFFLINE_SYNC': return VentaResponseOrigenEnum.OFFLINE_SYNC;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static VentaResponseOrigenEnumTypeTransformer? _instance;
}


