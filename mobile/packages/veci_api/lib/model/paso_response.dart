//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class PasoResponse {
  /// Returns a new [PasoResponse] instance.
  PasoResponse({
    required this.codigo,
    required this.listo,
    required this.obligatorio,
  });

  PasoResponseCodigoEnum codigo;

  bool listo;

  /// Si falta, impide abrir el negocio
  bool obligatorio;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PasoResponse &&
    other.codigo == codigo &&
    other.listo == listo &&
    other.obligatorio == obligatorio;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (codigo.hashCode) +
    (listo.hashCode) +
    (obligatorio.hashCode);

  @override
  String toString() => 'PasoResponse[codigo=$codigo, listo=$listo, obligatorio=$obligatorio]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'codigo'] = this.codigo;
      json[r'listo'] = this.listo;
      json[r'obligatorio'] = this.obligatorio;
    return json;
  }

  /// Returns a new [PasoResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PasoResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'codigo'), 'Required key "PasoResponse[codigo]" is missing from JSON.');
        assert(json[r'codigo'] != null, 'Required key "PasoResponse[codigo]" has a null value in JSON.');
        assert(json.containsKey(r'listo'), 'Required key "PasoResponse[listo]" is missing from JSON.');
        assert(json[r'listo'] != null, 'Required key "PasoResponse[listo]" has a null value in JSON.');
        assert(json.containsKey(r'obligatorio'), 'Required key "PasoResponse[obligatorio]" is missing from JSON.');
        assert(json[r'obligatorio'] != null, 'Required key "PasoResponse[obligatorio]" has a null value in JSON.');
        return true;
      }());

      return PasoResponse(
        codigo: PasoResponseCodigoEnum.fromJson(json[r'codigo'])!,
        listo: mapValueOfType<bool>(json, r'listo')!,
        obligatorio: mapValueOfType<bool>(json, r'obligatorio')!,
      );
    }
    return null;
  }

  static List<PasoResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PasoResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PasoResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PasoResponse> mapFromJson(dynamic json) {
    final map = <String, PasoResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PasoResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PasoResponse-objects as value to a dart map
  static Map<String, List<PasoResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PasoResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PasoResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'codigo',
    'listo',
    'obligatorio',
  };
}


enum PasoResponseCodigoEnum {
  DATOS._(r'DATOS'),
  HORARIOS._(r'HORARIOS'),
  EQUIPO._(r'EQUIPO'),
  TIQUETERAS._(r'TIQUETERAS'),
  ;

  /// Instantiate a new enum with the provided value.
  const PasoResponseCodigoEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PasoResponseCodigoEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PasoResponseCodigoEnum? fromJson(dynamic value) => PasoResponseCodigoEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PasoResponseCodigoEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PasoResponseCodigoEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PasoResponseCodigoEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PasoResponseCodigoEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PasoResponseCodigoEnum] to String,
/// and [decode] dynamic data back to [PasoResponseCodigoEnum].
class PasoResponseCodigoEnumTypeTransformer {
  factory PasoResponseCodigoEnumTypeTransformer() => _instance ??= const PasoResponseCodigoEnumTypeTransformer._();

  const PasoResponseCodigoEnumTypeTransformer._();

  String encode(PasoResponseCodigoEnum data) => data._value;

  /// Returns the instance of [PasoResponseCodigoEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PasoResponseCodigoEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PasoResponseCodigoEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'DATOS': return PasoResponseCodigoEnum.DATOS;
        case r'HORARIOS': return PasoResponseCodigoEnum.HORARIOS;
        case r'EQUIPO': return PasoResponseCodigoEnum.EQUIPO;
        case r'TIQUETERAS': return PasoResponseCodigoEnum.TIQUETERAS;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PasoResponseCodigoEnumTypeTransformer? _instance;
}


