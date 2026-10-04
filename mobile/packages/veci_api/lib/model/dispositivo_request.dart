//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class DispositivoRequest {
  /// Returns a new [DispositivoRequest] instance.
  DispositivoRequest({
    required this.id,
    this.modelo,
    required this.plataforma,
    this.versionApp,
    this.versionSo,
  });

  /// Id que el dispositivo generó para sí
  String id;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? modelo;

  DispositivoRequestPlataformaEnum plataforma;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? versionApp;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? versionSo;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DispositivoRequest &&
    other.id == id &&
    other.modelo == modelo &&
    other.plataforma == plataforma &&
    other.versionApp == versionApp &&
    other.versionSo == versionSo;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (modelo == null ? 0 : modelo!.hashCode) +
    (plataforma.hashCode) +
    (versionApp == null ? 0 : versionApp!.hashCode) +
    (versionSo == null ? 0 : versionSo!.hashCode);

  @override
  String toString() => 'DispositivoRequest[id=$id, modelo=$modelo, plataforma=$plataforma, versionApp=$versionApp, versionSo=$versionSo]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
    if (this.modelo != null) {
      json[r'modelo'] = this.modelo;
    } else {
      json[r'modelo'] = null;
    }
      json[r'plataforma'] = this.plataforma;
    if (this.versionApp != null) {
      json[r'versionApp'] = this.versionApp;
    } else {
      json[r'versionApp'] = null;
    }
    if (this.versionSo != null) {
      json[r'versionSo'] = this.versionSo;
    } else {
      json[r'versionSo'] = null;
    }
    return json;
  }

  /// Returns a new [DispositivoRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DispositivoRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "DispositivoRequest[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "DispositivoRequest[id]" has a null value in JSON.');
        assert(json.containsKey(r'plataforma'), 'Required key "DispositivoRequest[plataforma]" is missing from JSON.');
        assert(json[r'plataforma'] != null, 'Required key "DispositivoRequest[plataforma]" has a null value in JSON.');
        return true;
      }());

      return DispositivoRequest(
        id: mapValueOfType<String>(json, r'id')!,
        modelo: mapValueOfType<String>(json, r'modelo'),
        plataforma: DispositivoRequestPlataformaEnum.fromJson(json[r'plataforma'])!,
        versionApp: mapValueOfType<String>(json, r'versionApp'),
        versionSo: mapValueOfType<String>(json, r'versionSo'),
      );
    }
    return null;
  }

  static List<DispositivoRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DispositivoRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DispositivoRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DispositivoRequest> mapFromJson(dynamic json) {
    final map = <String, DispositivoRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DispositivoRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DispositivoRequest-objects as value to a dart map
  static Map<String, List<DispositivoRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DispositivoRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DispositivoRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'plataforma',
  };
}


enum DispositivoRequestPlataformaEnum {
  ANDROID._(r'ANDROID'),
  IOS._(r'IOS'),
  WEB._(r'WEB'),
  ;

  /// Instantiate a new enum with the provided value.
  const DispositivoRequestPlataformaEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [DispositivoRequestPlataformaEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static DispositivoRequestPlataformaEnum? fromJson(dynamic value) => DispositivoRequestPlataformaEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [DispositivoRequestPlataformaEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<DispositivoRequestPlataformaEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DispositivoRequestPlataformaEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DispositivoRequestPlataformaEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [DispositivoRequestPlataformaEnum] to String,
/// and [decode] dynamic data back to [DispositivoRequestPlataformaEnum].
class DispositivoRequestPlataformaEnumTypeTransformer {
  factory DispositivoRequestPlataformaEnumTypeTransformer() => _instance ??= const DispositivoRequestPlataformaEnumTypeTransformer._();

  const DispositivoRequestPlataformaEnumTypeTransformer._();

  String encode(DispositivoRequestPlataformaEnum data) => data._value;

  /// Returns the instance of [DispositivoRequestPlataformaEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  DispositivoRequestPlataformaEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is DispositivoRequestPlataformaEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'ANDROID': return DispositivoRequestPlataformaEnum.ANDROID;
        case r'IOS': return DispositivoRequestPlataformaEnum.IOS;
        case r'WEB': return DispositivoRequestPlataformaEnum.WEB;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static DispositivoRequestPlataformaEnumTypeTransformer? _instance;
}


