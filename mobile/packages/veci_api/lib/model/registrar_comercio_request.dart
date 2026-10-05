//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class RegistrarComercioRequest {
  /// Returns a new [RegistrarComercioRequest] instance.
  RegistrarComercioRequest({
    required this.celular,
    this.correo,
    this.direccion,
    this.logoUrl,
    this.municipioId,
    required this.nombre,
    required this.numeroDocumento,
    required this.tipoDocumento,
    required this.tipoNegocio,
  });

  String celular;

  String? correo;

  String? direccion;

  String? logoUrl;

  /// Municipio (DIVIPOLA) de la sede principal
  num? municipioId;

  String nombre;

  /// NIT con o sin dígito de verificación
  String numeroDocumento;

  RegistrarComercioRequestTipoDocumentoEnum tipoDocumento;

  /// Código del tipo de negocio (catálogo)
  String tipoNegocio;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RegistrarComercioRequest &&
    other.celular == celular &&
    other.correo == correo &&
    other.direccion == direccion &&
    other.logoUrl == logoUrl &&
    other.municipioId == municipioId &&
    other.nombre == nombre &&
    other.numeroDocumento == numeroDocumento &&
    other.tipoDocumento == tipoDocumento &&
    other.tipoNegocio == tipoNegocio;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (celular.hashCode) +
    (correo == null ? 0 : correo!.hashCode) +
    (direccion == null ? 0 : direccion!.hashCode) +
    (logoUrl == null ? 0 : logoUrl!.hashCode) +
    (municipioId == null ? 0 : municipioId!.hashCode) +
    (nombre.hashCode) +
    (numeroDocumento.hashCode) +
    (tipoDocumento.hashCode) +
    (tipoNegocio.hashCode);

  @override
  String toString() => 'RegistrarComercioRequest[celular=$celular, correo=$correo, direccion=$direccion, logoUrl=$logoUrl, municipioId=$municipioId, nombre=$nombre, numeroDocumento=$numeroDocumento, tipoDocumento=$tipoDocumento, tipoNegocio=$tipoNegocio]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'celular'] = this.celular;
    if (this.correo != null) {
      json[r'correo'] = this.correo;
    } else {
      json[r'correo'] = null;
    }
    if (this.direccion != null) {
      json[r'direccion'] = this.direccion;
    } else {
      json[r'direccion'] = null;
    }
    if (this.logoUrl != null) {
      json[r'logoUrl'] = this.logoUrl;
    } else {
      json[r'logoUrl'] = null;
    }
    if (this.municipioId != null) {
      json[r'municipioId'] = this.municipioId;
    } else {
      json[r'municipioId'] = null;
    }
      json[r'nombre'] = this.nombre;
      json[r'numeroDocumento'] = this.numeroDocumento;
      json[r'tipoDocumento'] = this.tipoDocumento;
      json[r'tipoNegocio'] = this.tipoNegocio;
    return json;
  }

  /// Returns a new [RegistrarComercioRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RegistrarComercioRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'celular'), 'Required key "RegistrarComercioRequest[celular]" is missing from JSON.');
        assert(json[r'celular'] != null, 'Required key "RegistrarComercioRequest[celular]" has a null value in JSON.');
        assert(json.containsKey(r'nombre'), 'Required key "RegistrarComercioRequest[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "RegistrarComercioRequest[nombre]" has a null value in JSON.');
        assert(json.containsKey(r'numeroDocumento'), 'Required key "RegistrarComercioRequest[numeroDocumento]" is missing from JSON.');
        assert(json[r'numeroDocumento'] != null, 'Required key "RegistrarComercioRequest[numeroDocumento]" has a null value in JSON.');
        assert(json.containsKey(r'tipoDocumento'), 'Required key "RegistrarComercioRequest[tipoDocumento]" is missing from JSON.');
        assert(json[r'tipoDocumento'] != null, 'Required key "RegistrarComercioRequest[tipoDocumento]" has a null value in JSON.');
        assert(json.containsKey(r'tipoNegocio'), 'Required key "RegistrarComercioRequest[tipoNegocio]" is missing from JSON.');
        assert(json[r'tipoNegocio'] != null, 'Required key "RegistrarComercioRequest[tipoNegocio]" has a null value in JSON.');
        return true;
      }());

      return RegistrarComercioRequest(
        celular: mapValueOfType<String>(json, r'celular')!,
        correo: mapValueOfType<String>(json, r'correo'),
        direccion: mapValueOfType<String>(json, r'direccion'),
        logoUrl: mapValueOfType<String>(json, r'logoUrl'),
        municipioId: json[r'municipioId'] == null
            ? null
            : num.parse('${json[r'municipioId']}'),
        nombre: mapValueOfType<String>(json, r'nombre')!,
        numeroDocumento: mapValueOfType<String>(json, r'numeroDocumento')!,
        tipoDocumento: RegistrarComercioRequestTipoDocumentoEnum.fromJson(json[r'tipoDocumento'])!,
        tipoNegocio: mapValueOfType<String>(json, r'tipoNegocio')!,
      );
    }
    return null;
  }

  static List<RegistrarComercioRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RegistrarComercioRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RegistrarComercioRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RegistrarComercioRequest> mapFromJson(dynamic json) {
    final map = <String, RegistrarComercioRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RegistrarComercioRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RegistrarComercioRequest-objects as value to a dart map
  static Map<String, List<RegistrarComercioRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RegistrarComercioRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RegistrarComercioRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'celular',
    'nombre',
    'numeroDocumento',
    'tipoDocumento',
    'tipoNegocio',
  };
}


enum RegistrarComercioRequestTipoDocumentoEnum {
  NIT._(r'NIT'),
  CC._(r'CC'),
  ;

  /// Instantiate a new enum with the provided value.
  const RegistrarComercioRequestTipoDocumentoEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [RegistrarComercioRequestTipoDocumentoEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static RegistrarComercioRequestTipoDocumentoEnum? fromJson(dynamic value) => RegistrarComercioRequestTipoDocumentoEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [RegistrarComercioRequestTipoDocumentoEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<RegistrarComercioRequestTipoDocumentoEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RegistrarComercioRequestTipoDocumentoEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RegistrarComercioRequestTipoDocumentoEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [RegistrarComercioRequestTipoDocumentoEnum] to String,
/// and [decode] dynamic data back to [RegistrarComercioRequestTipoDocumentoEnum].
class RegistrarComercioRequestTipoDocumentoEnumTypeTransformer {
  factory RegistrarComercioRequestTipoDocumentoEnumTypeTransformer() => _instance ??= const RegistrarComercioRequestTipoDocumentoEnumTypeTransformer._();

  const RegistrarComercioRequestTipoDocumentoEnumTypeTransformer._();

  String encode(RegistrarComercioRequestTipoDocumentoEnum data) => data._value;

  /// Returns the instance of [RegistrarComercioRequestTipoDocumentoEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  RegistrarComercioRequestTipoDocumentoEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is RegistrarComercioRequestTipoDocumentoEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'NIT': return RegistrarComercioRequestTipoDocumentoEnum.NIT;
        case r'CC': return RegistrarComercioRequestTipoDocumentoEnum.CC;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static RegistrarComercioRequestTipoDocumentoEnumTypeTransformer? _instance;
}


