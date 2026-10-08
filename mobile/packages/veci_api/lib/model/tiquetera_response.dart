//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class TiqueteraResponse {
  /// Returns a new [TiqueteraResponse] instance.
  TiqueteraResponse({
    required this.clienteId,
    required this.compradaEn,
    required this.compradas,
    required this.estado,
    required this.nombre,
    this.precio,
    required this.saldo,
    required this.tipoId,
    required this.tiqueteraId,
    this.turno,
    required this.ultimoDia,
    required this.unidad,
    required this.venceEn,
    required this.ventaId,
    required this.vigente,
  });

  String clienteId;

  DateTime compradaEn;

  num compradas;

  TiqueteraResponseEstadoEnum estado;

  String nombre;

  /// Lo que se cobró; null en la app del cliente
  num? precio;

  num saldo;

  String tipoId;

  String tiqueteraId;

  /// 1 = la que se gasta primero (la que vence antes)
  num? turno;

  /// Último día en que sirve (fecha local)
  String ultimoDia;

  UnidadResponse unidad;

  /// Desde este instante ya no sirve
  DateTime venceEn;

  String ventaId;

  /// Tiene unidades y no ha vencido
  bool vigente;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TiqueteraResponse &&
    other.clienteId == clienteId &&
    other.compradaEn == compradaEn &&
    other.compradas == compradas &&
    other.estado == estado &&
    other.nombre == nombre &&
    other.precio == precio &&
    other.saldo == saldo &&
    other.tipoId == tipoId &&
    other.tiqueteraId == tiqueteraId &&
    other.turno == turno &&
    other.ultimoDia == ultimoDia &&
    other.unidad == unidad &&
    other.venceEn == venceEn &&
    other.ventaId == ventaId &&
    other.vigente == vigente;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (clienteId.hashCode) +
    (compradaEn.hashCode) +
    (compradas.hashCode) +
    (estado.hashCode) +
    (nombre.hashCode) +
    (precio == null ? 0 : precio!.hashCode) +
    (saldo.hashCode) +
    (tipoId.hashCode) +
    (tiqueteraId.hashCode) +
    (turno == null ? 0 : turno!.hashCode) +
    (ultimoDia.hashCode) +
    (unidad.hashCode) +
    (venceEn.hashCode) +
    (ventaId.hashCode) +
    (vigente.hashCode);

  @override
  String toString() => 'TiqueteraResponse[clienteId=$clienteId, compradaEn=$compradaEn, compradas=$compradas, estado=$estado, nombre=$nombre, precio=$precio, saldo=$saldo, tipoId=$tipoId, tiqueteraId=$tiqueteraId, turno=$turno, ultimoDia=$ultimoDia, unidad=$unidad, venceEn=$venceEn, ventaId=$ventaId, vigente=$vigente]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'clienteId'] = this.clienteId;
      json[r'compradaEn'] = this.compradaEn.toUtc().toIso8601String();
      json[r'compradas'] = this.compradas;
      json[r'estado'] = this.estado;
      json[r'nombre'] = this.nombre;
    if (this.precio != null) {
      json[r'precio'] = this.precio;
    } else {
      json[r'precio'] = null;
    }
      json[r'saldo'] = this.saldo;
      json[r'tipoId'] = this.tipoId;
      json[r'tiqueteraId'] = this.tiqueteraId;
    if (this.turno != null) {
      json[r'turno'] = this.turno;
    } else {
      json[r'turno'] = null;
    }
      json[r'ultimoDia'] = this.ultimoDia;
      json[r'unidad'] = this.unidad;
      json[r'venceEn'] = this.venceEn.toUtc().toIso8601String();
      json[r'ventaId'] = this.ventaId;
      json[r'vigente'] = this.vigente;
    return json;
  }

  /// Returns a new [TiqueteraResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TiqueteraResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'clienteId'), 'Required key "TiqueteraResponse[clienteId]" is missing from JSON.');
        assert(json[r'clienteId'] != null, 'Required key "TiqueteraResponse[clienteId]" has a null value in JSON.');
        assert(json.containsKey(r'compradaEn'), 'Required key "TiqueteraResponse[compradaEn]" is missing from JSON.');
        assert(json[r'compradaEn'] != null, 'Required key "TiqueteraResponse[compradaEn]" has a null value in JSON.');
        assert(json.containsKey(r'compradas'), 'Required key "TiqueteraResponse[compradas]" is missing from JSON.');
        assert(json[r'compradas'] != null, 'Required key "TiqueteraResponse[compradas]" has a null value in JSON.');
        assert(json.containsKey(r'estado'), 'Required key "TiqueteraResponse[estado]" is missing from JSON.');
        assert(json[r'estado'] != null, 'Required key "TiqueteraResponse[estado]" has a null value in JSON.');
        assert(json.containsKey(r'nombre'), 'Required key "TiqueteraResponse[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "TiqueteraResponse[nombre]" has a null value in JSON.');
        assert(json.containsKey(r'saldo'), 'Required key "TiqueteraResponse[saldo]" is missing from JSON.');
        assert(json[r'saldo'] != null, 'Required key "TiqueteraResponse[saldo]" has a null value in JSON.');
        assert(json.containsKey(r'tipoId'), 'Required key "TiqueteraResponse[tipoId]" is missing from JSON.');
        assert(json[r'tipoId'] != null, 'Required key "TiqueteraResponse[tipoId]" has a null value in JSON.');
        assert(json.containsKey(r'tiqueteraId'), 'Required key "TiqueteraResponse[tiqueteraId]" is missing from JSON.');
        assert(json[r'tiqueteraId'] != null, 'Required key "TiqueteraResponse[tiqueteraId]" has a null value in JSON.');
        assert(json.containsKey(r'ultimoDia'), 'Required key "TiqueteraResponse[ultimoDia]" is missing from JSON.');
        assert(json[r'ultimoDia'] != null, 'Required key "TiqueteraResponse[ultimoDia]" has a null value in JSON.');
        assert(json.containsKey(r'unidad'), 'Required key "TiqueteraResponse[unidad]" is missing from JSON.');
        assert(json[r'unidad'] != null, 'Required key "TiqueteraResponse[unidad]" has a null value in JSON.');
        assert(json.containsKey(r'venceEn'), 'Required key "TiqueteraResponse[venceEn]" is missing from JSON.');
        assert(json[r'venceEn'] != null, 'Required key "TiqueteraResponse[venceEn]" has a null value in JSON.');
        assert(json.containsKey(r'ventaId'), 'Required key "TiqueteraResponse[ventaId]" is missing from JSON.');
        assert(json[r'ventaId'] != null, 'Required key "TiqueteraResponse[ventaId]" has a null value in JSON.');
        assert(json.containsKey(r'vigente'), 'Required key "TiqueteraResponse[vigente]" is missing from JSON.');
        assert(json[r'vigente'] != null, 'Required key "TiqueteraResponse[vigente]" has a null value in JSON.');
        return true;
      }());

      return TiqueteraResponse(
        clienteId: mapValueOfType<String>(json, r'clienteId')!,
        compradaEn: mapDateTime(json, r'compradaEn', r'')!,
        compradas: num.parse('${json[r'compradas']}'),
        estado: TiqueteraResponseEstadoEnum.fromJson(json[r'estado'])!,
        nombre: mapValueOfType<String>(json, r'nombre')!,
        precio: json[r'precio'] == null
            ? null
            : num.parse('${json[r'precio']}'),
        saldo: num.parse('${json[r'saldo']}'),
        tipoId: mapValueOfType<String>(json, r'tipoId')!,
        tiqueteraId: mapValueOfType<String>(json, r'tiqueteraId')!,
        turno: json[r'turno'] == null
            ? null
            : num.parse('${json[r'turno']}'),
        ultimoDia: mapValueOfType<String>(json, r'ultimoDia')!,
        unidad: UnidadResponse.fromJson(json[r'unidad'])!,
        venceEn: mapDateTime(json, r'venceEn', r'')!,
        ventaId: mapValueOfType<String>(json, r'ventaId')!,
        vigente: mapValueOfType<bool>(json, r'vigente')!,
      );
    }
    return null;
  }

  static List<TiqueteraResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TiqueteraResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TiqueteraResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TiqueteraResponse> mapFromJson(dynamic json) {
    final map = <String, TiqueteraResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TiqueteraResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TiqueteraResponse-objects as value to a dart map
  static Map<String, List<TiqueteraResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TiqueteraResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TiqueteraResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'clienteId',
    'compradaEn',
    'compradas',
    'estado',
    'nombre',
    'saldo',
    'tipoId',
    'tiqueteraId',
    'ultimoDia',
    'unidad',
    'venceEn',
    'ventaId',
    'vigente',
  };
}


