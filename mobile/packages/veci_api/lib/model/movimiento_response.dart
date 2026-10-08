//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class MovimientoResponse {
  /// Returns a new [MovimientoResponse] instance.
  MovimientoResponse({
    this.corrigeA,
    required this.eventoId,
    this.motivo,
    this.nota,
    required this.ocurridoEn,
    this.quien,
    required this.tipo,
    this.tiquetera,
    required this.unidades,
  });

  String? corrigeA;

  String eventoId;

  String? motivo;

  String? nota;

  DateTime ocurridoEn;

  String? quien;

  MovimientoResponseTipoEnum tipo;

  String? tiquetera;

  /// Unidades que sumó (+) o quitó (-)
  num unidades;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MovimientoResponse &&
    other.corrigeA == corrigeA &&
    other.eventoId == eventoId &&
    other.motivo == motivo &&
    other.nota == nota &&
    other.ocurridoEn == ocurridoEn &&
    other.quien == quien &&
    other.tipo == tipo &&
    other.tiquetera == tiquetera &&
    other.unidades == unidades;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (corrigeA == null ? 0 : corrigeA!.hashCode) +
    (eventoId.hashCode) +
    (motivo == null ? 0 : motivo!.hashCode) +
    (nota == null ? 0 : nota!.hashCode) +
    (ocurridoEn.hashCode) +
    (quien == null ? 0 : quien!.hashCode) +
    (tipo.hashCode) +
    (tiquetera == null ? 0 : tiquetera!.hashCode) +
    (unidades.hashCode);

  @override
  String toString() => 'MovimientoResponse[corrigeA=$corrigeA, eventoId=$eventoId, motivo=$motivo, nota=$nota, ocurridoEn=$ocurridoEn, quien=$quien, tipo=$tipo, tiquetera=$tiquetera, unidades=$unidades]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.corrigeA != null) {
      json[r'corrigeA'] = this.corrigeA;
    } else {
      json[r'corrigeA'] = null;
    }
      json[r'eventoId'] = this.eventoId;
    if (this.motivo != null) {
      json[r'motivo'] = this.motivo;
    } else {
      json[r'motivo'] = null;
    }
    if (this.nota != null) {
      json[r'nota'] = this.nota;
    } else {
      json[r'nota'] = null;
    }
      json[r'ocurridoEn'] = this.ocurridoEn.toUtc().toIso8601String();
    if (this.quien != null) {
      json[r'quien'] = this.quien;
    } else {
      json[r'quien'] = null;
    }
      json[r'tipo'] = this.tipo;
    if (this.tiquetera != null) {
      json[r'tiquetera'] = this.tiquetera;
    } else {
      json[r'tiquetera'] = null;
    }
      json[r'unidades'] = this.unidades;
    return json;
  }

  /// Returns a new [MovimientoResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MovimientoResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'eventoId'), 'Required key "MovimientoResponse[eventoId]" is missing from JSON.');
        assert(json[r'eventoId'] != null, 'Required key "MovimientoResponse[eventoId]" has a null value in JSON.');
        assert(json.containsKey(r'ocurridoEn'), 'Required key "MovimientoResponse[ocurridoEn]" is missing from JSON.');
        assert(json[r'ocurridoEn'] != null, 'Required key "MovimientoResponse[ocurridoEn]" has a null value in JSON.');
        assert(json.containsKey(r'tipo'), 'Required key "MovimientoResponse[tipo]" is missing from JSON.');
        assert(json[r'tipo'] != null, 'Required key "MovimientoResponse[tipo]" has a null value in JSON.');
        assert(json.containsKey(r'unidades'), 'Required key "MovimientoResponse[unidades]" is missing from JSON.');
        assert(json[r'unidades'] != null, 'Required key "MovimientoResponse[unidades]" has a null value in JSON.');
        return true;
      }());

      return MovimientoResponse(
        corrigeA: mapValueOfType<String>(json, r'corrigeA'),
        eventoId: mapValueOfType<String>(json, r'eventoId')!,
        motivo: mapValueOfType<String>(json, r'motivo'),
        nota: mapValueOfType<String>(json, r'nota'),
        ocurridoEn: mapDateTime(json, r'ocurridoEn', r'')!,
        quien: mapValueOfType<String>(json, r'quien'),
        tipo: MovimientoResponseTipoEnum.fromJson(json[r'tipo'])!,
        tiquetera: mapValueOfType<String>(json, r'tiquetera'),
        unidades: num.parse('${json[r'unidades']}'),
      );
    }
    return null;
  }

  static List<MovimientoResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MovimientoResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MovimientoResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MovimientoResponse> mapFromJson(dynamic json) {
    final map = <String, MovimientoResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MovimientoResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MovimientoResponse-objects as value to a dart map
  static Map<String, List<MovimientoResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MovimientoResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MovimientoResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'eventoId',
    'ocurridoEn',
    'tipo',
    'unidades',
  };
}


enum MovimientoResponseTipoEnum {
  SALE._(r'SALE'),
  CONSUMPTION._(r'CONSUMPTION'),
  CONSUMPTION_REVERSAL._(r'CONSUMPTION_REVERSAL'),
  SALE_VOID._(r'SALE_VOID'),
  ADJUSTMENT._(r'ADJUSTMENT'),
  EXPIRATION._(r'EXPIRATION'),
  ;

  /// Instantiate a new enum with the provided value.
  const MovimientoResponseTipoEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [MovimientoResponseTipoEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static MovimientoResponseTipoEnum? fromJson(dynamic value) => MovimientoResponseTipoEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [MovimientoResponseTipoEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<MovimientoResponseTipoEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MovimientoResponseTipoEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MovimientoResponseTipoEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MovimientoResponseTipoEnum] to String,
/// and [decode] dynamic data back to [MovimientoResponseTipoEnum].
class MovimientoResponseTipoEnumTypeTransformer {
  factory MovimientoResponseTipoEnumTypeTransformer() => _instance ??= const MovimientoResponseTipoEnumTypeTransformer._();

  const MovimientoResponseTipoEnumTypeTransformer._();

  String encode(MovimientoResponseTipoEnum data) => data._value;

  /// Returns the instance of [MovimientoResponseTipoEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MovimientoResponseTipoEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is MovimientoResponseTipoEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'SALE': return MovimientoResponseTipoEnum.SALE;
        case r'CONSUMPTION': return MovimientoResponseTipoEnum.CONSUMPTION;
        case r'CONSUMPTION_REVERSAL': return MovimientoResponseTipoEnum.CONSUMPTION_REVERSAL;
        case r'SALE_VOID': return MovimientoResponseTipoEnum.SALE_VOID;
        case r'ADJUSTMENT': return MovimientoResponseTipoEnum.ADJUSTMENT;
        case r'EXPIRATION': return MovimientoResponseTipoEnum.EXPIRATION;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static MovimientoResponseTipoEnumTypeTransformer? _instance;
}


