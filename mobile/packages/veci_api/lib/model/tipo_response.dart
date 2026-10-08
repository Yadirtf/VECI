//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class TipoResponse {
  /// Returns a new [TipoResponse] instance.
  TipoResponse({
    required this.estado,
    required this.nombre,
    required this.precio,
    required this.precioPorUnidad,
    required this.tipoId,
    required this.unidad,
    required this.unidades,
    required this.vendidas,
    required this.vigenciaDias,
    required this.vigentes,
  });

  /// Solo el activo se vende
  TipoResponseEstadoEnum estado;

  String nombre;

  /// Pesos, sin centavos
  num precio;

  /// Lo que sale cada unidad, redondeado
  num precioPorUnidad;

  String tipoId;

  UnidadResponse unidad;

  num unidades;

  /// Tiqueteras vendidas de este tipo
  num vendidas;

  /// Días que sirve desde la compra
  num vigenciaDias;

  /// Vendidas que siguen con unidades por servir
  num vigentes;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TipoResponse &&
    other.estado == estado &&
    other.nombre == nombre &&
    other.precio == precio &&
    other.precioPorUnidad == precioPorUnidad &&
    other.tipoId == tipoId &&
    other.unidad == unidad &&
    other.unidades == unidades &&
    other.vendidas == vendidas &&
    other.vigenciaDias == vigenciaDias &&
    other.vigentes == vigentes;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (estado.hashCode) +
    (nombre.hashCode) +
    (precio.hashCode) +
    (precioPorUnidad.hashCode) +
    (tipoId.hashCode) +
    (unidad.hashCode) +
    (unidades.hashCode) +
    (vendidas.hashCode) +
    (vigenciaDias.hashCode) +
    (vigentes.hashCode);

  @override
  String toString() => 'TipoResponse[estado=$estado, nombre=$nombre, precio=$precio, precioPorUnidad=$precioPorUnidad, tipoId=$tipoId, unidad=$unidad, unidades=$unidades, vendidas=$vendidas, vigenciaDias=$vigenciaDias, vigentes=$vigentes]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'estado'] = this.estado;
      json[r'nombre'] = this.nombre;
      json[r'precio'] = this.precio;
      json[r'precioPorUnidad'] = this.precioPorUnidad;
      json[r'tipoId'] = this.tipoId;
      json[r'unidad'] = this.unidad;
      json[r'unidades'] = this.unidades;
      json[r'vendidas'] = this.vendidas;
      json[r'vigenciaDias'] = this.vigenciaDias;
      json[r'vigentes'] = this.vigentes;
    return json;
  }

  /// Returns a new [TipoResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TipoResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'estado'), 'Required key "TipoResponse[estado]" is missing from JSON.');
        assert(json[r'estado'] != null, 'Required key "TipoResponse[estado]" has a null value in JSON.');
        assert(json.containsKey(r'nombre'), 'Required key "TipoResponse[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "TipoResponse[nombre]" has a null value in JSON.');
        assert(json.containsKey(r'precio'), 'Required key "TipoResponse[precio]" is missing from JSON.');
        assert(json[r'precio'] != null, 'Required key "TipoResponse[precio]" has a null value in JSON.');
        assert(json.containsKey(r'precioPorUnidad'), 'Required key "TipoResponse[precioPorUnidad]" is missing from JSON.');
        assert(json[r'precioPorUnidad'] != null, 'Required key "TipoResponse[precioPorUnidad]" has a null value in JSON.');
        assert(json.containsKey(r'tipoId'), 'Required key "TipoResponse[tipoId]" is missing from JSON.');
        assert(json[r'tipoId'] != null, 'Required key "TipoResponse[tipoId]" has a null value in JSON.');
        assert(json.containsKey(r'unidad'), 'Required key "TipoResponse[unidad]" is missing from JSON.');
        assert(json[r'unidad'] != null, 'Required key "TipoResponse[unidad]" has a null value in JSON.');
        assert(json.containsKey(r'unidades'), 'Required key "TipoResponse[unidades]" is missing from JSON.');
        assert(json[r'unidades'] != null, 'Required key "TipoResponse[unidades]" has a null value in JSON.');
        assert(json.containsKey(r'vendidas'), 'Required key "TipoResponse[vendidas]" is missing from JSON.');
        assert(json[r'vendidas'] != null, 'Required key "TipoResponse[vendidas]" has a null value in JSON.');
        assert(json.containsKey(r'vigenciaDias'), 'Required key "TipoResponse[vigenciaDias]" is missing from JSON.');
        assert(json[r'vigenciaDias'] != null, 'Required key "TipoResponse[vigenciaDias]" has a null value in JSON.');
        assert(json.containsKey(r'vigentes'), 'Required key "TipoResponse[vigentes]" is missing from JSON.');
        assert(json[r'vigentes'] != null, 'Required key "TipoResponse[vigentes]" has a null value in JSON.');
        return true;
      }());

      return TipoResponse(
        estado: TipoResponseEstadoEnum.fromJson(json[r'estado'])!,
        nombre: mapValueOfType<String>(json, r'nombre')!,
        precio: num.parse('${json[r'precio']}'),
        precioPorUnidad: num.parse('${json[r'precioPorUnidad']}'),
        tipoId: mapValueOfType<String>(json, r'tipoId')!,
        unidad: UnidadResponse.fromJson(json[r'unidad'])!,
        unidades: num.parse('${json[r'unidades']}'),
        vendidas: num.parse('${json[r'vendidas']}'),
        vigenciaDias: num.parse('${json[r'vigenciaDias']}'),
        vigentes: num.parse('${json[r'vigentes']}'),
      );
    }
    return null;
  }

  static List<TipoResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TipoResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TipoResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TipoResponse> mapFromJson(dynamic json) {
    final map = <String, TipoResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TipoResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TipoResponse-objects as value to a dart map
  static Map<String, List<TipoResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TipoResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TipoResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'estado',
    'nombre',
    'precio',
    'precioPorUnidad',
    'tipoId',
    'unidad',
    'unidades',
    'vendidas',
    'vigenciaDias',
    'vigentes',
  };
}

/// Solo el activo se vende
enum TipoResponseEstadoEnum {
  ACTIVE._(r'ACTIVE'),
  INACTIVE._(r'INACTIVE'),
  ARCHIVED._(r'ARCHIVED'),
  ;

  /// Instantiate a new enum with the provided value.
  const TipoResponseEstadoEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [TipoResponseEstadoEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static TipoResponseEstadoEnum? fromJson(dynamic value) => TipoResponseEstadoEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [TipoResponseEstadoEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<TipoResponseEstadoEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TipoResponseEstadoEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TipoResponseEstadoEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [TipoResponseEstadoEnum] to String,
/// and [decode] dynamic data back to [TipoResponseEstadoEnum].
class TipoResponseEstadoEnumTypeTransformer {
  factory TipoResponseEstadoEnumTypeTransformer() => _instance ??= const TipoResponseEstadoEnumTypeTransformer._();

  const TipoResponseEstadoEnumTypeTransformer._();

  String encode(TipoResponseEstadoEnum data) => data._value;

  /// Returns the instance of [TipoResponseEstadoEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  TipoResponseEstadoEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is TipoResponseEstadoEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'ACTIVE': return TipoResponseEstadoEnum.ACTIVE;
        case r'INACTIVE': return TipoResponseEstadoEnum.INACTIVE;
        case r'ARCHIVED': return TipoResponseEstadoEnum.ARCHIVED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static TipoResponseEstadoEnumTypeTransformer? _instance;
}