enum TiqueteraResponseEstadoEnum {
  ACTIVE._(r'ACTIVE'),
  DEPLETED._(r'DEPLETED'),
  EXPIRED._(r'EXPIRED'),
  VOIDED._(r'VOIDED'),
  ;

  /// Instantiate a new enum with the provided value.
  const TiqueteraResponseEstadoEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [TiqueteraResponseEstadoEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static TiqueteraResponseEstadoEnum? fromJson(dynamic value) => TiqueteraResponseEstadoEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [TiqueteraResponseEstadoEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<TiqueteraResponseEstadoEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TiqueteraResponseEstadoEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TiqueteraResponseEstadoEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [TiqueteraResponseEstadoEnum] to String,
/// and [decode] dynamic data back to [TiqueteraResponseEstadoEnum].
class TiqueteraResponseEstadoEnumTypeTransformer {
  factory TiqueteraResponseEstadoEnumTypeTransformer() => _instance ??= const TiqueteraResponseEstadoEnumTypeTransformer._();

  const TiqueteraResponseEstadoEnumTypeTransformer._();

  String encode(TiqueteraResponseEstadoEnum data) => data._value;

  /// Returns the instance of [TiqueteraResponseEstadoEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  TiqueteraResponseEstadoEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is TiqueteraResponseEstadoEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'ACTIVE': return TiqueteraResponseEstadoEnum.ACTIVE;
        case r'DEPLETED': return TiqueteraResponseEstadoEnum.DEPLETED;
        case r'EXPIRED': return TiqueteraResponseEstadoEnum.EXPIRED;
        case r'VOIDED': return TiqueteraResponseEstadoEnum.VOIDED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static TiqueteraResponseEstadoEnumTypeTransformer? _instance;
}


