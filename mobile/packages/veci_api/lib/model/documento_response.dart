//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class DocumentoResponse {
  /// Returns a new [DocumentoResponse] instance.
  DocumentoResponse({
    required this.numero,
    required this.tipo,
  });

  /// El NIT incluye el dígito de verificación
  String numero;

  DocumentoResponseTipoEnum tipo;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DocumentoResponse &&
    other.numero == numero &&
    other.tipo == tipo;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (numero.hashCode) +
    (tipo.hashCode);

  @override
  String toString() => 'DocumentoResponse[numero=$numero, tipo=$tipo]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'numero'] = this.numero;
      json[r'tipo'] = this.tipo;
    return json;
  }

  /// Returns a new [DocumentoResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DocumentoResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'numero'), 'Required key "DocumentoResponse[numero]" is missing from JSON.');
        assert(json[r'numero'] != null, 'Required key "DocumentoResponse[numero]" has a null value in JSON.');
        assert(json.containsKey(r'tipo'), 'Required key "DocumentoResponse[tipo]" is missing from JSON.');
        assert(json[r'tipo'] != null, 'Required key "DocumentoResponse[tipo]" has a null value in JSON.');
        return true;
      }());

      return DocumentoResponse(
        numero: mapValueOfType<String>(json, r'numero')!,
        tipo: DocumentoResponseTipoEnum.fromJson(json[r'tipo'])!,
      );
    }
    return null;
  }

  static List<DocumentoResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DocumentoResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DocumentoResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DocumentoResponse> mapFromJson(dynamic json) {
    final map = <String, DocumentoResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DocumentoResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DocumentoResponse-objects as value to a dart map
  static Map<String, List<DocumentoResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DocumentoResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DocumentoResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'numero',
    'tipo',
  };
}


enum DocumentoResponseTipoEnum {
  NIT._(r'NIT'),
  CC._(r'CC'),
  ;

  /// Instantiate a new enum with the provided value.
  const DocumentoResponseTipoEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [DocumentoResponseTipoEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static DocumentoResponseTipoEnum? fromJson(dynamic value) => DocumentoResponseTipoEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [DocumentoResponseTipoEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<DocumentoResponseTipoEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DocumentoResponseTipoEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DocumentoResponseTipoEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [DocumentoResponseTipoEnum] to String,
/// and [decode] dynamic data back to [DocumentoResponseTipoEnum].
class DocumentoResponseTipoEnumTypeTransformer {
  factory DocumentoResponseTipoEnumTypeTransformer() => _instance ??= const DocumentoResponseTipoEnumTypeTransformer._();

  const DocumentoResponseTipoEnumTypeTransformer._();

  String encode(DocumentoResponseTipoEnum data) => data._value;

  /// Returns the instance of [DocumentoResponseTipoEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  DocumentoResponseTipoEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is DocumentoResponseTipoEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'NIT': return DocumentoResponseTipoEnum.NIT;
        case r'CC': return DocumentoResponseTipoEnum.CC;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static DocumentoResponseTipoEnumTypeTransformer? _instance;
}


