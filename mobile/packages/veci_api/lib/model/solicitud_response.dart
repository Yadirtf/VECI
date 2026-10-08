//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class SolicitudResponse {
  /// Returns a new [SolicitudResponse] instance.
  SolicitudResponse({
    required this.celular,
    this.comercioId,
    this.correo,
    this.direccion,
    required this.estado,
    this.logoUrl,
    required this.municipio,
    required this.municipioId,
    required this.nombre,
    this.nota,
    required this.numeroDocumento,
    required this.radicadaEn,
    this.revisadaEn,
    required this.solicitante,
    required this.solicitudId,
    required this.tipoDocumento,
    required this.tipoNegocio,
  });

  String celular;

  /// El negocio que nació al aprobarla
  String? comercioId;

  String? correo;

  String? direccion;

  SolicitudResponseEstadoEnum estado;

  String? logoUrl;

  String municipio;

  num municipioId;

  String nombre;

  /// Por qué se rechazó, en palabras para la persona
  String? nota;

  String numeroDocumento;

  DateTime radicadaEn;

  DateTime? revisadaEn;

  SolicitanteResponse solicitante;

  String solicitudId;

  SolicitudResponseTipoDocumentoEnum tipoDocumento;

  String tipoNegocio;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SolicitudResponse &&
    other.celular == celular &&
    other.comercioId == comercioId &&
    other.correo == correo &&
    other.direccion == direccion &&
    other.estado == estado &&
    other.logoUrl == logoUrl &&
    other.municipio == municipio &&
    other.municipioId == municipioId &&
    other.nombre == nombre &&
    other.nota == nota &&
    other.numeroDocumento == numeroDocumento &&
    other.radicadaEn == radicadaEn &&
    other.revisadaEn == revisadaEn &&
    other.solicitante == solicitante &&
    other.solicitudId == solicitudId &&
    other.tipoDocumento == tipoDocumento &&
    other.tipoNegocio == tipoNegocio;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (celular.hashCode) +
    (comercioId == null ? 0 : comercioId!.hashCode) +
    (correo == null ? 0 : correo!.hashCode) +
    (direccion == null ? 0 : direccion!.hashCode) +
    (estado.hashCode) +
    (logoUrl == null ? 0 : logoUrl!.hashCode) +
    (municipio.hashCode) +
    (municipioId.hashCode) +
    (nombre.hashCode) +
    (nota == null ? 0 : nota!.hashCode) +
    (numeroDocumento.hashCode) +
    (radicadaEn.hashCode) +
    (revisadaEn == null ? 0 : revisadaEn!.hashCode) +
    (solicitante.hashCode) +
    (solicitudId.hashCode) +
    (tipoDocumento.hashCode) +
    (tipoNegocio.hashCode);

  @override
  String toString() => 'SolicitudResponse[celular=$celular, comercioId=$comercioId, correo=$correo, direccion=$direccion, estado=$estado, logoUrl=$logoUrl, municipio=$municipio, municipioId=$municipioId, nombre=$nombre, nota=$nota, numeroDocumento=$numeroDocumento, radicadaEn=$radicadaEn, revisadaEn=$revisadaEn, solicitante=$solicitante, solicitudId=$solicitudId, tipoDocumento=$tipoDocumento, tipoNegocio=$tipoNegocio]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'celular'] = this.celular;
    if (this.comercioId != null) {
      json[r'comercioId'] = this.comercioId;
    } else {
      json[r'comercioId'] = null;
    }
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
      json[r'estado'] = this.estado;
    if (this.logoUrl != null) {
      json[r'logoUrl'] = this.logoUrl;
    } else {
      json[r'logoUrl'] = null;
    }
      json[r'municipio'] = this.municipio;
      json[r'municipioId'] = this.municipioId;
      json[r'nombre'] = this.nombre;
    if (this.nota != null) {
      json[r'nota'] = this.nota;
    } else {
      json[r'nota'] = null;
    }
      json[r'numeroDocumento'] = this.numeroDocumento;
      json[r'radicadaEn'] = this.radicadaEn.toUtc().toIso8601String();
    if (this.revisadaEn != null) {
      json[r'revisadaEn'] = this.revisadaEn!.toUtc().toIso8601String();
    } else {
      json[r'revisadaEn'] = null;
    }
      json[r'solicitante'] = this.solicitante;
      json[r'solicitudId'] = this.solicitudId;
      json[r'tipoDocumento'] = this.tipoDocumento;
      json[r'tipoNegocio'] = this.tipoNegocio;
    return json;
  }

  /// Returns a new [SolicitudResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SolicitudResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'celular'), 'Required key "SolicitudResponse[celular]" is missing from JSON.');
        assert(json[r'celular'] != null, 'Required key "SolicitudResponse[celular]" has a null value in JSON.');
        assert(json.containsKey(r'estado'), 'Required key "SolicitudResponse[estado]" is missing from JSON.');
        assert(json[r'estado'] != null, 'Required key "SolicitudResponse[estado]" has a null value in JSON.');
        assert(json.containsKey(r'municipio'), 'Required key "SolicitudResponse[municipio]" is missing from JSON.');
        assert(json[r'municipio'] != null, 'Required key "SolicitudResponse[municipio]" has a null value in JSON.');
        assert(json.containsKey(r'municipioId'), 'Required key "SolicitudResponse[municipioId]" is missing from JSON.');
        assert(json[r'municipioId'] != null, 'Required key "SolicitudResponse[municipioId]" has a null value in JSON.');
        assert(json.containsKey(r'nombre'), 'Required key "SolicitudResponse[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "SolicitudResponse[nombre]" has a null value in JSON.');
        assert(json.containsKey(r'numeroDocumento'), 'Required key "SolicitudResponse[numeroDocumento]" is missing from JSON.');
        assert(json[r'numeroDocumento'] != null, 'Required key "SolicitudResponse[numeroDocumento]" has a null value in JSON.');
        assert(json.containsKey(r'radicadaEn'), 'Required key "SolicitudResponse[radicadaEn]" is missing from JSON.');
        assert(json[r'radicadaEn'] != null, 'Required key "SolicitudResponse[radicadaEn]" has a null value in JSON.');
        assert(json.containsKey(r'solicitante'), 'Required key "SolicitudResponse[solicitante]" is missing from JSON.');
        assert(json[r'solicitante'] != null, 'Required key "SolicitudResponse[solicitante]" has a null value in JSON.');
        assert(json.containsKey(r'solicitudId'), 'Required key "SolicitudResponse[solicitudId]" is missing from JSON.');
        assert(json[r'solicitudId'] != null, 'Required key "SolicitudResponse[solicitudId]" has a null value in JSON.');
        assert(json.containsKey(r'tipoDocumento'), 'Required key "SolicitudResponse[tipoDocumento]" is missing from JSON.');
        assert(json[r'tipoDocumento'] != null, 'Required key "SolicitudResponse[tipoDocumento]" has a null value in JSON.');
        assert(json.containsKey(r'tipoNegocio'), 'Required key "SolicitudResponse[tipoNegocio]" is missing from JSON.');
        assert(json[r'tipoNegocio'] != null, 'Required key "SolicitudResponse[tipoNegocio]" has a null value in JSON.');
        return true;
      }());

      return SolicitudResponse(
        celular: mapValueOfType<String>(json, r'celular')!,
        comercioId: mapValueOfType<String>(json, r'comercioId'),
        correo: mapValueOfType<String>(json, r'correo'),
        direccion: mapValueOfType<String>(json, r'direccion'),
        estado: SolicitudResponseEstadoEnum.fromJson(json[r'estado'])!,
        logoUrl: mapValueOfType<String>(json, r'logoUrl'),
        municipio: mapValueOfType<String>(json, r'municipio')!,
        municipioId: num.parse('${json[r'municipioId']}'),
        nombre: mapValueOfType<String>(json, r'nombre')!,
        nota: mapValueOfType<String>(json, r'nota'),
        numeroDocumento: mapValueOfType<String>(json, r'numeroDocumento')!,
        radicadaEn: mapDateTime(json, r'radicadaEn', r'')!,
        revisadaEn: mapDateTime(json, r'revisadaEn', r''),
        solicitante: SolicitanteResponse.fromJson(json[r'solicitante'])!,
        solicitudId: mapValueOfType<String>(json, r'solicitudId')!,
        tipoDocumento: SolicitudResponseTipoDocumentoEnum.fromJson(json[r'tipoDocumento'])!,
        tipoNegocio: mapValueOfType<String>(json, r'tipoNegocio')!,
      );
    }
    return null;
  }

  static List<SolicitudResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SolicitudResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SolicitudResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SolicitudResponse> mapFromJson(dynamic json) {
    final map = <String, SolicitudResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SolicitudResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SolicitudResponse-objects as value to a dart map
  static Map<String, List<SolicitudResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SolicitudResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SolicitudResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'celular',
    'estado',
    'municipio',
    'municipioId',
    'nombre',
    'numeroDocumento',
    'radicadaEn',
    'solicitante',
    'solicitudId',
    'tipoDocumento',
    'tipoNegocio',
  };
}


