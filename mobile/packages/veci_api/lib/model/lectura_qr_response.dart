//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class LecturaQrResponse {
  /// Returns a new [LecturaQrResponse] instance.
  LecturaQrResponse({
    this.cliente,
    this.persona,
    required this.resultado,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ClienteResponse? cliente;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  PersonaPorAfiliarResponse? persona;

  LecturaQrResponseResultadoEnum resultado;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LecturaQrResponse &&
    other.cliente == cliente &&
    other.persona == persona &&
    other.resultado == resultado;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (cliente == null ? 0 : cliente!.hashCode) +
    (persona == null ? 0 : persona!.hashCode) +
    (resultado.hashCode);

  @override
  String toString() => 'LecturaQrResponse[cliente=$cliente, persona=$persona, resultado=$resultado]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.cliente != null) {
      json[r'cliente'] = this.cliente;
    } else {
      json[r'cliente'] = null;
    }
    if (this.persona != null) {
      json[r'persona'] = this.persona;
    } else {
      json[r'persona'] = null;
    }
      json[r'resultado'] = this.resultado;
    return json;
  }

  /// Returns a new [LecturaQrResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static LecturaQrResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'resultado'), 'Required key "LecturaQrResponse[resultado]" is missing from JSON.');
        assert(json[r'resultado'] != null, 'Required key "LecturaQrResponse[resultado]" has a null value in JSON.');
        return true;
      }());

      return LecturaQrResponse(
        cliente: ClienteResponse.fromJson(json[r'cliente']),
        persona: PersonaPorAfiliarResponse.fromJson(json[r'persona']),
        resultado: LecturaQrResponseResultadoEnum.fromJson(json[r'resultado'])!,
      );
    }
    return null;
  }

  static List<LecturaQrResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <LecturaQrResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LecturaQrResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, LecturaQrResponse> mapFromJson(dynamic json) {
    final map = <String, LecturaQrResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = LecturaQrResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of LecturaQrResponse-objects as value to a dart map
  static Map<String, List<LecturaQrResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<LecturaQrResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = LecturaQrResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'resultado',
  };
}


enum LecturaQrResponseResultadoEnum {
  PERSONA_POR_AFILIAR._(r'PERSONA_POR_AFILIAR'),
  CLIENTE._(r'CLIENTE'),
  QR_CAMBIADO._(r'QR_CAMBIADO'),
  OTRO_NEGOCIO._(r'OTRO_NEGOCIO'),
  NO_ES_DE_VECI._(r'NO_ES_DE_VECI'),
  ;

  /// Instantiate a new enum with the provided value.
  const LecturaQrResponseResultadoEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [LecturaQrResponseResultadoEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static LecturaQrResponseResultadoEnum? fromJson(dynamic value) => LecturaQrResponseResultadoEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [LecturaQrResponseResultadoEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<LecturaQrResponseResultadoEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <LecturaQrResponseResultadoEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LecturaQrResponseResultadoEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [LecturaQrResponseResultadoEnum] to String,
/// and [decode] dynamic data back to [LecturaQrResponseResultadoEnum].
class LecturaQrResponseResultadoEnumTypeTransformer {
  factory LecturaQrResponseResultadoEnumTypeTransformer() => _instance ??= const LecturaQrResponseResultadoEnumTypeTransformer._();

  const LecturaQrResponseResultadoEnumTypeTransformer._();

  String encode(LecturaQrResponseResultadoEnum data) => data._value;

  /// Returns the instance of [LecturaQrResponseResultadoEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  LecturaQrResponseResultadoEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is LecturaQrResponseResultadoEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'PERSONA_POR_AFILIAR': return LecturaQrResponseResultadoEnum.PERSONA_POR_AFILIAR;
        case r'CLIENTE': return LecturaQrResponseResultadoEnum.CLIENTE;
        case r'QR_CAMBIADO': return LecturaQrResponseResultadoEnum.QR_CAMBIADO;
        case r'OTRO_NEGOCIO': return LecturaQrResponseResultadoEnum.OTRO_NEGOCIO;
        case r'NO_ES_DE_VECI': return LecturaQrResponseResultadoEnum.NO_ES_DE_VECI;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static LecturaQrResponseResultadoEnumTypeTransformer? _instance;
}


