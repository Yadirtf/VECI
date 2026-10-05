//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class MiQrResponse {
  /// Returns a new [MiQrResponse] instance.
  MiQrResponse({
    required this.emitidoEn,
    required this.token,
    required this.version,
  });

  DateTime emitidoEn;

  /// Texto del QR: solo un token firmado, sin datos personales
  String token;

  num version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MiQrResponse &&
    other.emitidoEn == emitidoEn &&
    other.token == token &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (emitidoEn.hashCode) +
    (token.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'MiQrResponse[emitidoEn=$emitidoEn, token=$token, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'emitidoEn'] = this.emitidoEn.toUtc().toIso8601String();
      json[r'token'] = this.token;
      json[r'version'] = this.version;
    return json;
  }

  /// Returns a new [MiQrResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MiQrResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'emitidoEn'), 'Required key "MiQrResponse[emitidoEn]" is missing from JSON.');
        assert(json[r'emitidoEn'] != null, 'Required key "MiQrResponse[emitidoEn]" has a null value in JSON.');
        assert(json.containsKey(r'token'), 'Required key "MiQrResponse[token]" is missing from JSON.');
        assert(json[r'token'] != null, 'Required key "MiQrResponse[token]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "MiQrResponse[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "MiQrResponse[version]" has a null value in JSON.');
        return true;
      }());

      return MiQrResponse(
        emitidoEn: mapDateTime(json, r'emitidoEn', r'')!,
        token: mapValueOfType<String>(json, r'token')!,
        version: num.parse('${json[r'version']}'),
      );
    }
    return null;
  }

  static List<MiQrResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MiQrResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MiQrResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MiQrResponse> mapFromJson(dynamic json) {
    final map = <String, MiQrResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MiQrResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MiQrResponse-objects as value to a dart map
  static Map<String, List<MiQrResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MiQrResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MiQrResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'emitidoEn',
    'token',
    'version',
  };
}