enum SolicitudResponseEstadoEnum {
  PENDING._(r'PENDING'),
  APPROVED._(r'APPROVED'),
  REJECTED._(r'REJECTED'),
  ;

  /// Instantiate a new enum with the provided value.
  const SolicitudResponseEstadoEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [SolicitudResponseEstadoEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static SolicitudResponseEstadoEnum? fromJson(dynamic value) => SolicitudResponseEstadoEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [SolicitudResponseEstadoEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<SolicitudResponseEstadoEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SolicitudResponseEstadoEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SolicitudResponseEstadoEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SolicitudResponseEstadoEnum] to String,
/// and [decode] dynamic data back to [SolicitudResponseEstadoEnum].
class SolicitudResponseEstadoEnumTypeTransformer {
  factory SolicitudResponseEstadoEnumTypeTransformer() => _instance ??= const SolicitudResponseEstadoEnumTypeTransformer._();

  const SolicitudResponseEstadoEnumTypeTransformer._();

  String encode(SolicitudResponseEstadoEnum data) => data._value;

  /// Returns the instance of [SolicitudResponseEstadoEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SolicitudResponseEstadoEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is SolicitudResponseEstadoEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'PENDING': return SolicitudResponseEstadoEnum.PENDING;
        case r'APPROVED': return SolicitudResponseEstadoEnum.APPROVED;
        case r'REJECTED': return SolicitudResponseEstadoEnum.REJECTED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static SolicitudResponseEstadoEnumTypeTransformer? _instance;
}



enum SolicitudResponseTipoDocumentoEnum {
  NIT._(r'NIT'),
  CC._(r'CC'),
  ;

  /// Instantiate a new enum with the provided value.
  const SolicitudResponseTipoDocumentoEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [SolicitudResponseTipoDocumentoEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static SolicitudResponseTipoDocumentoEnum? fromJson(dynamic value) => SolicitudResponseTipoDocumentoEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [SolicitudResponseTipoDocumentoEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<SolicitudResponseTipoDocumentoEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SolicitudResponseTipoDocumentoEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SolicitudResponseTipoDocumentoEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SolicitudResponseTipoDocumentoEnum] to String,
/// and [decode] dynamic data back to [SolicitudResponseTipoDocumentoEnum].
class SolicitudResponseTipoDocumentoEnumTypeTransformer {
  factory SolicitudResponseTipoDocumentoEnumTypeTransformer() => _instance ??= const SolicitudResponseTipoDocumentoEnumTypeTransformer._();

  const SolicitudResponseTipoDocumentoEnumTypeTransformer._();

  String encode(SolicitudResponseTipoDocumentoEnum data) => data._value;

  /// Returns the instance of [SolicitudResponseTipoDocumentoEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SolicitudResponseTipoDocumentoEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is SolicitudResponseTipoDocumentoEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'NIT': return SolicitudResponseTipoDocumentoEnum.NIT;
        case r'CC': return SolicitudResponseTipoDocumentoEnum.CC;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static SolicitudResponseTipoDocumentoEnumTypeTransformer? _instance;
}


