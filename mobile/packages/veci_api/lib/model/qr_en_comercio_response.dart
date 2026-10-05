//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class QrEnComercioResponse {
  /// Returns a new [QrEnComercioResponse] instance.
  QrEnComercioResponse({
    required this.token,
    required this.version,
  });

  /// Token firmado por el negocio
  String token;

  num version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is QrEnComercioResponse &&
    other.token == token &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (token.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'QrEnComercioResponse[token=$token, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'token'] = this.token;
      json[r'version'] = this.version;
    return json;
  }

  /// Returns a new [QrEnComercioResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static QrEnComercioResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'token'), 'Required key "QrEnComercioResponse[token]" is missing from JSON.');
        assert(json[r'token'] != null, 'Required key "QrEnComercioResponse[token]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "QrEnComercioResponse[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "QrEnComercioResponse[version]" has a null value in JSON.');
        return true;
      }());

      return QrEnComercioResponse(
        token: mapValueOfType<String>(json, r'token')!,
        version: num.parse('${json[r'version']}'),
      );
    }
    return null;
  }

  static List<QrEnComercioResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <QrEnComercioResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = QrEnComercioResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, QrEnComercioResponse> mapFromJson(dynamic json) {
    final map = <String, QrEnComercioResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = QrEnComercioResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of QrEnComercioResponse-objects as value to a dart map
  static Map<String, List<QrEnComercioResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<QrEnComercioResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = QrEnComercioResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'token',
    'version',
  };
}

